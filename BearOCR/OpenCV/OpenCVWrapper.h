//
//  OpenCVWrapper.h
//  BearOCR
//
//  Created by zly on 2019/5/8.
//  Copyright © 2019 zly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (UIImage *)detect:(UIImage *) image;

@end

NS_ASSUME_NONNULL_END
