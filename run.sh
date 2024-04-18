#!/usr/bin/env bash

if [ ! -f run_id ]; then
    echo 0 > run_id
fi

run_id=$(cat run_id)
run_id=$((${run_id}+1))
echo ${run_id} > run_id

docker build . -t aerostack2-modality
docker run --rm -it \
       --network=host \
       --device=/dev/kfd \
       --device=/dev/dri \
       --group-add=video \
       --ipc=host \
       --cap-add=SYS_PTRACE \
       --security-opt seccomp=unconfined \
       --security-opt label=type:container_runtime_t  \
       -e DISPLAY \
       --env="QT_X11_NO_MITSHM=1" \
       -v "${XAUTHORITY}:/root/.Xauthority:rw" \
       -v /tmp/.X11-unix:/tmp/.X11-unix  \
       -v ~/.config/modality_cli:/root/.config/modality_cli \
       -e MODALITY_RUN_ID=${run_id} \
       aerostack2-modality
