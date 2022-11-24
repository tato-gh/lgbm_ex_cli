# LGBMExCli

LightGBM CLI wrapper on Elixir.

NOTE:

- Beta version / Not stable


## Try with docker elixir

```
git clone https://github.com/tato-gh/lgbm_ex_cli
cd lgbm_ex_cli
docker run -it --rm -v `pwd`:/srv elixir:1.13 /bin/bash
```

**install LightGBM**

In docker container

```
apt update && apt install -y cmake
cd /root
git clone --recursive https://github.com/microsoft/LightGBM.git
cd LightGBM
mkdir build && cd build
cmake ..
make -j4
```

refs:

- [LightGBM Installation Guide](https://lightgbm.readthedocs.io/en/latest/Installation-Guide.html#linux)


**ENVIRONMENT**

```
export LIGHTGBM_DIR=/root/LightGBM
```

**run test**

```
cd /srv
MIX_ENV=test mix test
```


## With your application

```
[
  {:lgbm_ex_cli, "0.1.0", git: "https://github.com/tato-gh/lgbm_ex_cli"}
]
```

And you should prepare microsoft/LightGBM and set environment variables `LIGHTGBM_DIR`.
