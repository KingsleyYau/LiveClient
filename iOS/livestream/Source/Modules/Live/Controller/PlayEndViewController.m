//
//  PlayEndViewController.m
//  livestream
//
//  Created by Max on 2017/5/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PlayEndViewController.h"

#import "FileCacheManager.h"

@interface PlayEndViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userHeadTopOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userHeadHight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *numberTopOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewerTopOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareTopOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareBtnTopOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followBtnTopOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followBtnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *liverImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *liverImageTopOffset;

@end

@implementation PlayEndViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
}

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageViewHeaderLoader = [ImageViewLoader loader];
    self.imageViewHeaderLoader.view = self.imageViewHeader;
    self.imageViewHeaderLoader.url = @"http://images3.charmdate.com/woman_photo/C841/174/C162683-d.jpg";
    self.imageViewHeaderLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:self.imageViewHeaderLoader.url];
    [self.imageViewHeaderLoader loadImage];
    
//    self.bottomMoreView.hidden = YES;
    
    UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *view = [[UIVisualEffectView alloc]initWithEffect:beffect];
    [self.liverCoverImageView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.liverCoverImageView);
    }];
    
    self.titleTopOffset.constant = DESGIN_TRANSFORM_3X(55);
    self.userHeadTopOffset.constant = DESGIN_TRANSFORM_3X(26);
    self.userHeadHight.constant = DESGIN_TRANSFORM_3X(85);
    self.numberTopOffset.constant = DESGIN_TRANSFORM_3X(30);
    self.viewerTopOffset.constant = 0;
    self.shareTopOffset.constant = DESGIN_TRANSFORM_3X(30);
    self.shareBtnTopOffset.constant = DESGIN_TRANSFORM_3X(12);
    self.followBtnTopOffset.constant = DESGIN_TRANSFORM_3X(16);
    self.liverImageWidth.constant = DESGIN_TRANSFORM_3X(46);
    self.followBtnWidth.constant = DESGIN_TRANSFORM_3X(170);
    self.followBtnHeight.constant = DESGIN_TRANSFORM_3X(40);
    self.liverImageTopOffset.constant = DESGIN_TRANSFORM_3X(15);
    
    self.imageViewHeader.layer.cornerRadius = DESGIN_TRANSFORM_3X(85/2);
    self.followBtn.layer.cornerRadius = DESGIN_TRANSFORM_3X(20);
    self.homepageBtn.layer.cornerRadius = DESGIN_TRANSFORM_3X(20);
    self.hotLiverImageView1.layer.cornerRadius = DESGIN_TRANSFORM_3X(23);
    self.hotLiverImageView2.layer.cornerRadius = DESGIN_TRANSFORM_3X(23);
    self.hotLiverImageView3.layer.cornerRadius = DESGIN_TRANSFORM_3X(23);
    self.imageViewHeader.layer.masksToBounds = YES;
    self.followBtn.layer.masksToBounds = YES;
    self.homepageBtn.layer.masksToBounds = YES;
    self.hotLiverImageView1.layer.masksToBounds = YES;
    self.hotLiverImageView2.layer.masksToBounds = YES;
    self.hotLiverImageView3.layer.masksToBounds = YES;
    
    self.titleLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(24)];
    self.liverNameLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(15)];
    self.viewverLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(27)];
    self.viewerCountLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(17)];
    self.shareTipLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(12)];
    self.moreLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(12)];
    self.hotLiverNameLabel1.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(12)];
    self.hotLiverNameLabel2.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(12)];
    self.hotLiverNameLabel3.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(12)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)setupContainView {
    [super setupContainView];
    
    // 初始化主播信息控件
    [self setupRoomView];
}

#pragma mark - 界面事件
- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}

// 关注主播
- (IBAction)followLiverAction:(id)sender {
    
    [self.followBtn setImage:[UIImage imageNamed:@"Liveend_isFollow_btn"] forState:UIControlStateNormal];
    [self.followBtn setBackgroundColor:[UIColor clearColor]];
    [self.followBtn setTitleColor:COLOR_WITH_16BAND_RGB(0xbfbfbf) forState:UIControlStateNormal];
}

- (IBAction)sharefaceBookAction:(id)sender {
}

- (IBAction)shareTwitterAction:(id)sender {

}

- (IBAction)shareInstagrmAction:(id)sender {
    
}
#pragma mark - 主播信息控件管理
- (void)setupRoomView {
    
}

@end
