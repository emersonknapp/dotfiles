FROM ubuntu:bionic

# Add ROS repos for colcon and stuff
RUN apt-get update && apt-get install -y curl gnupg2 lsb-release locales
RUN curl http://repo.ros2.org/repos.key | apt-key add -
RUN sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
  build-essential \
  cmake \
  git \
  python3-colcon-common-extensions \
  python3-pip \
  python-rosdep \
  python3-vcstool \
  wget \
  liblog4cxx-dev

# packages for clang build
RUN apt-get update && apt-get install -y \
  clang \
  libc++-dev \
  libc++abi-dev \
  zlib1g-dev \
  libpcre++-dev


# additional packages needed for testing
RUN apt-get update && apt-get install -y \
  python3-colcon-mixin \
  cppcheck \
  libeigen3-dev

# install some pip packages needed for testing
RUN python3 -m pip install -U \
  argcomplete \
  flake8 \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  git+https://github.com/lark-parser/lark.git@0.7d \
  mock \
  pytest-repeat \
  pytest-rerunfailures \
  pytest \
  pytest-cov \
  pytest-runner \
  setuptools

# install Fast-RTPS dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
  libasio-dev \
  libtinyxml2-dev
