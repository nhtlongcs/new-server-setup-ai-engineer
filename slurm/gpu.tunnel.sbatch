#!/bin/bash
#SBATCH --output="tunnel.log"  
#SBATCH --job-name="tunnel"  
#SBATCH --time=4:00:00 # walltime  
#SBATCH --cpus-per-task=2 # number of cores  
#SBATCH --mem-per-cpu=8G # memory per CPU core

#SBATCH --gres=gpu:a100:1 # request 1 A100 GPU
#SBATCH --partition=compute # for interactive jobs

# find open port  
PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')  
scontrol update JobId="$SLURM_JOB_ID" Comment="$PORT"

# start sshd server on the available port  
echo "Starting sshd on port $PORT"  
/usr/sbin/sshd -D -p ${PORT} -f /dev/null -h ${HOME}/.ssh/id_rsa