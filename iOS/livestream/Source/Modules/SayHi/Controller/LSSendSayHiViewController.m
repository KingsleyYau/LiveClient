//
//  LSSendSayHiViewController.m
//  livestream
//
//  Created by Randy_Fan on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSendSayHiViewController.h"
#import "LSSayHiDialogViewController.h"
#import "LSSayHiThemeListViewController.h"
#import "LSSayHiListViewController.h"
#import "LSSayHiDetailViewController.h"
#import "LSSendMailViewController.h"
#import "QNChatViewController.h"

#import "LSShadowView.h"
#import "IntroduceView.h"
#import "QNChatTextView.h"

#import "LSSayHiIsCanSendRequest.h"
#import "LSSayHiSendSayHiRequest.h"
#import "SetFavoriteRequest.h"
#import "LSSessionRequestManager.h"

#import "LSImageViewLoader.h"
#import "LSLoginManager.h"
#import "LSSayHiManager.h"
#import "LiveModule.h"

#define SelectViewHeight 117

@interface LSSendSayHiViewController ()<LSSayHiThemeListViewControllerDelegate,ChatTextViewDelegate,LSSayHiDialogViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *themeImageView;

@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet QNChatTextView *chatTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextViewHeight;

@property (weak, nonatomic) IBOutlet UILabel *fromLabel;

@property (weak, nonatomic) IBOutlet UIButton *hiddenSelectBtn;

@property (strong, nonatomic) LSSessionRequestManager *sessionManager;

@property (strong, nonatomic) LSImageViewLoader *imageLoader;

@property (strong, nonatomic) LSSayHiManager *sayHiManager;

@property (strong, nonatomic) LSSayHiThemeListViewController *themeListVC;

@property (strong, nonatomic) LSSayHiDialogViewController *dialogVC;

@end

@implementation LSSendSayHiViewController

- (void)dealloc {
    NSLog(@"LSSendSayHiViewController::dealloc()");
}

- (void)initCustomParam {
    [super initCustomParam];
    
    self.sessionManager = [LSSessionRequestManager manager];
    
    self.imageLoader = [LSImageViewLoader loader];
    
    self.sayHiManager = [LSSayHiManager manager];
    
    self.themeListVC = [[LSSayHiThemeListViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.themeListVC];
    self.themeListVC.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedStringFromSelf(@"SAY_HI");
    
    self.dialogVC = [[LSSayHiDialogViewController alloc] initWithNibName:nil bundle:nil];
    self.dialogVC.anchorName = self.anchorName;
    self.dialogVC.anchorId = self.anchorId;
    self.dialogVC.delegate = self;
    
    self.themeListVC.view.layer.shadowOffset = CGSizeMake(0, -1);
    self.themeListVC.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.themeListVC.view.layer.shadowOpacity = 0.1;
    self.themeListVC.view.layer.shadowRadius = 1;
    [self.view addSubview:self.themeListVC.view];
    [self.themeListVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@(SelectViewHeight));
    }];
    
    self.chatTextView.editable = NO;
    self.chatTextView.selectable = NO;
    self.chatTextView.chatTextViewDelegate = self;
    self.chatTextView.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:22];
    [self.chatTextView setContentOffset:CGPointZero];
    
    self.toLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"PwS-Bd-wUz.text"),self.anchorName];
    self.fromLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Ynh-pD-tdr.text"),[LSLoginManager manager].loginItem.nickName];
    
    if (self.sayHiManager.item) {
        [self.chatTextView setText:self.sayHiManager.item.text];
        [self.imageLoader loadImageWithImageView:self.themeImageView options:0 imageUrl:self.sayHiManager.item.bigImage placeholderImage:nil finishHandler:^(UIImage *image) {

        }];
    } else {
        WeakObject(self, weakSelf);
        [self.sayHiManager getSayHiConfig:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiResourceConfigItemObject *item) {
            if (success) {
                LSSayHiThemeItemObject *themeObj = item.themeList.firstObject;
                LSSayHiTextItemObject *textObj = item.textList.firstObject;
                
                weakSelf.sayHiManager.item = [[LSLastSayHiConfigItem alloc] init];
                weakSelf.sayHiManager.item.themeId = themeObj.themeId;
                weakSelf.sayHiManager.item.bigImage = themeObj.bigImg;
                weakSelf.sayHiManager.item.textId = textObj.textId;
                weakSelf.sayHiManager.item.text = textObj.text;
                
                [weakSelf.imageLoader loadImageWithImageView:weakSelf.themeImageView options:0 imageUrl:weakSelf.sayHiManager.item.bigImage placeholderImage:nil finishHandler:^(UIImage *image) {

                }];
                [weakSelf.chatTextView setText:weakSelf.sayHiManager.item.text];
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.dialogVC.view removeFromSuperview];
    [self.dialogVC removeFromParentViewController];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - HTTP请求
- (void)sendSayHiRequest:(NSString *)anchorId {
    [self showAndResetLoading];
    WeakObject(self, weakSelf);
    LSSayHiSendSayHiRequest *request = [[LSSayHiSendSayHiRequest alloc] init];
    request.anchorId = anchorId;
    request.themeId = self.sayHiManager.item.themeId;
    request.textId = self.sayHiManager.item.textId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *sayHiId, NSString *loiId, BOOL isFollow, OnLineStatus onlineStatus) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSendSayHiViewController::sendSayHiRequest([发送SayHi] success : %@, errnum : %d, errmsg : %@, sayHiId : %@, loiId : %@)",BOOL2SUCCESS(success),errnum,errmsg,sayHiId,loiId);
            [weakSelf hideAndResetLoading];
            if (!success) {
                switch (errnum) {
                    case HTTP_LCC_ERR_SAYHI_ALREADY_CONTACT:{
                        // 已建立联系
                        weakSelf.dialogVC.errorType = SAYHIERROR_HAS_CALL;
                    }break;
                    
                    case HTTP_LCC_ERR_SAYHI_MAN_ALREADY_SEND_SAYHI:{
                        // 发过SayHi
                        weakSelf.dialogVC.sayHiId = sayHiId;
                        weakSelf.dialogVC.errorType = SAYHIERROR_HAS_SEND;
                    }break;
                        
                    case HTTP_LCC_ERR_SAYHI_MAN_LIMIT_NUM_DAY:{
                        // 每日总量限制
                        weakSelf.dialogVC.errorType = SAYHIERROR_DAY_SEND_MAX;
                    }break;
                        
                    case HTTP_LCC_ERR_SAYHI_MAN_LIMIT_TOTAL_ANCHOR_REPLY:{
                        // 总量限制-有主播回复
                        weakSelf.dialogVC.errorType = SAYHIERROR_SEND_MAX_ISREPLRY;
                    }break;
                        
                    case HTTP_LCC_ERR_SAYHI_MAN_LIMIT_TOTAL_ANCHOR_UNREPLY:{
                        // 总量限制-无主播回复
                        weakSelf.dialogVC.errorType = SAYHIERROR_SEND_MAX_NOREPLRY;
                    }break;
                        
                    default:{
                        weakSelf.dialogVC.errorType = SAYHIERROR_NONE;
                    }break;
                }
            }
            [weakSelf showDialodViewIsSuccess:success hasFollow:isFollow isOnline:onlineStatus errMsg:errmsg];
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - LSSayHiThemeListViewControllerDelegate
- (void)didSelectThemeWithItem:(LSSayHiThemeItemObject *)theme {
    self.sayHiManager.item.themeId = theme.themeId;
    self.sayHiManager.item.bigImage = theme.bigImg;
    [self.imageLoader loadImageWithImageView:self.themeImageView options:0 imageUrl:theme.bigImg placeholderImage:nil finishHandler:^(UIImage *image) {
        
    }];
}

- (void)didSelectWordWithItem:(LSSayHiTextItemObject *)word {
    self.sayHiManager.item.text = word.text;
    self.sayHiManager.item.textId = word.textId;
    
    [self.chatTextView setText:word.text];
}

- (void)didShowSelectThemeWord:(LSSayHiThemeListViewController *)vc index:(NSInteger)index {
    self.hiddenSelectBtn.hidden = NO;
    CGFloat height = SelectViewHeight + (self.view.tx_width / 2);
    [self.themeListVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(height));
    }];
    [self.themeListVC.view layoutSubviews];
    [self.themeListVC changeSegementSelect:index];
}

- (void)didSubmitSayHi {
    [[LiveModule module].analyticsManager reportActionEvent:SayHiEditClickSendNow eventCategory:EventCategorySayHi];
    [self sendSayHiRequest:self.anchorId];
}

#pragma mark - LSSayHiDialogViewControllerDelegate
- (void)didCloseCurrentView:(LSSayHiDialogViewController *)vc {
    [self.dialogVC.view removeFromSuperview];
    [self.dialogVC removeFromParentViewController];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didCloseCilck:(LSSayHiDialogViewController *)vc {
    [self.dialogVC.view removeFromSuperview];
    [self.dialogVC removeFromParentViewController];
}

- (void)didViewSayHiClick:(NSString *)sayHiId {
    [self.dialogVC.view removeFromSuperview];
    [self.dialogVC removeFromParentViewController];
    LSSayHiDetailViewController *vc = [[LSSayHiDetailViewController alloc]initWithNibName:nil bundle:nil];
    vc.sayHiID = sayHiId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didViewSayHiList:(LiveUrlSayHiListType)type {
    [self.dialogVC.view removeFromSuperview];
    [self.dialogVC removeFromParentViewController];
    int index = 0;
    switch (type) {
        case LiveUrlSayHiListTypeAll: {
            index = 0;
        } break;
        case LiveUrlSayHiListTypeResponse: {
            index = 1;
        } break;
        default:
            break;
    }
    LSSayHiListViewController *vc = [[LSSayHiListViewController alloc] initWithNibName:nil bundle:nil];
    vc.curIndex = index;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didFollowClick:(LSSayHiDialogViewController *)vc {
    [self.dialogVC showIsFollowBtn];
    SetFavoriteRequest *request = [[SetFavoriteRequest alloc] init];
    request.userId = self.anchorId;
    request.isFav = YES;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
        NSLog(@"LSSendSayHiViewController::SetFavoriteRequest([关注主播 %@] errnum : %d, errmsg : %@)",BOOL2SUCCESS(success),errnum,errmsg);
    };
    [self.sessionManager sendRequest:request];
}

- (void)didChatClick:(LSSayHiDialogViewController *)vc {
    [self.dialogVC.view removeFromSuperview];
    [self.dialogVC removeFromParentViewController];
    QNChatViewController *chatVC = [[QNChatViewController alloc] initWithNibName:nil bundle:nil];
    chatVC.womanId = self.anchorId;
    chatVC.firstName = self.anchorName;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)didStartOneOnOneClick:(LSSayHiDialogViewController *)vc {
    [self.dialogVC.view removeFromSuperview];
    [self.dialogVC removeFromParentViewController];
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:@"" anchorName:self.anchorName anchorId:self.anchorId roomType:LiveRoomType_Private];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

- (void)didSendMailClick:(LSSayHiDialogViewController *)vc {
    [self.dialogVC.view removeFromSuperview];
    [self.dialogVC removeFromParentViewController];
    LSSendMailViewController *mailVC = [[LSSendMailViewController alloc] initWithNibName:nil bundle:nil];
    mailVC.anchorId = self.anchorId;
    mailVC.anchorName = self.anchorName;
    [self.navigationController pushViewController:mailVC animated:YES];
}

#pragma mark - 输入栏高度改变回调
- (void)textViewChangeHeight:(QNChatTextView *_Nonnull)textView height:(CGFloat)height {
    self.chatTextViewHeight.constant = height + 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [textView setNeedsDisplay];
    });
}

- (IBAction)closeSelectView:(id)sender {
    self.hiddenSelectBtn.hidden = YES;
    self.themeListVC.selectWordBtn.selected = NO;
    self.themeListVC.selectThemeBtn.selected = NO;
    [self.themeListVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(SelectViewHeight));
    }];
    [self.themeListVC.view layoutSubviews];
    [self.themeListVC showButtonViewOrSegmentView:NO];
}

- (void)showDialodViewIsSuccess:(BOOL)isSuccess hasFollow:(BOOL)hasFollow isOnline:(BOOL)isOnline errMsg:(NSString *)errMsg {
    [self.navigationController addChildViewController:self.dialogVC];
    [self.navigationController.view addSubview:self.dialogVC.view];
    [self.dialogVC showDiaLogView:isSuccess hasFollow:hasFollow isOnline:isOnline errMsg:errMsg];
    [self.dialogVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.navigationController.view);
    }];
}

@end
