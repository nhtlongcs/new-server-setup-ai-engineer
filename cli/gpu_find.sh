#!/bin/bash

#SBATCH --output="find_gpu.log"  
#SBATCH --job-name="find_gpu"  
#SBATCH --cpus-per-task=16 # number of cores  
#SBATCH --mem-per-cpu=8G # memory per CPU core
#SBATCH --partition=compute # partition for job

# Priority order of GPUs
declare -a gpu_priority=("a100" "rtxa6000" "rtx6000" "rtx2080ti" "titanv" "tesla")
declare -a blacklist_nodes=("g122", "g105")
declare -a partition_list=("compute", "long")
# Number of GPUs requested (default to 1 if not provided)
NUM_GPUS=${1:-1}
HOURS=${2:-24}
# Target partition
# TARGET_PARTITION="compute"

# Function to count available GPUs of a specific type on ready nodes
count_available_gpus() {
    local gpu_type=$1
    local total_gpus=0
    local available_gpus=0
    
    for partition in "${partition_list[@]}"; do
        partition=$(echo $partition | tr -d ',')
        sinfo -N -o "%n %P %t %G" | grep "$gpu_type" | while read -r line; do
            node=$(echo "$line" | awk '{print $1}')
            partition=$(echo "$line" | awk '{print $2}')
            state=$(echo "$line" | awk '{print $3}')
            total_gpus=$(echo "$line" | grep -o "$gpu_type:[0-9]*" | cut -d ':' -f2)

            # Ensure total_gpus is a valid number
            total_gpus=${total_gpus:-0}  # Default to 0 if not found
            # Check if node is in the correct partition and is ready (state "idle" or "mix")
            if [[ "$partition" == *"$partition"* && ("$state" == "idle" || "$state" == "mix") ]]; then
                in_use_gpus=$(squeue --nodes="$node" --format="%b" | grep -o "$gpu_type:[0-9]*" | cut -d ':' -f2 | paste -sd+ - | bc)
                in_use_gpus=${in_use_gpus:-0}  # Default to 0 if not found
                available_gpus=$((total_gpus - in_use_gpus))

                # Return if we found enough available GPUs
                if [ "$available_gpus" -ge "$NUM_GPUS" ]; then
                    # Return the count and node name
                    echo "$available_gpus $node $partition"
                    return
                fi
            fi
        done
    done
    
    # Return 0 if no suitable nodes found
    echo 0 0
}

# Search for available GPUs based on priority
selected_gpu=""
for gpu in "${gpu_priority[@]}"; do
    echo "-------------------"
    gpu_node_partition=$(count_available_gpus "$gpu")
    available_gpus=$(echo "$gpu_node_partition" | awk '{print $1}')
    available_gpus=$(count_available_gpus "$gpu" | tr -d '\r')  # Trim any carriage returns
    available_gpus=$(echo $available_gpus | cut -d ' ' -f1)
    node_name=$(echo "$gpu_node_partition" | awk '{print $2}')
    node_name=$(echo $node_name | cut -d ' ' -f1)
    partition_name=$(echo "$gpu_node_partition" | awk '{print $3}')
    partition_name=$(echo $partition_name | cut -d ' ' -f1)
    # echo "Available gpu and node: $gpu_node_partition"
    echo "Available $gpu GPUs: $available_gpus"
    echo "Node: $node_name"
    echo "Partition: $partition_name"
    echo "Requested $NUM_GPUS GPUs"

    for blacklisted_node in "${blacklist_nodes[@]}"; do
        blacklisted_node=$(echo $blacklisted_node | tr -d ',')
        if [[ "$node_name" == "$blacklisted_node" ]]; then
            echo "Rejection: Node $node_name is blacklisted."
            continue 2
        fi
    done
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
echo "Found $node_name($partition_name) with $NUM_GPUS x $selected_gpu GPUs."

