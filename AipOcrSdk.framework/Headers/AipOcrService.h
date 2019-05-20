//
// Created by chenxiaoyu on 17/2/21.
// Copyright (c) 2017 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface AipOcrService : NSObject


/**
 * 使用授权文件授权(推荐)
 * @param licenseFileContent 授权文件内容
 */
- (void) authWithLicenseFileData: (NSData *)licenseFileContent;


/**
 * 使用Api Key, Secret Key授权
 */
- (void) authWithAK: (NSString *)ak andSK: (NSString *)sk;

/**
 * 获取身份证检测Token
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */

- (void )getTokenSuccessHandler:(void (^)(NSString *token))successHandler
                    failHandler:(void (^)(NSError *error))failHandler;


- (void) formRecognitionFromImage: (UIImage*)image
  withOptions: (NSDictionary *)options
successHandler: (void (^)(id result))successHandler
  failHandler: (void (^)(NSError* err))failHandler;
/**
 * 通用文字识别（含位置信息）
 * @param image 需要识别的图片
 * @param options direction, language ... 详见开发者文档
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void) detectTextFromImage: (UIImage*)image
                 withOptions: (NSDictionary *)options
              successHandler: (void (^)(id result))successHandler
                 failHandler: (void (^)(NSError* err))failHandler;


/**
 * 通用文字识别(不含位置信息版)
 * @param image 需要识别的图片
 * @param options direction, language ... 详见开发者文档
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void) detectTextBasicFromImage: (UIImage*)image
                      withOptions: (NSDictionary *)options
                   successHandler: (void (^)(id result))successHandler
                      failHandler: (void (^)(NSError* err))failHandler;

/**
 * 通用文字识别（含生僻字版）
 * @param image 需要识别的图片
 * @param options direction, language ... 详见开发者文档
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void) detectTextEnhancedFromImage: (UIImage*)image
                         withOptions: (NSDictionary *)options
                      successHandler: (void (^)(id result))successHandler
                         failHandler: (void (^)(NSError* err))failHandler;



/**
 * 通用文字识别，高精度，带位置信息
 * @param image 图像
 * @param options 可选参数
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void) detectTextAccurateFromImage: (UIImage*)image
                         withOptions: (NSDictionary *)options
                      successHandler: (void (^)(id result))successHandler
                         failHandler: (void (^)(NSError* err))failHandler;


/**
 * 通用文字识别，高精度，不带位置信息
 * @param image 图像
 * @param options 可选参数
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void)detectTextAccurateBasicFromImage:(UIImage *)image
                             withOptions:(NSDictionary *)options
                          successHandler:(void (^)(id result))successHandler
                             failHandler:(void (^)(NSError *err))failHandler;

- (void) detectIdCardFromImage: (UIImage*)image
                   withOptions: (NSDictionary *)options
                successHandler: (void (^)(id result))successHandler
                   failHandler: (void (^)(NSError* err))failHandler;

/**
 * 身份证正面识别
 * @param image 需要识别的图片
 * @param options 参数，详见开发者文档
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void)detectIdCardFrontFromImage:(UIImage *)image
                       withOptions:(NSDictionary *)options
                    successHandler:(void (^)(id result))successHandler
                       failHandler:(void (^)(NSError *err))failHandler;

/**
 * 身份证背面识别
 * @param image 需要识别的图片
 * @param options 参数，详见开发者文档
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void)detectIdCardBackFromImage:(UIImage *)image
                      withOptions:(NSDictionary *)options
                   successHandler:(void (^)(id result))successHandler
                      failHandler:(void (^)(NSError *err))failHandler;

/**
 * 银行卡识别
 * @param image 需要识别的图片
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void) detectBankCardFromImage: (UIImage*)image
                  successHandler: (void (^)(id result))successHandler
                     failHandler: (void (^)(NSError* err))failHandler;


/**
 * 网图识别
 * @param image 需要识别的图片
 * @param options 额外参数
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void)detectWebImageFromImage:(UIImage *)image
                    withOptions:(NSDictionary *)options
                 successHandler:(void (^)(id result))successHandler
                    failHandler:(void (^)(NSError *err))failHandler;

/**
 * 驾驶证识别
 * @param image 需要识别的图片
 * @param options 额外参数
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void) detectDrivingLicenseFromImage: (UIImage *)image
                           withOptions: (NSDictionary *)options
                        successHandler: (void (^)(id result))successHandler
                           failHandler: (void (^)(NSError* err))failHandler;

/**
 * 行驶证证识别
 * @param image 需要识别的图片
 * @param options 额外参数
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void) detectVehicleLicenseFromImage: (UIImage *)image
                           withOptions: (NSDictionary *)options
                        successHandler: (void (^)(id result))successHandler
                           failHandler: (void (^)(NSError* err))failHandler;

/**
 * 车牌证识别
 * @param image 需要识别的图片
 * @param options 额外参数
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void)detectPlateNumberFromImage:(UIImage *)image
                       withOptions:(NSDictionary *)options
                    successHandler:(void (^)(id result))successHandler
                       failHandler: (void (^)(NSError* err))failHandler;



/**
 * 营业执照识别
 * @param image 图像
 * @param options 可选参数
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void) detectBusinessLicenseFromImage: (UIImage *)image
                            withOptions: (NSDictionary *)options
                         successHandler: (void (^)(id result))successHandler
                            failHandler: (void (^)(NSError* err))failHandler;


/**
 * 票据识别
 * @param image 图像
 * @param options 可选参数
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void) detectReceiptFromImage: (UIImage *)image
                    withOptions: (NSDictionary *)options
                 successHandler: (void (^)(id result))successHandler
                    failHandler: (void (^)(NSError* err))failHandler;

/**
 * iOCR
 * @param image 图像
 * @param options 可选参数
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void) iOCRRecognitionFromImage: (UIImage *)image
                    withOptions: (NSDictionary *)options
                 successHandler: (void (^)(id result))successHandler
                    failHandler: (void (^)(NSError* err))failHandler;


/**
 * 清空验证缓存
 * 出现验证过期等特殊情况调用
 */
- (void) clearCache;

+ (NSError *)aipErrorWithCode:(NSInteger)code andMessage:(NSString *)message;

+ (instancetype)shardService;

@end
