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
#import "LSGetUserInfoRequest.h"
#import "LiveModule.h"
@interface LSAnchorCardViewController ()

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapToDismiss:(UITapGestureRecognizer *)gesture {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}


- (BOOL)getFriendDetailMsg {
    BOOL bFlag = NO;
    LSSessionRequestManager *requestManager = [LSSessionRequestManager manager];
    LSGetUserInfoRequest *request = [[LSGetUserInfoRequest alloc] init];
    request.userId = self.userId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSUserInfoItemObject *userInfoItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSAnchorCardViewController::getFriendDetailMsg( [获取好友详情信息],success : %@ errmsg : %@)",BOOL2YES(success), errmsg);
            if (success) {
                [self loadUserData:userInfoItem];
            }
            
        });
    };
    bFlag = [requestManager sendRequest:request];
    return bFlag;
}


- (void)showAnchorCardView {
    UIViewController *topVc = [LiveModule module].moduleVC.navigationController;
    [topVc addChildViewController:self];
    [topVc.view addSubview:self.view];
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(topVc.view);
    }];
    
    
    [self loadFriendItem];
}


- (void)loadFriendItem {
    LSUserInfoItemObject *userInfoItem = [[LSUserInfoItemObject alloc] init];
    userInfoItem.nickName = self.nickName;
    userInfoItem.userId = self.userId;
    [self loadUserData:userInfoItem];
    [self getFriendDetailMsg];
}

- (void)loadUserData:(LSUserInfoItemObject *)item {
    self.nameLabel.text = item.nickName;
    if (item.country.length > 0 && item.age > 0) {
        self.ageAndCountryLabel.text = [NSString stringWithFormat:@"%d Years old  • %@",item.age,item.country];
    }else {
        self.ageAndCountryLabel.text = @"-";
    }
    self.friendID.text = [NSString stringWithFormat:@"ID: %@",item.userId];
    LSImageViewLoader *loader = [LSImageViewLoader loader];
    [loader loadImageWithImageView:self.photoImageView options:0 imageUrl:item.photoUrl placeholderImage:nil];
}

@end
