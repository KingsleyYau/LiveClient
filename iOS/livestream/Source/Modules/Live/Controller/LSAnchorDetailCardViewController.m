//
//  LSAnchorDetailCardViewController.m
//  livestream
//
//  Created by test on 2019/6/6.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSAnchorDetailCardViewController.h"
#import "LSLoginManager.h"
#import "HangoutDialogViewController.h"
#import "LiveGobalManager.h"
#import "LSShadowView.h"
#import "LiveUrlHandler.h"
#import "SetFavoriteRequest.h"
#import "HomeVouchersManager.h"
#import "LSUserInfoManager.h"
#import "LiveGobalManager.h"
@interface LSAnchorDetailCardViewController ()
@property (strong,nonatomic) LSSessionRequestManager *sessionManager;

@end

@implementation LSAnchorDetailCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.contentView.layer.cornerRadius = 7;
    self.contentView.layer.masksToBounds = YES;
    
//    self.bgView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismiss:)];
//    [self.bgView addGestureRecognizer:tap];
    
    self.loader = [LSImageViewLoader loader];
    
    self.sessionManager = [LSSessionRequestManager manager];
    
    self.anchorIcon.adjustsImageWhenHighlighted = NO;
    self.anchorName.adjustsImageWhenHighlighted = NO;
    
    
}

- (void)initCustomParam {
    [super initCustomParam];
    self.isShowNavBar = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self dismissView];
    [self hideNavigationBar];
}

//- (void)tapToDismiss:(UITapGestureRecognizer *)gesture {
//
//    [self dismissView];
//}

- (void)dismissView {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [[LiveGobalManager manager] removeLiveRoomPopup];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)loadAchorDetail:(UIViewController *)vc {
    [[LiveGobalManager manager] showPopupView:self.view withVc:self];
    [vc addChildViewController:self];
    [vc.view addSubview:self.view];
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(vc.view);
    }];
    [self.anchorName setTitle:self.item.userName forState:UIControlStateNormal];
    
    self.anchorIcon.layer.cornerRadius = self.anchorIcon.frame.size.height * 0.5f;
    self.anchorIcon.layer.masksToBounds = YES;
    
    self.anchorIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    self.anchorIcon.layer.borderWidth = 1.0f;

    self.anchorDetail.text = @"";
    
    self.anchorProfile.text = [NSString stringWithFormat:@"ID: %@",self.item.userId];
    
    [self.loader loadImageFromCache:self.anchorHeadImage options:SDWebImageRefreshCached imageUrl:self.item.photoUrl placeholderImage:[UIImage imageNamed:@""] finishHandler:nil];
    
    if (self.item.imLiveRoom.favorite) {
        self.favouriteBtn.selected = YES;
        [self.favouriteBtn setImage:[UIImage imageNamed:@"LS_Home_Follow"] forState:UIControlStateNormal];
    }else {
        self.favouriteBtn.selected = NO;
        [self.favouriteBtn setImage:[UIImage imageNamed:@"LS_Home_Unfollow"] forState:UIControlStateNormal];
    }

    [self getDetailMsg];
}

- (void)getDetailMsg {
    [[LSUserInfoManager manager] getUserInfo:self.item.userId
                               finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       NSString *anchorDetail = [item.anchorInfo.introduction stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
                                       anchorDetail = [anchorDetail stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                                       self.anchorDetail.text = anchorDetail;

                                   });
                               }];
}


- (IBAction)favouriteAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self setAddFavorite:sender.selected];
}

- (void)setAddFavorite:(BOOL)isAddFavorite {
    __block BOOL favoriteResult = isAddFavorite;
    SetFavoriteRequest *request = [[SetFavoriteRequest alloc] init];
    request.userId = self.item.userId;
    request.roomId = self.item.roomId;
    request.isFav = favoriteResult;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSAnchorDetailCardViewController::followLiverAction( success : %d, errnum : %ld, errmsg : %@ )", success, (long)errnum, errmsg);
            if (success) {
                if ([self.anchorDetailDelegate respondsToSelector:@selector(lsAnchorDetailCardViewController:didAddFavorite:)]) {
                    [self.anchorDetailDelegate lsAnchorDetailCardViewController:self didAddFavorite:favoriteResult];
                }
                if (favoriteResult) {
                    [self.favouriteBtn setImage:[UIImage imageNamed:@"LS_Home_Follow"] forState:UIControlStateNormal];
                    
                }else {
                    [self.favouriteBtn setImage:[UIImage imageNamed:@"LS_Home_Unfollow"] forState:UIControlStateNormal];

                }
            } else {
                
            }
            
        });
    };
    [self.sessionManager sendRequest:request];
}



- (IBAction)chatAction:(id)sender {
    [self dismissView];
    
    NSURL *url = [[LiveUrlHandler shareInstance] createLiveChatByanchorId:self.item.userId anchorName:self.item.userName];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}
- (IBAction)mailAction:(id)sender {
    [self dismissView];
    NSURL *url = [[LiveUrlHandler shareInstance] createSendmailByanchorId:self.item.userId anchorName:self.item.userName emfiId:@""];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}
- (IBAction)closeAction:(id)sender {
    [self dismissView];
}
- (IBAction)anchorIconAction:(id)sender {
    [self dismissView];
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToAnchorDetail:self.item.userId];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}

@end
