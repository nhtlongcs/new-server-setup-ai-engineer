# New Server Setup AI Engineer

This repository contains scripts and documentation to assist AI engineers in setting up a new server environment. The setup includes configurations for CLI tools, installations, and SLURM job scheduling.

## Directory Structure

- **`cli/`**: Contains shell scripts and binaries for command-line interface operations.
  - `active.sh`: Activate CUDA driver on GPU node.
  - `disk.sh`: Analyze and display disk usage statistics (aggregated by depth 1)
  - `hfd.md` and `hfd.sh`: Hugging Face Downloader (multi-process)
  - `slurm.sh`: A utility script for executing commands in many scenarios.

- **`installations/`**: Scripts and files for software installations.
  - `udocker.md`: Docker without root
  - `gdrive.md`: Google Drive integration
  - `install_npm.sh`: Script to install npm.
  - `miniforge.sh`: Script for installing Miniforge.
  - `vscode_cli_alpine_x64_cli.tar.gz`: Archive for VSCode CLI installation (opening tunnel)
  - `wsl_gpu.md`: Documentation for GPU setup in WSL.

- **`mount/`**: Scripts for managing disk mounts.
  - `mount_disk.sh`: Script to mount disks.
  - `mount_list.sh`: Script to list mounted disks.
  - `unmount.sh`: Script to unmount disks.

- **`slurm/`**: SLURM job scheduling scripts.
  - `cpu.tunnel.sbatch`: SLURM batch script for CPU jobs.
  - `gpu.tunnel.sbatch`: SLURM batch script for GPU jobs.

- **`dotfiles/`**: Dotfiles for configuration.
- 
## Getting Started

1. **Installation**: Use the scripts in the `installations/` directory to set up necessary packages.
2. **Configuration**: Modify and run scripts in the `cli/` and `mount/` directories as needed for your environment.
3. **Job Scheduling**: Use the `slurm/` scripts to allocate resources and run jobs.

## License

This project is licensed under the MIT License.
