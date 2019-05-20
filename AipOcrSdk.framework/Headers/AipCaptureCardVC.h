//
//  AipCaptureCardVC.h
//  OCRLib
//  卡片识别VewController
//  Created by Yan,Xiangda on 16/11/9.
//  Copyright © 2016年 Baidu Passport. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, CardType) {
    
    CardTypeIdCardFont = 0,
    CardTypeIdCardBack,
    CardTypeBankCard,
    CardTypeLocalIdCardFont ,
    CardTypeLocalIdCardBack,
    CardTypeLocalBankCard
};

@interface AipCaptureCardVC : UIViewController

@property (nonatomic, assign) CardType cardType;
@property (nonatomic, copy) void (^handler)(UIImage *);


+(UIViewController *)ViewControllerWithCardType:(CardType)type andImageHandler:(void (^)(UIImage *image))handler;

@end
