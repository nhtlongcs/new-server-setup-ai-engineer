#!/bin/bash -l
#SBATCH --job-name=llm         # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --gres=gpu:a100:1             # number of gpus per node
#SBATCH --time=2-00:00:00          # total run time limit (HH:MM:SS)

#run your job

# REQUIRED

udocker pull lmsysorg/sglang:v0.4.4.post1-cu125
udocker create --name=llm lmsysorg/sglang:v0.4.4.post1-cu125