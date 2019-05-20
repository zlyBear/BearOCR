## iOS利用OpenCV 实现文字行区域提取的尝试

最近下了几个OCR的App（比如白描），发现可以选中图片中的文字行逐行转成文字，觉得很有意思(当然想用要花钱啦)，想着自己研究一下实现原理，google之后，发现了两个库，一个是OpenCV，在机器视觉方面应用广泛，图像分析必备利器。另一个是Tesseract，谷歌开源的文字识别框架，iOS端gali8编译了一个**Tesseract-OCR-iOS**的库可以使用，但是集成过程不是很愉快，**Tesseract-OCR-iOS**使用的Tesseract 3.3版本，而Tesseract已经更新到4.0，所以字库不匹配问题搞的很烦，而且利用官方提供的训练字库识别效果很差，想要实现高准确率的识别效果需要自行进行字库训练，相当繁琐，并且工作量巨大，在完成demo之后就放弃使用了。接着，我又Google了一番，得到的答案是ABBYY是业界中文OCR识别效果最好的，其次是百度，于是我又点开了白描，在关于页里看到了这个![image-20190515152454081](/Users/zly/Library/Application Support/typora-user-images/image-20190515152454081.png)

额，好吧，那我就研究下他是如何把选中的文字和百度OCR的结果进行对应的，等等，让我先抓个包看看。

![](http://lyz0818.5166.info//img/20190515153506.png?markdown)

这是…坐标？百度666，好像没啥好研究的了，不过出于好奇还是想知道使用openCV是如何做到把文字区域进行框选的，所以接下来我们就看看如何在iOS上使用OpenCV实现图片中的文字框选。

首先，需要去[OpenCV官网](https://opencv.org/releases/)下载iOS的framework，下载好后拖入新建的工程中即可，由于OpenCV库是使用C++编写，所以swift无法直接使用，需要使用OC做桥接，需要使用swift的同学可以看下这篇文章[Using OpenCV in an iOS app](https://www.timpoulsen.com/2019/using-opencv-in-an-ios-app.html)。

根据[OpenCV入门笔记（七） 文字区域的提取](https://blog.csdn.net/huobanjishijian/article/details/63685503)中提供的思路，我实现了OC版本的代码，通过测试，清晰的文字截图识别没有问题，但是在复杂的拍照场景中几乎无法识别任何内容，例如下图

![](http://lyz0818.5166.info//img/20190517104042.png?markdown)

这张是相机拍摄的屏幕上的文字，有清晰的竖纹及屏幕反光，在该算法下，最终的框选区域是整个图片，无法识别文字区域，说明这个处理流程还是不完善的，我们先来看一下他的处理过程：

1. 将图片转为灰度图
2. 形态学变换的预处理，得到可以查找矩形的图片
3. 查找和筛选文字区域
4. 用绿线画出这些找到的轮廓

根据前面得到的识别结果，我们大致可以猜测问题出在了第二步，由于竖纹影响将全部文字区域连城一片，导致整图被框选。那么在第二步中都做了哪些操作呢？

![](http://lyz0818.5166.info//img/20190517111832.png?markdown)

实际上上面的流程一共做了4步操作，二值化->膨胀->腐蚀->再膨胀，这个流程对于正常的白底文本截图的识别没有问题，一但图片中出现了噪点，噪点在第一次膨胀的之后被放大，对整个图像产生不可逆的污染，我们先来看一下二值化后的图像

![](http://lyz0818.5166.info//img/20190517141916.png?markdown)

文字还是很清晰的，但是竖纹一样明显，接着第二步膨胀，看下会怎样

![](http://lyz0818.5166.info//img/20190517142017.png?markdown)

一片白，不用往下看了吧。

既然如此，就需要我们修改一下在第二步的处理流程了，在反转图像（由黑白变为白黑）之前，需要对图像进行降噪处理，因为OpenCV是对亮点进行操作，在黑白图像中降噪更容易处理(去除杂乱黑点)，降噪使用的方法仍然是上面的膨胀和腐蚀法

```c++
//第一次二值化,转为黑白图片
cv::Mat binary;  			    
cv::adaptiveThreshold(gray,binary,255,cv::ADAPTIVE_THRESH_GAUSSIAN_C,cv::THRESH_BINARY,31,10);

//在第二次二值化之前 为了去除噪点 做了两次膨胀腐蚀

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

```

看一下经过两次降噪之后的图像是怎么样的

![](http://lyz0818.5166.info//img/20190517144346.png?markdown)

竖纹基本上不见了，仍然还有一部分黑点，但是已经不影响后面的识别了，这里降噪只能适度，过度处理可能会使文字部分丢失。

![](http://lyz0818.5166.info//img/20190517144821.png?markdown)

做完二值化反转之后是上面这个样子的，接下来再对图片做膨胀->腐蚀->膨胀处理

```
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
```

处理的结果图如下：

![](http://lyz0818.5166.info//img/20190517145242.png?markdown)

最终的框选效果

![](http://lyz0818.5166.info//img/20190517150141.png?markdown)

当然调试过程中不止用了这一张图片，毕竟结果要有一定的普适性，下面是其他几种情况下的识别结果

![](http://lyz0818.5166.info//img/20190517150639.png?markdown)

![](http://lyz0818.5166.info//img/20190517151327.png?markdown)

![](http://lyz0818.5166.info//img/20190517150921.png?markdown)

好了，下面贴一下整个过程的源码

```objective-c
+ (UIImage *)detect:(UIImage *) image {
    
    cv::Mat img;
    img = [self cvMatFromUIImage:image];
    
    //1.转化成灰度图
    cv::Mat gray;
    cvtColor(bigImg, gray, cv::COLOR_BGR2GRAY);
    
    //2.形态学变换的预处理,得到可以查找矩形的轮廓
    cv::Mat dilation = [self preprocess:gray];
    
    //3.查找和筛选文字区域
    std::vector<cv::RotatedRect> rects = [self findTextRegion:dilation];
    
    //4.用线画出这些找到的轮廓
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

+ (cv::Mat) preprocess:(cv::Mat)gray {
    
    //第一次二值化,转为黑白图片
    cv::Mat binary; 				  
    cv::adaptiveThreshold(gray, binary, 255,cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 31, 10);
    
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
    cv::adaptiveThreshold(erode12, binary2, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY_INV, 17, 10);
    
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
```

这里还有几个cv::Mat 与 UIImage相互转换的方法一并提供

```objective-c
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

```

###结语

调试是一个反复修改流程、修改参数的过程，至于为什么是这样的流程和参数都是不断尝试之后，通过主观感受得到的结果，有兴趣的小伙伴可以自己修改下参数看看效果，如果有更好的方案欢迎你来和我交流探讨，还有如果真的要运用到项目中，这个方案还是不完善的，比如黑底白字就没办法识别，所以还需要加入逻辑判断，进行不同的处理。最后附上[demo地址](https://github.com/zlyBear/BearOCR)，由于openCV框架很大，需要自行下载加入工程，pod文件也没有上传，请自行pod install，最后...欢迎Star。
