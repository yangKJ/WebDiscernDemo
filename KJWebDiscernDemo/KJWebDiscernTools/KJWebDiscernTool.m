//
//  KJWebDiscernTool.m
//  KJWebDiscernDemo
//
//  Created by 杨科军 on 2019/10/11.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "KJWebDiscernTool.h"

@interface KJWebDiscernTool ()<UIGestureRecognizerDelegate>//,WKNavigationDelegate>
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
//    self.saveWebView.navigationDelegate = self;
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
///// 用工厂方法如何return block里的值 - 同步处理
//- (UIImage*)kj_getWebImageWithTouchPoint:(CGPoint)touchPoint{
//    __block UIImage *image = NULL;
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_semaphore_t sem = dispatch_semaphore_create(0);//创建信号量初始值为0  0:表示无限等待
//    __weak typeof(self) weakself = self;
//    dispatch_group_async(dispatch_group_create(), queue, ^{
//        // 获取长按位置对应的图片url的JS代码
//        NSString *imgJS = [NSString stringWithFormat:@"document.elementFromPoint(%f,%f).src", touchPoint.x, touchPoint.y];
//        // 执行对应的JS代码 获取url
//        [weakself.saveWebView evaluateJavaScript:imgJS completionHandler:^(id _Nullable imgUrl, NSError * _Nullable error) {
//            if (imgUrl) {
//                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
//                image = [UIImage imageWithData:data];
//            }
//            dispatch_semaphore_signal(sem); //发送信号量 信号量+1
//        }];
//    });
//    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);//阻塞等待 信号量-1
//    return image;
//}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
//#pragma mark - WKNavigationDelegate
//// 页面加载完成之后调用
//- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
//    /// 禁止弹出菜单
//    [self.saveWebView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout = 'none';" completionHandler:nil];
//    // 禁止选中 - 禁止用户复制粘贴
//    [self.saveWebView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect = 'none';" completionHandler:nil];
//}

@end
