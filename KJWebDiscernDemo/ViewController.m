//
//  ViewController.m
//  KJWebDiscernDemo
//
//  Created by 杨科军 on 2019/10/11.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "ViewController.h"
#import "KJWebViewController.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
- (IBAction)thouch:(UIButton *)sender {
    KJWebViewController *vc = [KJWebViewController new];
    [self.navigationController pushViewController:vc animated:YES];
    __weak typeof(self) weakself = self;
    vc.KJGetImageBlock = ^(UIImage * _Nonnull image) {
        weakself.imageView.image = image;
    };
}


@end
