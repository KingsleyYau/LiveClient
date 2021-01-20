//
//  StreamBaseViewController.m
//  RtmpClientTest
//
//  Created by Max on 2020/10/26.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "StreamBaseViewController.h"
#import "StreamToastView.h"

#import <Masonry/Masonry.h>

@interface StreamBaseViewController ()
@property (weak) StreamToastView *taostView;
@property (assign) CGRect fromRect;
@property (assign) UIView *fromView;
@end

@implementation StreamBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 处理暗黑模式
    [self updateTrait];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)isDarkStyle {
    BOOL bFlag = NO;
    if (@available(iOS 12.0, *)) {
        BOOL isDark = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
        bFlag = isDark;
    } else {
        // Fallback on earlier versions
    }
    return bFlag;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self updateTrait];
}

- (void)updateTrait {
    BOOL isDark = [self isDarkStyle];
    if (isDark) {
        self.view.backgroundColor = [UIColor blackColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

- (void)toast:(NSString *)msg {
    [self.taostView removeFromSuperview];

    self.taostView = [StreamToastView view];
    [self.view addSubview:self.taostView];

    self.taostView.msgLabel.text = msg;
    CGSize size = [self.taostView.msgLabel sizeThatFits:CGSizeZero];
    [self.taostView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.center.equalTo(self.view);
    }];
    [self.taostView.msgLabel sizeToFit];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.taostView removeFromSuperview];
        self.taostView = nil;
    });
}

#pragma mark - 全屏图片预览
- (void)showImage:(UIImage *)image fromView:(UIView *)fromView {
    // Convert to window
    CGRect fromRect = [fromView convertRect:fromView.bounds toView:nil];
    self.fromRect = fromRect;
    // 全屏幕图片
    UIView *container = [UIApplication sharedApplication].delegate.window;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:fromRect];
    imageView.backgroundColor = [UIColor blackColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    imageView.image = image;
    [container addSubview:imageView];

    // TODO:手势 - 单击收起全屏
    UITapGestureRecognizer *tapSingleGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSingleGuestureAction:)];
    tapSingleGuesture.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:tapSingleGuesture];

    self.fromView = fromView;
    self.fromView.hidden = YES;
    NSTimeInterval duration = 0.18;
    [UIView animateWithDuration:duration
                     animations:^{
                         // Make all constraint changes here, Called on parent view
                         imageView.frame = container.frame;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)tapSingleGuestureAction:(UITapGestureRecognizer *)sender {
    UIImageView *imageView = (UIImageView *)sender.view;

    NSTimeInterval duration = 0.18;
    imageView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:duration
        animations:^{
            // Make all constraint changes here, Called on parent view
            imageView.frame = self.fromRect;
        }
        completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            self.fromView.hidden = NO;
            self.fromView = nil;
        }];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
