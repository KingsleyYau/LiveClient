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
        make.center.equalTo(self.view);
    }];
    [self.taostView.msgLabel sizeToFit];
//    [self.view layoutIfNeeded];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.taostView removeFromSuperview];
        self.taostView = nil;
    });
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
