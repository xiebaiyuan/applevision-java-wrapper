package com.applevision.example;

import com.applevision.OCRResult;
import com.applevision.VisionOCR;

import java.io.File;
import java.util.List;

public class ChineseOCRTest {
    public static void main(String[] args) {
        if (args.length < 1) {
            System.out.println("Usage: java ChineseOCRTest <image_path>");
            System.exit(1);
        }

        String imagePath = args[0];
        File imageFile = new File(imagePath);

        if (!imageFile.exists() || !imageFile.isFile()) {
            System.err.println("Image file does not exist or is not a regular file: " + imagePath);
            System.exit(1);
        }

        try {
            VisionOCR ocr = new VisionOCR();
            
            System.out.println("==========================================");
            System.out.println("测试中文OCR识别");
            System.out.println("图片路径: " + imagePath);
            System.out.println("==========================================");
            
            // 使用默认设置（已经优化为中文）
            List<OCRResult> results = ocr.recognizeText(imageFile.getAbsolutePath(), true);

            System.out.println("==========================================");
            System.out.println("识别结果分析:");
            
            if (results.isEmpty()) {
                System.out.println("未识别到任何文本");
            } else {
                for (int i = 0; i < results.size(); i++) {
                    OCRResult result = results.get(i);
                    String text = result.getText();
                    double confidence = result.getConfidence();
                    
                    System.out.println("=== 文本块 " + (i + 1) + " ===");
                    System.out.println("识别文本: \"" + text + "\"");
                    System.out.println("置信度: " + String.format("%.2f%%", confidence * 100));
                    
                    // 简单的文本分析
                    boolean hasChinese = containsChinese(text);
                    boolean hasEnglish = containsEnglish(text);
                    boolean hasNumbers = containsNumbers(text);
                    
                    System.out.println("文本分析:");
                    System.out.println("  包含中文: " + hasChinese);
                    System.out.println("  包含英文: " + hasEnglish);
                    System.out.println("  包含数字: " + hasNumbers);
                    System.out.println("  文本长度: " + text.length());
                    
                    OCRResult.BoundingBox bbox = result.getBoundingBox();
                    System.out.println("位置信息:");
                    System.out.println("  归一化坐标: (" + 
                                     String.format("%.3f", bbox.getX()) + ", " + 
                                     String.format("%.3f", bbox.getY()) + ", " + 
                                     String.format("%.3f", bbox.getWidth()) + ", " + 
                                     String.format("%.3f", bbox.getHeight()) + ")");
                    System.out.println();
                }
            }

            System.out.println("==========================================");
            System.out.println("总结:");
            System.out.println("总共识别到 " + results.size() + " 个文本块");
            
            // 统计中文文本块
            int chineseBlocks = 0;
            for (OCRResult result : results) {
                if (containsChinese(result.getText())) {
                    chineseBlocks++;
                }
            }
            System.out.println("包含中文的文本块: " + chineseBlocks);
            
        } catch (Exception e) {
            System.err.println("OCR识别错误: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // 检查文本是否包含中文字符
    private static boolean containsChinese(String text) {
        for (char c : text.toCharArray()) {
            if (Character.UnicodeScript.of(c) == Character.UnicodeScript.HAN) {
                return true;
            }
        }
        return false;
    }
    
    // 检查文本是否包含英文字符
    private static boolean containsEnglish(String text) {
        for (char c : text.toCharArray()) {
            if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')) {
                return true;
            }
        }
        return false;
    }
    
    // 检查文本是否包含数字
    private static boolean containsNumbers(String text) {
        for (char c : text.toCharArray()) {
            if (Character.isDigit(c)) {
                return true;
            }
        }
        return false;
    }
}
