
<h2 align="center"> Bare Metal High Performance AI Final Report </h2>

In this project, we take an AI workfow - [BigGAN](https://github.com/BU-CLOUD-S20/Cloud-native-deployments-of-bare-metal-high-performance-AI-workflows/blob/update-readme/README.md#mit-satori) in our case - that is operational in MIT's HPC [Satori](https://mit-satori.github.io/) (modded with IBM Power PC CPUs, NVIDIA V100 GPUs, etc.) and convert it to a running workflow on OpenShift ([Mass Open Cloud](https://massopen.cloud/)) to measure similarities and to delineate the process of moving an application from a bare metal environment to a cloud native platform.

The instructions to run BigGAN on Satori are [here](https://github.com/BU-CLOUD-S20/Cloud-native-deployments-of-bare-metal-high-performance-AI-workflows/blob/update-readme/README.md#mit-satori). These instructions are our starting point.

***
# Index
1. [Conclusions](#Conclusions)
2. [Running On Satori](#Running-on-Satori)
3. [Running on Mass Open Cloud](#Running-on-OpenShift-on-MOC)

|                  | MIT Satori    | MOC  |
| :-------------:  |:-------------:| -----:|
| GPU Architecture | TESLA V100 32GB | TESLA V100 32GB |
| CPU Architecture | IBM Power9       |   IBM Power9 |

# 1. Conclusions

### 1. Efficiency 
`Measured as the ratio of useful output to total input (measured in CPU/GPU cycles here)` 
- Text for efficiency here...
  - more text here...

### 2. Scalability 
`The ability of the cloud platform to function well when it's changed in size or volume in order to meet a user need (i.e. to rescale).` 

<h2 align="center"> Elasticity </h2>

We selected the BigGAN workflow from a pool of [tutorial examples](https://mit-satori.github.io/tutorial-examples/index.html) offered on the Satori platform.  

We looked into each of the existing examples(workflows) and observed that they all used popular python-written machine learning library such as Tensorflow, PyTorch and Sklearn.  

We further investigate whether these software frameworks allow dynamic resource utilization. In other words, we want to know if these libraries allow the programs to scale-up  resource utilization when the instance(s) it's running in was(were) allocated with more computing resources.

Since the BigGAN workflow is written in PyTorch, we wil focus on discussing the possibility of running/training Pytorch programs in an "elastic manner":

### Elasticity for PyTorch
According to Pytorch documentation [link here](https://pytorch.org/blog/pytorch-adds-new-tools-and-libraries-welcomes-preferred-networks-to-its-community/#tools-for-elastic-training-and-large-scale-computer-vision),  current PyTorch parallelism is achieved by something called **Distributed Data Parallel (DPP)** module, and it has following short-commings:  

1. Parallel jobs cannot start without aquiring all the request nodes(pod/containers).
2. Parallel jobs is not recoverable from node(pod/container) failures.
3. Parallel jobs is not able to incorporate nodes that join later.

Recently the comunity is working on incorporating **elastic training** functionality to PyTorch. Experimental implementation of the functionality can be found at [PyTorch-Elastic](https://github.com/pytorch/elastic).  

However, **PyTorch-Elastic** only supports AWS environment with Amazon Sagemaker and Elastic Kubernetes Service(EKS) and haven't support OpenShift yet.  

After discussion among group members, we figure that given the time and scope of our project, we might not be able to finish adapting **PyTorch-Elastic** to OpenShift environment and re-writing the BigGAN workflow using PyTorch-Elastic APIs by the end of the semester. We will leave it as a future TODO for now.
<!-- <h5 align="center"> shawn </h5> -->


### 4. Automation 
Compared with Satori, OpenShift does have more advantages on tasks automation. We depolyed the AI workflow on OpenShift by using `DeploymentConfig`, `BuildConfig`, `Dockerfile`. The codes of AI workflow are on the Github repository, and we can set the triggers inside `BuildConfig` which makes `BuildConfig` be triggered after we pushing new changes to the Github repository, which can build a new image based on our new codes **automatically**, and after the build finished, it will trigger `DeploymentConfig` to start deploy a container from the image built just now **automatically**. The only thing for researchers need to do is just push the new codes, and the AI workflows can be deployed **automatically** and get the result, without requesting node resources or submitting bash jobs.

![](https://www.lucidchart.com/publicSegments/view/35091b47-7861-4f5d-a2e9-5e4afddfaaaf/image.png)

### 5. Environment Comparisons </h2>
 shubham 

<h2 align="center"> Environment Issues </h2>
<!-- <h5 align="center"> shawn + jing </h5> -->

- Trouble accessing GPU(s) on MoC
  * **Solution**: Specify CUDA related environment variables in deployconfig. (worked until Sprint 4)
- Nvidia cards randomly unavailable
  * **Solution**: None.
  * **Workaround**: Try more times. (worked until Sprint 4)
- Cannot get enough quota for volume
  * **Solution**: MoC administrator granted volume to our OpenShift account.
- Pod creation timeout when mounting volume
  * **Solution**: Currently still blocked. Requires support from MoC.
  * **Workaround**: Manually copied subset of data and build into our base image to make the workflow runnable.
- Trouble pushing to internal image registry on OpenShift
  * **Description**: OpenShift reports error when pulling/pushing image to internel image registry. Possibly due to DNS mapping error on MoC. Currently we can not run any pods that uses our image on OpenShift.
  * **Solution**: Currently still blocked. Requires support from MoC.
  * **Workaround**: None.

### 6. Lessons Learned </h2>
 hao 
 
1. We should ask for mentors' help as soon as possible instead of trying debugging the issue by ourselves so that we may not stuck into one problem for a long time.
2. // TODO


# 2. Running on Satori

We use the instructions to run BigGAN on Satori given [here](https://github.com/BU-CLOUD-S20/Cloud-native-deployments-of-bare-metal-high-performance-AI-workflows/blob/update-readme/README.md#mit-satori). We use 2 GPUs for training. We measured the CPU usage, GPU usage and memory usage while training. 

## CPU usage

Here we notice that the BigGAN workflow consumes just less than 20 % CPU on average. 

![satori cpu usage](https://github.com/BU-CLOUD-S20/Cloud-native-deployments-of-bare-metal-high-performance-AI-workflows/blob/master/doc/imgs/sat-cpu.png)

## Memory usage

The memory usage lingers around 8.3%. For the node that we are running on, this is around 95 GB used of 1145 GB available.

![satori memory usage](https://github.com/BU-CLOUD-S20/Cloud-native-deployments-of-bare-metal-high-performance-AI-workflows/blob/master/doc/imgs/sat-mem.png)


## GPU usage

The GPUs are fully utilized, both GPUs running at almost full capacity. Take note, that this was a shared node, and there might be other users processes running on this GPU node. The workflow can be run in an exlusive node to get the exact usage by only the BigGAN process. However, exclusive nodes are very hard to get scheduled on Satori, in our experience.


![satori gpu usage](https://github.com/BU-CLOUD-S20/Cloud-native-deployments-of-bare-metal-high-performance-AI-workflows/blob/master/doc/imgs/sat-gpu.png)

## GPU Memory usage

The GPU memory is also pretty well utilized. It is Consistently measured around 80%. 

![satori gpu memory usage](https://github.com/BU-CLOUD-S20/Cloud-native-deployments-of-bare-metal-high-performance-AI-workflows/blob/master/doc/imgs/sat-gpu-mem.png)

***

# 3. Running on OpenShift on MOC

We created a docker container that runs the training process of BigGAN. We modified the instructions to run BigGAN on Satori, and use the scripts [here](https://github.com/BU-CLOUD-S20/Cloud-native-deployments-of-bare-metal-high-performance-AI-workflows/tree/feature-gpubiggan/workflows/BigGAN/gpu).
This test used 1 GPU for training. We measured the CPU usage, GPU usage and memory usage while training. 

### CPU usage

Here we notice that the BigGAN workflow consumes just less around 2 % CPU on average. 

![openshift cpu usage](https://github.com/BU-CLOUD-S20/Cloud-native-deployments-of-bare-metal-high-performance-AI-workflows/blob/master/doc/imgs/os-cpu.png)


## CPU usage multiplexed with CPU heavy workload

Now, we ran a CPU-heavy workload multiplexed with the BigGAN workflow. We see that more CPU is definitely more utilized.

![openshift cpu-multiplexed usage](https://github.com/BU-CLOUD-S20/Cloud-native-deployments-of-bare-metal-high-performance-AI-workflows/blob/master/doc/imgs/os-cpu-load.png)



## Memory usage

The memory usage lingers around 15%. For the node that we are running on, this is around 84 GB used of 541 GB available.

![openshift memory usage](https://github.com/BU-CLOUD-S20/Cloud-native-deployments-of-bare-metal-high-performance-AI-workflows/blob/master/doc/imgs/os-mem.png)

## GPU & GPU memory usage

The GPU is around 40% utilized. This might be because that the GPU is not used by other users. THe GPU memory usage stays between 5-10%.

![openshift gpu usage](https://github.com/BU-CLOUD-S20/Cloud-native-deployments-of-bare-metal-high-performance-AI-workflows/blob/master/doc/imgs/os-gpu.png)


TODO: Add CPU and GPU specs, for Satori and OpenShift nodes.