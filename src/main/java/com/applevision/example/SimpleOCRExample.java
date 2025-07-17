package com.applevision.example;

import com.applevision.VisionOCR;
import com.applevision.OCRResult;
import com.applevision.util.NativeLibraryLoader;
import java.util.List;

/**
 * 简单的OCR使用示例
 * 展示如何在外部项目中使用本库
 */
public class SimpleOCRExample {
    
    public static void main(String[] args) {
        // 1. 检查系统要求
        System.out.println("系统信息: " + NativeLibraryLoader.getOSInfo());
        
        if (!NativeLibraryLoader.isMacOS()) {
            System.err.println("此库仅支持macOS系统");
            return;
        }
        
        // 2. 手动加载本地库
        try {
            NativeLibraryLoader.validateSystemRequirements();
            NativeLibraryLoader.loadLibrary();
        } catch (RuntimeException e) {
            System.err.println("本地库加载失败: " + e.getMessage());
            e.printStackTrace();
            return;
        }
        
        // 3. 检查库是否加载成功
        if (!NativeLibraryLoader.isLoaded()) {
            System.err.println("本地库未加载");
            return;
        }
        
        System.out.println("本地库加载成功");
        
        // 4. 检查参数
        if (args.length < 1) {
            System.err.println("用法: java SimpleOCRExample <图片路径>");
            return;
        }
        
        String imagePath = args[0];
        System.out.println("开始识别图片: " + imagePath);
        
        try {
            // 5. 创建OCR实例
            VisionOCR ocr = new VisionOCR();
            
            // 6. 执行OCR识别
            List<OCRResult> results = ocr.recognizeText(imagePath);
            
            // 7. 显示结果
            System.out.println("\n识别结果:");
            System.out.println("共找到 " + results.size() + " 个文本块");
            
            for (int i = 0; i < results.size(); i++) {
                OCRResult result = results.get(i);
                System.out.printf("\n文本块 %d:\n", i + 1);
                System.out.printf("  内容: %s\n", result.getText());
                System.out.printf("  置信度: %.2f\n", result.getConfidence());
                System.out.printf("  边界框: (%.2f, %.2f, %.2f, %.2f)\n", 
                    result.getBoundingBox().getX(),
                    result.getBoundingBox().getY(),
                    result.getBoundingBox().getWidth(),
                    result.getBoundingBox().getHeight());
            }
            
        } catch (Exception e) {
            System.err.println("OCR识别失败: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
