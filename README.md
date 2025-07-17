# Apple Vision Framework Java Wrapper

这个项目提供了一个 Java 包装器，用于在 macOS 上调用 Apple Vision Framework 的 OCR 功能。

## 特性

- ✅ **完整的 OCR 功能**: 使用 Apple Vision Framework 进行高精度文本识别
- ✅ **详细的位置信息**: 返回文本的精确边界框坐标（支持归一化和像素坐标）
- ✅ **中文优化**: 专门针对中文文本识别进行优化配置
- ✅ **多语言支持**: 支持指定语言进行识别
- ✅ **Universal Binary**: 同时支持 Intel (x86_64) 和 Apple Silicon (arm64) 架构
- ✅ **自动库加载**: 智能的本地库加载机制（系统路径 + JAR 嵌入式加载）
- ✅ **一键部署**: 提供完整的 JAR 包，包含所有依赖
- ✅ **易于集成**: 简单的 API 设计，易于在其他 Java 项目中使用

## 系统要求

- **操作系统**: macOS 10.15 (Catalina) 或更高版本
- **处理器**: 支持 Intel (x86_64) 和 Apple Silicon (arm64) 架构的 Universal Binary
- **Java**: Java 11 或更高版本
- **依赖**: Apple Vision Framework (macOS 内置)

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
## 在其他Java项目中使用

### 方式1：使用JAR文件

1. **构建JAR文件**：
   ```bash
   ./build.sh
   ```

2. **复制必要文件到目标项目**：
   ```bash
   # 复制JAR文件
   cp build/libs/applevision-ocr-1.0.jar /path/to/your/project/libs/
   
   # 复制本地库
   cp build/libs/native/libapplevision.dylib /path/to/your/project/native/
   ```

3. **在目标项目中配置**：
   ```bash
   # 编译时
   javac -cp libs/applevision-ocr-1.0.jar:. YourClass.java
   
   # 运行时
   java -Djava.library.path=native -cp libs/applevision-ocr-1.0.jar:. YourClass
   ```

### 方式2：Maven项目集成

1. **安装到本地Maven仓库**：
   ```bash
   ./build.sh
   mvn install:install-file -Dfile=build/libs/applevision-ocr-1.0.jar \
     -DgroupId=com.applevision \
     -DartifactId=applevision-java-wrapper \
     -Dversion=1.0 \
     -Dpackaging=jar
   ```

2. **在目标项目的pom.xml中添加依赖**：
   ```xml
   <dependency>
       <groupId>com.applevision</groupId>
       <artifactId>applevision-java-wrapper</artifactId>
       <version>1.0</version>
   </dependency>
   ```

3. **复制本地库到项目资源目录**：
   ```bash
   mkdir -p src/main/resources/native
   cp build/libs/native/libapplevision.dylib src/main/resources/native/
   ```

4. **在Java代码中加载本地库**：
   ```java
   public class YourClass {
       static {
           // 从资源目录加载本地库
           String libPath = "/native/libapplevision.dylib";
           try (InputStream is = YourClass.class.getResourceAsStream(libPath)) {
               if (is != null) {
                   Path tempLib = Files.createTempFile("libapplevision", ".dylib");
                   Files.copy(is, tempLib, StandardCopyOption.REPLACE_EXISTING);
                   System.load(tempLib.toString());
               }
           } catch (IOException e) {
               e.printStackTrace();
           }
       }
   }
   ```

### 方式3：Gradle项目集成

1. **在build.gradle中添加**：
   ```gradle
   repositories {
       flatDir {
           dirs 'libs'
       }
   }
   
   dependencies {
       implementation name: 'applevision-ocr', version: '1.0'
   }
   ```

2. **创建项目结构**：
   ```bash
   mkdir -p libs native
   cp build/libs/applevision-ocr-1.0.jar libs/
   cp build/libs/native/libapplevision.dylib native/
   ```

3. **配置JVM参数**：
   ```gradle
   run {
       jvmArgs = ["-Djava.library.path=native"]
   }
   ```

### 方式4：使用内置工具类（推荐）

本项目提供了 `NativeLibraryLoader` 工具类，简化了本地库的加载过程：

1. **基本使用**：
   ```java
   import com.applevision.VisionOCR;
   import com.applevision.OCRResult;
   import com.applevision.util.NativeLibraryLoader;
   import java.util.List;
   
   public class MyApp {
       public static void main(String[] args) {
           try {
               // 验证系统要求
               NativeLibraryLoader.validateSystemRequirements();
               
               // 创建OCR实例（工具类会自动加载本地库）
               VisionOCR ocr = new VisionOCR();
               
               // 执行OCR
               List<OCRResult> results = ocr.recognizeText("image.jpg");
               
               // 处理结果
               for (OCRResult result : results) {
                   System.out.println("文本: " + result.getText());
                   System.out.println("置信度: " + result.getConfidence());
               }
               
           } catch (RuntimeException e) {
               System.err.println("系统不支持: " + e.getMessage());
           }
       }
   }
   ```

2. **工具类功能**：
   - **系统兼容性检查**：`NativeLibraryLoader.validateSystemRequirements()`
   - **自动库加载**：支持系统路径和JAR嵌入式加载
   - **系统信息获取**：`NativeLibraryLoader.getOSInfo()`
   - **macOS检查**：`NativeLibraryLoader.isMacOS()`
   - **加载状态检查**：`NativeLibraryLoader.isLoaded()`

3. **高级用法**：
   ```java
   // 检查系统兼容性
   if (!NativeLibraryLoader.isMacOS()) {
       System.err.println("此库仅支持macOS系统");
       return;
   }
   
   System.out.println("系统信息: " + NativeLibraryLoader.getOSInfo());
   
   // 使用中文识别
   VisionOCR ocr = new VisionOCR();
   List<OCRResult> results = ocr.recognizeTextWithLanguage("image.jpg", "zh-Hans");
   
   // 获取像素坐标
   for (OCRResult result : results) {
       OCRResult.PixelBoundingBox pixelBox = result.toPixelBoundingBox(800, 600);
       System.out.printf("像素位置: (%d, %d, %d, %d)\n",
           pixelBox.getX(), pixelBox.getY(), 
           pixelBox.getWidth(), pixelBox.getHeight());
   }
   ```

### 方式5：创建可分发的JAR包

使用 `deploy.sh` 脚本创建包含本地库的完整JAR包：

1. **运行部署脚本**：
   ```bash
   ./deploy.sh
   ```

2. **脚本功能**：
   - 自动检查并构建项目（如果需要）
   - 将本地库嵌入到JAR的META-INF/native目录
   - 创建完整的可分发JAR文件
   - 显示文件大小和内容信息

3. **在目标项目中使用**：
   ```java
   import com.applevision.VisionOCR;
   import com.applevision.util.NativeLibraryLoader;
   
   public class MyApp {
       public static void main(String[] args) {
           // 直接使用，无需手动指定library.path
           // NativeLibraryLoader会自动从JAR中提取本地库
           VisionOCR ocr = new VisionOCR();
           
           // 执行OCR
           var results = ocr.recognizeText("image.jpg");
           results.forEach(result -> {
               System.out.println("文本: " + result.getText());
           });
       }
   }
   ```

4. **运行完整JAR**：
   ```bash
   # 直接运行，无需额外参数
   java -cp applevision-ocr-1.0-complete.jar com.applevision.example.SimpleOCRExample test.jpg
   ```

### 方式6：手动创建可分发的JAR包

创建一个包含本地库的完整JAR包：

1. **创建包含本地库的JAR**：
   ```bash
   # 创建临时目录
   mkdir -p temp/META-INF/native
   
   # 复制本地库
   cp build/libs/native/libapplevision.dylib temp/META-INF/native/
   
   # 解压原JAR
   cd temp
   jar -xf ../build/libs/applevision-ocr-1.0.jar
   
   # 创建新的完整JAR
   jar -cf ../applevision-ocr-1.0-complete.jar .
   cd ..
   rm -rf temp
   ```

2. **在目标项目中使用**：
   ```java
   public class LibraryLoader {
       private static boolean loaded = false;
       
       public static synchronized void loadLibrary() {
           if (loaded) return;
           
           try {
               // 从JAR中提取本地库
               String libName = "libapplevision.dylib";
               String libPath = "/META-INF/native/" + libName;
               
               try (InputStream is = LibraryLoader.class.getResourceAsStream(libPath)) {
                   if (is == null) {
                       throw new RuntimeException("Native library not found: " + libPath);
                   }
                   
                   // 创建临时文件
                   Path tempLib = Files.createTempFile("libapplevision", ".dylib");
                   Files.copy(is, tempLib, StandardCopyOption.REPLACE_EXISTING);
                   
                   // 加载库
                   System.load(tempLib.toString());
                   loaded = true;
                   
                   // 确保临时文件在JVM退出时被删除
                   tempLib.toFile().deleteOnExit();
               }
           } catch (IOException e) {
               throw new RuntimeException("Failed to load native library", e);
           }
       }
   }
   ```

### 示例项目代码

```java
package com.yourcompany.yourproject;

import com.applevision.OCRResult;
import com.applevision.VisionOCR;
import java.util.List;

public class YourOCRApplication {
    static {
        // 方式1：如果使用-Djava.library.path
        // 无需额外代码
        
        // 方式2：如果使用嵌入式加载
        // LibraryLoader.loadLibrary();
    }
    
    public static void main(String[] args) {
        if (args.length == 0) {
            System.out.println("请提供图像文件路径");
            return;
        }
        
        try {
            VisionOCR ocr = new VisionOCR();
            List<OCRResult> results = ocr.recognizeText(args[0], true);
            
            System.out.println("识别结果：");
            for (OCRResult result : results) {
                System.out.println("文本: " + result.getText());
                System.out.println("置信度: " + String.format("%.2f%%", 
                    result.getConfidence() * 100));
            }
        } catch (Exception e) {
            System.err.println("OCR错误: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

### 部署注意事项

1. **系统要求**：
   - 目标系统必须是macOS 10.15或更高版本
   - 目标系统必须安装了Vision框架（通常预装）

2. **库文件管理**：
   - 本地库(libapplevision.dylib)必须与Java应用一起分发
   - 建议将库文件嵌入到JAR中以简化部署

3. **权限设置**：
   - 确保本地库文件具有执行权限
   - 如果从JAR中提取，可能需要设置权限：
     ```java
     tempLib.toFile().setExecutable(true);
     ```

4. **错误处理**：
   - 添加适当的异常处理来应对库加载失败
   - 提供清晰的错误信息和解决方案

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

## 开发和发布

### 本地开发

1. **构建项目**：
   ```bash
   ./build.sh
   ```

2. **测试项目**：
   ```bash
   ./test.sh /path/to/test/image.jpg
   ```

3. **创建可分发JAR包**：
   ```bash
   ./deploy.sh
   ```

### 版本管理

使用 `version.sh` 脚本管理项目版本：

```bash
# 增加 patch 版本 (1.0.0 -> 1.0.1)
./version.sh patch

# 增加 minor 版本 (1.0.0 -> 1.1.0) 
./version.sh minor

# 增加 major 版本 (1.0.0 -> 2.0.0)
./version.sh major

# 设置指定版本
./version.sh 2.1.0
```

### 自动发布

项目配置了 GitHub Actions 自动化流程：

1. **触发条件**：
   - 推送到 `master` 或 `main` 分支
   - 创建 Pull Request
   - 手动触发

2. **自动构建**：
   - 在 macOS 环境下构建 Universal Binary
   - 运行测试
   - 创建可分发 JAR 包

3. **自动发布**（仅限主分支推送）：
   - 自动增加版本号
   - 创建 Git 标签
   - 发布到 GitHub Releases
   - 发布到 GitHub Packages (Maven)

4. **发布产物**：
   - `applevision-ocr-x.y.z-complete.jar` - 完整JAR包（包含本地库）
   - `applevision-ocr-x.y.z.jar` - 基础JAR包
   - `libapplevision.dylib` - Universal Binary 本地库

### 手动发布流程

1. **更新版本**：
   ```bash
   ./version.sh patch  # 或 minor, major
   ```

2. **推送到GitHub**：
   ```bash
   git push origin master --tags
   ```

3. **GitHub Actions 自动处理其余步骤**

### Maven 集成

项目发布到 GitHub Packages，可以在其他项目中使用：

```xml
<repositories>
    <repository>
        <id>github</id>
        <url>https://maven.pkg.github.com/xiebaiyuan/applevision-java-wrapper</url>
    </repository>
</repositories>

<dependencies>
    <dependency>
        <groupId>com.applevision</groupId>
        <artifactId>applevision-java-wrapper</artifactId>
        <version>1.0.0</version>
    </dependency>
</dependencies>
```

**注意**：发布到 GitHub Packages 的 JAR 是 complete 版本，包含了所有必需的本地库，可以直接使用。

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

