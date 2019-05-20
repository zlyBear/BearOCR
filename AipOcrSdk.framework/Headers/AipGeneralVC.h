//
//  AipGeneralVC.h
//  OCRLib
//
//  Created by Yan,Xiangda on 2017/2/16.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AipGeneralVC : UIViewController


@property (nonatomic, copy) void (^handler)(UIImage *);

+(UIViewController *)ViewControllerWithHandler:(void (^)(UIImage *image))handler;

@end
