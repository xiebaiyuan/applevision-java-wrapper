# Apple Vision Framework Java Wrapper

这个项目提供了一个 Java 包装器，用于在 macOS 上调用 Apple Vision Framework 的 OCR 功能。

## 功能特性

- 使用 Apple 的 Vision Framework 进行高精度文字识别
- 专门优化了中文识别能力
- 识别图像中的文本内容并返回精确的位置信息
- 获取文本的边界框坐标（支持归一化坐标和像素坐标）
- 获取识别置信度
- 支持左上角原点坐标系统（已转换Apple原始的左下角坐标系）
- 提供便捷的坐标转换方法
- 支持多候选文本识别，提高准确性

## 系统要求

- macOS 10.15 (Catalina) 或更高版本
- JDK 8 或更高版本
- Xcode 命令行工具 (用于编译原生代码)

## 快速开始

### 1. 构建项目

使用提供的构建脚本：

```bash
./build.sh
```

构建脚本会自动执行以下步骤：
- 检查系统要求
- 创建必要的目录结构
- 编译Java源代码并生成JNI头文件
- 编译本地动态库
- 创建JAR文件

### 2. 运行测试

使用测试脚本：

```bash
./test.sh <图像文件路径>
```

例如：
```bash
./test.sh /path/to/your/image.jpg
```

这将运行基本OCR示例和详细OCR示例。

## 构建说明

### 手动构建

如果需要手动构建，请按照以下步骤：

1. 确保已安装所有必要的开发工具：
   ```bash
   # 检查Java
   java --version
   javac --version
   
   # 检查Xcode命令行工具
   xcode-select --version
   ```

2. 编译Java源代码：
   ```bash
   mkdir -p build/classes build/generated/jni
   javac -h build/generated/jni -d build/classes \
     src/main/java/com/applevision/OCRResult.java \
     src/main/java/com/applevision/VisionOCR.java \
     src/main/java/com/applevision/example/OCRExample.java \
     src/main/java/com/applevision/example/DetailedOCRExample.java \
     src/main/java/com/applevision/example/ChineseOCRTest.java
   ```

3. 编译本地库：
   ```bash
   cd src/main/cpp
   clang++ -dynamiclib -o libapplevision.dylib VisionOCR.mm \
     -framework Foundation -framework Vision -framework AppKit \
     -I ${JAVA_HOME}/include -I ${JAVA_HOME}/include/darwin \
     -std=c++11 -fPIC -Wl,-no_compact_unwind
   ```

4. 复制库文件：
   ```bash
   mkdir -p build/libs/native
   cp src/main/cpp/libapplevision.dylib build/libs/native/
   ```
## 使用示例

### 基本使用

```java
import com.applevision.OCRResult;
import com.applevision.VisionOCR;

import java.io.File;
import java.util.List;

public class Example {
    public static void main(String[] args) {
        VisionOCR ocr = new VisionOCR();
        
        // 方法 1: 使用文件路径
        List<OCRResult> results = ocr.recognizeText("/path/to/image.jpg");
        
        // 方法 2: 使用 File 对象
        File imageFile = new File("/path/to/image.jpg");
        List<OCRResult> results2 = ocr.recognizeText(imageFile);
        
        // 方法 3: 使用调试模式
        List<OCRResult> results3 = ocr.recognizeText("/path/to/image.jpg", true);
        
        // 处理结果
        for (OCRResult result : results) {
            System.out.println("识别文本: " + result.getText());
            System.out.println("置信度: " + String.format("%.2f%%", result.getConfidence() * 100));
            
            OCRResult.BoundingBox box = result.getBoundingBox();
            System.out.println("位置: x=" + box.getX() + 
                             ", y=" + box.getY() + 
                             ", width=" + box.getWidth() + 
                             ", height=" + box.getHeight());
        }
    }
}
```

### 运行示例程序

构建项目后，可以使用以下命令运行示例程序：

#### 基本OCR示例
```bash
java -Djava.library.path=build/libs/native -cp build/classes \
  com.applevision.example.OCRExample /path/to/image.jpg
```

#### 详细OCR示例
```bash
java -Djava.library.path=build/libs/native -cp build/classes \
  com.applevision.example.DetailedOCRExample /path/to/image.jpg
```

#### 中文OCR测试
```bash
java -Djava.library.path=build/libs/native -cp build/classes \
  com.applevision.example.ChineseOCRTest /path/to/chinese_image.jpg
```

### 使用构建脚本

项目提供了便捷的构建和测试脚本：

#### 构建脚本 (build.sh)
```bash
./build.sh
```

构建脚本功能：
- 自动检查系统要求（Java、Xcode命令行工具等）
- 创建必要的目录结构
- 编译Java源代码
- 生成JNI头文件
- 编译本地动态库
- 创建JAR文件

#### 测试脚本 (test.sh)
```bash
./test.sh <图像文件路径>
```

测试脚本功能：
- 验证构建是否成功
- 运行基本OCR示例
- 运行详细OCR示例
- 提供完整的测试报告

## API 文档

### VisionOCR 类

主要的OCR类，提供文本识别功能。

#### 方法

- `List<OCRResult> recognizeText(String imagePath)` - 从图像文件路径识别文本
- `List<OCRResult> recognizeText(File imageFile)` - 从File对象识别文本
- `List<OCRResult> recognizeText(String imagePath, boolean debug)` - 从图像路径识别文本（带调试输出）

### OCRResult 类

表示单个OCR识别结果。

#### 属性

- `String getText()` - 识别出的文本内容
- `double getConfidence()` - 识别置信度 (0.0 到 1.0)
- `BoundingBox getBoundingBox()` - 文本在图像中的位置

### BoundingBox 类

表示文本在图像中的位置（归一化坐标 0.0-1.0）。

#### 属性

- `double getX()` - 左上角X坐标
- `double getY()` - 左上角Y坐标  
- `double getWidth()` - 宽度
- `double getHeight()` - 高度
- `double getMaxX()` - 右下角X坐标
- `double getMaxY()` - 右下角Y坐标

#### 方法

- `PixelBoundingBox toPixelBoundingBox(int imageWidth, int imageHeight)` - 转换为像素坐标

### PixelBoundingBox 类

表示文本在图像中的位置（像素坐标）。

#### 属性

- `int getX()` - 左上角X坐标 (像素)
- `int getY()` - 左上角Y坐标 (像素)
- `int getWidth()` - 宽度 (像素)
- `int getHeight()` - 高度 (像素)
- `int getMaxX()` - 右下角X坐标
- `int getMaxY()` - 右下角Y坐标

## 中文识别优化

本项目专门针对中文识别进行了优化：

1. **语言配置**：优先使用简体中文(zh-Hans)和繁体中文(zh-Hant)
2. **多候选文本**：获取多个候选结果，选择置信度最高的
3. **关闭自动语言检测**：强制使用中文语言模型
4. **调试支持**：提供详细的识别过程调试信息

## 坐标系统

这个库使用左上角为原点的坐标系统，这与大多数图像处理库一致。归一化坐标的范围是 0.0 到 1.0，其中：
- (0.0, 0.0) 表示图像的左上角
- (1.0, 1.0) 表示图像的右下角

**注意**：Apple Vision Framework 原始使用左下角为原点的坐标系统，本库已自动转换为左上角原点系统。

## 故障排除

### 常见问题

1. **UnsatisfiedLinkError**：
   - 确保本地库已正确编译
   - 检查 `java.library.path` 设置
   - 验证库文件存在于 `build/libs/native/` 目录

2. **中文识别不准确**：
   - 确保图像质量良好
   - 尝试使用 `ChineseOCRTest` 进行详细测试
   - 检查控制台输出的语言支持信息

3. **编译错误**：
   - 确保安装了Xcode命令行工具
   - 验证Java版本兼容性
   - 检查环境变量设置

### 调试技巧

1. 使用调试模式运行：
   ```bash
   java -Djava.library.path=build/libs/native -cp build/classes \
     com.applevision.example.ChineseOCRTest /path/to/image.jpg
   ```

2. 查看系统日志（支持的语言等信息会输出到控制台）

3. 检查图像格式和质量

## 注意事项

- 此库仅在macOS上可用，因为它依赖于Apple的Vision框架
- 需要macOS 10.15或更高版本
- 建议在使用前检查图像文件是否存在和有效
- OCR性能取决于图像质量和文本清晰度
- 中文识别效果可能因字体、大小、背景等因素而异

## 许可证

此项目采用 MIT 许可证。

