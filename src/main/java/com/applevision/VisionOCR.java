package com.applevision;

import com.applevision.util.NativeLibraryLoader;
import java.io.File;
import java.util.List;

public class VisionOCR {
    static {
        try {
            // 使用工具类加载本地库
            NativeLibraryLoader.validateSystemRequirements();
            NativeLibraryLoader.loadLibrary();
        } catch (RuntimeException e) {
            System.err.println("Native code library failed to load: " + e.getMessage());
            throw e;
        }
    }

    /**
     * 识别图片中的文字并返回结果
     *
     * @param imagePath 图片的路径
     * @return 识别结果列表，包含文字内容及位置坐标
     * @throws RuntimeException 如果OCR过程中发生错误
     */
    public native List<OCRResult> recognizeText(String imagePath);

    /**
     * 使用指定语言识别图片中的文字
     *
     * @param imagePath 图片的路径
     * @param language 语言代码 (如: "zh-Hans", "zh-Hant", "en-US")
     * @return 识别结果列表，包含文字内容及位置坐标
     * @throws RuntimeException 如果OCR过程中发生错误
     */
    public native List<OCRResult> recognizeTextWithLanguage(String imagePath, String language);

    /**
     * 识别图片中的文字并返回结果（带调试信息）
     *
     * @param imagePath 图片的路径
     * @param debug 是否输出调试信息
     * @return 识别结果列表，包含文字内容及位置坐标
     * @throws RuntimeException 如果OCR过程中发生错误
     */
    public List<OCRResult> recognizeText(String imagePath, boolean debug) {
        if (debug) {
            System.out.println("正在识别图片: " + imagePath);
        }
        
        List<OCRResult> results = recognizeText(imagePath);
        
        if (debug) {
            System.out.println("识别完成，共找到 " + results.size() + " 个文本块");
            for (int i = 0; i < results.size(); i++) {
                OCRResult result = results.get(i);
                System.out.println("文本块 " + (i + 1) + ": \"" + result.getText() + 
                                 "\" (置信度: " + String.format("%.2f", result.getConfidence()) + ")");
            }
        }
        
        return results;
    }

    /**
     * 识别图片中的文字并返回结果
     *
     * @param imageFile 图片文件
     * @return 识别结果列表，包含文字内容及位置坐标
     * @throws RuntimeException 如果OCR过程中发生错误
     */
    public List<OCRResult> recognizeText(File imageFile) {
        return recognizeText(imageFile.getAbsolutePath());
    }
}

