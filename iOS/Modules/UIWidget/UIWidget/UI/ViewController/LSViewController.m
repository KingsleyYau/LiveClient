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

        self.loadingCount = 0;
        [self initCustomParam];
    }

    return self;
}

- (void)dealloc {
    NSLog(@"LSViewController::dealloc( %@, %p )", NSStringFromClass([self class]), self);
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
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"LSViewController::viewWillAppear( %@, %p, viewDidAppearEver : %@ )", NSStringFromClass([self class]), self, self.viewDidAppearEver?@"YES":@"NO");
    
    if (!_viewDidAppearEver) {
        [UIView setAnimationsEnabled:YES];
        [self setupNavigationBar];
        [self setupContainView];
        [self setupLoadingActivityView];
    }
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"LSViewController::viewDidAppear( %@, %p )", NSStringFromClass([self class]), self);
    _viewDidAppearEver = YES;
    _viewIsAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"LSViewController::viewWillDisappear( %@, %p )", NSStringFromClass([self class]), self);
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

- (void)initCustomParam {
    NSLog(@"LSViewController::initCustomParam( %@, %p )", NSStringFromClass([self class]), self);

    //self.backTitle = NSLocalizedString(@"", nil);
    //    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = backButtonItem;
}

- (void)setupNavigationBar {
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:19]}];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
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

- (void)hideNavgationBarBottomLine:(BOOL)isHide {
    UIImageView *blackLineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    blackLineImageView.hidden = isHide;
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

@end
