//
//  IdcardQualityAdaptor.h
//  IdcardQuality
//
//  Created by Yan,Xiangda on 2017/4/17.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "idcard_quality.h"

typedef NS_ENUM(NSInteger, IdcardQualityImageStatus) {
    
    IdcardQualityImageStatusNormal = 0,
    IdcardQualityImageStatusWrongLocation,
    IdcardQualityImageStatusBlurred,
    IdcardQualityImageStatusOverExposure,
    IdcardQualityImageStatusReversedSide
};

@interface IdcardQualityModel : NSObject

@property (assign ,nonatomic) idcard_quality::ImageStatusType image_status;
@property (assign ,nonatomic) idcard_quality::IdCardQualityErrorType errorType;
@property (assign ,nonatomic) bool has_warpped_image;
@property (assign ,nonatomic) unsigned char *warpped_image_data;
@property (assign ,nonatomic) int warped_image_width;
@property (assign ,nonatomic) int warped_image_height;
@property (assign ,nonatomic) int warped_image_channel;


@end

@interface IdcardQualityAdaptor : NSObject

- (void)initWithAPIKey:(NSString *)apiKey andLocalLicenceFile:(NSString *)localLicencePath;

- (BOOL)initWithToken:(NSString *)token;

- (BOOL)canWork;

- (IdcardQualityModel *)process:(UIImage *)image width:(int)width height:(int)height channel:(int)channel cardType:(idcard_quality::IdCardType)type;

//QA 测试接口
- (IdcardQualityModel *)processIsMoving:(UIImage *)image width:(int)width height:(int)height channel:(int)channel cardType:(idcard_quality::IdCardType)type;

- (IdcardQualityModel *)processWithoutIsMoving:(UIImage *)image width:(int)width height:(int)height channel:(int)channel cardType:(idcard_quality::IdCardType)type;

- (void)releaseIdcardQuality;

@end
