//
//  OpenCVWrapper.m
//  BearOCR
//
//  Created by zly on 2019/5/8.
//  Copyright © 2019 zly. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc.hpp>

struct RectArray {
    cv::RotatedRect rects[100];
};


@implementation OpenCVWrapper

+ (cv::Mat) preprocess:(cv::Mat)gray {
    
    

    
    //第一次二值化,转为黑白图片
    cv::Mat binary;
    cv::adaptiveThreshold(gray,binary,255,cv::ADAPTIVE_THRESH_GAUSSIAN_C,cv::THRESH_BINARY,31,10);
    

    
    //在第二次二值化之前 为了去除噪点 做了两次膨胀腐蚀,OpenCV是对亮点进行操作,在黑白图像中降噪更容易处理(去除杂乱黑点)
    
    //膨胀一次
    cv::Mat dilateelement = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(4,2));
    cv::Mat dilate1;
    dilate(binary, dilate1, dilateelement);
    
    
    //轻度腐蚀一次,去除噪点
    cv::Mat element3 = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(4,4));
    cv::Mat erode11;
    erode(dilate1, erode11, element3);
    
    
    //第二次膨胀
    cv::Mat dilateelement12 = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5,1));
    cv::Mat dilate12;
    dilate(erode11, dilate12, dilateelement12);
    
    
    //轻度腐蚀一次,去除噪点
    cv::Mat element12 = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5,1));
    cv::Mat erode12;
    erode(dilate12, erode12, element12);
    
    
    
    //////////////////////////////////////////////////////////
    //二值化 第二次二值化将黑白图像反转 文字变亮
    cv::Mat binary2;
    cv::adaptiveThreshold(erode12,binary2,255,cv::ADAPTIVE_THRESH_GAUSSIAN_C,cv::THRESH_BINARY_INV,17,10);
    
    
    //横向膨胀拉伸 文字连片形成亮条
    cv::Mat dilateelement21 = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(60,1));
    cv::Mat dilate21;
    dilate(binary2, dilate21, dilateelement21);


    //腐蚀一次，去掉细节，表格线等。这里去掉的是竖直的线
    cv::Mat erodeelement21 = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(30,1));
    cv::Mat erode21;
    erode(dilate21, erode21, erodeelement21);


    //再次膨胀，让轮廓明显一些
    cv::Mat dilateelement22 = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5,1));
    cv::Mat dilate22;
    dilate(erode21, dilate22, dilateelement22);

    
    
    return dilate22;
}

+ (std::vector<cv::RotatedRect>) findTextRegion:(cv::Mat) img {
    
    std::vector<cv::RotatedRect> rects;
    std::vector<int> heights;
    //1.查找轮廓
    std::vector<std::vector<cv::Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    cv::Mat m = img.clone();
    cv::findContours(img,contours,hierarchy,
                     cv::RETR_EXTERNAL,cv::CHAIN_APPROX_SIMPLE,cv::Point(0,0));
    //2.筛选那些面积小的
    for (int i = 0; i < contours.size(); i++) {
        //计算当前轮廓的面积
        double area = cv::contourArea(contours[i]);
        //面积小于1000的全部筛选掉
        if (area < 1000)
            continue;
        //轮廓近似，作用较小，approxPolyDP函数有待研究
        double epsilon = 0.001*arcLength(contours[i], true);
        cv::Mat approx;
        approxPolyDP(contours[i], approx, epsilon, true);
        
        //找到最小矩形，该矩形可能有方向
        cv::RotatedRect rect = minAreaRect(contours[i]);
        
        //计算高和宽
        int m_width = rect.boundingRect().width;
        int m_height = rect.boundingRect().height;
        
        //筛选那些太细的矩形，留下扁的
        if (m_height > m_width * 1.2)
            continue;
        //过滤很扁的
        if (m_height < 20)
            continue;
        heights.push_back(m_height);
        //符合条件的rect添加到rects集合中
        rects.push_back(rect);
    }
    
    return rects;
}

+ (UIImage *)detect:(UIImage *) image {
    
    cv::Mat img;
    img = [self cvMatFromUIImage:image];
    
    //放大图片
    cv::Mat bigImg;
    cv::resize(img, bigImg, cv::Size(img.cols*1,img.rows*1),0,0,cv::INTER_LINEAR);
    
    //1.转化成灰度图
    cv::Mat gray;
    cvtColor(bigImg, gray, cv::COLOR_BGR2GRAY);
    
    //2.形态学变换的预处理,得到可以查找矩形的轮廓
    cv::Mat dilation = [self preprocess:gray];
    
    //3.查找和筛选文字区域
    std::vector<cv::RotatedRect> rects = [self findTextRegion:dilation];
    
    //4.用绿线画出这些找到的轮廓
    for (int i = 0; i < rects.size(); i++) {
        cv::Point2f P[4];
        cv::RotatedRect rect = rects[i];
        rect.points(P);
        for (int j = 0; j <= 3; j++) {
            cv::line(bigImg, P[j], P[(j + 1) % 4], cv::Scalar(0,0,255),2);
        }
    }
    
    return [self UIImageFromCVMat:bigImg];
}



//从UIImage对象转换为4通道的Mat，即是原图的Mat
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,
                                                    cols,
                                                    rows,
                                                    8,
                                                    cvMat.step[0],
                                                    colorSpace,
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

//从UIImage转换单通道的Mat，即灰度值
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,
                                                    cols,
                                                    rows,
                                                    8,
                                                    cvMat.step[0],
                                                    colorSpace,
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

//将Mat转换为UIImage
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,
                                        cvMat.rows,
                                        8,
                                        8 * cvMat.elemSize(),
                                        cvMat.step[0],
                                        colorSpace,
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
