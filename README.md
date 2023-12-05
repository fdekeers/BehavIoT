# BehavIoT
This repository is a fork of the code for the following IMC23 paper:

```
@inproceedings{hu-imc23,
title={{BehavIoT: Measuring Smart Home IoT Behavior Using Network-Inferred Behavior Models}},
author={Hu, Tianrui and Dubois, Daniel J. and Choffnes, David},
booktitle={Proc. of the Internet Measurement Conference (IMC)},
year={2023}
}
```

## Docker container

Pull with:
```bash
docker pull fdekeers/behaviot
```

If you are a lone wolf, you can also build by yourself with:
```bash
docker build [-t IMAGE_TAG] --build-arg UID=$(id -u) --build-arg GID=$(id -g) .
```

Run with:
```bash
docker run --rm --mount type=bind,source=$(pwd),target=/home/user/BehavIoT -it fdekeers/behaviot /bin/bash
```
(If you built the image by yourself, replace `fdekeers/behaviot` with the tag you gave to your image.)


## [Event inference](event_inference/README.md)
Modeling device behavior: inferring periodic and user events

## [PFSM](PFSM/README.md)
Modeling system behavior: building probabilistic finite state machine 

## [Analysis scripts](analysis_scripts/README.md)
Characterization: Event destination and non-essential destination analysis

# Testbed
The [device file](devices.txt) lists the smart home devices and their MAC address used in the paper.
For the testbed setup and software for traffic capture, please check out the [IMC19 paper](https://moniotrlab.khoury.northeastern.edu/publications/imc19/).

# Datasets
[Request here](https://moniotrlab.khoury.northeastern.edu/behaviot-imc23/)
