import os
import json
import base64
from flask import Flask, jsonify
import sim_engine  # 引入预编译的免授权核心

app = Flask(__name__)

print("正在初始化免授权 MATLAB Runtime 引擎...")
# 初始化编译库（只需要在启动时执行一次）
engine = sim_engine.initialize()
print("引擎就绪！")


@app.route('/run_matlab', methods=['GET'])
def run_matlab():
    try:
        img_path = 'simulation_dashboard.png'

        # 1. 直接调用编译好的函数，获取返回的 JSON 字符串
        raw_json_str = engine.resilient_control()

        # 2. 将 MATLAB 传回的 JSON 字符串解析为 Python 字典
        vars_data = json.loads(raw_json_str)

        # 3. 读取静默生成的图像并转为 Base64
        with open(img_path, "rb") as image_file:
            encoded_image = base64.b64encode(image_file.read()).decode('utf-8')
        base64_src = f"data:image/png;base64,{encoded_image}"

        # 4. 清理本地临时图片
        if os.path.exists(img_path):
            os.remove(img_path)

        # 5. 组装响应
        response = {
            "code": 200,
            "msg": "免授权仿真执行成功",
            "data": {
                "variables": vars_data,  # 前端可直接读取 vars_data.Results 等
                "image": base64_src
            }
        }
        return jsonify(response)

    except Exception as e:
        return jsonify({"code": 500, "msg": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5045, debug=False)