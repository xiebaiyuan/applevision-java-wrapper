package com.applevision;

/**
 * OCR识别结果类
 * 包含识别出的文本内容、置信度和位置信息
 */
public class OCRResult {
    private final String text;
    private final double confidence;
    private final BoundingBox boundingBox;

    /**
     * 构造函数
     * 
     * @param text 识别出的文本内容
     * @param confidence 置信度 (0.0 到 1.0)
     * @param boundingBox 文本在图像中的位置边界框
     */
    public OCRResult(String text, double confidence, BoundingBox boundingBox) {
        this.text = text;
        this.confidence = confidence;
        this.boundingBox = boundingBox;
    }

    /**
     * 获取识别出的文本内容
     * 
     * @return 文本内容
     */
    public String getText() {
        return text;
    }

    /**
     * 获取识别的置信度
     * 
     * @return 置信度值 (0.0 到 1.0)
     */
    public double getConfidence() {
        return confidence;
    }

    /**
     * 获取文本在图像中的位置边界框
     * 
     * @return 边界框对象
     */
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

    /**
     * 边界框类
     * 表示文本在图像中的位置和大小
     */
    public static class BoundingBox {
        private final double x;
        private final double y;
        private final double width;
        private final double height;

        /**
         * 构造函数
         * 
         * @param x 左上角X坐标 (归一化坐标 0.0-1.0)
         * @param y 左上角Y坐标 (归一化坐标 0.0-1.0)
         * @param width 宽度 (归一化坐标 0.0-1.0)
         * @param height 高度 (归一化坐标 0.0-1.0)
         */
        public BoundingBox(double x, double y, double width, double height) {
            this.x = x;
            this.y = y;
            this.width = width;
            this.height = height;
        }

        /**
         * 获取左上角X坐标
         * 
         * @return X坐标 (归一化坐标 0.0-1.0)
         */
        public double getX() {
            return x;
        }

        /**
         * 获取左上角Y坐标
         * 
         * @return Y坐标 (归一化坐标 0.0-1.0)
         */
        public double getY() {
            return y;
        }

        /**
         * 获取宽度
         * 
         * @return 宽度 (归一化坐标 0.0-1.0)
         */
        public double getWidth() {
            return width;
        }

        /**
         * 获取高度
         * 
         * @return 高度 (归一化坐标 0.0-1.0)
         */
        public double getHeight() {
            return height;
        }

        /**
         * 获取右下角X坐标
         * 
         * @return 右下角X坐标 (归一化坐标 0.0-1.0)
         */
        public double getMaxX() {
            return x + width;
        }

        /**
         * 获取右下角Y坐标
         * 
         * @return 右下角Y坐标 (归一化坐标 0.0-1.0)
         */
        public double getMaxY() {
            return y + height;
        }

        /**
         * 转换为实际像素坐标
         * 
         * @param imageWidth 图像宽度
         * @param imageHeight 图像高度
         * @return 像素坐标的边界框
         */
        public PixelBoundingBox toPixelBoundingBox(int imageWidth, int imageHeight) {
            return new PixelBoundingBox(
                (int) (x * imageWidth),
                (int) (y * imageHeight),
                (int) (width * imageWidth),
                (int) (height * imageHeight)
            );
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

    /**
     * 像素坐标边界框类
     * 表示文本在图像中的像素位置和大小
     */
    public static class PixelBoundingBox {
        private final int x;
        private final int y;
        private final int width;
        private final int height;

        /**
         * 构造函数
         * 
         * @param x 左上角X坐标 (像素)
         * @param y 左上角Y坐标 (像素)
         * @param width 宽度 (像素)
         * @param height 高度 (像素)
         */
        public PixelBoundingBox(int x, int y, int width, int height) {
            this.x = x;
            this.y = y;
            this.width = width;
            this.height = height;
        }

        /**
         * 获取左上角X坐标
         * 
         * @return X坐标 (像素)
         */
        public int getX() {
            return x;
        }

        /**
         * 获取左上角Y坐标
         * 
         * @return Y坐标 (像素)
         */
        public int getY() {
            return y;
        }

        /**
         * 获取宽度
         * 
         * @return 宽度 (像素)
         */
        public int getWidth() {
            return width;
        }

        /**
         * 获取高度
         * 
         * @return 高度 (像素)
         */
        public int getHeight() {
            return height;
        }

        /**
         * 获取右下角X坐标
         * 
         * @return 右下角X坐标 (像素)
         */
        public int getMaxX() {
            return x + width;
        }

        /**
         * 获取右下角Y坐标
         * 
         * @return 右下角Y坐标 (像素)
         */
        public int getMaxY() {
            return y + height;
        }

        @Override
        public String toString() {
            return "PixelBoundingBox{" +
                    "x=" + x +
                    ", y=" + y +
                    ", width=" + width +
                    ", height=" + height +
                    '}';
        }
    }
}
