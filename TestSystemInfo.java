import com.applevision.util.NativeLibraryLoader;

public class TestSystemInfo {
    public static void main(String[] args) {
        System.out.println("系统名称: " + System.getProperty("os.name"));
        System.out.println("系统版本: " + System.getProperty("os.version"));
        System.out.println("是否macOS: " + NativeLibraryLoader.isMacOS());
        System.out.println("系统信息: " + NativeLibraryLoader.getOSInfo());
        
        try {
            NativeLibraryLoader.validateSystemRequirements();
            System.out.println("系统要求验证通过");
        } catch (RuntimeException e) {
            System.err.println("系统要求验证失败: " + e.getMessage());
        }
        
        try {
            NativeLibraryLoader.loadLibrary();
            System.out.println("本地库加载成功");
        } catch (RuntimeException e) {
            System.err.println("本地库加载失败: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("本地库是否已加载: " + NativeLibraryLoader.isLoaded());
    }
}
