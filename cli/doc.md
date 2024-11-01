
## Usage
First, Download [`hfd.sh`](#file-hfd-sh) or clone this repo, and then grant execution permission to the script.
```bash
chmod a+x hfd.sh
```

you can create an alias for convenience
```bash
alias hfd="$PWD/hfd.sh"
```

**Usage Instructions:**
```
$ ./hfd.sh -h
Usage:
  hfd <repo_id> [--include include_pattern1 include_pattern2 ...] [--exclude exclude_pattern1 exclude_pattern2 ...] [--hf_username username] [--hf_token token] [--tool aria2c|wget] [-x threads] [--dataset] [--local-dir path]

Description:
  Downloads a model or dataset from Hugging Face using the provided repo ID.

Parameters:
  repo_id        The Hugging Face repo ID in the format 'org/repo_name'.
  --include       (Optional) Flag to specify string patterns to include files for downloading. Supports multiple patterns.
  --exclude       (Optional) Flag to specify string patterns to exclude files from downloading. Supports multiple patterns.
  include/exclude_pattern The patterns to match against filenames, supports wildcard characters. e.g., '--exclude *.safetensor *.txt', '--include vae/*'.
  --hf_username   (Optional) Hugging Face username for authentication. **NOT EMAIL**.
  --hf_token      (Optional) Hugging Face token for authentication.
  --tool          (Optional) Download tool to use. Can be aria2c (default) or wget.
  -x              (Optional) Number of download threads for aria2c. Defaults to 4.
  --dataset       (Optional) Flag to indicate downloading a dataset.
  --local-dir     (Optional) Local directory path where the model or dataset will be stored.

Example:
  hfd bigscience/bloom-560m --exclude *.safetensors
  hfd meta-llama/Llama-2-7b --hf_username myuser --hf_token mytoken -x 4
  hfd lavita/medical-qa-shared-task-v1-toy --dataset
```
**Download a model:**
```
hfd bigscience/bloom-560m
```

**Download a model need login**

Get huggingface token from [https://huggingface.co/settings/tokens](https://huggingface.co/settings/tokens), then
```bash
hfd meta-llama/Llama-2-7b --hf_username YOUR_HF_USERNAME_NOT_EMAIL --hf_token YOUR_HF_TOKEN
```
**Download a model and exclude certain files (e.g., .safetensors):**


```bash
hfd bigscience/bloom-560m --exclude *.safetensors
```

**Download with aria2c and multiple threads:**
 ```bash
 hfd bigscience/bloom-560m
 ```

*Output*:
During the download, the file URLs will be displayed:

```console
$ hfd bigscience/bloom-560m --tool wget --exclude *.safetensors
...
Start Downloading lfs files, bash script:

wget -c https://huggingface.co/bigscience/bloom-560m/resolve/main/flax_model.msgpack
# wget -c https://huggingface.co/bigscience/bloom-560m/resolve/main/model.safetensors
wget -c https://huggingface.co/bigscience/bloom-560m/resolve/main/onnx/decoder_model.onnx
...
```
