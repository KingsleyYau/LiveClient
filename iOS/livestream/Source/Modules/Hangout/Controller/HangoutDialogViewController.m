//
//  HangoutDialogViewController.m
//  livestream
//
//  Created by test on 2019/1/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "HangoutDialogViewController.h"
#import "AnchorPersonalViewController.h"
#import "LSAnchorCardViewController.h"

#import "LSShadowView.h"
#import "LSHangoutFriendCollectionViewCell.h"

#import "LSGetHangoutFriendsRequest.h"
#import "LiveUrlHandler.h"
#import "LiveModule.h"
#import "LiveGobalManager.h"
#import "LSUserInfoManager.h"

@interface HangoutDialogViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
// 个人信息管理器
@property (nonatomic, strong) LSUserInfoManager *userInfoManager;
@end

@implementation HangoutDialogViewController

- (LSHangoutListItemObject *)item {
    if (_item == nil) {
        _item = [[LSHangoutListItemObject alloc] init];
    }

    return _item;
}

- (void)initCustomParam {
    [super initCustomParam];
    self.useUrlHandler = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //    // Do any additional setup after loading the view from its nib.

    self.userInfoManager = [LSUserInfoManager manager];

    self.hangOutNowBtn.layer.cornerRadius = self.hangOutNowBtn.frame.size.height / 2.0f;
    self.hangOutNowBtn.layer.masksToBounds = YES;
    LSShadowView *shadow = [[LSShadowView alloc] init];
    [shadow showShadowAddView:self.hangOutNowBtn];

    self.anchorImageView.layer.cornerRadius = self.anchorImageView.frame.size.width * 0.5;
    self.anchorImageView.layer.masksToBounds = YES;

    self.anchorImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.anchorImageView.layer.borderWidth = 2.0f;

    self.friendView.dataSource = self;
    self.friendView.delegate = self;
    self.friendView.layer.cornerRadius = 4.0f;
    self.friendView.layer.masksToBounds = YES;
    self.friendView.contentInset = UIEdgeInsetsMake(0, 14, 0, 0);
    self.friendView.delaysContentTouches = NO;

    UINib *nib = [UINib nibWithNibName:@"LSHangoutFriendCollectionViewCell" bundle:[LiveBundle mainBundle]];
    [self.friendView registerNib:nib forCellWithReuseIdentifier:[LSHangoutFriendCollectionViewCell cellIdentifier]];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView)];
    self.dismissSpaceView.userInteractionEnabled = YES;
    [self.dismissSpaceView addGestureRecognizer:tap];

    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToHideView:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.dismissSpaceView addGestureRecognizer:swipe];

    self.anchorContentView.userInteractionEnabled = YES;
    [self.anchorContentView addGestureRecognizer:swipe];

    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    CGRect frame = self.bgImageView.bounds;
    frame.size.width = screenSize.width;
    self.effectView.frame = frame;
    [self.bgImageView addSubview:self.effectView];
    [self.bgImageView sendSubviewToBack:self.effectView];

    LSShadowView *shadow1 = [[LSShadowView alloc] init];
    [shadow1 showShadowAddView:self.anchorContentView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self dismissView];
}

- (void)dismissView {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [[LiveGobalManager manager] removeDialogVc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideView {
    [UIView animateWithDuration:0.3
        animations:^{
            self.view.frame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height);
        }
        completion:^(BOOL finished) {
            [self dismissView];
        }];
}

- (void)swipeToHideView:(UISwipeGestureRecognizer *)swipe {
    [self hideView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)getUserInfo {
    [self.userInfoManager getUserInfo:self.anchorId
                        finishHandler:^(LSUserInfoModel *_Nonnull item) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.item.nickName = item.nickName;
                                self.item.anchorId = self.anchorId;
                                self.item.avatarImg = item.photoUrl;
                                [self reloadPersonBaseMsg];
                                [self loadAchorImage];
                            });
                        }];
}

- (void)reloadPersonBaseMsg {
    NSString *hangout = [NSString stringWithFormat:@"Hang-out with %@ and Her Friends", self.anchorName];
    NSMutableAttributedString *attrbuteStr = [[NSMutableAttributedString alloc] initWithString:hangout];
    NSRange nameRange = [hangout rangeOfString:self.anchorName];
    [attrbuteStr addAttributes:@{
        NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
        NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0xFFAA00)
    }
                         range:nameRange];
    self.anchorInviteTips.attributedText = attrbuteStr;

    self.anchorNameFriend.text = [NSString stringWithFormat:@"%@'s Friends", self.anchorName];
    NSString *exceedName = @"";
    if (self.anchorName.length > 12) {
        exceedName = [NSString stringWithFormat:@"%@...%@", [self.anchorName substringToIndex:3], [self.anchorName substringFromIndex:self.anchorName.length - 3]];
    } else {
        exceedName = self.anchorName;
    }

    self.inviteHangoutTips.text = [NSString stringWithFormat:@"Click Start button below, you will first enter %@'s Hang-out room. Then, through your or %@'s invitation, %@'s friends will join the Hang-out.", exceedName, exceedName, exceedName];
}

- (void)loadAchorImage {
    LSImageViewLoader *loader = [LSImageViewLoader loader];
    WeakObject(self, weakSelf);
    [loader loadImageFromCache:self.anchorImageView
                       options:SDWebImageRefreshCached
                      imageUrl:self.item.avatarImg
              placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]
                 finishHandler:^(UIImage *image) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (image) {
                             weakSelf.bgImageView.image = image;
                         }
                     });
                 }];
}

- (void)reloadFriendView {
    // 如果是好友列表为空显示默认大小和retry按钮
    if (self.friendArray.count > 0) {
        // TODO:刷新推荐列表
        self.friendViewWidth.constant = [LSHangoutFriendCollectionViewCell cellWidth] * self.friendArray.count + ((self.friendArray.count + 1) * 14);

        if (self.friendViewWidth.constant > screenSize.width - 22) {
            self.friendViewWidth.constant = screenSize.width - 22;
            self.friendView.contentInset = UIEdgeInsetsMake(0, 7, 0, 7);
        }

        [self.friendView reloadData];
    } else {

        self.friendViewWidth.constant = 320;
        self.retryBtn.hidden = NO;
    }
}

- (BOOL)getFriendList {
    LSSessionRequestManager *sessionManager = [LSSessionRequestManager manager];
    BOOL bflag = NO;
    LSGetHangoutFriendsRequest *request = [[LSGetHangoutFriendsRequest alloc] init];
    request.anchorId = self.anchorId;
    self.loadingActivity.hidden = NO;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *anchorId, NSArray<LSHangoutAnchorItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"HangoutDialogViewController::getFriendList( [获取好友列表], arrayCount : %ld ,success : %@ errmsg : %@)", (long)array.count, BOOL2YES(success), errmsg);
            self.loadingActivity.hidden = YES;
            if (success) {
                self.friendArray = array;
                [self reloadFriendView];
            } else {
                self.retryBtn.hidden = NO;
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
    } else {
        cell.onlineWidth.constant = 0;
        cell.onlineView.hidden = YES;
    }
    [cell.imageViewLoader stop];
    [cell.imageViewLoader loadImageWithImageView:cell.imageView
                                         options:0
                                        imageUrl:item.avatarImg
                                placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_HangOut"]
                                   finishHandler:nil];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LSHangoutAnchorItemObject *item = [self.friendArray objectAtIndex:indexPath.row];
    LSAnchorCardViewController *vc = [[LSAnchorCardViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorPhotourl = item.avatarImg;
    vc.userId = item.anchorId;
    vc.nickName = item.nickName;
    [vc showAnchorCardView:self];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    LSHangoutFriendCollectionViewCell *cell = (LSHangoutFriendCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderColor = [UIColor clearColor].CGColor;
}

//当cell高亮时返回是否高亮
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)colView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [colView cellForItemAtIndexPath:indexPath];
    cell.layer.borderColor = COLOR_WITH_16BAND_RGB(0xFF6D00).CGColor;
}

- (void)collectionView:(UICollectionView *)colView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [colView cellForItemAtIndexPath:indexPath];
    cell.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void)showhangoutView {
    [self reloadPersonBaseMsg];
    [self getUserInfo];
    [self getFriendList];
    self.view.frame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height);
    [UIView animateWithDuration:0.3
        animations:^{
        }
        completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
                             }];
        }];
}

- (IBAction)hangoutBtnAction:(id)sender {
    [[LiveModule module].analyticsManager reportActionEvent:InviteHangOut eventCategory:EventCategoryBroadcast];
    [self dismissView];
    if (self.useUrlHandler) {
        NSURL *url = [[LiveUrlHandler shareInstance] createUrlToHangoutByRoomId:@"" anchorId:self.anchorId anchorName:self.item.nickName hangoutAnchorId:@"" hangoutAnchorName:@""];
        [[LiveModule module].serviceManager handleOpenURL:url];
    } else {
        if ([self.dialogDelegate respondsToSelector:@selector(hangoutDialogViewController:didClickHangoutBtn:)]) {
            [self.dialogDelegate hangoutDialogViewController:self didClickHangoutBtn:sender];
        }
    }
}
- (IBAction)retryAction:(id)sender {
    self.retryBtn.hidden = YES;
    [self getFriendList];
}

// 添加颜色渐变动画
- (CABasicAnimation *)addBorderAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    animation.fromValue = (id)[UIColor clearColor].CGColor;
    animation.toValue = (id)COLOR_WITH_16BAND_RGB(0xFF6D00).CGColor;
    animation.autoreverses = YES;
    animation.duration = 0.3;
    animation.repeatCount = 1;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return animation;
}
@end
