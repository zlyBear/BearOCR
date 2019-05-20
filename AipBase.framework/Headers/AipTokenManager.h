//
// Created by chenxiaoyu on 17/8/29.
// Copyright (c) 2017 baidu. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface AipTokenManager : NSObject

- (instancetype) init __attribute__((unavailable(
"Use 'initWithLicenseFileData' or 'initWithAK:andSK' instead")));

- (instancetype) initWithLicenseFileData: (NSData *)licenseFileContent;

- (instancetype) initWithAK: (NSString *)ak andSK: (NSString *)sk;

//- (instancetype) initWithToken: (NSString *)token;

/**
 * 获取身份证前端检测Token
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void)getIdcardTokenWithSuccessHandler:(void (^)(NSString *token))successHandler
                             failHandler:(void (^)(NSError *error))failHandler;


/**
 * 获取Token。回调可能在mainQueue或其他子线程中
 * @param successHandler 成功回调
 * @param failHandler 失败回调
 */
- (void)getTokenWithSuccessHandler:(void (^)(NSString *token))successHandler
                       failHandler:(void (^)(NSError *error))failHandler;

/**
 * 清空cache
 */
- (void) clearCache;

/**
 * 设置验证服务器地址前缀，包含protocol
 * 如 https://verify.baidubce.com:80
 * 若设置为http，需设置NSAppTransportSecurity
 */
- (void)setAuthHost:(NSString *)host;

@end
