# 1. 使用完全公开且极速拉取的 Ubuntu 22.04 官方基础镜像
FROM ubuntu:22.04

# 2. 避免安装过程中出现时区选择等交互式弹窗
ENV DEBIAN_FRONTEND=noninteractive

# 3. 安装 Python3, pip 以及 mpm 运行所需的核心系统依赖
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    wget \
    unzip \
    libxext6 libxt6 libxmu6 libxpm4 \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 4. 引入 MathWorks 官方包管理器 (mpm) 进行免授权全自动部署
# 下载 mpm -> 赋予执行权限 -> 自动拉取并安装 R2023b Runtime -> 清理安装包
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm \
    && chmod +x mpm \
    && ./mpm install --release=R2023b --destination=/usr/local/MATLAB/MATLAB_Runtime/v915 --products MATLAB_Runtime \
    && rm -f mpm

# 5. 配置 MATLAB Runtime 的全局动态链接库环境变量
ENV LD_LIBRARY_PATH="/usr/local/MATLAB/MATLAB_Runtime/v915/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v915/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v915/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v915/sys/opengl/lib/glnxa64:${LD_LIBRARY_PATH}"

# 6. 设置工作目录并将你的代码库（包括 sim_engine）拷贝进镜像
WORKDIR /app
COPY . /app/

# 7. 安装 Flask 后端依赖，并编译部署你的无授权 MATLAB-Python 接口核心库
RUN pip3 install --no-cache-dir -r requirements.txt \
    && cd sim_engine && python3 setup.py install

# 8. 暴露 5045 端口供前端拉取仿真数据
EXPOSE 5045

# 9. 启动底层控制仿真引擎后端
CMD ["python3", "app.py"]
