//
//  LSSayHiDialogViewController.m
//  livestream
//
//  Created by Randy_Fan on 2019/4/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiDialogViewController.h"
#import "LSShadowView.h"
#import "SetFavoriteRequest.h"
#import "LSSessionRequestManager.h"

#define BUTTONHEIGHT 44

@interface LSSayHiDialogViewController ()
// 失败提示界面
@property (weak, nonatomic) IBOutlet UIView *dialogView;
@property (weak, nonatomic) IBOutlet UILabel *tiltleLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewSayHiButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewSayHiButtonHeight;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneOnOneButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendMailButtonHeight;
// 发送成功界面
@property (weak, nonatomic) IBOutlet UIView *successView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *successChatViewHeight;

@end

@implementation LSSayHiDialogViewController

- (void)dealloc {
    
}

- (void)initCustomParam {
    [super initCustomParam];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.canPopWithGesture = NO;
    
    self.dialogView.layer.cornerRadius = 5;
    self.dialogView.layer.masksToBounds = YES;
//    LSShadowView *shadowView = [[LSShadowView alloc] init];
//    [shadowView showShadowAddView:self.dialogView];
    
    self.successView.layer.cornerRadius = 5;
    self.successView.layer.masksToBounds = YES;
//    LSShadowView *successShadowView = [[LSShadowView alloc] init];
//    [successShadowView showShadowAddView:self.dialogView];
    
    self.tiltleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"AKz-xJ-eQ5.text"),self.anchorName];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)showDiaLogView:(BOOL)success hasFollow:(BOOL)hasFollow isOnline:(BOOL)isOnline errMsg:(NSString *)errMsg {
    
    if (success) {
        self.dialogView.hidden = YES;
        self.successView.hidden = NO;
        if (isOnline) {
            self.successChatViewHeight.constant = BUTTONHEIGHT;
        } else {
            self.successChatViewHeight.constant = 0;
        }
    } else {
        self.dialogView.hidden = NO;
        self.successView.hidden = YES;
        
        switch (self.errorType) {
            case SAYHIERROR_HAS_SEND:{
                [self showHasSendView:errMsg isOnline:isOnline];
            }break;
             
            case SAYHIERROR_HAS_CALL:{
                [self showHasCallView:errMsg isOnline:isOnline];
            }break;
                
            case SAYHIERROR_DAY_SEND_MAX:{
                [self showDaySendMaxAndOther:hasFollow isOnline:isOnline errMsg:errMsg];
            }break;
                
            case SAYHIERROR_SEND_MAX_ISREPLRY:{
                [self showSendMaxIsRepley:hasFollow errMsg:errMsg];
            }break;
                
            case SAYHIERROR_SEND_MAX_NOREPLRY:{
                [self showSendMaxNoRepley:hasFollow errMsg:errMsg];
            }break;
                
            default:{
                [self showDaySendMaxAndOther:hasFollow isOnline:isOnline errMsg:errMsg];
            }break;
        }
    }
}

- (IBAction)closeCurrentView:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didCloseCurrentView:)]) {
        [self.delegate didCloseCurrentView:self];
    }
}

- (IBAction)closeAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didCloseCilck:)]) {
        [self.delegate didCloseCilck:self];
    }
}

- (IBAction)viewSayHiAction:(id)sender {
    switch (self.errorType) {
        case SAYHIERROR_HAS_SEND:{
            if (self.sayHiId.length > 0) {
                if ([self.delegate respondsToSelector:@selector(didViewSayHiClick:)]) {
                    [self.delegate didViewSayHiClick:self.sayHiId];
                }
            }
        }break;
            
        case SAYHIERROR_SEND_MAX_ISREPLRY:{
            if ([self.delegate respondsToSelector:@selector(didViewSayHiList:)]) {
                [self.delegate didViewSayHiList:LiveUrlSayHiListTypeResponse];
            }
        }break;
            
        case SAYHIERROR_SEND_MAX_NOREPLRY:{
            if ([self.delegate respondsToSelector:@selector(didViewSayHiList:)]) {
                [self.delegate didViewSayHiList:LiveUrlSayHiListTypeAll];
            }
        }break;
            
        default:{
        }break;
    }
}

- (IBAction)followAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didFollowClick:)]) {
        [self.delegate didFollowClick:self];
    }
}

- (IBAction)chatAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didChatClick:)]) {
        [self.delegate didChatClick:self];
    }
}

- (IBAction)starOneOnOneAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didStartOneOnOneClick:)]) {
        [self.delegate didStartOneOnOneClick:self];
    }
}

- (IBAction)sendMailAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSendMailClick:)]) {
        [self.delegate didSendMailClick:self];
    }
}

- (void)showHasSendView:(NSString *)errMsg isOnline:(BOOL)isOnline {
    CGFloat chatHeight = 0;
    if (isOnline) {
        chatHeight = BUTTONHEIGHT;
    }
    CGFloat sayHiHeight = 0;
    if (self.sayHiId.length > 0) {
        sayHiHeight = BUTTONHEIGHT;
    }
    self.viewSayHiButtonHeight.constant = sayHiHeight;
    self.followButtonHeight.constant = 0;
    self.chatButtonHeight.constant = chatHeight;
    self.oneOnOneButtonHeight.constant = 0;
    self.sendMailButtonHeight.constant = BUTTONHEIGHT;
    
    [self.viewSayHiButton setTitle:NSLocalizedStringFromSelf(@"c9E-7c-e2t.normalTitle") forState:UIControlStateNormal];
    self.errorLabel.text = errMsg;
}

- (void)showHasCallView:(NSString *)errMsg isOnline:(BOOL)isOnline {
    CGFloat chatHeight = 0;
    if (isOnline) {
        chatHeight = BUTTONHEIGHT;
    }
    self.viewSayHiButtonHeight.constant = 0;
    self.followButtonHeight.constant = 0;
    self.chatButtonHeight.constant = chatHeight;
    self.oneOnOneButtonHeight.constant = chatHeight;
    self.sendMailButtonHeight.constant = BUTTONHEIGHT;
    
    self.errorLabel.text = errMsg;
}

- (void)showDaySendMaxAndOther:(BOOL)hasFollow isOnline:(BOOL)isOnline errMsg:(NSString *)errMsg {
    CGFloat followHeight = 0;
    CGFloat chatHeight = 0;
    if (!hasFollow) {
        followHeight = BUTTONHEIGHT;
    }
    if (isOnline) {
        chatHeight = BUTTONHEIGHT;
    }
    self.viewSayHiButtonHeight.constant = 0;
    self.followButtonHeight.constant = followHeight;
    self.chatButtonHeight.constant = chatHeight;
    self.oneOnOneButtonHeight.constant = 0;
    self.sendMailButtonHeight.constant = BUTTONHEIGHT;
    
    self.errorLabel.text = errMsg;
}

- (void)showSendMaxIsRepley:(BOOL)hasFollow errMsg:(NSString *)errMsg {
    CGFloat followHeight = 0;
    if (!hasFollow) {
        followHeight = BUTTONHEIGHT;
    }
    self.viewSayHiButtonHeight.constant = BUTTONHEIGHT;
    self.followButtonHeight.constant = followHeight;
    self.chatButtonHeight.constant = 0;
    self.oneOnOneButtonHeight.constant = 0;
    self.sendMailButtonHeight.constant = 0;
    
    [self.viewSayHiButton setTitle:NSLocalizedStringFromSelf(@"VIEW_RESPONSRS") forState:UIControlStateNormal];
    self.errorLabel.text = errMsg;
}

- (void)showSendMaxNoRepley:(BOOL)hasFollow errMsg:(NSString *)errMsg {
    CGFloat followHeight = 0;
    if (!hasFollow) {
        followHeight = BUTTONHEIGHT;
    }
    self.viewSayHiButtonHeight.constant = BUTTONHEIGHT;
    self.followButtonHeight.constant = followHeight;
    self.chatButtonHeight.constant = 0;
    self.oneOnOneButtonHeight.constant = 0;
    self.sendMailButtonHeight.constant = 0;
    
    [self.viewSayHiButton setTitle:NSLocalizedStringFromSelf(@"MY_SAY_HI") forState:UIControlStateNormal];
    self.errorLabel.text = errMsg;
}

- (void)showIsFollowBtn {
    self.followButton.userInteractionEnabled = NO;
    [self.followButton setImage:[UIImage imageNamed:@"Dialog_Did_Follow"] forState:UIControlStateNormal];
}

@end
