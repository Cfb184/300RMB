# 1. 使用完全公开且极速拉取的 Ubuntu 22.04 官方基础镜像
FROM ubuntu:22.04

# 2. 避免安装过程中出现时区选择等交互式弹窗
ENV DEBIAN_FRONTEND=noninteractive

# 3. 安装 Python3, pip 以及 MATLAB Runtime 运行所需的底层依赖库
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    wget \
    unzip \
    libxext6 libxt6 libxmu6 libxpm4 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 4. 下载并静默安装完全免费的 MATLAB Runtime R2023b (基础版，永久有效不失效)
RUN wget -q https://ssd.mathworks.com/supportfiles/downloads/R2023b/Release/9.15/installers/MATLAB_Runtime_R2023b_glnxa64.zip \
    && unzip -q MATLAB_Runtime_R2023b_glnxa64.zip -d /tmp/matlab_runtime \
    && /tmp/matlab_runtime/install -mode silent -agreeToLicense yes \
    && rm -rf /tmp/matlab_runtime MATLAB_Runtime_R2023b_glnxa64.zip

# 5. 配置 MATLAB Runtime 的全局环境变量 (已修复未定义变量警告)
ENV LD_LIBRARY_PATH="/usr/local/MATLAB/MATLAB_Runtime/v915/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v915/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v915/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v915/sys/opengl/lib/glnxa64"

# 6. 设置工作目录并将你的所有代码和编译库拷贝进镜像
WORKDIR /app
COPY . /app/

# 7. 安装 Flask 后端依赖，并安装你编译好的免授权 MATLAB-Python 接口库
RUN pip3 install --no-cache-dir -r requirements.txt \
    && cd sim_engine && python3 setup.py install

# 8. 暴露给前端访问的 5045 端口
EXPOSE 5045

# 9. 启动 Python 后端服务
CMD ["python3", "app.py"]
