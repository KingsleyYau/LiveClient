//
//  ChatSecretPhotoViewController.m
//  dating
//
//  Created by test on 16/7/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSChatSecretPhotoViewController.h"
#import "LSAddCreditsViewController.h"
#import "LSLiveChatManagerOC.h"
#import "RequestErrorCode.h"
#import "LSPZPhotoView.h"
#import "LSShadowView.h"

typedef enum : NSUInteger {
    SecretPhotoStatusNormal,
    SecretPhotoStatusFee,
} SecretPhotoStatus;

@interface LSChatSecretPhotoViewController ()<LSLiveChatManagerListenerDelegate,LSPZPhotoViewDelegate>

@property (nonatomic, strong) LSLiveChatManagerOC *liveChatManager;
/** 私密照状态 */
@property (nonatomic,assign) SecretPhotoStatus status;

@property (nonatomic,strong) LSPZPhotoView *imageScrollViewPhoto;
/** 还没开始下载标识 */
@property (nonatomic,assign) BOOL downloadPhoto;

@end

@implementation LSChatSecretPhotoViewController

- (void)dealloc {
    [self.liveChatManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 根据付费状态设置显示状态
    self.status = self.msgItem.secretPhoto.isGetCharge?SecretPhotoStatusFee:SecretPhotoStatusNormal;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
 }

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - 界面初始化
- (void)setupContainView {
    [super setupContainView];
    
    self.buyBtn.layer.cornerRadius = self.buyBtn.tx_height/2;
    self.buyBtn.layer.masksToBounds = YES;
    
    LSShadowView * buyView = [[LSShadowView alloc]init];
    [buyView showShadowAddView:self.buyBtn];
    
    self.downBtn.layer.cornerRadius = self.downBtn.tx_height/2;
    self.downBtn.layer.masksToBounds = YES;
    
    LSShadowView * downView = [[LSShadowView alloc]init];
    [downView showShadowAddView:self.downBtn];
    
    [self hideBuyControll];
    [self hideDownControll];
    
    if (![self.msgItem.fromId isEqualToString:[LSLoginManager manager].loginItem.userId]) {
        // 显示描述
        NSString * descStr = [NSString stringWithFormat:@"%@",self.msgItem.secretPhoto.photoDesc];
        CGRect rect = [descStr boundingRectWithSize:CGSizeMake(self.fileName.tx_width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName :self.fileName.font } context:nil];
        
        if (rect.size.height > 24) {
            self.fileNameH.constant = 48;
        }else {
            self.fileNameH.constant = 24;
        }
        self.fileName.text = descStr;
    }
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0xD4000000).CGColor,(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x25000000).CGColor, (__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x00000000).CGColor];
    gradientLayer.locations = @[@0,@0.75,@1.0];
    gradientLayer.startPoint = CGPointMake(0, 1.0);
    gradientLayer.endPoint = CGPointMake(0, 0.0);
    gradientLayer.frame = CGRectMake(0, 0, screenSize.width, self.bottomView.tx_height);
    [self.bottomView.layer addSublayer:gradientLayer];
    
    // 显示可缩放的清晰图
    self.imageScrollViewPhoto = [[LSPZPhotoView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.imageScrollViewPhoto prepareForReuse];
    self.imageScrollViewPhoto.photoViewDelegate = self;
    [self.view addSubview:self.imageScrollViewPhoto];
    [self.view sendSubviewToBack:self.imageScrollViewPhoto];
}

- (void)hideDownControll {
    self.downBtn.hidden = YES;
    self.downTip.hidden = YES;
}

- (void)showDownControll:(NSString *)msg {
    self.downBtn.hidden = YES;
    self.downTip.text = msg;
    self.downTip.hidden = NO;
    self.bottomView.hidden = YES;
    self.fileName.hidden = YES;
}

- (void)showLocalNewworkErorr {
    self.downBtn.hidden = NO;
    self.downTip.text = NSLocalizedString(@"NetworkError", nil);
    self.downTip.hidden = NO;
    self.bottomView.hidden = YES;
    self.fileName.hidden = YES;
}

- (void)hideBuyControll {
    self.creditTip.hidden = YES;
    self.ladyName.hidden = YES;
    self.buyBtn.hidden = YES;
    self.lockIcon.hidden = YES;
    self.bottomView.hidden = NO;
    self.fileName.hidden = NO;
}

- (void)showBuyControll {
    self.creditTip.hidden = NO;
    self.ladyName.hidden = NO;
    self.buyBtn.hidden = NO;
    self.lockIcon.hidden = NO;
    self.bottomView.hidden = NO;
    self.fileName.hidden = NO;
    
    LSLCLiveChatUserItemObject * ladyItem = [self.liveChatManager getUserWithId:self.msgItem.fromId];
    
    NSString * ladyNamePhoto = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"LADY_NAME_PHOTO"),ladyItem.userName];
     CGRect rect = [ladyNamePhoto boundingRectWithSize:CGSizeMake(self.ladyName.tx_width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName :self.ladyName.font } context:nil];
    
    if (rect.size.height > self.ladyName.tx_height) {
        self.ladyNameH.constant = rect.size.height;
    }
    self.ladyName.text = ladyNamePhoto;
}

- (void)initCustomParam {
    [super initCustomParam];
    self.liveChatManager = [LSLiveChatManagerOC manager];
    [self.liveChatManager addDelegate:self];
    self.isShowNavBar = NO;
}

- (void)showLoading {
    self.loading.hidden = NO;
}

- (void)hideLoading {
    self.loading.hidden = YES;
}

#pragma mark - 购买状态
- (void)setStatus:(SecretPhotoStatus)status {
    
        [self hideBuyControll];
        [self hideDownControll];
    switch (status) {
        case SecretPhotoStatusNormal:{ // 没付费状态
            // 显示模糊图
            NSData *data = nil;
            if (self.msgItem.secretPhoto.thumbFuzzyFilePath.length > 0 ){
                data = [NSData dataWithContentsOfFile:self.msgItem.secretPhoto.thumbFuzzyFilePath];
                NSLog(@"ChatSecretPhotoViewController::setStatus thumbFuzzyFilePath:%@",self.msgItem.secretPhoto.thumbFuzzyFilePath);
            }
            self.secretImageView.image = [UIImage imageWithData:data];
            
            if(self.secretImageView.image) {
                // 图片已经存在
                // 显示购买按钮, 提示信息
                [self showBuyControll];
            } else {
               [self downloadPhotoRequest];
            }
        }break;
        case SecretPhotoStatusFee:{// 付费状态
            // 显示清晰图
            self.secretImageView.image = nil;
            NSData *data = nil;
            if( self.msgItem.secretPhoto.srcFilePath.length > 0 ) {
                data  = [NSData dataWithContentsOfFile:self.msgItem.secretPhoto.srcFilePath];
                NSLog(@"ChatSecretPhotoViewController::setStatus srcFilePath:%@",self.msgItem.secretPhoto.srcFilePath);
            }
            self.secretImageView.image = [UIImage imageWithData:data];
            
            if(self.secretImageView.image) {
                [self.imageScrollViewPhoto setImage:self.secretImageView.image];
                self.secretImageView.hidden = YES;
                if ([self.msgItem.fromId isEqualToString:[LSLoginManager manager].loginItem.userId]) {
                    self.bottomView.hidden = YES;
                }else {
                    self.bottomView.hidden = NO;
                }
            } else {
                [self downloadPhotoRequest];
            }
        }break;
        default:
            break;
    }
}

#pragma mark - 界面事件
- (IBAction)buySecretPhotoAction:(id)sender {
    // 点击购买图片
    [self hideBuyControll];
    // 显示菊花
    [self showLoading];
    self.downloadPhoto = NO;
    if( ![self.liveChatManager photoFee:self.msgItem.fromId mphotoId:self.msgItem.secretPhoto.photoId inviteId:self.msgItem.inviteId] ) {
        [self showRequestError];
    }
}

- (IBAction)downSecretPhotoAction:(id)sender {
 
    if (self.downloadPhoto) {
      [self downloadPhotoRequest];
    }
    else {
        [self buySecretPhotoAction:nil];
    }
}

// 点击下载图片
- (void)downloadPhotoRequest {
    
    [self hideDownControll];
    [self hideBuyControll];
    [self showLoading];
    self.downloadPhoto = YES;
    if (self.msgItem.sendType == SendType_Send) {
        // 获取付费图片(自己发的图片), 显示菊花
        if (![self.liveChatManager getPhoto:self.msgItem.toId photoId:self.msgItem.secretPhoto.photoId sizeType:GPT_ORIGINAL sendType:self.msgItem.sendType]) {
            [self showRequestError];
        }
    } else {
        // 获取付费图片(收到的图片), 显示菊花
        if (![self.liveChatManager getPhoto:self.msgItem.fromId photoId:self.msgItem.secretPhoto.photoId sizeType:GPT_ORIGINAL sendType:self.msgItem.sendType]) {
            [self showRequestError];
        }
    }
}

- (void)showRequestError {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideLoading];
        [self showLocalNewworkErorr];
    });
}

#pragma mark - 私密照回调
- (void)onGetPhoto:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg msgList:(NSArray<LSLCLiveChatMsgItemObject*>* _Nonnull)msgList sizeType:(GETPHOTO_PHOTOSIZE_TYPE)sizeType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoading];
        if (errType == LSLIVECHAT_LCC_ERR_SUCCESS) {
            for(LSLCLiveChatMsgItemObject* msgItem in msgList) {
                if( [msgItem.secretPhoto.photoId isEqualToString:self.msgItem.secretPhoto.photoId] ) {
                    NSLog(@"ChatSecretPhotoViewController::onGetPhoto( 获取私密照 errType : %d, msgItem.msgId : %ld )", errType, (long)msgItem.msgId);
                    // 保存数据
                    self.msgItem = msgItem;
                    [self reloadPhoto];
                    break;
                }
            }
        }else if (errType == LSLIVECHAT_LCC_ERR_CONNECTFAIL){
            [self showLocalNewworkErorr];
        }
        else {
            [self showDownControll:errMsg];
        }
    });
}

- (void)onPhotoFee:(bool)success errNo:(NSString *)errNo errMsg:(NSString *)errMsg msgItem:(LSLCLiveChatMsgItemObject *)msgItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [msgItem.secretPhoto.photoId isEqualToString: self.msgItem.secretPhoto.photoId] ) {
            NSLog(@"ChatSecretPhotoViewController::onPhotoFee( 获取收费私密照 success : %d, srcFilePath : %@ )", success, msgItem.secretPhoto.srcFilePath);
            // 保存数据
            self.msgItem = msgItem;
            // 停止菊花
            [self hideLoading];
            if( success ) {
                // 更新图片状态
                [self reloadPhoto];
            } else {
                //余额不足
                if( [self.liveChatManager isNoMoneyWithErrCode:errNo] ) {
                    self.status = self.msgItem.secretPhoto.isGetCharge?SecretPhotoStatusFee:SecretPhotoStatusNormal;
                    if (self.viewDelegate != nil && [self.viewDelegate respondsToSelector:@selector(photoDetailspushAddCreditsViewController)]) {
                        [self.viewDelegate photoDetailspushAddCreditsViewController];
                    }
                    
                } else if (msgItem.procResult.errType == LSLIVECHAT_LCC_ERR_CONNECTFAIL){
                    [self showLocalNewworkErorr];
                }else {
                    [self showDownControll:errMsg];
                }
            }
        }
    });
}

- (void)reloadMsgItem:(LSLCLiveChatMsgItemObject *)msgItem {
    self.msgItem = msgItem;
    self.status = self.msgItem.secretPhoto.isGetCharge?SecretPhotoStatusFee:SecretPhotoStatusNormal;
}

- (void)reloadPhoto {
    self.status = self.msgItem.secretPhoto.isGetCharge?SecretPhotoStatusFee:SecretPhotoStatusNormal;
}

#pragma mark - 照片手势处理回调

- (void)photoViewDidSingleTap:(LSPZPhotoView *)photoView {
    
    if (![self.msgItem.fromId isEqualToString:[LSLoginManager manager].loginItem.userId]) {
        self.fileName.hidden = !self.fileName.hidden;
        self.bottomView.hidden = !self.bottomView.hidden;
    }
}


- (void)photoViewDidDoubleTap:(LSPZPhotoView *)photoView {
        
}

- (void)photoViewDidTwoFingerTap:(LSPZPhotoView *)photoView {
    
}

- (void)photoViewDidDoubleTwoFingerTap:(LSPZPhotoView *)photoView {
    
}

@end
