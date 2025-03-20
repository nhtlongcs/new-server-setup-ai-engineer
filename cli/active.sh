JOB_ID=$(squeue -u tnguyenho --name interactive --states R -h -O jobid)
srun --jobid $JOB_ID --pty bash