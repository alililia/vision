#!/bin/bash
# Copyright 2021 Huawei Technologies Co., Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================

if [ $# != 3 ]
then
    echo "Usage: bash ./scripts/run_distribute_train_gpu.sh [EDGE_PATH] [CKPT_NAME] [DEVICE_NUM]"
exit 1
fi

if [ ! -d "logs" ]; then
    mkdir logs
fi

EDGE_PATH=$1
CKPT_NAME=$2
DEVICE_NUM=$3
echo "$EDGE_PATH"

mpirun --allow-run-as-root -n "$DEVICE_NUM" \
python train.py \
  --device_target=GPU \
  --distributed=True \
  --edge-path=$EDGE_PATH \
  --features-path=$EDGE_PATH \
  --checkpoint_file=./logs/distributed_$CKPT_NAME > logs/distributed_train_$CKPT_NAME.log 2>&1 &
