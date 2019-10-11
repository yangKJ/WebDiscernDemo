# KJWebDiscernDemo
一款长按识别网页当中的图片工具  
<p align="left">
  <img width="200" src="Res/12.jpg" hspace="30px" />
  <img width="200" src="Res/13.jpg" hspace="30px" />
</p>

----------------------------------------
### 框架整体介绍
* [作者信息](#作者信息)
* [作者其他库](#作者其他库)
* [使用方法](#使用方法)

#### <a id="作者信息"></a>作者信息
> Github地址：https://github.com/yangKJ  
> 简书地址：https://www.jianshu.com/u/c84c00476ab6  
> 博客地址：https://blog.csdn.net/qq_34534179  

#### <a id="作者其他库"></a>作者其他Pod库
```
播放器 - KJPlayer是一款视频播放器，AVPlayer的封装，继承UIView
pod 'KJPlayer'  # 播放器功能区
pod 'KJPlayer/KJPlayerView'  # 自带展示界面

实用又方便的Category和一些自定义控件
pod 'KJEmitterView'
pod 'KJEmitterView/Function'#
pod 'KJEmitterView/Control' # 自定义控件

轮播图 - 支持缩放 多种pagecontrol 支持继承自定义样式 自带网络加载和缓存
pod 'KJBannerView'  # 轮播图，网络图片加载

菜单控件 - 下拉控件 选择控件
pod 'KJMenuView' # 菜单控件

加载Loading - 多种样式供选择
pod 'KJLoadingAnimation' # 加载控件

```

##### Issue
如果您在使用中有好的需求及建议，或者遇到什么bug，欢迎随时issue，我会及时的回复，有空也会不断优化更新这些库

#### <a id="使用方法"></a>使用方法
```
/// 回调获取长按识别的图片
+ (void)kj_initWithWKWebView:(WKWebView*)webView QRCodeImageBlock:(KJQRCodeImageBlock)block;

```
实现代码

```
//
//  KJWebDiscernTool.m
//  KJWebDiscernDemo
//
//  Created by 杨科军 on 2019/10/11.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "KJWebDiscernTool.h"

@interface KJWebDiscernTool ()<UIGestureRecognizerDelegate,WKNavigationDelegate>
@property(nonatomic,copy,class) KJQRCodeImageBlock xxblock; /// 类属性block
@property(nonatomic,strong) WKWebView *saveWebView;
@property(nonatomic,strong) UIImage *currentImage;

@end

@implementation KJWebDiscernTool
static KJQRCodeImageBlock _xxblock = nil;
static KJWebDiscernTool *kj_tool = nil;
+ (KJQRCodeImageBlock)xxblock{
    if (_xxblock == nil) {
        _xxblock = ^void(UIImage *image){ };
    }
    return _xxblock;
}
+ (void)setXxblock:(KJQRCodeImageBlock)xxblock{
    if (xxblock != _xxblock) {
        _xxblock = [xxblock copy];
    }
}

+ (void)kj_initWithWKWebView:(WKWebView*)webView QRCodeImageBlock:(KJQRCodeImageBlock)block{
    self.xxblock = block;
    @synchronized (self) {
        if (kj_tool == nil) {
            kj_tool = [[KJWebDiscernTool alloc]init];
        }
    }
    [kj_tool kj_configWithWKWebView:webView];
}

- (void)kj_configWithWKWebView:(WKWebView*)webView{
    self.saveWebView = webView;
    self.saveWebView.navigationDelegate = self;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1;
    longPress.delegate = self;
    [webView addGestureRecognizer:longPress];
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender{
    if (sender.state != UIGestureRecognizerStateBegan) return;
    CGPoint touchPoint = [sender locationInView:self.saveWebView];
//    UIImage *image = [self kj_getWebImageWithTouchPoint:touchPoint];
//    if (self.currentImage == nil || self.currentImage != image) {
//        self.currentImage = image;
//    }
//    _xxblock(self.currentImage);
    __weak typeof(self) weakself = self;
    // 获取长按位置对应的图片url的JS代码
    NSString *imgJS = [NSString stringWithFormat:@"document.elementFromPoint(%f,%f).src", touchPoint.x, touchPoint.y];
    // 执行对应的JS代码 获取url
    [self.saveWebView evaluateJavaScript:imgJS completionHandler:^(id _Nullable imgUrl, NSError * _Nullable error) {
        if (imgUrl) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
            weakself.currentImage = [UIImage imageWithData:data];
        }
        _xxblock(weakself.currentImage);
    }];
}

/// 用工厂方法如何return block里的值 - 同步处理
- (UIImage*)kj_getWebImageWithTouchPoint:(CGPoint)touchPoint{
    dispatch_semaphore_t signal = dispatch_semaphore_create(1);// 创建信号量
    __block UIImage *image = NULL;
    // 获取长按位置对应的图片url的JS代码
    NSString *imgJS = [NSString stringWithFormat:@"document.elementFromPoint(%f,%f).src", touchPoint.x, touchPoint.y];
    // 执行对应的JS代码 获取url
    [self.saveWebView evaluateJavaScript:imgJS completionHandler:^(id _Nullable imgUrl, NSError * _Nullable error) {
        if (imgUrl) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
            image = [UIImage imageWithData:data];
        }
        dispatch_semaphore_signal(signal);// 发送信号量
    }];
    dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);// 等待信号量
    return image;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
#pragma mark - WKNavigationDelegate
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    /// 禁止弹出菜单
    [self.saveWebView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout = 'none';" completionHandler:nil];
    // 禁止选中 - 禁止用户复制粘贴
    [self.saveWebView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect = 'none';" completionHandler:nil];
}

@end

```

