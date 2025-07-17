#!/bin/bash

# 测试脚本

set -e

echo "Apple Vision OCR Java Wrapper 测试脚本"
echo "========================================"

# 检查是否已构建
if [[ ! -f "build/libs/native/libapplevision.dylib" ]]; then
    echo "错误：未找到本地库。请先运行 ./build.sh 构建项目。"
    exit 1
fi

if [[ ! -d "build/classes" ]]; then
    echo "错误：未找到编译后的类文件。请先运行 ./build.sh 构建项目。"
    exit 1
fi

# 检查是否提供了图像文件
if [[ $# -eq 0 ]]; then
    echo "使用方法: $0 <图像文件路径>"
    echo "例如: $0 /path/to/test-image.png"
    exit 1
fi

IMAGE_PATH="$1"

# 检查图像文件是否存在
if [[ ! -f "$IMAGE_PATH" ]]; then
    echo "错误：图像文件不存在: $IMAGE_PATH"
    exit 1
fi

echo "测试图像: $IMAGE_PATH"
echo "========================================"

# 运行基本示例
echo "运行基本OCR示例..."
java -Djava.library.path=build/libs/native -cp build/classes com.applevision.example.OCRExample "$IMAGE_PATH"

echo ""
echo "========================================"
echo "运行详细OCR示例..."
java -Djava.library.path=build/libs/native -cp build/classes com.applevision.example.DetailedOCRExample "$IMAGE_PATH"

echo ""
echo "测试完成！"
