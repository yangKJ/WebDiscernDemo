//
//  KJWebDiscernTool.h
//  KJWebDiscernDemo
//
//  Created by 杨科军 on 2019/10/11.
//  Copyright © 2019 杨科军. All rights reserved.
//  长按识别web当中的二维码工具 - 获取网页图片

/*
 - (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
     // 不执行前段界面弹出列表的JS代码
     [self.webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
 }
 */

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^KJQRCodeImageBlock)(UIImage *image);
@interface KJWebDiscernTool : NSObject
/// 回调获取长按识别的图片
+ (void)kj_initWithWKWebView:(WKWebView*)webView QRCodeImageBlock:(KJQRCodeImageBlock)block;
@end

NS_ASSUME_NONNULL_END
