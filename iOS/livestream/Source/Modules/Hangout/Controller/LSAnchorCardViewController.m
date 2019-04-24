//
//  LSAnchorCardViewController.m
//  livestream
//
//  Created by test on 2019/1/30.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSAnchorCardViewController.h"
#import "LSShadowView.h"
#import "LSImageViewLoader.h"
#import "LSUserInfoManager.h"
#import "LiveModule.h"
@interface LSAnchorCardViewController ()
@property (nonatomic, strong) LSImageViewLoader *loader;
@end

@implementation LSAnchorCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.contentView.layer.cornerRadius = 5;
    self.contentView.layer.masksToBounds = YES;

    self.bgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismiss:)];
    [self.bgView addGestureRecognizer:tap];

    self.loader = [LSImageViewLoader loader];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self dismissView];
}

- (void)tapToDismiss:(UITapGestureRecognizer *)gesture {
    [self dismissView];
}

- (void)dismissView {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)getFriendDetailMsg {
    [[LSUserInfoManager manager] getUserInfo:self.userId
                                     finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self loadUserData:item];
                                         });
                                     }];
}

- (void)showAnchorCardView:(UIViewController *)vc {
    [vc addChildViewController:self];
    [vc.view addSubview:self.view];
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(vc.view);
    }];
    //创建一个CABasicAnimation对象
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    self.contentView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    animation.fromValue = @0.5f;
    animation.toValue = @1.0f;
    animation.duration = 0.1;
    //把animation添加到图层的layer中
    [self.contentView.layer addAnimation:animation forKey:@"scale"];

    [self loadFriendItem];
}

- (void)loadFriendItem {
    LSUserInfoModel *userInfoItem = [[LSUserInfoModel alloc] init];
    userInfoItem.nickName = self.nickName;
    userInfoItem.userId = self.userId;
    [self loadUserData:userInfoItem];
    [self getFriendDetailMsg];
}

- (void)loadUserData:(LSUserInfoModel *)item {
    self.nameLabel.text = item.nickName;
    if (item.country.length > 0 && item.age > 0) {
        self.ageAndCountryLabel.text = [NSString stringWithFormat:@"%d Years old  • %@", item.age, item.country];
    } else {
        self.ageAndCountryLabel.text = @"-";
    }
    self.friendID.text = [NSString stringWithFormat:@"ID: %@", item.userId];
    [self.loader stop];
    [self.loader loadImageWithImageView:self.photoImageView options:0 imageUrl:item.photoUrl placeholderImage:nil finishHandler:nil];
}

@end
