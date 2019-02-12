//
//  HangoutDialogViewController.m
//  livestream
//
//  Created by test on 2019/1/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "HangoutDialogViewController.h"
#import "LSUserInfoManager.h"
#import "LSGetHangoutFriendsRequest.h"
#import "LSShadowView.h"
#import "LSHangoutFriendCollectionViewCell.h"
#import "LiveUrlHandler.h"
#import "LiveModule.h"
#import "AnchorPersonalViewController.h"

@interface HangoutDialogViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) UIVisualEffectView *effectView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topDistance;
@property (weak, nonatomic) IBOutlet UIView *dismissSpaceView;
/** 好友数据 */
@property (weak, nonatomic) IBOutlet UILabel *inviteHangoutTips;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *friendViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *friendViewWidth;

/** 好友列表 */
@property (nonatomic, strong) NSArray<LSHangoutAnchorItemObject *> *friendArray;

@end

@implementation HangoutDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    self.item = [[LSHangoutListItemObject alloc] init];
    //    // Do any additional setup after loading the view from its nib.
    //    self.hangOutNowBtn.layer.cornerRadius = self.hangOutNowBtn.frame.size.height / 2;
    //    self.hangOutNowBtn.layer.masksToBounds = YES;
    //    self.bgView.layer.cornerRadius = 5;
    //    self.bgView.layer.masksToBounds = YES;
    //
    self.anchorImageView.layer.cornerRadius = self.anchorImageView.frame.size.width * 0.5;
    self.anchorImageView.layer.masksToBounds = YES;
    self.friendView.dataSource = self;
    self.friendView.delegate = self;
    
    UINib *nib = [UINib nibWithNibName:@"LSHangoutFriendCollectionViewCell" bundle:[LiveBundle mainBundle] ];
    [self.friendView registerNib:nib forCellWithReuseIdentifier:[LSHangoutFriendCollectionViewCell cellIdentifier]];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView)];
    self.dismissSpaceView.userInteractionEnabled = YES;
    [self.dismissSpaceView addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToHideView:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.dismissSpaceView addGestureRecognizer:swipe];
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.effectView.frame = self.bgImageView.bounds;
    [self.bgImageView addSubview:self.effectView];
    
    [self reloadPersonBaseMsg];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideView {
    [UIView animateWithDuration:0.3 animations:^{
        //        self.topDistance.constant = screenSize.height;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height);
        }];
    }];
}

- (void)swipeToHideView:(UISwipeGestureRecognizer *)swipe {
    [self hideView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

//- (void)reloadView {
//    [self getUserInfo];
//
//}


- (void)getUserInfo {
    [[LSUserInfoManager manager] getUserInfo:self.anchorId finishHandler:^(LSUserInfoModel * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.item.nickName = item.nickName;
            self.item.anchorId = self.anchorId;
            self.item.avatarImg = item.photoUrl;
            [self reloadPersonBaseMsg];
        });
    }];
}

- (void)reloadPersonBaseMsg {
    NSString *hangout = [NSString stringWithFormat:@"Hang-out with %@ and Her Friends",self.anchorName];
    NSMutableAttributedString *attrbuteStr = [[NSMutableAttributedString alloc] initWithString:hangout];
    NSRange nameRange = [hangout rangeOfString:self.anchorName];
    [attrbuteStr addAttributes:@{
                                 NSFontAttributeName : [UIFont systemFontOfSize:16],
                                 NSForegroundColorAttributeName : [UIColor orangeColor]
                                 } range:nameRange];
    self.anchorInviteTips.attributedText = attrbuteStr;
    
    self.anchorNameFriend.text = [NSString stringWithFormat:@"%@'s Friend",self.anchorName];
    self.inviteHangoutTips.text = [NSString stringWithFormat:@"Once you enter %@’s live video Hang-out room, you will see more information about her friends and be able to invite them to hang out together.",self.anchorName];
    
    LSImageViewLoader *loader =  [LSImageViewLoader loader];
    WeakObject(self, weakSelf);
    [loader sdWebImageLoadView:self.anchorImageView options:SDWebImageRefreshCached imageUrl:self.item.avatarImg placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                weakSelf.bgImageView.image = image;
            }
        });
    }];
    
}


- (void)reloadFriendView {
    
    //    // TODO:刷新推荐列表
    self.friendViewWidth.constant = [LSHangoutFriendCollectionViewCell cellWidth] * self.friendArray.count + ((self.friendArray.count - 1) * 20 + 10);
    //
    if (self.friendViewWidth.constant > screenSize.width * 0.9) {
        self.friendViewWidth.constant = screenSize.width * 0.9;
    }
    [self.friendView reloadData];
}

- (BOOL)getFriendList {
    LSSessionRequestManager *sessionManager = [LSSessionRequestManager manager];
    BOOL bflag = NO;
    LSGetHangoutFriendsRequest *request = [[LSGetHangoutFriendsRequest alloc] init];
    request.anchorId = self.item.anchorId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *anchorId, NSArray<LSHangoutAnchorItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.friendArray = array;
                [self reloadFriendView];
                
            }
        });
    };
    
    bflag = [sessionManager sendRequest:request];
    return bflag;
}



#pragma mark - 推荐逻辑
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.friendArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSHangoutFriendCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LSHangoutFriendCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    LSHangoutAnchorItemObject *item = [self.friendArray objectAtIndex:indexPath.row];
    cell.anchorName.text = item.nickName;
    if (item.onlineStatus == ONLINE_STATUS_LIVE) {
        cell.onlineWidth.constant = 10;
        cell.onlineView.hidden = NO;
    }else{
        cell.onlineWidth.constant = 0;
        cell.onlineView.hidden = YES;
    }
    cell.imageView.image = nil;
    [cell.imageViewLoader stop];
    [cell.imageViewLoader loadImageWithImageView:cell.imageView
                                         options:0
                                        imageUrl:item.photoUrl
                                placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LSHangoutAnchorItemObject *item = [self.friendArray objectAtIndex:indexPath.row];
    AnchorPersonalViewController *vc = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = item.anchorId;
//    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showhangoutView {
    [self getUserInfo];
    [self getFriendList];
    self.view.frame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height);
    [UIView animateWithDuration:0.3 animations:^{
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
        }];
    }];
}


@end
