//
// Created by chenxiaoyu on 17/2/16.
// Copyright (c) 2017 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSInteger AipErr_SUCCESS;

@interface NSErrorHelper : NSObject

+ (NSError *)aipErrorWithCode:(NSInteger)code andMessage:(NSString *)message;

+ (NSError *)aipError_bundleMismatch;
+ (NSError *)aipError_licenseMismatch;

+ (NSError *)aipError_serverIllegalResponse;
+ (NSError *)aipError_serverConnectFailWithMessage:(NSString *)message;
@end
