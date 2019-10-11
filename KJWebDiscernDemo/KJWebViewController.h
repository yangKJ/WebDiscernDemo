//
//  KJWebViewController.h
//  KJWebDiscernDemo
//
//  Created by 杨科军 on 2019/10/11.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJWebViewController : UIViewController
@property (nonatomic,strong) NSString *url;
@property (nonatomic,readwrite,copy) void(^KJGetImageBlock)(UIImage *image);

@end

NS_ASSUME_NONNULL_END
