//
//  ListViewController.m
//  UIWidget
//
//  Created by test on 2017/9/25.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "LSListViewController.h"
#import "LSUIWidgetBundle.h"

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
        [self setupContainView];
          [self setupFailView];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewDidAppearEver = YES;
}


- (void)setupContainView {
    [super setupContainView];

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
        CGPoint failBtnCenter = self.failBtn.center;
        failBtnCenter.x = iconCenter;
        failBtnCenter.y = failBtnY;
        self.failBtn.center = failBtnCenter;
        [self.failBtn setTitle:self.failBtnText forState:UIControlStateNormal];
        self.failBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.failBtn.layer.cornerRadius = 8.0f;
        self.failBtn.layer.masksToBounds = YES;
        
        self.failBtn.backgroundColor = [UIColor colorWithRed:93.0 / 255.0 green:14.0 / 255.0 blue:134.0 / 255.0 alpha:1];
        
//        [self.failBtn addTarget:self action:self.delegateSelect forControlEvents:UIControlEventTouchUpInside];
           [self.failBtn addTarget:self.delegate action:@selector(btnActionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.failView addSubview:self.failBtn];
        
        
        [self.view addSubview:self.failView];
        self.failView.hidden = YES;
    }

}

- (void)btnActionClick:(UIButton *)sender {
//    NSLog(@"%s",__func__);
    if (self.delegate && [self.delegate respondsToSelector:@selector(lsListViewController:didClick:)]) {
        [self.delegate lsListViewController:self didClick:sender];
    }
}

- (void)reloadFailViewContent {
    self.failTips.text = self.failTipsText;
    [self.failBtn setTitle:self.failBtnText forState:UIControlStateNormal];

//    [self.failBtn removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
//    [self.failBtn addTarget:self action:self.delegateSelect forControlEvents:UIControlEventTouchUpInside];
}



@end
