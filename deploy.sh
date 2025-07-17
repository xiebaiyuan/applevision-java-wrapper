#!/bin/bash

# deploy.sh - 创建可分发的JAR包
# 使用方法: ./deploy.sh [version]

set -e

# 获取版本号
VERSION=${1:-${VERSION:-"1.0.0"}}
BASE_JAR="build/libs/applevision-ocr-${VERSION}.jar"
COMPLETE_JAR="applevision-ocr-${VERSION}-complete.jar"

echo "开始创建可分发的JAR包..."
echo "版本: $VERSION"

# 1. 检查构建是否完成
if [ ! -f "$BASE_JAR" ]; then
    echo "警告: 未找到构建的JAR文件 ($BASE_JAR)，正在执行构建..."
    VERSION=$VERSION ./build.sh
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
jar -xf "../$BASE_JAR"
echo "解压原JAR文件"

# 5. 创建新的完整JAR
jar -cf "../$COMPLETE_JAR" .
cd ..

# 6. 清理临时目录
rm -rf "$TEMP_DIR"

echo ""
echo "✅ 部署成功！"
echo "创建的文件:"
echo "  - $COMPLETE_JAR (包含本地库的完整JAR)"
echo ""
echo "使用方法:"
echo "  java -cp $COMPLETE_JAR com.applevision.example.SimpleOCRExample test.jpg"
echo ""
echo "JAR文件详情:"
jar -tf "$COMPLETE_JAR" | grep -E "(\.class|\.dylib)$" | head -10
echo "  ... 更多文件"
echo ""
echo "大小信息:"
ls -lh "$COMPLETE_JAR" | awk '{print "  完整JAR大小: " $5}'
ls -lh "$BASE_JAR" | awk '{print "  原JAR大小: " $5}'
ls -lh build/libs/native/libapplevision.dylib | awk '{print "  本地库大小: " $5}'
