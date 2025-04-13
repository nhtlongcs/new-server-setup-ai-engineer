export PATH=/home/tnguyenho/setup/udocker-1.3.16/udocker:$PATH
export MODEL_ARG=/home/tnguyenho/spinning-storage/tnguyenho/llms/Qwen2.5-VL-7B-Instruct/
export CONTAINER_NAME=llm
export EXPOSE_PORT=30000

export MOUNT_SRC=/home/tnguyenho/spinning-storage/tnguyenho/lsc/long/
export MOUNT_DST=/sgl-workspace/data/

# Refresh the linker cache
# violently kill the process that is using the port
kill -9 $(lsof -t -i:$EXPOSE_PORT)

# udocker run -p 30000:30000 -v $MODEL_ARG:/sgl-workspace/llm $CONTAINER_NAME python3 -c "import torch; print(f'TORCH_VERSION={torch.__version__}\nCUDA_AVAILABLE={torch.cuda.is_available()}\nTORCH_CUDA_ARCH_LIST={torch.cuda.get_device_capability()}')"
# udocker run -p $EXPOSE_PORT:30000 -v $MODEL_ARG:/sgl-workspace/llm $CONTAINER_NAME python3 -m sglang.launch_server  --model-path /sgl-workspace/llm --host 0.0.0.0 --port 30000 --disable-cuda-graph
# udocker run --user=root $CONTAINER_NAME -p $EXPOSE_PORT:30000 -v $MODEL_ARG:/sgl-workspace/llm $CONTAINER_NAME "/sbin/ldconfig && python3 -m sglang.launch_server"  --model-path /sgl-workspace/llm --host 0.0.0.0 --port 30000 
# udocker run -p $EXPOSE_PORT:30000 -v $MODEL_ARG:/sgl-workspace/llm $CONTAINER_NAME  python3 -m sglang.launch_server  --model-path /sgl-workspace/llm --host 0.0.0.0 --port 30000 
# chat template https://github.com/sgl-project/sglang/blob/main/python/sglang/srt/conversation.py
# https://github.com/sgl-project/sglang/issues/4645#issuecomment-2743304486 (disable radix cache & chunked prefill size)
udocker run -p $EXPOSE_PORT:30000 \
    -v $MODEL_ARG:/sgl-workspace/llm \
    -v $MOUNT_SRC:$MOUNT_DST \
    -e LANG="en_US.utf-8" \
    -e LC_ALL="en_US.UTF-8" \
    -e LD_LIBRARY_PATH="/usr/lib64-nvidia" \
    -e LIBRARY_PATH="/usr/local/cuda/lib64/stubs" \
    --entrypoint /bin/bash $CONTAINER_NAME -c "
    ldconfig /usr/lib64-nvidia && 
    python3 -m sglang.launch_server \
    --model-path /sgl-workspace/llm \
    --host 0.0.0.0 \
    --port 30000 \
    --disable-cuda-graph \
    --disable-radix-cache \
    --chunked-prefill-size -1 \
    --chat-template=qwen2-vl
    "
