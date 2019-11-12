//
//  ListViewController.m
//  UIWidget
//
//  Created by test on 2017/9/25.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "LSListViewController.h"
#import "LSUIWidgetBundle.h"

#define List_Reload @"Retry"
#define List_FailTips @"Fail to load this page. Please try again later."


@interface LSListViewController()
@end

@implementation LSListViewController


- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        [self initCustomParam];
    }

    return self;
}

- (void)dealloc {
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initCustomParam {
    [super initCustomParam];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if( !self.viewDidAppearEver ) {
        [UIView setAnimationsEnabled:YES];
        [self setupFailView];
        // 失败页默认提示
        [self reloadFailViewFailTipsText:List_FailTips failBtnText:List_Reload];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)setupFailView {
    self.failView.userInteractionEnabled = YES;
    if (!self.failView) {
         self.failView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.failView.backgroundColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1];
        NSString *imgStr = [[[LSUIWidgetBundle resourceBundle] bundlePath] stringByAppendingPathComponent:@"Fail.png"];
        UIImage *image = [UIImage imageNamed:imgStr];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        CGFloat iconCenter = CGRectGetMidX([UIScreen mainScreen].bounds);
        CGFloat originY = 173;
        if ([UIScreen mainScreen].bounds.size.width == 320) {
            originY = 120;
        }
        imageView.frame = CGRectMake(0, originY, 98, 98);
        CGPoint imageVCenter = imageView.center;
        imageVCenter.x = iconCenter;
        imageView.center = imageVCenter;
        self.failIcon = imageView;
        [self.failView addSubview:imageView];
        
        CGFloat failTipsY = CGRectGetMaxY(imageView.frame) + 20.0f;
        
        self.failTips = [[UILabel alloc] initWithFrame:CGRectMake(0, failTipsY, 312, 24)];
        CGPoint failTipsCenter = self.failTips.center;
        failTipsCenter.x = iconCenter;
        self.failTips.center = failTipsCenter;
        self.failTips.text = List_FailTips;
        self.failTips.textAlignment = NSTextAlignmentCenter;
        self.failTips.font = [UIFont systemFontOfSize:15];
        self.failTips.textColor = [UIColor colorWithRed:153.0 / 255.0 green:153.0 / 255.0 blue:153.0 / 255.0 alpha:1];
        [self.failView addSubview:self.failTips];
    
        CGFloat failBtnY = failTipsY + self.failTips.frame.size.height + 30.0f;

        self.failBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.failBtn setFrame:CGRectMake(0, failBtnY, 200, 44)];
        [self.failBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        CGPoint failBtnCenter = self.failBtn.center;
        failBtnCenter.x = iconCenter;
        self.failBtn.center = failBtnCenter;
        [self.failBtn setTitle:List_Reload forState:UIControlStateNormal];
        self.failBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.failBtn.layer.cornerRadius = 6.0f;
        self.failBtn.layer.masksToBounds = YES;
        
        self.failBtn.backgroundColor = [UIColor colorWithRed:41.0 / 255.0 green:122.0 / 255.0 blue:243.0 / 255.0 alpha:1];
        
        [self.failBtn addTarget:self.listDelegate action:@selector(btnActionClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.failView addSubview:self.failBtn];
    

        [self.view addSubview:self.failView];
        self.failView.hidden = YES;
    }

}

- (void)btnActionClick:(UIButton *)sender {
//    NSLog(@"%s",__func__);
    if (self.listDelegate && [self.listDelegate respondsToSelector:@selector(lsListViewController:didClick:)]) {
        [self.listDelegate lsListViewController:self didClick:sender];
    }
    
    [self lsListViewControllerDidClick:sender];
}

- (void)lsListViewControllerDidClick:(UIButton *)sender
{
    
}

- (void)reloadFailViewFailTipsText:(NSString *)failTipsText failBtnText:(NSString *)failBtnText {
    self.failTips.text = failTipsText;
    [self.failBtn setTitle:failBtnText forState:UIControlStateNormal];
}

- (void)viewDidAppearGetList:(BOOL)isSwitchSite {
    
}

- (void)setupLoadData:(BOOL)isLoadData {
    
}

- (void)setupFirstLogin:(BOOL)isFirstLogin {
    
}

- (void)reloadUnreadNum {
    
}


- (void)showNoDataView {

    NSString *imgStr = [[[LSUIWidgetBundle resourceBundle] bundlePath] stringByAppendingPathComponent:@"NoDataIcon.png"];
    UIImage *image = [UIImage imageNamed:imgStr];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGFloat iconCenter = CGRectGetMidX([UIScreen mainScreen].bounds);
    imageView.frame = CGRectMake(0, 173, 98, 98);
    CGPoint imageVCenter = imageView.center;
    imageVCenter.x = iconCenter;
    imageView.center = imageVCenter;
    self.noDataIcon = imageView;
    [self.view addSubview:imageView];
    
    CGFloat failTipsY = CGRectGetMaxY(imageView.frame) + 20.0f;
    
    self.noDataTip = [[UILabel alloc] initWithFrame:CGRectMake(0, failTipsY, 312, 24)];
    CGPoint failTipsCenter = self.noDataTip.center;
    failTipsCenter.x = iconCenter;
    self.noDataTip.center = failTipsCenter;
    self.noDataTip.textAlignment = NSTextAlignmentCenter;
    self.failTips.font = [UIFont systemFontOfSize:16];
    self.noDataTip.textColor = [UIColor colorWithRed:153.0 / 255.0 green:153.0 / 255.0 blue:153.0 / 255.0 alpha:1];
    [self.failTips sizeToFit];
    [self.view addSubview:self.noDataTip];
    
}


- (void)hideNoDataView {
    [self.noDataIcon removeFromSuperview];
    [self.noDataTip removeFromSuperview];
    
}
@end
