//
//  BaseViewController.m
//  Cartoon
//
//  Created by Max on 2021/5/7.
//

#import "BaseViewController.h"
#import "AppDelegate.h"
#import "ToastView.h"
#import "LoadingView.h"

#import <Masonry/Masonry.h>

@interface BaseViewController ()
@property (weak) ToastView *taostView;
@property (weak) LoadingView *loadingView;
@property (assign) CGRect fromRect;
@property (assign) UIView *fromView;
@end

@implementation BaseViewController
- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        NSLog(@"%@, %p", NSStringFromClass([self class]), self);
    }

    return self;
}

- (void)dealloc {
    NSLog(@"%@, %p", NSStringFromClass([self class]), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 处理暗黑模式
    [self updateTrait];
}

- (void)viewWillAppear:(BOOL)animated {
    if (!_viewDidAppearEver) {
        [UIView setAnimationsEnabled:YES];
    }
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    _viewDidAppearEver = YES;
    _viewIsAppear = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    _viewIsAppear = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)toast:(NSString *)msg {
    [self.taostView removeFromSuperview];

    self.taostView = [ToastView view];
    [self.view addSubview:self.taostView];

    self.taostView.msgLabel.text = msg;
    CGSize size = [self.taostView.msgLabel sizeThatFits:CGSizeZero];
    [self.taostView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.view).offset(20);
        make.right.lessThanOrEqualTo(self.view).offset(-20);
        make.center.equalTo(self.view);
    }];
    [self.taostView.msgLabel sizeToFit];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.taostView removeFromSuperview];
        self.taostView = nil;
    });
}

- (void)showLoading {
    [self.loadingView removeFromSuperview];
    self.loadingView = [LoadingView view];
    [self.view addSubview:self.loadingView];
    [self.loadingView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@100);
        make.height.equalTo(@100);
    }];
    self.view.userInteractionEnabled = NO;
}

- (void)hideLoading {
    [self.loadingView removeFromSuperview];
    self.view.userInteractionEnabled = YES;
}

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
