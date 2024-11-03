#!/bin/bash

#SBATCH --output="find_gpu.log"  
#SBATCH --job-name="find_gpu"  
#SBATCH --cpus-per-task=16 # number of cores  
#SBATCH --mem-per-cpu=8G # memory per CPU core
#SBATCH --partition=compute # partition for job

# Priority order of GPUs
declare -a gpu_priority=("a100" "rtxa6000" "rtx6000" "rtx2080ti" "titanv" "tesla")

# Number of GPUs requested (default to 1 if not provided)
NUM_GPUS=${1:-1}
HOURS=${2:-24}

# Target partition
TARGET_PARTITION="compute"

# Function to count available GPUs of a specific type on ready nodes
count_available_gpus() {
    local gpu_type=$1
    local total_gpus=0
    local available_gpus=0
    
    sinfo -N -o "%n %P %t %G" | grep "$gpu_type" | while read -r line; do
        node=$(echo "$line" | awk '{print $1}')
        partition=$(echo "$line" | awk '{print $2}')
        state=$(echo "$line" | awk '{print $3}')
        total_gpus=$(echo "$line" | grep -o "$gpu_type:[0-9]*" | cut -d ':' -f2)

        # Ensure total_gpus is a valid number
        total_gpus=${total_gpus:-0}  # Default to 0 if not found

        # Check if node is in the correct partition and is ready (state "idle" or "mix")
        if [[ "$partition" == *"$TARGET_PARTITION"* && ("$state" == "idle" || "$state" == "mix") ]]; then
            in_use_gpus=$(squeue --nodes="$node" --format="%b" | grep -o "$gpu_type:[0-9]*" | cut -d ':' -f2 | paste -sd+ - | bc)
            in_use_gpus=${in_use_gpus:-0}  # Default to 0 if not found
            
            available_gpus=$((total_gpus - in_use_gpus))

            # Return if we found enough available GPUs
            if [ "$available_gpus" -ge "$NUM_GPUS" ]; then
                echo "$available_gpus"  # Return only the count
                return
            fi
        fi
    done
    
    # Return 0 if no suitable nodes found
    echo 0
}

# Search for available GPUs based on priority
selected_gpu=""
for gpu in "${gpu_priority[@]}"; do
    echo "-------------------"
    available_gpus=$(count_available_gpus "$gpu" | tr -d '\r')  # Trim any carriage returns
    available_gpus=$(echo $available_gpus | cut -d ' ' -f1)
    echo "Available $gpu GPUs: $available_gpus"
    echo "Requested $NUM_GPUS GPUs"
    if [[ "$available_gpus" =~ ^[0-9]+$ && "$available_gpus" -ge "$NUM_GPUS" ]]; then
        selected_gpu=$gpu
        echo "Selected GPU: $selected_gpu"
        break
    else
        echo "Rejection: Not enough $gpu GPUs available."
    fi
done

# Check if we found a suitable GPU type
if [ -z "$selected_gpu" ]; then
    echo "Error: Could not find $NUM_GPUS available GPU(s) in the '$TARGET_PARTITION' partition and in ready state."
    exit 1
fi

# Dynamically set the selected GPU type and count in SBATCH
echo "#SBATCH --gres=gpu:$selected_gpu:$NUM_GPUS" >> /tmp/sbatch_config.txt
echo "-------------------"

# The rest of your job script here
echo "Requested $NUM_GPUS x $selected_gpu GPUs"

# Export the configuration to a new SBATCH file
cat <<EOL > job_submission.sbatch
#!/bin/bash
#SBATCH --output="tunnel.log"  
#SBATCH --job-name="tunnel"  
#SBATCH --time=$HOURS:00:00 # walltime  
#SBATCH --cpus-per-task=16 # number of cores  
#SBATCH --mem-per-cpu=8G # memory per CPU core
#SBATCH --partition=compute # partition for job
#SBATCH --gres=gpu:$selected_gpu:$NUM_GPUS

# find open port  
PORT=\$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')  
scontrol update JobId="\$SLURM_JOB_ID" Comment="\$PORT"

# start sshd server on the available port  
echo "Starting sshd on port \$PORT"  
/usr/sbin/sshd -D -p \${PORT} -f /dev/null -h \${HOME}/.ssh/id_rsa

EOL

echo "New SBATCH file 'job_submission.sbatch' created with $NUM_GPUS x $selected_gpu GPUs."
sbatch job_submission.sbatch