# 部署

利用`Docker`在服务器部署本项目。

## 1. `Docker`相关依赖安装
### 1.1 Ubuntu安装`Docker`

根据[官网的安装方法](https://store.docker.com/editions/community/docker-ce-server-ubuntu?tab=description)安装Docker。如果速度缓慢，可以用`Daocloud`的方法安装，进入[Daocloud Docker安装教程](http://get.daocloud.io)可以找到Docker安装方法



### 1.2 Ubuntu安装`Docker Compose`

在Ubuntu中安装Python3和pip3，之后利用pip安装

```
$ pip3 install docker-compose
```



### 1.3 Ubuntu设置 `Docker`镜像

利用`Daocloud`设置`Docker`镜像，对于Ubuntu系统，在命令行中输入

```
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://d2287b03.m.daocloud.io
```

然后*成功之后按照提示重启`Docker`*

