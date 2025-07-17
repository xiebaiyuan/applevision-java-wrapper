package com.applevision.util;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

/**
 * 本地库加载工具类
 * 用于简化在其他项目中使用本库的过程
 */
public class NativeLibraryLoader {
    private static boolean loaded = false;
    private static final String LIBRARY_NAME = "libapplevision.dylib";
    private static final String LIBRARY_PATH = "/META-INF/native/" + LIBRARY_NAME;
    
    /**
     * 加载本地库
     * 支持从JAR文件中提取并加载本地库
     * 
     * @throws RuntimeException 如果加载失败
     */
    public static synchronized void loadLibrary() {
        if (loaded) {
            return;
        }
        
        try {
            // 首先尝试通过系统路径加载
            System.loadLibrary("applevision");
            loaded = true;
            return;
        } catch (UnsatisfiedLinkError e) {
            // 如果系统路径加载失败，尝试从JAR中提取
            loadFromJar();
        }
    }
    
    /**
     * 从JAR文件中提取并加载本地库
     */
    private static void loadFromJar() {
        try (InputStream is = NativeLibraryLoader.class.getResourceAsStream(LIBRARY_PATH)) {
            if (is == null) {
                throw new RuntimeException("Native library not found in JAR: " + LIBRARY_PATH);
            }
            
            // 创建临时文件
            Path tempLib = Files.createTempFile("libapplevision", ".dylib");
            Files.copy(is, tempLib, StandardCopyOption.REPLACE_EXISTING);
            
            // 设置执行权限
            tempLib.toFile().setExecutable(true);
            
            // 加载库
            System.load(tempLib.toString());
            loaded = true;
            
            // 确保临时文件在JVM退出时被删除
            tempLib.toFile().deleteOnExit();
            
        } catch (IOException e) {
            throw new RuntimeException("Failed to load native library from JAR", e);
        }
    }
    
    /**
     * 检查本地库是否已加载
     * 
     * @return 如果已加载返回true，否则返回false
     */
    public static boolean isLoaded() {
        return loaded;
    }
    
    /**
     * 获取操作系统信息
     * 
     * @return 操作系统名称和版本
     */
    public static String getOSInfo() {
        return System.getProperty("os.name") + " " + System.getProperty("os.version");
    }
    
    /**
     * 检查是否在macOS上运行
     * 
     * @return 如果在macOS上返回true，否则返回false
     */
    public static boolean isMacOS() {
        return System.getProperty("os.name").toLowerCase().contains("mac");
    }
    
    /**
     * 验证系统要求
     * 
     * @throws RuntimeException 如果系统不满足要求
     */
    public static void validateSystemRequirements() {
        if (!isMacOS()) {
            throw new RuntimeException("This library only works on macOS. Current OS: " + getOSInfo());
        }
        
        // 检查macOS版本
        String version = System.getProperty("os.version");
        if (version != null) {
            String[] parts = version.split("\\.");
            if (parts.length >= 1) {
                try {
                    int major = Integer.parseInt(parts[0]);
                    
                    // 对于macOS 10.x版本
                    if (major == 10 && parts.length >= 2) {
                        int minor = Integer.parseInt(parts[1]);
                        if (minor < 15) {
                            throw new RuntimeException("This library requires macOS 10.15 or later. Current version: " + version);
                        }
                    }
                    // 对于macOS 11+版本（都支持）
                    else if (major >= 11) {
                        // macOS 11+ 都支持
                    }
                    // 对于其他情况（如果版本格式不是预期的）
                    else if (major < 10) {
                        throw new RuntimeException("This library requires macOS 10.15 or later. Current version: " + version);
                    }
                } catch (NumberFormatException e) {
                    // 如果无法解析版本，继续执行
                    System.out.println("Warning: Could not parse macOS version: " + version);
                }
            }
        }
    }
}
