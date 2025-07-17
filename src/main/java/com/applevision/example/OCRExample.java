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
            List<OCRResult> results = ocr.recognizeText(imageFile);

            System.out.println("OCR Results:");
            for (int i = 0; i < results.size(); i++) {
                OCRResult result = results.get(i);
                System.out.println("=== Text Block " + (i + 1) + " ===");
                System.out.println("Text: \"" + result.getText() + "\"");
                System.out.println("Confidence: " + String.format("%.2f%%", result.getConfidence() * 100));
                
                OCRResult.BoundingBox bbox = result.getBoundingBox();
                System.out.println("Normalized Position:");
                System.out.println("  X: " + String.format("%.3f", bbox.getX()));
                System.out.println("  Y: " + String.format("%.3f", bbox.getY()));
                System.out.println("  Width: " + String.format("%.3f", bbox.getWidth()));
                System.out.println("  Height: " + String.format("%.3f", bbox.getHeight()));
                System.out.println("  Top-Left: (" + String.format("%.3f", bbox.getX()) + ", " + String.format("%.3f", bbox.getY()) + ")");
                System.out.println("  Bottom-Right: (" + String.format("%.3f", bbox.getMaxX()) + ", " + String.format("%.3f", bbox.getMaxY()) + ")");
                
                // 假设一个示例图像尺寸来展示像素坐标
                int exampleWidth = 800;
                int exampleHeight = 600;
                OCRResult.PixelBoundingBox pixelBbox = bbox.toPixelBoundingBox(exampleWidth, exampleHeight);
                System.out.println("Pixel Position (假设图像尺寸 " + exampleWidth + "x" + exampleHeight + "):");
                System.out.println("  X: " + pixelBbox.getX() + " px");
                System.out.println("  Y: " + pixelBbox.getY() + " px");
                System.out.println("  Width: " + pixelBbox.getWidth() + " px");
                System.out.println("  Height: " + pixelBbox.getHeight() + " px");
                System.out.println();
            }

            System.out.println("Total recognized text blocks: " + results.size());
        } catch (Exception e) {
            System.err.println("Error performing OCR: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

