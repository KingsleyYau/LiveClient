//
//  LSMailLadySecretPhotoView.m
//  dating
//
//  Created by test on 2017/6/26.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSMailLadySecretPhotoView.h"

@implementation LSMailLadySecretPhotoView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        LSMailLadySecretPhotoView *contenView = (LSMailLadySecretPhotoView *)[[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        contenView.frame = frame;
        [contenView layoutIfNeeded];
        self = contenView;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.stampsBuyBtn.layer.cornerRadius = 5;
    self.stampsBuyBtn.layer.masksToBounds = YES;
    self.creditsBuyButton.layer.cornerRadius = 5;
    self.creditsBuyButton.layer.masksToBounds = YES;
    self.retryBtn.layer.cornerRadius = 5;
    self.retryBtn.layer.masksToBounds = YES;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)COLOR_WITH_16BAND_RGB(0x2D2D2D).CGColor, (__bridge id)Color(89, 89, 89, 0).CGColor];
    gradientLayer.locations = @[@0.0, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 1.0);
    gradientLayer.endPoint = CGPointMake(0, 0.0);
    gradientLayer.frame = CGRectMake(0, 0, screenSize.width, self.shadowView.bounds.size.height);
    [self.shadowView.layer addSublayer:gradientLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)onlyShowLoadingView {
    self.photoImageView.hidden = YES;
    self.representLabel.hidden = YES;
    self.saveAction.hidden = YES;
    self.shadowView.hidden = YES;
    self.noteLabel.hidden = YES;
    self.noteLabel.text = @"";
    self.photoLockView.hidden = YES;
    self.loadPhotoFailView.hidden = YES;
    self.photoExpiredView.hidden = YES;
}

- (void)onlyShowImageView {
    self.photoImageView.hidden = NO;
    self.representLabel.hidden = NO;
    self.saveAction.hidden = YES;
    self.shadowView.hidden = NO;
    self.noteLabel.hidden = YES;
    self.noteLabel.text = @"";
    self.photoLockView.hidden = YES;
    self.loadPhotoFailView.hidden = YES;
    self.photoExpiredView.hidden = YES;
}

// 只有当图片下载完成之后才显示下载的按钮
- (void)showDownloadBtn {
    self.saveAction.hidden = NO;
}


- (void)onlyShowExpiredView {
    self.photoExpiredView.hidden = NO;
    self.photoImageView.hidden = NO;
    self.representLabel.hidden = NO;
    self.noteLabel.hidden = YES;
    self.noteLabel.text = @"";
    self.noteLabelTop.constant = 0;
    self.saveAction.hidden = YES;
    self.shadowView.hidden = YES;
    self.photoLockView.hidden = YES;
    self.loadPhotoFailView.hidden = YES;
}

- (void)onlyShowBuyView {
    self.photoLockView.hidden = NO;
    self.photoImageView.hidden = NO;
    self.noteLabel.hidden = NO;
    self.noteLabel.text = NSLocalizedStringFromSelf(@"fqh-5U-VKL.text");
    self.representLabel.hidden = NO;
    self.saveAction.hidden = YES;
    self.shadowView.hidden = YES;
    self.loadPhotoFailView.hidden = YES;
    self.photoExpiredView.hidden = YES;
}

- (void)onlyShowLoadFailView {
    self.loadPhotoFailView.hidden = NO;
    self.photoImageView.hidden = YES;
    self.saveAction.hidden = YES;
    self.shadowView.hidden = YES;
    self.noteLabel.hidden = YES;
    self.representLabel.hidden = YES;
    self.photoLockView.hidden = YES;
    self.photoExpiredView.hidden = YES;
}

- (void)activiViewIsShow:(BOOL)isShow {
    if (isShow) {
        [self.activiView startAnimating];
        self.activiView.hidden = NO;
    } else {
        [self.activiView stopAnimating];
        self.activiView.hidden = YES;
    }
}

- (IBAction)stampBuyPhotoAction:(id)sender {
    if (self.photoDelegate && [self.photoDelegate respondsToSelector:@selector(emfLadySecretPhotoView:didStampBuyPhotoAction:)]) {
        [self.photoDelegate emfLadySecretPhotoView:self didStampBuyPhotoAction:self.item];
    }
}

- (IBAction)buyPhotoAction:(id)sender {
    if (self.photoDelegate && [self.photoDelegate respondsToSelector:@selector(emfLadySecretPhotoView:didBuyPhotoAction:)]) {
        [self.photoDelegate emfLadySecretPhotoView:self didBuyPhotoAction:self.item];
    }
}

- (IBAction)retryAction:(id)sender {
    if (self.photoDelegate && [self.photoDelegate respondsToSelector:@selector(emfLadySecretPhotoView:didRetryDownPhotoAction:)]) {
        [self.photoDelegate emfLadySecretPhotoView:self didRetryDownPhotoAction:self.item];
    }
}

- (IBAction)downPhotoAction:(id)sender {
    if (self.photoDelegate && [self.photoDelegate respondsToSelector:@selector(emfLadySecretPhotoView:didDownPhotoAction:)]) {
        [self.photoDelegate emfLadySecretPhotoView:self didDownPhotoAction:self.item];
    }
}

- (IBAction)clickPhotoImage:(id)sender {
    if (self.photoDelegate && [self.photoDelegate respondsToSelector:@selector(emfLadySecretPhotoViewIsHiddenRepresent:)]) {
        [self.photoDelegate emfLadySecretPhotoViewIsHiddenRepresent:self];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    BOOL canUser = NO;
    if (self.noteLabel.text.length <= 0 && self.noteLabel.hidden &&  self.photoLockView.hidden && self.photoExpiredView.hidden && self.loadPhotoFailView.hidden && !self.photoImageView.hidden) {
        canUser = YES;
    }
    return canUser;
}

@end
