//
//  LSMailLadySecretPhotoView.h
//  dating
//
//  Created by test on 2017/6/26.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMailAttachmentModel.h"

@class LSMailLadySecretPhotoView;
@protocol LSMailLadySecretPhotoViewDelegate <NSObject>
- (void)emfLadySecretPhotoView:(LSMailLadySecretPhotoView *)photo didStampBuyPhotoAction:(LSMailAttachmentModel *)model;
- (void)emfLadySecretPhotoView:(LSMailLadySecretPhotoView *)photo didBuyPhotoAction:(LSMailAttachmentModel *)model;
- (void)emfLadySecretPhotoView:(LSMailLadySecretPhotoView *)photo didRetryDownPhotoAction:(LSMailAttachmentModel *)model;
- (void)emfLadySecretPhotoView:(LSMailLadySecretPhotoView *)photo didDownPhotoAction:(LSMailAttachmentModel *)model;
- (void)emfLadySecretPhotoViewIsHiddenRepresent:(LSMailLadySecretPhotoView *)photo;
@end

@interface LSMailLadySecretPhotoView : UIView <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UIButton *saveAction;

@property (weak, nonatomic) IBOutlet UIButton *stampsBuyBtn;

@property (weak, nonatomic) IBOutlet UIButton *creditsBuyButton;

@property (weak, nonatomic) IBOutlet UIButton *retryBtn;

@property (weak, nonatomic) IBOutlet UILabel *noteLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noteLabelTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noteLabelBottom;

@property (weak, nonatomic) IBOutlet UILabel *representLabel;

@property (weak, nonatomic) IBOutlet UIView *photoLockView;
@property (weak, nonatomic) IBOutlet UILabel *buyPhotoTipLabel;

@property (weak, nonatomic) IBOutlet UIView *loadPhotoFailView;

@property (weak, nonatomic) IBOutlet UIView *photoExpiredView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activiView;

@property (weak, nonatomic) IBOutlet UIView *shadowView;

/** 相册 */
@property (nonatomic, strong) LSMailAttachmentModel* item;

/** 代理 */
@property (nonatomic, weak) id<LSMailLadySecretPhotoViewDelegate> photoDelegate;


- (void)onlyShowLoadingView;
- (void)onlyShowImageView;
- (void)onlyShowExpiredView;
- (void)onlyShowBuyView;
- (void)onlyShowLoadFailView;
- (void)activiViewIsShow:(BOOL)isShow;
- (void)showDownloadBtn;
@end
