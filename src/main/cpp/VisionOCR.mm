/**
 * VisionOCR.mm - Apple Vision框架OCR文本识别JNI实现
 *
 * 功能描述：
 * 本文件实现了Java与Apple Vision框架之间的桥接，提供OCR（光学字符识别）功能。
 * 主要用于从图像中识别和提取文本，特别优化了中文文本识别。
 *
 * 依赖框架：
 * - Foundation: 提供基础的Objective-C类和数据类型
 * - Vision: Apple的计算机视觉框架，提供OCR功能
 * - AppKit: 提供NSImage等图像处理类
 * - JNI: Java本地接口，用于Java和C/C++代码交互
 *
 * 作者：xiebaiyuan
 * 版本：1.0.0
 * 创建时间：2025
 */

#import <Foundation/Foundation.h>
#import <Vision/Vision.h>
#import <AppKit/AppKit.h>
#include <jni.h>
#include "com_applevision_VisionOCR.h"

/**
 * 辅助函数：创建Java OCR结果对象
 *
 * 功能描述：
 * 将Objective-C的OCR识别结果转换为Java对象，包括识别的文本、置信度和边界框信息。
 *
 * 参数说明：
 * @param env JNI环境指针，用于Java和C++之间的交互
 * @param text 识别出的文本内容（NSString类型）
 * @param confidence 识别置信度，范围0.0-1.0，值越高表示识别越准确
 * @param boundingBox 文本在图像中的边界框坐标（CGRect类型）
 *
 * 返回值：
 * @return jobject 创建的Java OCRResult对象，如果创建失败返回NULL
 *
 * 实现细节：
 * 1. 通过JNI查找Java类定义
 * 2. 创建BoundingBox内部类对象存储坐标信息
 * 3. 创建OCRResult主对象包含文本、置信度和边界框
 * 4. 正确管理JNI本地引用，避免内存泄漏
 */
jobject createOCRResultObject(JNIEnv *env, NSString *text, float confidence, CGRect boundingBox) {
    // 获取OCRResult类引用 - 主要的结果容器类
    jclass ocrResultClass = env->FindClass("com/applevision/OCRResult");
    if (ocrResultClass == NULL) {
        return NULL; // 类未找到，可能是类路径配置问题
    }

    // 获取BoundingBox类引用 - 用于存储文本边界框坐标的内部类
    jclass boundingBoxClass = env->FindClass("com/applevision/OCRResult$BoundingBox");
    if (boundingBoxClass == NULL) {
        return NULL; // 内部类未找到
    }

    // 获取BoundingBox构造函数
    // 签名"(DDDD)V"表示：接受4个double参数（x, y, width, height），返回void
    jmethodID boundingBoxConstructor = env->GetMethodID(boundingBoxClass, "<init>", "(DDDD)V");
    if (boundingBoxConstructor == NULL) {
        return NULL; // 构造函数未找到，可能是方法签名不匹配
    }

    // 创建BoundingBox对象
    // 将CGRect的坐标信息转换为double类型传递给Java构造函数
    jobject boundingBoxObj = env->NewObject(boundingBoxClass, boundingBoxConstructor,
                                           (double)boundingBox.origin.x,      // X坐标
                                           (double)boundingBox.origin.y,      // Y坐标
                                           (double)boundingBox.size.width,    // 宽度
                                           (double)boundingBox.size.height);  // 高度

    // 获取OCRResult构造函数
    // 签名表示：接受String、double、BoundingBox三个参数
    jmethodID ocrResultConstructor = env->GetMethodID(ocrResultClass, "<init>", "(Ljava/lang/String;DLcom/applevision/OCRResult$BoundingBox;)V");
    if (ocrResultConstructor == NULL) {
        return NULL; // 构造函数未找到
    }

    // 转换NSString到jstring
    // 使用UTF-8编码确保中文字符正确传递
    jstring jText = env->NewStringUTF([text UTF8String]);

    // 创建OCRResult对象
    // 组装最终的识别结果对象
    jobject ocrResult = env->NewObject(ocrResultClass, ocrResultConstructor,
                                      jText,                    // 识别的文本
                                      (double)confidence,       // 置信度
                                      boundingBoxObj);          // 边界框对象

    // 清理本地引用，防止内存泄漏
    // JNI本地引用有数量限制，必须及时释放
    env->DeleteLocalRef(jText);
    env->DeleteLocalRef(boundingBoxObj);

    return ocrResult;
}

// extern "C" 块确保函数使用C链接约定，避免C++名称修饰
extern "C" {

/**
 * JNI主入口函数：文本识别功能实现
 *
 * 功能描述：
 * 这是Java调用的主要接口函数，接收图像路径，使用Apple Vision框架进行OCR识别，
 * 返回识别出的所有文本结果列表。特别优化了中文文本识别效果。
 *
 * 参数说明：
 * @param env JNI环境指针，提供Java和C++交互的所有功能
 * @param thisObj Java对象实例（本例中未使用）
 * @param imagePath Java字符串，包含待识别图像的完整文件路径
 *
 * 返回值：
 * @return jobject Java ArrayList对象，包含所有识别的OCRResult对象
 *
 * 异常处理：
 * - 图像加载失败：抛出RuntimeException
 * - Vision框架错误：抛出RuntimeException包含详细错误信息
 * - 内存不足：返回NULL
 *
 * 性能优化：
 * - 使用@autoreleasepool管理Objective-C对象内存
 * - 选择VNRequestTextRecognitionLevelAccurate获得最佳识别精度
 * - 支持多候选文本结果，选择置信度最高的
 */
JNIEXPORT jobject JNICALL Java_com_applevision_VisionOCR_recognizeText
  (JNIEnv *env, jobject thisObj, jstring imagePath) {

    // 将Java字符串转换为C字符串
    // GetStringUTFChars获取UTF-8编码的字符串，支持中文路径
    const char *pathStr = env->GetStringUTFChars(imagePath, NULL);
    if (pathStr == NULL) {
        return NULL; // 内存不足，无法分配字符串缓冲区
    }

    // 将C字符串转换为NSString，用于Objective-C API调用
    NSString *nsImagePath = [NSString stringWithUTF8String:pathStr];
    // 立即释放C字符串，避免内存泄漏
    env->ReleaseStringUTFChars(imagePath, pathStr);

    // 创建返回的ArrayList - 用于存储所有OCR识别结果
    jclass arrayListClass = env->FindClass("java/util/ArrayList");
    if (arrayListClass == NULL) {
        return NULL; // ArrayList类未找到，可能是Java环境问题
    }

    // 获取ArrayList的构造函数和add方法
    jmethodID arrayListConstructor = env->GetMethodID(arrayListClass, "<init>", "()V");
    jmethodID arrayListAdd = env->GetMethodID(arrayListClass, "add", "(Ljava/lang/Object;)Z");

    // 创建ArrayList实例用于收集识别结果
    jobject resultList = env->NewObject(arrayListClass, arrayListConstructor);

    // 使用自动释放池管理Objective-C对象内存
    // 确保所有NSString、NSImage等对象在池销毁时自动释放
    @autoreleasepool {
        // 第一步：加载图像文件
        // 将文件路径转换为NSURL，支持本地文件系统路径
        NSURL *imageURL = [NSURL fileURLWithPath:nsImagePath];
        // 使用NSImage加载图像，支持多种图像格式（JPEG、PNG、TIFF等）
        NSImage *nsImage = [[NSImage alloc] initWithContentsOfURL:imageURL];

        // 检查图像是否成功加载
        if (nsImage == nil) {
            // 图像加载失败，可能是文件不存在、格式不支持或权限问题
            jclass exceptionClass = env->FindClass("java/lang/RuntimeException");
            env->ThrowNew(exceptionClass, "Failed to load the image");
            return NULL;
        }

        // 第二步：转换为CGImage格式
        // Vision框架需要CGImage格式，NSImage需要转换
        CGImageRef cgImage = [nsImage CGImageForProposedRect:nil context:nil hints:nil];
        if (cgImage == NULL) {
            // CGImage转换失败，可能是图像数据损坏
            jclass exceptionClass = env->FindClass("java/lang/RuntimeException");
            env->ThrowNew(exceptionClass, "Failed to convert image to CGImage");
            return NULL;
        }

        // 第三步：创建Vision请求处理器
        // 配置图像处理选项，添加更多选项来改善识别效果
        NSDictionary *options = @{
            VNImageOptionProperties: @{},              // 图像属性配置
            VNImageOptionCameraIntrinsics: [NSNull null]  // 相机内参（此处不使用）
        };
        // 创建请求处理器，负责执行Vision请求
        VNImageRequestHandler *requestHandler = [[VNImageRequestHandler alloc] initWithCGImage:cgImage options:options];

        // 第四步：设置文本识别请求
        // 使用块变量存储异步请求的结果
        __block NSArray<VNRecognizedTextObservation *> *textObservations = nil;
        __block NSError *requestError = nil;

        // 创建文本识别请求，设置完成回调
        VNRecognizeTextRequest *textRequest = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
            // 回调函数：保存识别结果和错误信息
            textObservations = request.results;  // 获取所有文本观察结果
            requestError = error;                 // 保存可能的错误
        }];

        // 第五步：配置识别参数以优化中文识别
        // 检查系统支持的语言（调试用）
        NSArray<NSString *> *supportedLanguages = [VNRecognizeTextRequest supportedRecognitionLanguagesForTextRecognitionLevel:VNRequestTextRecognitionLevelAccurate revision:VNRecognizeTextRequestRevision1 error:nil];
        NSLog(@"系统支持的语言: %@", supportedLanguages);

        // 设置识别级别为最高精度
        textRequest.recognitionLevel = VNRequestTextRecognitionLevelAccurate;
        // 启用语言校正，提高识别准确性
        textRequest.usesLanguageCorrection = YES;
        
        // 明确设置中文为主要识别语言
        // 支持简体中文和繁体中文
        NSArray<NSString *> *preferredLanguages = @[@"zh-Hans", @"zh-Hant"];
        textRequest.recognitionLanguages = preferredLanguages;
        
        // 关闭自动语言检测，强制使用指定语言
        // 这样可以提高中文识别的准确性
        if (@available(macOS 11.0, *)) {
            textRequest.automaticallyDetectsLanguage = NO;
        }

        // 第六步：执行识别请求
        // 同步执行请求，等待结果返回
        [requestHandler performRequests:@[textRequest] error:&requestError];

        // 检查请求执行是否成功
        if (requestError != nil) {
            // 请求失败，构造详细错误信息
            NSString *errorMessage = [NSString stringWithFormat:@"Vision error: %@", requestError.localizedDescription];
            jclass exceptionClass = env->FindClass("java/lang/RuntimeException");
            env->ThrowNew(exceptionClass, [errorMessage UTF8String]);
            return NULL;
        }

        // 第七步：处理识别结果
        // 遍历所有文本观察结果
        for (VNRecognizedTextObservation *observation in textObservations) {
            // 获取多个候选文本，提高识别准确性
            // topCandidates:3 表示获取置信度最高的3个候选结果
            NSArray<VNRecognizedText *> *topCandidates = [observation topCandidates:3];
            
            // 选择置信度最高的文本作为最终结果
            VNRecognizedText *bestCandidate = nil;
            float bestConfidence = 0.0;
            
            // 遍历候选结果，找出置信度最高的
            for (VNRecognizedText *candidate in topCandidates) {
                if (candidate.confidence > bestConfidence) {
                    bestCandidate = candidate;
                    bestConfidence = candidate.confidence;
                }
            }
            
            // 如果找到有效的文本候选（非空且置信度合理）
            if (bestCandidate && bestCandidate.string.length > 0) {
                NSString *text = bestCandidate.string;          // 识别的文本
                float confidence = bestCandidate.confidence;    // 置信度
                CGRect boundingBox = observation.boundingBox;   // 边界框

                // 第八步：坐标系转换
                // Vision框架使用左下角为原点的坐标系
                // 需要转换为常用的左上角原点坐标系
                CGRect convertedBoundingBox = CGRectMake(
                    boundingBox.origin.x,                                      // X坐标保持不变
                    1.0 - boundingBox.origin.y - boundingBox.size.height,     // Y坐标翻转
                    boundingBox.size.width,                                    // 宽度保持不变
                    boundingBox.size.height                                    // 高度保持不变
                );

                // 第九步：创建Java结果对象并添加到列表
                // 调用辅助函数创建OCRResult对象
                jobject ocrResult = createOCRResultObject(env, text, confidence, convertedBoundingBox);
                if (ocrResult != NULL) {
                    // 添加到结果列表
                    env->CallBooleanMethod(resultList, arrayListAdd, ocrResult);
                    // 释放本地引用
                    env->DeleteLocalRef(ocrResult);
                }
            }
        }
    } // @autoreleasepool 结束，自动释放所有Objective-C对象

    // 返回包含所有识别结果的ArrayList
    return resultList;
}

} // extern "C" 结束
