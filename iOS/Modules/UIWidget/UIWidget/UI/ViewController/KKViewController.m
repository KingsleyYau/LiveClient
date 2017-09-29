//
//  KKViewController.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "UIColor+RGB.h"

@interface KKViewController ()
@property (assign) NSInteger loadingCount;
@end

@implementation KKViewController
- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        self.loadingCount = 0;
        [self initCustomParam];
    }
    
    return self;
}

- (void)dealloc {

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSString *nibNameOrNilReal = nibNameOrNil;
    
    BOOL bSupportiPad = NO;
    /*  应用是否支持iPad
     *  1:iPhone or iTouch
     *  2:iPad
     */
    NSArray *array = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIDeviceFamily"];
    for(NSNumber *deviceFamily in array) {
        if([deviceFamily integerValue] == 2) {
            bSupportiPad = YES;
            break;
        }
    }

    if(bSupportiPad) {
        // 应用支持iPad
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            // iPhone
        }
        else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // iPad
            if(nil == nibNameOrNil || nibNameOrNil.length == 0) {
                nibNameOrNil = NSStringFromClass([self class]);
            }
            nibNameOrNilReal = [NSString stringWithFormat:@"%@-iPad", nibNameOrNil];
        }
    }
    
    self = [super initWithNibName:nibNameOrNilReal bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initCustomParam];
       
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initCustomParam];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
        
}

- (void)viewWillAppear:(BOOL)animated {
    if( !self.viewDidAppearEver ) {
        [UIView setAnimationsEnabled:YES];
        [self setupNavigationBar];
        [self setupContainView];
        [self setupLoadingActivityView];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewDidAppearEver = YES;
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

- (void)setBackTitle:(NSString *)backTitle {
    UINavigationItem *item = self.navigationItem;
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:backTitle style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    item.backBarButtonItem = barButtonItem;
    
    item.backBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)setNavigationTitle:(NSString *)navigationTitle{
    
    self.title = navigationTitle;
}

- (void)initCustomParam {
    self.backTitle = NSLocalizedString(@"", nil);
}

- (void)setupNavigationBar {
    [self.navigationController.navigationBar setTitleTextAttributes:
  @{NSForegroundColorAttributeName : [UIColor whiteColor],
    NSFontAttributeName:[UIFont systemFontOfSize:19]}];
    
}

- (void)setupContainView {

}

- (void)setBackleftBarButtonItemOffset:(CGFloat)offset {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"nav_back_icon"] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, 40, 40);
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -offset, 0, 0)];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButtonItem;
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
    
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:loadActivityView];
//    [[UIApplication sharedApplication].keyWindow addSubview:loadActivityView];
}

- (void)showLoading {
    self.loadingCount++;
    self.loadActivityView.hidden = NO;
    self.view.userInteractionEnabled = NO;
}

- (void)hideLoading {
    self.loadingCount--;
    if( self.loadingCount <= 0 ) {
        self.loadActivityView.hidden = YES;
        self.view.userInteractionEnabled = YES;
    }
}

- (void)hideNavgationBarBottomLine {
    UIImageView* blackLineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    blackLineImageView.hidden = YES;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view
{
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0)
    {
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
-(void)hideAndResetLoading;
{
    self.loadingCount = 0;
    if( self.loadingCount <= 0 ) {
        self.loadActivityView.hidden = YES;
        self.view.userInteractionEnabled = YES;
    }

}


- (void)showAndResetLoading;
{
    self.loadingCount = 0;
    self.loadingCount++;
    self.loadActivityView.hidden = NO;
    self.view.userInteractionEnabled = NO;
}

@end
