package com.applevision.example;

import com.applevision.OCRResult;
import com.applevision.VisionOCR;

import java.io.File;
import java.util.List;

/**
 * 详细的OCR使用示例
 * 展示如何使用Apple Vision OCR库进行文本识别
 */
public class DetailedOCRExample {
    
    public static void main(String[] args) {
        if (args.length < 1) {
            System.out.println("使用方法: java DetailedOCRExample <图像文件路径>");
            System.out.println("例如: java DetailedOCRExample /path/to/image.jpg");
            System.exit(1);
        }

        String imagePath = args[0];
        processImage(imagePath);
    }

    /**
     * 处理单个图像文件
     */
    private static void processImage(String imagePath) {
        File imageFile = new File(imagePath);
        
        // 验证图像文件
        if (!imageFile.exists()) {
            System.err.println("错误：图像文件不存在: " + imagePath);
            return;
        }
        
        if (!imageFile.isFile()) {
            System.err.println("错误：指定的路径不是一个文件: " + imagePath);
            return;
        }
        
        // 检查文件扩展名
        String fileName = imageFile.getName().toLowerCase();
        if (!fileName.endsWith(".jpg") && !fileName.endsWith(".jpeg") && 
            !fileName.endsWith(".png") && !fileName.endsWith(".gif") &&
            !fileName.endsWith(".bmp") && !fileName.endsWith(".tiff")) {
            System.out.println("警告：文件扩展名不是常见的图像格式");
        }

        System.out.println("正在处理图像: " + imagePath);
        System.out.println("文件大小: " + formatFileSize(imageFile.length()));
        System.out.println("==========================================");

        try {
            // 创建OCR实例
            VisionOCR ocr = new VisionOCR();
            
            // 执行OCR识别
            long startTime = System.currentTimeMillis();
            List<OCRResult> results = ocr.recognizeText(imageFile);
            long endTime = System.currentTimeMillis();
            
            // 显示执行时间
            System.out.println("OCR执行时间: " + (endTime - startTime) + " 毫秒");
            System.out.println("识别到的文本块数量: " + results.size());
            System.out.println("==========================================");

            if (results.isEmpty()) {
                System.out.println("未在图像中识别到任何文本");
                return;
            }

            // 处理每个识别结果
            for (int i = 0; i < results.size(); i++) {
                OCRResult result = results.get(i);
                displayResult(result, i + 1);
            }
            
            // 显示统计信息
            displayStatistics(results);
            
        } catch (Exception e) {
            System.err.println("OCR处理过程中发生错误: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 显示单个OCR结果
     */
    private static void displayResult(OCRResult result, int index) {
        System.out.println("=== 文本块 " + index + " ===");
        
        // 显示文本内容
        String text = result.getText();
        System.out.println("识别文本: \"" + text + "\"");
        System.out.println("文本长度: " + text.length() + " 个字符");
        
        // 显示置信度
        double confidence = result.getConfidence();
        System.out.println("置信度: " + String.format("%.2f%%", confidence * 100));
        
        // 显示置信度级别
        String confidenceLevel = getConfidenceLevel(confidence);
        System.out.println("置信度级别: " + confidenceLevel);
        
        // 显示位置信息
        OCRResult.BoundingBox bbox = result.getBoundingBox();
        System.out.println("归一化坐标:");
        System.out.println("  左上角: (" + String.format("%.4f", bbox.getX()) + ", " + String.format("%.4f", bbox.getY()) + ")");
        System.out.println("  右下角: (" + String.format("%.4f", bbox.getMaxX()) + ", " + String.format("%.4f", bbox.getMaxY()) + ")");
        System.out.println("  宽度: " + String.format("%.4f", bbox.getWidth()));
        System.out.println("  高度: " + String.format("%.4f", bbox.getHeight()));
        
        // 显示示例像素坐标转换
        displayPixelCoordinates(bbox);
        
        System.out.println();
    }

    /**
     * 显示像素坐标转换示例
     */
    private static void displayPixelCoordinates(OCRResult.BoundingBox bbox) {
        // 假设几种常见的图像尺寸
        int[][] imageSizes = {
            {800, 600},   // 4:3 比例
            {1920, 1080}, // 16:9 比例
            {1024, 768},  // 4:3 比例
            {1280, 720}   // 16:9 比例
        };
        
        System.out.println("像素坐标转换示例:");
        for (int[] size : imageSizes) {
            int width = size[0];
            int height = size[1];
            OCRResult.PixelBoundingBox pixelBbox = bbox.toPixelBoundingBox(width, height);
            
            System.out.println("  " + width + "x" + height + " 像素: " +
                "(" + pixelBbox.getX() + ", " + pixelBbox.getY() + ") " +
                "到 (" + pixelBbox.getMaxX() + ", " + pixelBbox.getMaxY() + ") " +
                "[" + pixelBbox.getWidth() + "x" + pixelBbox.getHeight() + "]");
        }
    }

    /**
     * 获取置信度级别描述
     */
    private static String getConfidenceLevel(double confidence) {
        if (confidence >= 0.9) {
            return "非常高";
        } else if (confidence >= 0.8) {
            return "高";
        } else if (confidence >= 0.7) {
            return "中等";
        } else if (confidence >= 0.6) {
            return "较低";
        } else {
            return "很低";
        }
    }

    /**
     * 显示统计信息
     */
    private static void displayStatistics(List<OCRResult> results) {
        System.out.println("==========================================");
        System.out.println("统计信息:");
        
        // 计算总字符数
        int totalCharacters = results.stream()
            .mapToInt(r -> r.getText().length())
            .sum();
        
        // 计算平均置信度
        double averageConfidence = results.stream()
            .mapToDouble(OCRResult::getConfidence)
            .average()
            .orElse(0.0);
        
        // 找到最高和最低置信度
        double maxConfidence = results.stream()
            .mapToDouble(OCRResult::getConfidence)
            .max()
            .orElse(0.0);
        
        double minConfidence = results.stream()
            .mapToDouble(OCRResult::getConfidence)
            .min()
            .orElse(0.0);
        
        System.out.println("总字符数: " + totalCharacters);
        System.out.println("平均置信度: " + String.format("%.2f%%", averageConfidence * 100));
        System.out.println("最高置信度: " + String.format("%.2f%%", maxConfidence * 100));
        System.out.println("最低置信度: " + String.format("%.2f%%", minConfidence * 100));
        
        // 显示置信度分布
        System.out.println("置信度分布:");
        int veryHigh = 0, high = 0, medium = 0, low = 0, veryLow = 0;
        
        for (OCRResult result : results) {
            double conf = result.getConfidence();
            if (conf >= 0.9) veryHigh++;
            else if (conf >= 0.8) high++;
            else if (conf >= 0.7) medium++;
            else if (conf >= 0.6) low++;
            else veryLow++;
        }
        
        System.out.println("  非常高 (≥90%): " + veryHigh + " 个");
        System.out.println("  高 (80-89%): " + high + " 个");
        System.out.println("  中等 (70-79%): " + medium + " 个");
        System.out.println("  较低 (60-69%): " + low + " 个");
        System.out.println("  很低 (<60%): " + veryLow + " 个");
    }

    /**
     * 格式化文件大小显示
     */
    private static String formatFileSize(long size) {
        if (size < 1024) {
            return size + " B";
        } else if (size < 1024 * 1024) {
            return String.format("%.1f KB", size / 1024.0);
        } else if (size < 1024 * 1024 * 1024) {
            return String.format("%.1f MB", size / (1024.0 * 1024.0));
        } else {
            return String.format("%.1f GB", size / (1024.0 * 1024.0 * 1024.0));
        }
    }
}
