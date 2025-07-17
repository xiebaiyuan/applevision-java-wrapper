# Apple Vision Framework Java Wrapper

这个项目提供了一个 Java 包装器，用于在 macOS 上调用 Apple Vision Framework 的 OCR 功能。

## 功能特性

- 使用 Apple 的 Vision Framework 进行高精度文字识别
- 识别图像中的文本内容并返回位置信息
- 获取文本的边界框坐标（支持归一化坐标和像素坐标）
- 获取识别置信度
- 支持左上角原点坐标系统
- 提供便捷的坐标转换方法

## 系统要求

- macOS 10.15 (Catalina) 或更高版本
- JDK 8 或更高版本
- Xcode 命令行工具 (用于编译原生代码)

## 构建说明

1. 确保已安装所有必要的开发工具：Java JDK 和 Xcode 命令行工具。
2. 克隆代码库：
   ```
   git clone https://github.com/yourusername/applevision-java-wrapper.git
   ```
3. 进入项目目录并执行 Gradle 构建：
   ```
   cd applevision-java-wrapper
   ./gradlew build
   ```

## 使用示例

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
        results = ocr.recognizeText(imageFile);
        
        // 处理结果
        for (OCRResult result : results) {
            System.out.println("文本: " + result.getText());
            System.out.println("置信度: " + result.getConfidence());
            
            OCRResult.BoundingBox box = result.getBoundingBox();
            System.out.println("位置: x=" + box.getX() + 
                             ", y=" + box.getY() + 
                             ", width=" + box.getWidth() + 
                             ", height=" + box.getHeight());
        }
    }
}
```

## 运行示例程序

构建项目后，可以使用以下命令运行示例程序：

```
java -Djava.library.path=./build/libs/native \
  -cp build/libs/applevision-java-wrapper-1.0-SNAPSHOT.jar \
  com.applevision.example.OCRExample /path/to/image.jpg
```

## 注意事项

- Vision Framework 使用的边界框坐标系统是基于左下角为原点的，而大多数图像处理库使用左上角作为原点。请注意坐标系统的差异。
- 目前只支持 macOS 系统，因为它依赖于 Apple 的 Vision Framework。
package com.applevision;

import java.util.List;

public class OCRResult {
    private final String text;
    private final double confidence;
    private final BoundingBox boundingBox;

    public OCRResult(String text, double confidence, BoundingBox boundingBox) {
        this.text = text;
        this.confidence = confidence;
        this.boundingBox = boundingBox;
    }

    public String getText() {
        return text;
    }

    public double getConfidence() {
        return confidence;
    }

    public BoundingBox getBoundingBox() {
        return boundingBox;
    }

    @Override
    public String toString() {
        return "OCRResult{" +
                "text='" + text + '\'' +
                ", confidence=" + confidence +
                ", boundingBox=" + boundingBox +
                '}';
    }

    public static class BoundingBox {
        private final double x;
        private final double y;
        private final double width;
        private final double height;

        public BoundingBox(double x, double y, double width, double height) {
            this.x = x;
            this.y = y;
            this.width = width;
            this.height = height;
        }

        public double getX() {
            return x;
        }

        public double getY() {
            return y;
        }

        public double getWidth() {
            return width;
        }

        public double getHeight() {
            return height;
        }

        @Override
        public String toString() {
            return "BoundingBox{" +
                    "x=" + x +
                    ", y=" + y +
                    ", width=" + width +
                    ", height=" + height +
                    '}';
        }
    }
}

