#!/bin/bash

# deploy.sh - 创建可分发的JAR包
# 使用方法: ./deploy.sh

set -e

echo "开始创建可分发的JAR包..."

# 1. 检查构建是否完成
if [ ! -f "build/libs/applevision-ocr-1.0.jar" ]; then
    echo "警告: 未找到构建的JAR文件，正在执行构建..."
    ./build.sh
fi

if [ ! -f "build/libs/native/libapplevision.dylib" ]; then
    echo "错误: 未找到本地库文件"
    exit 1
fi

# 2. 创建临时目录
TEMP_DIR="temp_deploy"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR/META-INF/native"

echo "创建临时目录: $TEMP_DIR"

# 3. 复制本地库到META-INF/native
cp build/libs/native/libapplevision.dylib "$TEMP_DIR/META-INF/native/"
echo "复制本地库到META-INF/native/"

# 4. 解压原JAR文件
cd "$TEMP_DIR"
jar -xf "../build/libs/applevision-ocr-1.0.jar"
echo "解压原JAR文件"

# 5. 创建新的完整JAR
jar -cf "../applevision-ocr-1.0-complete.jar" .
cd ..

# 6. 清理临时目录
rm -rf "$TEMP_DIR"

echo ""
echo "✅ 部署成功！"
echo "创建的文件:"
echo "  - applevision-ocr-1.0-complete.jar (包含本地库的完整JAR)"
echo ""
echo "使用方法:"
echo "  java -cp applevision-ocr-1.0-complete.jar com.applevision.example.SimpleOCRExample test.jpg"
echo ""
echo "JAR文件详情:"
jar -tf applevision-ocr-1.0-complete.jar | grep -E "(\.class|\.dylib)$" | head -10
echo "  ... 更多文件"
echo ""
echo "大小信息:"
ls -lh applevision-ocr-1.0-complete.jar | awk '{print "  完整JAR大小: " $5}'
ls -lh build/libs/applevision-ocr-1.0.jar | awk '{print "  原JAR大小: " $5}'
ls -lh build/libs/native/libapplevision.dylib | awk '{print "  本地库大小: " $5}'
