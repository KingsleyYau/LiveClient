//
//  LSViewController.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSViewController.h"
#import "LSUIWidgetBundle.h"

@interface LSViewController ()
@property (assign) NSInteger loadingCount;
@end

@implementation LSViewController
- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        NSLog(@"LSViewController::init( %@, %p )", NSStringFromClass([self class]), self);

        [self initCustomParam];
    }

    return self;
}

- (void)dealloc {
    NSLog(@"LSViewController::dealloc( %@, %p )", NSStringFromClass([self class]), self);
}

- (void)initCustomParam {
    NSLog(@"LSViewController::initCustomParam( %@, %p )", NSStringFromClass([self class]), self);
    
    self.loadingCount = 0;
    self.isShowNavBar = YES;
    self.isHideNavBackButton = YES;
    self.isHideNavBottomLine = NO;
    self.canPopWithGesture = YES;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = backButtonItem;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSString *nibNameOrNilReal = nibNameOrNil;
    NSBundle *bundle = nibBundleOrNil ? nibBundleOrNil : [LSUIWidgetBundle mainBundle];

    BOOL bSupportiPad = NO;
    /*  应用是否支持iPad
     *  1:iPhone or iTouch
     *  2:iPad
     */
    NSArray *array = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIDeviceFamily"];
    for (NSNumber *deviceFamily in array) {
        if ([deviceFamily integerValue] == 2) {
            bSupportiPad = YES;
            break;
        }
    }

    // iPhone
    if (nil == nibNameOrNil || nibNameOrNil.length == 0) {
        nibNameOrNil = NSStringFromClass([self class]);
    }
    nibNameOrNilReal = [NSString stringWithFormat:@"%@", nibNameOrNil];

    if (bSupportiPad) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // iPad
            nibNameOrNilReal = [NSString stringWithFormat:@"%@-iPad", nibNameOrNil];
        }
    }

    NSLog(@"LSViewController::initWithNibName( %@, %p, nibNameOrNilReal : %@ )", NSStringFromClass([self class]), self, nibNameOrNilReal);

    self = [super initWithNibName:nibNameOrNilReal bundle:bundle];
    if (self) {
        // Custom initialization
        [self initCustomParam];
    }

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    NSLog(@"LSViewController::awakeFromNib( %@, %p )", NSStringFromClass([self class]), self);
    [self initCustomParam];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"LSViewController::viewDidLoad( %@, %p )", NSStringFromClass([self class]), self);
    [self setNeedsStatusBarAppearanceUpdate];
    [self setupLoadingActivityView];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"LSViewController::viewWillAppear( %@, %p, viewDidAppearEver : %@ )", NSStringFromClass([self class]), self, self.viewDidAppearEver ? @"YES" : @"NO");
    if (!_viewDidAppearEver) {
        [UIView setAnimationsEnabled:YES];
        [self setupNavigationBar];
        [self setupContainView];
        
        self.navigationController.navigationBar.hidden = NO;
        self.navigationController.navigationBar.translucent = YES;
        self.edgesForExtendedLayout = UIRectEdgeAll;
        
        if (self.isShowNavBar) {
            [self showNavigationBar];
        } else {
            [self hideNavigationBar];
        }
    }

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSLog(@"LSViewController::viewDidAppear( %@, %p )", NSStringFromClass([self class]), self);

    if (_viewDidAppearEver) {
        [self reflashNavigationBar];
    }
    
    if (self.isShowNavBar) {
        [self showNavigationBar];
    } else {
        [self hideNavigationBar];
    }

    _viewDidAppearEver = YES;
    _viewIsAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    NSLog(@"LSViewController::viewWillDisappear( %@, %p )", NSStringFromClass([self class]), self);

    // 还原导航栏可显示, 但是可能是透明
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    NSLog(@"LSViewController::viewDidDisappear( %@, %p )", NSStringFromClass([self class]), self);
    _viewIsAppear = NO;
    [self hideLoading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - 横屏切换
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    //return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark － 界面布局
- (NSString *)backTitle {
    return self.navigationItem.backBarButtonItem.title;
}

- (void)setNavigationTitle:(NSString *)navigationTitle {
    self.title = navigationTitle;
}

- (void)setupNavigationBar {
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:19]}];
}

- (void)setupContainView {
}

- (void)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupLoadingActivityView {
    UIView *loadActivityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [self.view addSubview:loadActivityView];

    loadActivityView.layer.cornerRadius = 5.0f;
    loadActivityView.layer.masksToBounds = YES;
    loadActivityView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];

    UIActivityIndicatorView *loadingActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [loadActivityView addSubview:loadingActivity];

    CGFloat centerX = [UIScreen mainScreen].bounds.size.width * 0.5f;
    CGFloat centerY = [UIScreen mainScreen].bounds.size.height * 0.5f;
    loadActivityView.center = CGPointMake(centerX, centerY);

    self.loadActivityView = loadActivityView;
    self.loadActivityView.hidden = YES;

    loadingActivity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [loadingActivity startAnimating];

    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:loadActivityView];
    //    [[UIApplication sharedApplication].keyWindow addSubview:loadActivityView];
}

- (void)showLoading {
    self.loadingCount++;
    self.loadActivityView.hidden = NO;
    self.view.userInteractionEnabled = NO;
}

- (void)hideLoading {
    self.loadingCount--;
    if (self.loadingCount <= 0) {
        self.loadActivityView.hidden = YES;
        self.view.userInteractionEnabled = YES;
    }
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

/**
 *  重设和隐藏加载状态
 */
- (void)hideAndResetLoading {
    self.loadActivityView.hidden = YES;
    self.view.userInteractionEnabled = YES;
    self.loadingCount = 0;
}

- (void)showAndResetLoading {
    self.loadingCount = 0;
    self.loadingCount++;
    self.loadActivityView.hidden = NO;
    self.view.userInteractionEnabled = NO;
}

#pragma mark - 隐藏iPhoneX主按键
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

#pragma mark - 导航栏处理
- (void)showNavigationBar {
    NSLog(@"LSViewController::showNavigationBar( %@, %p )", NSStringFromClass([self class]), self);
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setNavigationBackgroundAlpha:1];
    [self setNavgationBarBottomLineHidden:self.isHideNavBottomLine];
    [self setNavigationBackButtonHidden:NO];
}

- (void)hideNavigationBar {
    NSLog(@"LSViewController::hideNavigationBar( %@, %p )", NSStringFromClass([self class]), self);
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    [self setNavigationBackgroundAlpha:0];
    [self setNavgationBarBottomLineHidden:YES];
    [self setNavigationBackButtonHidden:self.isHideNavBackButton];
}

- (void)setNavigationBackButtonHidden:(BOOL)isHide {
    self.navigationItem.hidesBackButton = isHide;
}

- (void)setNavgationBarBottomLineHidden:(BOOL)isHide {
    UIImageView *blackLineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    blackLineImageView.hidden = isHide;
}

- (void)setNavigationBackgroundAlpha:(CGFloat)alpha {
    // 导航栏背景透明度设置
    [self.navigationController.navigationBar layoutIfNeeded];

    NSArray *views = [self.navigationController.navigationBar subviews];
    if (views.count > 0) {
        UIView *barBackgroundView = [views objectAtIndex:0];
        UIImageView *backgroundImageView = [[barBackgroundView subviews] objectAtIndex:0];
        BOOL result = self.navigationController.navigationBar.isTranslucent;
        if (result) {
            if (backgroundImageView != nil && backgroundImageView.image != nil) {
                barBackgroundView.alpha = alpha;
            } else {
                NSArray *subViews = [barBackgroundView subviews];
                if (subViews.count > 1) {
                    UIView *backgroundEffectView = [subViews objectAtIndex:1];
                    if (backgroundEffectView != nil) {
                        backgroundEffectView.alpha = alpha;
                    }
                } else {
                    barBackgroundView.alpha = alpha;
                }
            }
        } else {
            barBackgroundView.alpha = alpha;
        }
    }
}

- (void)reflashNavigationBar {
    NSLog(@"LSViewController::reflashNavigationBar( %@, %p )", NSStringFromClass([self class]), self);
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - 导航跳转处理
- (NSString *)identification {
    NSString *identification = [NSString stringWithFormat:@"%p", self];
    return identification;
}

- (BOOL)isSameVC:(LSViewController *)vc {
    BOOL bFlag = NO;
    if ( [[self identification] isEqualToString:[vc identification]] ) {
        bFlag = YES;
    }
    return bFlag;
}

@end
