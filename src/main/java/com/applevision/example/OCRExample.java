package com.applevision.example;

import com.applevision.OCRResult;
import com.applevision.VisionOCR;

import java.io.File;
import java.util.List;

public class OCRExample {
    public static void main(String[] args) {
        if (args.length < 1) {
            System.out.println("Usage: java OCRExample <image_path>");
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
            
            // 使用调试模式进行识别
            List<OCRResult> results = ocr.recognizeText(imageFile.getAbsolutePath(), true);

            System.out.println("==========================================");
            System.out.println("OCR 详细结果:");
            for (int i = 0; i < results.size(); i++) {
                OCRResult result = results.get(i);
                System.out.println("=== 文本块 " + (i + 1) + " ===");
                System.out.println("文本: \"" + result.getText() + "\"");
                System.out.println("置信度: " + String.format("%.2f%%", result.getConfidence() * 100));
                
                OCRResult.BoundingBox bbox = result.getBoundingBox();
                System.out.println("位置 (归一化): x=" + String.format("%.3f", bbox.getX()) + 
                                 ", y=" + String.format("%.3f", bbox.getY()) + 
                                 ", w=" + String.format("%.3f", bbox.getWidth()) + 
                                 ", h=" + String.format("%.3f", bbox.getHeight()));
                System.out.println();
            }

            System.out.println("总共识别到 " + results.size() + " 个文本块");
        } catch (Exception e) {
            System.err.println("Error performing OCR: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

