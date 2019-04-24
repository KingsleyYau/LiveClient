//
//  LSMailAttachmentViewController.m
//  dating
//
//  Created by test on 2017/6/26.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSMailAttachmentViewController.h"
#import "LSAddCreditsViewController.h"
#import "LSSendMailViewController.h"

#import "LSMailPrivatePlayView.h"
#import "LSGreetingVideoPlayView.h"
#import "LSMailLadySecretPhotoView.h"
#import "LSMailFreePhotoView.h"

#import "LSImageViewLoader.h"
#import "LSVideoPlayManager.h"
#import "LSFileCacheManager.h"

#import "LSSessionRequestManager.h"
#import "LSBuyPrivatePhotoVideoRequest.h"

#import "LSAddCreditsViewController.h"
#import "LiveModule.h"
#import "DialogTip.h"

@interface LSMailAttachmentViewController()<LSPZPagingScrollViewDelegate,LSVideoPlayManagerDelegate,LSGreetingVideoPlayViewDelegate,LSMailPrivatePlayViewDelegate,LSMailLadySecretPhotoViewDelegate,LSSendMailViewControllerDelegate>
/**
 *  接口管理器
 */
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
/** 私密照 */
@property (nonatomic, strong)  LSMailLadySecretPhotoView *secretPhoto;
/** 下载成功 */
@property (nonatomic, assign) BOOL downloadSuccess;
/** 意向信视频 */
@property (nonatomic, strong) LSGreetingVideoPlayView *greetingVideoView;
/** 信件视频 */
@property (nonatomic, strong) LSMailPrivatePlayView *privateVideoView;
/**
 播放管理者
 */
@property (nonatomic, strong) LSVideoPlayManager *playManager;
/** 微视频播放url */
@property (nonatomic, copy) NSString* shortVideoPath;

@end

@implementation LSMailAttachmentViewController

- (void)dealloc {
    NSLog(@"LSMailAttachmentViewController::dealloc()");
    [self.playManager removeNotification];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sessionManager = [LSSessionRequestManager manager];
    self.pageScrollView.pagingViewDelegate = self;
    self.downloadSuccess = YES;
    self.playManager = [[LSVideoPlayManager alloc]init];
    self.playManager.delegate = self;
    self.pageScrollView.frame = [UIScreen mainScreen].bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.pageScrollView displayPagingViewAtIndex:self.photoIndex animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.playManager removeNotification];
}

#pragma mark - 画廊回调 (PZPagingScrollViewDelegate)
- (Class)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    Class cl = nil;
    LSMailAttachmentModel *obj = [self.attachmentsArray objectAtIndex:index];
    switch (obj.attachType) {
        case AttachmentTypeFreePhoto:{
            cl = [UIImageView class];
        }break;
        case AttachmentTypePrivatePhoto:{
            cl = [LSMailLadySecretPhotoView class];
        }break;
        case AttachmentTypeGreetingVideo:{
            cl = [LSGreetingVideoPlayView class];
        }break;
        case AttachmentTypePrivateVideo:{
            cl = [LSGreetingVideoPlayView class];
        }break;
        case AttachmentTypeSendPhoto:{
            cl = [UIImageView class];
        }break;
        default:
            cl = [UIView class];
            break;
    }
    return cl;
}

- (NSUInteger)pagingScrollViewPagingViewCount:(LSPZPagingScrollView *)pagingScrollView {
    CGSize size = pagingScrollView.contentSize;
    size.height = 0;
    size.width = CGRectGetWidth(pagingScrollView.frame) * self.attachmentsArray.count;
    pagingScrollView.contentSize = size;
    return self.attachmentsArray.count;
}

- (UIView *)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    UIView *view = nil;
    CGFloat photoSizeHeight = CGRectGetHeight(pagingScrollView.frame);
    CGFloat photoSizeWidth = [UIScreen mainScreen].bounds.size.width;
    LSMailAttachmentModel *obj = [self.attachmentsArray objectAtIndex:index];
    switch (obj.attachType) {
        case AttachmentTypeFreePhoto: {
            LSMailFreePhotoView *imageView = [[LSMailFreePhotoView alloc] initWithFrame:CGRectMake(0, 0,  photoSizeWidth, photoSizeHeight)];
            view = imageView;
        }break;
        case AttachmentTypePrivatePhoto: {
            LSMailLadySecretPhotoView *secretPhoto = [[LSMailLadySecretPhotoView alloc] initWithFrame:CGRectMake(0, 0,  photoSizeWidth, photoSizeHeight)];
            view = secretPhoto;
        }break;
        case AttachmentTypeGreetingVideo:{
            LSGreetingVideoPlayView *videoView = [[LSGreetingVideoPlayView alloc] initWithFrame:CGRectMake(0, 0, photoSizeWidth, photoSizeHeight)];
            view = videoView;
        }break;
        case AttachmentTypePrivateVideo: {
            LSMailPrivatePlayView *videoView = [[LSMailPrivatePlayView alloc] initWithFrame:CGRectMake(0, 0, photoSizeWidth, photoSizeHeight)];
            view = videoView;
        }break;
        case AttachmentTypeSendPhoto:{
            UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,  photoSizeWidth, photoSizeHeight)];
            view = imageV;
        }break;
        default:
            break;
    }
    return view;
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    
    LSMailAttachmentModel *obj = [self.attachmentsArray objectAtIndex:index];
    switch (obj.attachType) {
        case AttachmentTypeFreePhoto: {
            // 还原默认图片
            LSMailFreePhotoView *freePhoto = (LSMailFreePhotoView *)pageView;
            LSImageViewLoader *loader = [LSImageViewLoader loader];
            [loader stop];
            [freePhoto.photoView sd_cancelCurrentImageLoad];
            freePhoto.photoView.image = nil;
            [freePhoto activiViewIsShow:YES];
            [loader loadImageWithImageView:freePhoto.photoView options:0 imageUrl:obj.originImgUrl placeholderImage:nil finishHandler:^(UIImage *image) {
                if (image) {
                    [freePhoto activiViewIsShow:NO];
                }
            }];
        }break;
        case AttachmentTypePrivatePhoto: {
            LSMailLadySecretPhotoView *secretPhoto = (LSMailLadySecretPhotoView *)pageView;
            LSImageViewLoader *loader = [LSImageViewLoader loader];
            [loader stop];
            [secretPhoto.photoImageView sd_cancelCurrentImageLoad];
            secretPhoto.photoImageView.image = nil;
            secretPhoto.item = obj;
            secretPhoto.photoDelegate = self;
            secretPhoto.representLabel.text = obj.photoDesc;
            [secretPhoto activiViewIsShow:NO];
            // 付费状态
            switch (obj.expenseType) {
                case ExpenseTypeNo:{
                    // 未付费
                    [secretPhoto onlyShowBuyView];
                    [loader loadImageWithImageView:secretPhoto.photoImageView options:0 imageUrl:obj.blurImgUrl placeholderImage:nil finishHandler:nil];
                }break;
                    
                case ExpenseTypeYes:{
                    // 已付费
                    [secretPhoto activiViewIsShow:YES];
                    [secretPhoto onlyShowImageView];
                    [loader loadImageWithImageView:secretPhoto.photoImageView options:0 imageUrl:obj.originImgUrl placeholderImage:nil finishHandler:^(UIImage *image) {
                        [secretPhoto activiViewIsShow:NO];
                        if (!image) {
                            [secretPhoto onlyShowLoadFailView];
                        }else {
                            [secretPhoto showDownloadBtn];
                        }
                    }];
                }break;
                    
                case ExpenseTypePaying:{
                    [secretPhoto activiViewIsShow:YES];
                    // 未付费
                    [secretPhoto onlyShowBuyView];
                    [loader loadImageWithImageView:secretPhoto.photoImageView options:0 imageUrl:obj.blurImgUrl placeholderImage:nil finishHandler:nil];
                }break;
                    
                default:{
                    // 已过期
                    [secretPhoto onlyShowExpiredView];
                    [loader loadImageWithImageView:secretPhoto.photoImageView options:0 imageUrl:obj.blurImgUrl placeholderImage:nil finishHandler:nil];
                }break;
            }
    
        }break;
        case AttachmentTypeGreetingVideo:{
            LSGreetingVideoPlayView *videoView = (LSGreetingVideoPlayView *)pageView;
            self.greetingVideoView = videoView;
            videoView.delegate = self;
            videoView.item = obj;
            videoView.endView.hidden = YES;
            videoView.activiView.hidden = YES;
            [videoView setupDetail];
            if (obj.videoUrl.length > 0) {
                [videoView activiViewIsShow:YES];
                [self.playManager playLdayVideo:obj.videoUrl forView:videoView.videoPlayView playTime:obj.videoTime isShowSlider:obj.isReplied isShowPlayTime:YES];
            }
        }break;
        case AttachmentTypePrivateVideo: {
            LSMailPrivatePlayView *videoView = (LSMailPrivatePlayView *)pageView;
            LSImageViewLoader *loader = [LSImageViewLoader loader];
            [loader stop];
            [videoView.videoImageView sd_cancelCurrentImageLoad];
            videoView.videoImageView.image = nil;
            self.privateVideoView = videoView;
            videoView.delegate = self;
            videoView.item = obj;
            videoView.representLabel.text = obj.videoDesc;
            [videoView activiViewIsShow:NO];
            // 付费状态
            switch (obj.expenseType) {
                case ExpenseTypeNo:{
                    // 未付费
                    [loader loadImageWithImageView:videoView.videoImageView options:0 imageUrl:obj.videoCoverUrl placeholderImage:nil finishHandler:nil];
                    [videoView showBuyVideoView];
                }break;
                    
                case ExpenseTypeYes:{
                    // 已付费
                    [loader loadImageWithImageView:videoView.videoImageView options:0 imageUrl:obj.videoCoverUrl placeholderImage:nil finishHandler:nil];
                    [videoView showUnlockPlayView];
                }break;
                    
                case ExpenseTypePaying:{
                    [videoView activiViewIsShow:YES];
                    // 付费中
                    [loader loadImageWithImageView:videoView.videoImageView options:0 imageUrl:obj.videoCoverUrl placeholderImage:nil finishHandler:nil];
                    [videoView showBuyVideoView];
                }break;
                    
                default:{
                    // 已过期
                    [loader loadImageWithImageView:videoView.videoImageView options:0 imageUrl:obj.videoCoverUrl placeholderImage:nil finishHandler:nil];
                    [videoView showExpiredView];
                }break;
            }
            
        }break;
        case AttachmentTypeSendPhoto:{
            UIImageView* imageView = (UIImageView *)pageView;
            [imageView setImage:nil];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            // 图片路径
            NSString *path = obj.originImgUrl;
            NSData *data = [NSData dataWithContentsOfFile:path];
            UIImage *image = [UIImage imageWithData:data];
            imageView.image = image;
        }break;
        default:
            break;
    }
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    LSMailAttachmentModel *obj = [self.attachmentsArray objectAtIndex:index];
    if (self.photoIndex == index) {
        
    } else {
        if (obj.attachType != AttachmentTypeGreetingVideo && obj.attachType != AttachmentTypePrivateVideo) {
            [self.playManager removeNotification];
        }
    }
    self.photoIndex = index;
}

#pragma mark - LSMailLadySecretPhotoViewDelegate
- (void)emfLadySecretPhotoView:(LSMailLadySecretPhotoView *)photo didDownPhotoAction:(LSMailAttachmentModel *)model {
    self.secretPhoto = photo;
    // 点击下载图片
    UIImageWriteToSavedPhotosAlbum(photo.photoImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)emfLadySecretPhotoView:(LSMailLadySecretPhotoView *)photo didRetryDownPhotoAction:(LSMailAttachmentModel *)model {
    self.secretPhoto = photo;
    // 加载图片失败 点击刷新
    [photo activiViewIsShow:YES];
    [photo onlyShowLoadingView];
    LSImageViewLoader *loader = [LSImageViewLoader loader];
    [loader stop];
    [loader loadImageWithImageView:photo.photoImageView options:0 imageUrl:model.originImgUrl placeholderImage:nil finishHandler:^(UIImage *image) {
        [photo activiViewIsShow:NO];
        if (image) {
            [photo onlyShowImageView];
            [photo showDownloadBtn];
        } else {
           [photo onlyShowLoadFailView];
        }
    }];
}

- (void)emfLadySecretPhotoView:(LSMailLadySecretPhotoView *)photo didBuyPhotoAction:(LSMailAttachmentModel *)model {
    self.secretPhoto = photo;
    [photo activiViewIsShow:YES];
    // 点击使用信用点购买图片
    [self getMailAttachment:model comsumeType:LSLETTERCOMSUMETYPE_CREDIT];
}

-(void)emfLadySecretPhotoView:(LSMailLadySecretPhotoView *)photo didStampBuyPhotoAction:(LSMailAttachmentModel *)model {
    self.secretPhoto = photo;
    [photo activiViewIsShow:YES];
    // 点击使用邮票购买图片
    [self getMailAttachment:model comsumeType:LSLETTERCOMSUMETYPE_STAMP];
}

- (void)emfLadySecretPhotoViewIsHiddenRepresent:(LSMailLadySecretPhotoView *)photo {
    self.secretPhoto = photo;
    if (photo.activiView.hidden) {
        photo.representLabel.hidden = !photo.representLabel.hidden;
        photo.saveAction.hidden = !photo.saveAction.hidden;
        photo.shadowView.hidden = !photo.shadowView.hidden;
    }
}

/**
 *  保存图片下载完成回调
 *
 *  @param image       图片
 *  @param error       成功信息
 *  @param contextInfo 信息内容
 */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *successMsg = NSLocalizedStringFromSelf(@"Photo_Successful_Save");
    NSString *errorMsg = NSLocalizedStringFromSelf(@"Photo_Error");
    if (nil == error) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:successMsg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:okAC];
        [self presentViewController:alertVC animated:YES completion:nil];
    } else {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:errorMsg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:okAC];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

#pragma mark - LSGreetingVideoPlayViewDelegate
- (void)greetingVideoPlayView:(LSGreetingVideoPlayView *)view noReplyReplayVideo:(LSMailAttachmentModel *)model {
    // 未回复重新播放视频
    if (model.videoUrl.length > 0) {
        [view activiViewIsShow:YES];
        self.greetingVideoView = view;
        view.endView.hidden = YES;
        [self.playManager playLdayVideo:model.videoUrl forView:view.videoPlayView playTime:model.videoTime isShowSlider:model.isReplied isShowPlayTime:YES];
    }
}

- (void)greetingVideoPlayView:(LSGreetingVideoPlayView *)view replyGreeting:(LSMailAttachmentModel *)mdoel {
    // 回信回调
    [[LiveModule module].analyticsManager reportActionEvent:GreetingMailClickVideoReply eventCategory:EventCategoryGreetings];
    
    // 跳转至完整回复页
    LSSendMailViewController *vc = [[LSSendMailViewController alloc] initWithNibName:nil bundle:nil];
    vc.sendDelegate = self;
    vc.loiId = self.letterItem.letterId;
    vc.anchorId = self.letterItem.anchorId;
    vc.anchorName = self.letterItem.anchorNickName;
    vc.photoUrl = self.letterItem.anchorAvatar;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)greetingVideoPlayView:(LSGreetingVideoPlayView *)view isReplyReplayVideo:(LSMailAttachmentModel *)model {
    // 已回复重新播放视频
    if (model.videoUrl.length > 0) {
        [view activiViewIsShow:YES];
        self.greetingVideoView = view;
        view.endView.hidden = YES;
        [self.playManager playLdayVideo:model.videoUrl forView:view.videoPlayView playTime:model.videoTime isShowSlider:model.isReplied isShowPlayTime:YES];
    }
}

#pragma mark - LSMailPrivatePlayViewDelegate
- (void)mailPrivatePlayView:(LSMailPrivatePlayView *)view playByStamp:(LSMailAttachmentModel *)model {
    // TODO: 邮票购买视频回调
    self.privateVideoView = view;
    [view activiViewIsShow:YES];
    [self getMailAttachment:model comsumeType:LSLETTERCOMSUMETYPE_STAMP];
}

- (void)mailPrivatePlayView:(LSMailPrivatePlayView *)view playByCredits:(LSMailAttachmentModel *)model {
    // TODO: 信用点购买视频回调
    self.privateVideoView = view;
    [view activiViewIsShow:YES];
    [self getMailAttachment:model comsumeType:LSLETTERCOMSUMETYPE_CREDIT];
}

- (void)mailPrivatePlayView:(LSMailPrivatePlayView *)view unlockPlayVideo:(LSMailAttachmentModel *)model {
    // TODO: 点击播放回调
    if (model.videoUrl.length > 0) {
        [view activiViewIsShow:YES];
        self.privateVideoView = view;
        [view hideenAllView];
        [self.playManager playLdayVideo:model.videoUrl forView:view.videoPlayView playTime:model.videoTime isShowSlider:YES isShowPlayTime:YES];
    }
}

#pragma mark - LSSendMailViewControllerDelegate
- (void)sendMailIsSuccess:(LSSendMailViewController *)vc {
    // 更新状态已回复
    if ([self.attachmentDelegate respondsToSelector:@selector(emfAttachmentViewControllerDidBuyAttachments:)]) {
        [self.attachmentDelegate emfAttachmentViewControllerDidBuyAttachments:self];
    }
}

#pragma mark - LSVideoPlayManagerDelegate
- (void)onRecvVideoDownloadFail {
}

- (void)onRecvVideoDownloadSucceed:(NSString *)path {
}

- (void)onRecvVideoPlayFailed {
    [self.playManager removeNotification];
    
    // TODO: 视频播放失败
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DialogTip dialogTip] showDialogTip:weakSelf.view tipText:NSLocalizedStringFromSelf(@"PLAY_VIDEO_FAILED")];
        
        UIView *vc =  [weakSelf pagingScrollView:weakSelf.pageScrollView pageViewForIndex:weakSelf.photoIndex];
        if ([vc isKindOfClass:[LSMailPrivatePlayView class]]) {
            [weakSelf.privateVideoView activiViewIsShow:NO];
            [weakSelf.privateVideoView showUnlockPlayView];
            
        } else if([vc isKindOfClass:[LSGreetingVideoPlayView class]]) {
            [weakSelf.greetingVideoView activiViewIsShow:NO];
            weakSelf.greetingVideoView.endView.hidden = NO;
            if (weakSelf.greetingVideoView.item.isReplied) {
                weakSelf.greetingVideoView.isReplyView.hidden = NO;
                weakSelf.greetingVideoView.noReplyView.hidden = YES;
            } else {
                weakSelf.greetingVideoView.isReplyView.hidden = YES;
                weakSelf.greetingVideoView.noReplyView.hidden = NO;
            }
        }
    });
}

- (void)onRecvVideoPlayDone {
    [self.playManager removeNotification];
    // TODO: 视频播放完成
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *vc =  [self pagingScrollView:self.pageScrollView pageViewForIndex:self.photoIndex];
        if ([vc isKindOfClass:[LSMailPrivatePlayView class]]) {
            [weakSelf.privateVideoView showUnlockPlayView];
            
        } else if([vc isKindOfClass:[LSGreetingVideoPlayView class]]) {
            [weakSelf.greetingVideoView.videoPlayView bringSubviewToFront:weakSelf.greetingVideoView.videoCoverImageView];
            weakSelf.greetingVideoView.endView.hidden = NO;
            if (weakSelf.greetingVideoView.item.isReplied) {
                weakSelf.greetingVideoView.isReplyView.hidden = NO;
                weakSelf.greetingVideoView.noReplyView.hidden = YES;
            } else {
                weakSelf.greetingVideoView.isReplyView.hidden = YES;
                weakSelf.greetingVideoView.noReplyView.hidden = NO;
            }
        }
    });
}

- (void)onRecvVideoPlayBufferEmpty {
    // TODO:缓冲加载中
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *vc =  [weakSelf pagingScrollView:weakSelf.pageScrollView pageViewForIndex:weakSelf.photoIndex];
        if ([vc isKindOfClass:[LSMailPrivatePlayView class]]) {
            [weakSelf.privateVideoView activiViewIsShow:YES];
        } else if([vc isKindOfClass:[LSGreetingVideoPlayView class]]) {
            [weakSelf.greetingVideoView activiViewIsShow:YES];
        }
    });
}

- (void)onRecvVideoPlayLikelyToKeepUp {
    // TODO:缓冲可以播放
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *vc =  [weakSelf pagingScrollView:weakSelf.pageScrollView pageViewForIndex:weakSelf.photoIndex];
        if ([vc isKindOfClass:[LSMailPrivatePlayView class]]) {
            [weakSelf.privateVideoView activiViewIsShow:NO];
        } else if([vc isKindOfClass:[LSGreetingVideoPlayView class]]) {
            [weakSelf.greetingVideoView activiViewIsShow:NO];
        }
    });
}

#pragma mark - HTTP请求
- (void)getMailAttachment:(LSMailAttachmentModel *)model comsumeType:(LSLetterComsumeType)comsumeType {
    // 更新购买中状态
    [self resetExpenseType:model expenseType:ExpenseTypePaying originImg:nil videoUrl:nil];
    WeakObject(self, weakSelf);
    LSBuyPrivatePhotoVideoRequest *request = [[LSBuyPrivatePhotoVideoRequest alloc] init];
    request.emfId = model.mailId;
    if (model.attachType == AttachmentTypePrivatePhoto) {
        if (model.photoId.length > 0) {
            request.resourceId = model.photoId;
        }
    } else if (model.attachType == AttachmentTypePrivateVideo) {
        if (model.videoId.length > 0) {
            request.resourceId = model.videoId;
        }
    }
    request.comsumeType = comsumeType;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSBuyAttachItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSMailAttachmentViewController::getMailAttachment(购买信件附件 success : %d, errnum : %d, errmsg : %@, originImg : %@, videoUrl : %@)",success, errnum, errmsg, item.originImg, item.videoUrl);
            // 判断当前界面数据是否是购买附件数据
            BOOL isCustent = NO;
            LSMailAttachmentModel *attach = weakSelf.attachmentsArray[weakSelf.photoIndex];
            if (([attach.photoId isEqualToString:model.photoId] && model.photoId.length > 0) || ([attach.videoId isEqualToString:model.videoId] && model.videoId.length > 0)) {
                isCustent = YES;
                [weakSelf.secretPhoto activiViewIsShow:NO];
                [weakSelf.privateVideoView activiViewIsShow:NO];
            }
            
            if (success) {
                // 更新购买成功状态
                [weakSelf resetExpenseType:model expenseType:ExpenseTypeYes originImg:item.originImg videoUrl:item.videoUrl];
                
                // 如果是当前页更新界面显示
                if (isCustent) {
                    UIView *vc =  [weakSelf pagingScrollView:weakSelf.pageScrollView pageViewForIndex:weakSelf.photoIndex];
                    if ([vc isKindOfClass:[LSMailPrivatePlayView class]]) {
                        [weakSelf.privateVideoView showUnlockPlayView];
                    } else if([vc isKindOfClass:[LSMailLadySecretPhotoView class]]) {
                        [weakSelf.secretPhoto onlyShowImageView];
                        [weakSelf.secretPhoto activiViewIsShow:YES];
                        LSImageViewLoader *loader = [LSImageViewLoader loader];
                        [loader stop];
                        [loader loadImageWithImageView:weakSelf.secretPhoto.photoImageView options:0 imageUrl:item.originImg placeholderImage:nil finishHandler:^(UIImage *image) {
                            [weakSelf.secretPhoto activiViewIsShow:NO];
                            if (!image) {
                                [weakSelf.secretPhoto onlyShowLoadFailView];
                            }else {
                                [weakSelf.secretPhoto showDownloadBtn];
                            }
                        }];
                    }
                }
                
                if ([weakSelf.attachmentDelegate respondsToSelector:@selector(emfAttachmentViewControllerDidBuyAttachments:)]) {
                    [weakSelf.attachmentDelegate emfAttachmentViewControllerDidBuyAttachments:weakSelf];
                }
            } else {
                // 当前页显示错误状态
                if (isCustent) {
                    [weakSelf showRequestError:errnum errmsg:errmsg buyAttachment:model];
                }
                // 更新购买失败状态
                [self resetExpenseType:model expenseType:ExpenseTypeNo originImg:nil videoUrl:nil];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)showRequestError:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg buyAttachment:(LSMailAttachmentModel *)model {
    switch (errnum) {
            // 跳转支付页
        case HTTP_LCC_ERR_LETTER_BUYPHOTO_USESTAMP_NOSTAMP_HASCREDIT:
        case HTTP_LCC_ERR_LETTER_BUYPHOTO_USESTAMP_NOSTAMP_NOCREDIT:
        case HTTP_LCC_ERR_LETTER_BUYPHOTO_USECREDIT_NOCREDIT_HASSTAMP:
        case HTTP_LCC_ERR_LETTER_BUYPHOTO_USECREDIT_NOSTAMP_NOCREDIT:
        case HTTP_LCC_ERR_LETTER_BUYPVIDEO_USESTAMP_NOSTAMP_HASCREDIT:
        case HTTP_LCC_ERR_LETTER_BUYPVIDEO_USESTAMP_NOSTAMP_NOCREDIT:
        case HTTP_LCC_ERR_LETTER_BUYPVIDEO_USECREDIT_NOCREDIT_HASSTAMP:
        case HTTP_LCC_ERR_LETTER_BUYPVIDEO_USECREDIT_NOSTAMP_NOCREDIT:{
            LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc]initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            
            // 更新过期状态
        case HTTP_LCC_ERR_LETTER_PHOTO_OVERTIME:
        case HTTP_LCC_ERR_LETTER_VIDEO_OVERTIME:{
            [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            
            // 更新状态过期
            [self resetExpenseType:model expenseType:ExpenseTypeExpire originImg:nil videoUrl:nil];
            
            UIView *vc =  [self pagingScrollView:self.pageScrollView pageViewForIndex:self.photoIndex];
            if ([vc isKindOfClass:[LSMailPrivatePlayView class]]) {
                [self.privateVideoView showExpiredView];
            } else if([vc isKindOfClass:[LSMailLadySecretPhotoView class]]) {
                [self.secretPhoto onlyShowExpiredView];
            }
        }break;
            
        default:{
            [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
        }break;
    }
}

- (void)resetExpenseType:(LSMailAttachmentModel *)model expenseType:(ExpenseType)expenseType originImg:(NSString *)originImg videoUrl:(NSString *)videoUrl {
    for (LSMailAttachmentModel *attachment in self.attachmentsArray) {
        if (([attachment.photoId isEqualToString:model.photoId] && model.photoId.length > 0) || ([attachment.videoId isEqualToString:model.videoId] && model.videoId.length > 0)) {
            attachment.expenseType = expenseType;
            attachment.originImgUrl = originImg;
            attachment.videoUrl = videoUrl;
        }
    }
}

@end
