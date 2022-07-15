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

if [[ $# -gt 4 ]]; then
    echo "Usage: bash ./scripts/run_export_gpu.sh [DEVICE_ID] [CKPT_PATH] [EDGE_PATH] [OUTPUT_FILE_NAME]"
exit 1
fi

if [ ! -d "logs" ]; then
        mkdir logs
fi

nohup python export.py \
--device_id=$1 \
--device_target=GPU \
--checkpoint_file=$2 \
--edge_path=$3 \
--features-path=$3 \
--file_name=$4 > logs/export.log 2>&1 &
