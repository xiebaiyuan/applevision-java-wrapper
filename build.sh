#!/bin/bash

# Apple Vision OCR Java Wrapper 构建脚本

set -e

echo "开始构建 Apple Vision OCR Java Wrapper..."

# 检查系统要求
echo "检查系统要求..."

# 检查 Java
if ! command -v java &> /dev/null; then
    echo "错误：未找到 Java。请确保已安装 Java 8 或更高版本。"
    exit 1
fi

# 检查 javac
if ! command -v javac &> /dev/null; then
    echo "错误：未找到 javac。请确保已安装 Java JDK。"
    exit 1
fi

# 检查 clang++
if ! command -v clang++ &> /dev/null; then
    echo "错误：未找到 clang++。请确保已安装 Xcode 命令行工具。"
    exit 1
fi

# 检查 macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "错误：此项目仅在 macOS 上可用。"
    exit 1
fi

echo "系统要求检查通过。"

# 创建构建目录
echo "创建构建目录..."
mkdir -p build/classes
mkdir -p build/libs/native
mkdir -p build/generated/jni

# 编译 Java 源代码并生成 JNI 头文件
echo "编译 Java 源代码并生成 JNI 头文件..."
javac -h build/generated/jni -d build/classes -cp src/main/java src/main/java/com/applevision/*.java src/main/java/com/applevision/example/*.java

# 复制生成的头文件到 cpp 目录
echo "复制头文件..."
cp build/generated/jni/com_applevision_VisionOCR.h src/main/cpp/

# 编译本地库
echo "编译本地库..."
cd src/main/cpp

# 获取 Java 头文件路径
JAVA_HOME_PATH=$(java -XshowSettings:properties -version 2>&1 | grep 'java.home' | cut -d'=' -f2 | tr -d ' ')
JAVA_INCLUDE_PATH="$JAVA_HOME_PATH/../include"
JAVA_INCLUDE_DARWIN_PATH="$JAVA_HOME_PATH/../include/darwin"

# 如果是较新的 Java 版本，头文件可能在不同的位置
if [[ ! -d "$JAVA_INCLUDE_PATH" ]]; then
    JAVA_INCLUDE_PATH="$JAVA_HOME_PATH/include"
    JAVA_INCLUDE_DARWIN_PATH="$JAVA_HOME_PATH/include/darwin"
fi

echo "Java 头文件路径: $JAVA_INCLUDE_PATH"

# 编译动态库
clang++ -dynamiclib -o libapplevision.dylib VisionOCR.mm \
    -framework Foundation \
    -framework Vision \
    -framework AppKit \
    -I "$JAVA_INCLUDE_PATH" \
    -I "$JAVA_INCLUDE_DARWIN_PATH" \
    -std=c++11 \
    -fPIC \
    -Wl,-no_compact_unwind

echo "本地库编译完成。"

# 回到项目根目录
cd ../../..

# 复制本地库到构建目录
echo "复制本地库..."
cp src/main/cpp/libapplevision.dylib build/libs/native/

# 创建可执行的JAR文件
echo "创建JAR文件..."
cd build/classes
jar -cf ../libs/applevision-ocr-1.0.jar com/
cd ../..

echo "构建完成！"
echo ""
echo "构建产物位置："
echo "  - Java classes: build/classes/"
echo "  - 本地库: build/libs/native/libapplevision.dylib"
echo "  - JAR文件: build/libs/applevision-ocr-1.0.jar"
echo ""
echo "运行示例："
echo "  java -Djava.library.path=build/libs/native -cp build/classes com.applevision.example.OCRExample <图像文件路径>"
echo ""
echo "或者："
echo "  java -Djava.library.path=build/libs/native -cp build/classes com.applevision.example.DetailedOCRExample <图像文件路径>"
