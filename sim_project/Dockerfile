# 1. 基础镜像改为官方提供的免费 MATLAB Runtime
# 注意：标签(r2023b)必须与你在第2步编译时所用的 MATLAB 版本完全一致！
FROM mathworks/matlab-runtime:r2023b

USER root

# 2. 安装 Python 及 pip (Ubuntu 环境)
RUN apt-get update && apt-get install -y python3 python3-pip && apt-get clean

# 3. 设置工作目录并将所有文件考入容器
WORKDIR /app
COPY . /app/

# 4. 安装刚才通过 MATLAB 编译出来的免授权 Python 库
RUN cd sim_engine && python3 setup.py install

# 5. 安装 Flask
RUN pip3 install --no-cache-dir -r requirements.txt

# 6. 暴露端口
EXPOSE 5045

# 7. 切换回安全用户并启动服务
USER matlab
CMD ["python3", "app.py"]