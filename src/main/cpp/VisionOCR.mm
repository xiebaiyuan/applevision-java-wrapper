#include <jni.h>
#include "com_applevision_VisionOCR.h"
#import <Foundation/Foundation.h>
#import <Vision/Vision.h>
#import <AppKit/AppKit.h>

// 辅助函数：创建Java OCR结果对象
jobject createOCRResultObject(JNIEnv *env, NSString *text, float confidence, CGRect boundingBox) {
    // 获取OCRResult类引用
    jclass ocrResultClass = env->FindClass("com/applevision/OCRResult");
    if (ocrResultClass == NULL) {
        return NULL;
    }

    // 获取BoundingBox类引用
    jclass boundingBoxClass = env->FindClass("com/applevision/OCRResult$BoundingBox");
    if (boundingBoxClass == NULL) {
        return NULL;
    }

    // 获取BoundingBox构造函数
    jmethodID boundingBoxConstructor = env->GetMethodID(boundingBoxClass, "<init>", "(DDDD)V");
    if (boundingBoxConstructor == NULL) {
        return NULL;
    }

    // 创建BoundingBox对象
    jobject boundingBoxObj = env->NewObject(boundingBoxClass, boundingBoxConstructor,
                                           (double)boundingBox.origin.x,
                                           (double)boundingBox.origin.y,
                                           (double)boundingBox.size.width,
                                           (double)boundingBox.size.height);

    // 获取OCRResult构造函数
    jmethodID ocrResultConstructor = env->GetMethodID(ocrResultClass, "<init>", 
                                                     "(Ljava/lang/String;DLcom/applevision/OCRResult$BoundingBox;)V");
    if (ocrResultConstructor == NULL) {
        return NULL;
    }

    // 转换NSString到jstring
    jstring jText = env->NewStringUTF([text UTF8String]);

    // 创建OCRResult对象
    jobject ocrResult = env->NewObject(ocrResultClass, ocrResultConstructor,
                                      jText, (double)confidence, boundingBoxObj);

    // 清理本地引用
    env->DeleteLocalRef(jText);
    env->DeleteLocalRef(boundingBoxObj);

    return ocrResult;
}

extern "C" {

/*
 * Class:     com_applevision_VisionOCR
 * Method:    recognizeText
 * Signature: (Ljava/lang/String;)Ljava/util/List;
 */
JNIEXPORT jobject JNICALL Java_com_applevision_VisionOCR_recognizeText
  (JNIEnv *env, jobject thisObj, jstring imagePath) {

    // 将Java字符串转换为C字符串
    const char *pathStr = env->GetStringUTFChars(imagePath, NULL);
    if (pathStr == NULL) {
        return NULL;
    }

    NSString *nsImagePath = [NSString stringWithUTF8String:pathStr];
    env->ReleaseStringUTFChars(imagePath, pathStr);

    // 创建返回的ArrayList
    jclass arrayListClass = env->FindClass("java/util/ArrayList");
    if (arrayListClass == NULL) {
        return NULL;
    }

    jmethodID arrayListConstructor = env->GetMethodID(arrayListClass, "<init>", "()V");
    jmethodID arrayListAdd = env->GetMethodID(arrayListClass, "add", "(Ljava/lang/Object;)Z");

    jobject resultList = env->NewObject(arrayListClass, arrayListConstructor);

    @autoreleasepool {
        // 加载图像
        NSURL *imageURL = [NSURL fileURLWithPath:nsImagePath];
        NSImage *nsImage = [[NSImage alloc] initWithContentsOfURL:imageURL];

        if (nsImage == nil) {
            jclass exceptionClass = env->FindClass("java/lang/RuntimeException");
            env->ThrowNew(exceptionClass, "Failed to load the image");
            return NULL;
        }

        CGImageRef cgImage = [nsImage CGImageForProposedRect:nil context:nil hints:nil];
        if (cgImage == NULL) {
            jclass exceptionClass = env->FindClass("java/lang/RuntimeException");
            env->ThrowNew(exceptionClass, "Failed to convert image to CGImage");
            return NULL;
        }

        // 创建Vision请求处理器
        VNImageRequestHandler *requestHandler = [[VNImageRequestHandler alloc] initWithCGImage:cgImage options:@{}];

        // 创建文本识别请求
        __block NSArray<VNRecognizedTextObservation *> *textObservations = nil;
        __block NSError *requestError = nil;

        VNRecognizeTextRequest *textRequest = [[VNRecognizeTextRequest alloc] 
            initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
                textObservations = request.results;
                requestError = error;
            }];

        // 设置识别级别和语言
        textRequest.recognitionLevel = VNRequestTextRecognitionLevelAccurate;
        textRequest.usesLanguageCorrection = YES;

        // 执行请求
        [requestHandler performRequests:@[textRequest] error:&requestError];

        if (requestError != nil) {
            NSString *errorMessage = [NSString stringWithFormat:@"Vision error: %@", requestError.localizedDescription];
            jclass exceptionClass = env->FindClass("java/lang/RuntimeException");
            env->ThrowNew(exceptionClass, [errorMessage UTF8String]);
            return NULL;
        }

        // 处理结果
        for (VNRecognizedTextObservation *observation in textObservations) {
            VNRecognizedText *recognizedText = [observation topCandidates:1].firstObject;
            if (recognizedText) {
                NSString *text = recognizedText.string;
                float confidence = recognizedText.confidence;
                CGRect boundingBox = observation.boundingBox;

                // 转换坐标系（从左下角原点到左上角原点）
                CGRect convertedBoundingBox = CGRectMake(
                    boundingBox.origin.x,
                    1.0 - boundingBox.origin.y - boundingBox.size.height,
                    boundingBox.size.width,
                    boundingBox.size.height
                );

                // 创建Java OCR结果对象并添加到列表
                jobject ocrResult = createOCRResultObject(env, text, confidence, convertedBoundingBox);
                if (ocrResult != NULL) {
                    env->CallBooleanMethod(resultList, arrayListAdd, ocrResult);
                    env->DeleteLocalRef(ocrResult);
                }
            }
        }
    }

    return resultList;
}

} // extern "C"
