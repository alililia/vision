# Contents

<!-- TOC -->

- [Contents](#contents)
- [Single-path-nas description](#single-path-nas-description)
- [Dataset](#dataset)
- [Features](#features)
    - [Mixed Precision](#mixed-precision)
- [Environment Requirements](#environment-requirements)
- [Quick Start](#quick-start)
- [Scripts Description](#scripts-description)
    - [Scripts and sample code](#scripts-and-sample-code)
    - [Script parameters](#script-parameters)
    - [Training process](#training-process)
        - [Standalone training](#standalone-training)
        - [Distributed training](#distributed-training)
    - [Evaluation process](#evaluation-process)
        - [Evaluate](#evaluate)
    - [Export process](#export-process)
        - [Export](#export)
    - [Inference process](#inference-process)
        - [Inference](#inference)
- [Model description](#model-description)
    - [Performance](#performance)
        - [Training performance](#training-performance)
            - [Single-Path-NAS on ImageNet-1k](#single-path-nas-on-imagenet-1k)
        - [Inference performance](#inference-performance)
            - [Single-Path-NAS on ImageNet-1k](#single-path-nas-on-imagenet-1k-1)
- [ModelZoo Homepage](#modelzoo-homepage)

<!-- /TOC -->

# Single-path-nas description

The author of single-path-nas used a large 7x7 convolution to represent the three convolutions of 3x3, 5x5, and 7x7.
The weights of the smaller convolution layers are shared with the larger ones. The largest kernel becomes a "superkernel".
This way when training the model we do not need to choose between different paths, instead we pass the data through a
layer with shared weights among different sub-kernels. The search space is a block-based straight structure.
Like in the ProxylessNAS and the FBNet, the Inverted Bottleneck block is used as the cell,
and the number of layers is 22 as in the MobileNetV2. Each layer has only two searchable hyper-parameters:
expansion rate and kernel size. The others hyper-parameters are fixed. For example, the filter number of each layer in
the 22nd layer is fixed. Like FBNet, it is slightly changed from MobileNetV2. The used kernel sizes in the paper are
only 3x3 and 5x5 like in the FBNet and ProxylessNAS, and 7x7 kernels are not used. The expansion ratio in the paper has
only two choices of 3 and 6. Both the kernel size and expansion ratio have only 2 choices.
The Single-Path-NAS paper uses the techniques described in Lightnn's paper.
In particular, it describes using a continuous smooth function to represent the discrete choice,
and the threshold is a group Lasso term. This paper uses the same technique as ProxylessNAS to express skip connection,
which is represented by a zero layer.
Paper: https://zhuanlan.zhihu.com/p/63605721

# Dataset

Dataset used：[ImageNet2012](http://www.image-net.org/)

- Dataset size：a total of 1000 categories, 224\*224 color images
    - Training set: 1,281,167 images in total
    - Test set: 50,000 images in total
- Data format：JPEG
    - Note: The data is processed in dataset.py.
- Download the dataset and prepare the directories structure as follows：

```text
└─dataset
    ├─train                 # Training dataset
    └─val                   # Evaluation dataset
```

# Features

## Mixed Precision

The [mixed-precision](https://www.mindspore.cn/tutorials/experts/zh-CN/master/others/mixed_precision.html)
training method uses single-precision and half-precision data to improve the training speed of
deep learning neural networks, while maintaining the network accuracy that can be achieved by single-precision training.
Mixed-precision training increases computing speed and reduces memory usage, while supporting training larger models or
allowing larger batches for training on specific hardware.

# Environment Requirements

- Framework
    - [MindSpore](https://www.mindspore.cn/install/en)
- For more information, please check the links below:
    - [MindSpore tutorials](https://www.mindspore.cn/tutorials/zh-CN/r1.3/index.html)
    - [MindSpore Python API](https://www.mindspore.cn/docs/api/zh-CN/r1.3/index.html)

# Quick Start

After installing MindSpore through the official website, you can follow the steps below for training and evaluation:


  ```bash
  # Run the training example

  # Run the standalone training example

  # Run a distributed training example

  # Run evaluation example

  # Run the inference example
  ```

  For distributed training, you need to create an **hccl** configuration file in JSON format in advance.

  Please follow the instructions in the link below:

  <https://gitee.com/mindspore/models/tree/master/utils/hccl_tools.>

- For the GPU hardware

  ```bash
  # Run the training example
  python train.py --device_id=0 --device_target="GPU" --data_path=/imagenet/train > train.log 2>&1 &

  # Run the standalone training example
  bash ./scripts/run_standalone_train_gpu.sh [DEVICE_ID] [DATA_PATH] > train.log 2>&1 &

  # Run a distributed training example
  bash ./scripts/run_distributed_train_gpu.sh [CUDA_VISIBLE_DEVICES] [DEVICE_NUM] [DATA_PATH]

  # Run evaluation example
  python eval.py --device_target="GPU" --device_id=0 --val_data_path="/path/to/imagenet/val/" --checkpoint_path ./ckpt_0 > ./eval.log 2>&1 &
  ```

# Scripts Description

## Scripts and sample code

```text
├── model_zoo
  ├── scripts
  │   ├──run_distribute_train_gpu.sh          // Shell script for running the GPU distributed training
  │   ├──run_standalone_train_gpu.sh          // Shell script for running the GPU standalone training
  │   ├──run_eval_gpu.sh                      // Shell script for running the GPU evaluation
  ├── src
  │   ├──lr_scheduler
  │   │   ├──__init__.py
  │   │   ├──linear_warmup.py                 // Definitions for the warm-up functionality
  │   │   ├──warmup_cosine_annealing_lr.py    // Definitions for the cosine annealing learning rate schedule
  │   │   ├──warmup_step_lr.py                // Definitions for the exponential learning rate schedule
  │   ├──__init__.py
  │   ├──config.py                            // Parameters configuration
  │   ├──CrossEntropySmooth.py                // Definitions for the cross entropy loss function
  │   ├──dataset.py                           // Functions for creating a dataset
  │   ├──spnasnet.py                          // Single-Path-NAS architecture.
  │   ├──utils.py                             // Auxiliary functions
  ├── create_imagenet2012_label.py            // Creating ImageNet labels
  ├── eval.py                                 // Evaluate the trained model
  ├── export.py                               // Export model to other formats
  ├── README.md                               // Single-Path-NAS related instruction in English
  ├── README_CN.md                            // Single-Path-NAS related instruction in Chinese
  ├── train.py                                // Train the model.
```

## Script parameters

Training parameters and evaluation parameters can be configured in a `config.py` file.

- Parameters of a Single-Path-NAS model for the ImageNet-1k dataset.

  ```python
  'name':'imagenet'                        # dataset
  'pre_trained':'False'                    # Whether to start using a pre-trained model
  'num_classes':1000                       # Number of classes in a dataset
  'lr_init':0.26                           # Initial learning rate, set to 0.26 for single-card training, and 1.5 for eight-card parallel training.
  'batch_size':128                         # training batch size
  'epoch_size':180                         # Number of epochs
  'momentum':0.9                           # Momentum
  'weight_decay':1e-5                      # Weight decay value
  'image_height':224                       # Height of the model input image
  'image_width':224                        # Width of the model input image
  'keep_checkpoint_max':40                 # Number of checkpoints to keep
  'checkpoint_path':None                   # The absolute path to the checkpoint file or a directory, where the checkpoints are saved

  'lr_scheduler': 'cosine_annealing'       # Learning rate scheduler ['cosine_annealing', 'exponential']
  'lr_epochs': [30, 60, 90]                # Key points for the exponential schedular
  'lr_gamma': 0.3                          # Learning rate decay for the exponential scheduler
  'eta_min': 0.0                           # Minimal learning rate
  'T_max': 180                             # Number of epochs for the cosine
  'warmup_epochs': 0                       # Number of warm-up epochs
  'is_dynamic_loss_scale': 1               # Use dynamic loss scale manager (scale manager is not used for GPU)
  'loss_scale': 1024                       # Loss scale value
  'label_smooth_factor': 0.1               # Factor for labels smoothing
  'use_label_smooth': True                 # Use label smoothing
  ```

For more configuration details, please refer to the script `config.py`.

## Training process

### Standalone training


  ```bash
  ```

  The above python command will run in the background, and the result can be viewed through the generated train.log file.

- Using an GPU environment

  ```bash
  python train.py --device_id=0 --device_target="GPU" --data_path=/imagenet/train > train.log 2>&1 &
  ```

  The above python command will run in the background, and the result can be viewed through the generated train.log file.

### Distributed training


  ```bash
  ```

  The above shell script will run distributed training in the background.

- Using a GPU environment

  ```bash
  bash ./scripts/run_distributed_train_gpu.sh [CUDA_VISIBLE_DEVICES] [DEVICE_NUM] [DATA_PATH]
  ```

> TRAIN_PATH - Path to the directory with the training subset of the dataset.

The above shell scripts will run the distributed training in the background.
Also `train_parallel` folder will be created where the copy of the code,
the training log files and the checkpoints will be stored.

## Evaluation process

### Evaluate


  “./ckpt_0” is a directory, where the trained model is saved in the .ckpt format.

  ```bash
  OR
  ```

- Evaluate the model on the ImageNet-1k dataset using the GPU environment

  “./ckpt_0” is a directory, where the trained model is saved in the .ckpt format.

  ```bash
  python eval.py --checkpoint_path=./ckpt_0 --device_id=0 --device_target="GPU" --val_data_path/imagenet/val > ./eval.log 2>&1 &
  OR
  bash ./scripts/run_eval_gpu.sh [DEVICE_ID] [DATA_PATH] [CKPT_FILE/CKPT_DIR]
  ```

> CKPT_FILE_OR_DIR - Path to the trained model checkpoint or to the directory, containing checkpoints.
>
> VALIDATION_DATASET - (optional) Path to the validation subset of the dataset.

## Export process

### Export

  ```shell
  python export.py --ckpt_file [CKPT_FILE] --device_target [DEVICE_TARGET]
  ```


## Inference process

### Inference

Before inference, we need to export the model first.
The following shows an example of using the MINDIR model to run the inference.


  The results of the inference are stored in the scripts directory,
  and results similar to the following can be found in the acc.log log file.

  ```shell
  Total data: 50000, top1 accuracy: 0.74214, top5 accuracy: 0.91652.
  ```

# Model description

## Performance

### Training performance

#### Single-Path-NAS on ImageNet-1k

| -------------------------- | --------------------------------------------------------------------------------------- | 
| Model                      | single-path-nas                                                                         | 
| Upload date                | 2021-06-27                                                                              | 
| MindSpore version          | 1.2.0                                                                                   | 
| Dataset                    | ImageNet-1k Train, 1,281,167 images in total                                            | 
| Training parameters        | epoch=180, batch_size=128, lr_init=0.26 (0.26 for a single card, 1.5 for eight cards)   | 
| Optimizer                  | Momentum                                                                                | 
| Loss function              | Softmax cross entropy                                                                   | 
| Output                     | Probability                                                                             | 
| Classification accuracy    | Eight cards: top1:74.21%, top5:91.712%                                                  | 
| Speed                      | Single card: milliseconds/step; eight cards: 87.173 milliseconds/step                   | 

### Inference performance

#### Single-Path-NAS on ImageNet-1k

| -------------------------- | --------------------------------------------- | ------------------------------------------- | 
| Model                      | single-path-nas                               | single-path-nas                             | 
| Upload date                | 2021-06-27                                    | -                                           | 
| MindSpore version          | 1.2.0                                         | 1.5.0                                       | 
| Dataset                    | ImageNet-1k Val, a total of 50,000 images     | ImageNet-1k Val, a total of 50,000 images   | 
| Classification accuracy    | top1: 74.214%, top5: 91.652%                  | top1: 74.01%, top5: 91.66%                  | 
| Speed                      | Average time 7.67324 ms of infer_count 50000  | 1285 images/second                          | 

# ModelZoo homepage

Please visit the official website [homepage](https://gitee.com/mindspore/models)