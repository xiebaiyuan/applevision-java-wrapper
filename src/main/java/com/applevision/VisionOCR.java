package com.applevision;

import java.io.File;
import java.util.List;

public class VisionOCR {
    static {
        try {
            System.loadLibrary("applevision");
        } catch (UnsatisfiedLinkError e) {
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

