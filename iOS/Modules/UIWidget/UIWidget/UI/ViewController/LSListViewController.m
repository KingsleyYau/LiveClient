//
//  ListViewController.m
//  UIWidget
//
//  Created by test on 2017/9/25.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "LSListViewController.h"
#import "LSUIWidgetBundle.h"

#define List_Reload @"Reload"
#define List_FailTips @"Failed to load"

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
        [self setupNavigationBar];
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
        imageView.frame = CGRectMake(0, 80, 80, 80);
        CGPoint imageVCenter = imageView.center;
        imageVCenter.x = iconCenter;
        imageView.center = imageVCenter;
        [self.failView addSubview:imageView];
        
        CGFloat failTipsY = CGRectGetMaxY(imageView.frame) + 24.0f;
        
        self.failTips = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 24)];
        CGPoint failTipsCenter = self.failTips.center;
        failTipsCenter.x = iconCenter;
        failTipsCenter.y = failTipsY;
        self.failTips.center = failTipsCenter;
        self.failTips.text = self.failTipsText;
        self.failTips.textAlignment = NSTextAlignmentCenter;
        self.failTips.textColor = [UIColor colorWithRed:194.0 / 255.0 green:194.0 / 255.0 blue:194.0 / 255.0 alpha:1];
        [self.failView addSubview:self.failTips];
        
        CGFloat failBtnY = CGRectGetMaxY(self.failTips.frame) + 44.0f;
        self.failBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 180, 36)];
        [self.failBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        CGPoint failBtnCenter = self.failBtn.center;
        failBtnCenter.x = iconCenter;
        failBtnCenter.y = failBtnY;
        self.failBtn.center = failBtnCenter;
        [self.failBtn setTitle:self.failBtnText forState:UIControlStateNormal];
        self.failBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.failBtn.layer.cornerRadius = 18.0f;
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

@end
