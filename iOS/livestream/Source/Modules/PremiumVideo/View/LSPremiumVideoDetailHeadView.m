//
//  LSPremiumVideoDetailHeadView.m
//  livestream
//
//  Created by Calvin on 2020/8/3.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPremiumVideoDetailHeadView.h"
#import "LSPremiumVideoView.h"
#import "Masonry.h"
#import "LSShadowView.h"
#import "LSImageViewLoader.h"
@interface LSPremiumVideoDetailHeadView ()<LSPremiumVideoViewDelegate>
@property (nonatomic, strong) LSPremiumVideoView * premiumVideoView;
@property (nonatomic, strong) LSPremiumVideoDetailItemObject * detailItem;
@property (nonatomic, strong) LSImageViewLoader * nextImageViewLoader;
@property (nonatomic, strong) LSImageViewLoader * imageViewLoader;
@property (nonatomic, copy) NSString * nextVideoId;
@end

@implementation LSPremiumVideoDetailHeadView

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;

    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.freeTipTitleView.layer.cornerRadius = 6;
    self.freeTipTitleView.layer.masksToBounds = YES;
    
    self.retryBtn.layer.cornerRadius = self.retryBtn.tx_height/2;
    self.retryBtn.layer.masksToBounds = YES;
    
    self.backBtn.layer.cornerRadius = self.backBtn.tx_height/2;
    self.backBtn.layer.masksToBounds = YES;
    
    self.nextVideoImage.layer.cornerRadius = 2;
    self.nextVideoImage.layer.masksToBounds = YES;
    
    LSShadowView * view = [[LSShadowView alloc]init];
    [view showShadowAddView:self.backBtn];
    
    if (SCREEN_WIDTH == 320) {
        self.freeTipTitleViewW.constant = 280;
    }
    
    self.nextImageViewLoader = [LSImageViewLoader loader];
    self.imageViewLoader = [LSImageViewLoader loader];
}

- (void)deleteVideo {
    [self.premiumVideoView deleteVideo];
}

- (void)setHeadViewUI:(LSPremiumVideoDetailItemObject *)item {
    self.detailItem = item;
    if (!self.premiumVideoView) {
        self.premiumVideoView = [[LSPremiumVideoView alloc]init];
        self.premiumVideoView.delegate = self;
        [self.videoView addSubview:self.premiumVideoView];
        [self.premiumVideoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self.videoView);
        }];
    }
    [self.premiumVideoView setUI:item];
    [self setVideoTitle:item];
}

- (void)setNextVideoUI:(LSPremiumVideoinfoItemObject *)item {
    self.nextVideoId = item.videoId;
    [self.nextImageViewLoader loadImageWithImageView:self.nextVideoImage options:0 imageUrl:item.coverUrlPng placeholderImage:nil finishHandler:nil];
    
    [self.imageViewLoader loadImageWithImageView:self.videoCoverImage options:0 imageUrl:self.detailItem.coverUrlPng placeholderImage:nil finishHandler:nil];
    
    self.nextVideoTitle.text = item.title;
    self.nextVideosubTitle.text = item.describe;
    self.nextVideoTime.text = [self convertTime:item.duration];
}

+ (NSMutableAttributedString *)getTitleStr:(LSPremiumVideoDetailItemObject *)item {
    NSMutableString * typeStr = [NSMutableString string];
    for (LSPremiumVideoTypeItemObject *obj in item.typeList) {
        [typeStr appendString:[NSString stringWithFormat:@" #%@ ",obj.typeName]];
    }
    NSString * title = @"";
    if (typeStr.length > 0) {
        title = [NSString stringWithFormat:@"%@%@",item.title,typeStr];
    }else {
        title = [NSString stringWithFormat:@"%@",item.title];
        return [[NSMutableAttributedString alloc]initWithString:title];
    }
     
    NSMutableAttributedString * attr = [[NSMutableAttributedString alloc]initWithString:title];
    
    [attr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x383838) range:[title rangeOfString:item.title]];
    [attr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial-BoldMT" size:16] range:[title rangeOfString:item.title]];
        [attr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x666666) range:[title rangeOfString:typeStr]];
        [attr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialMT" size:14] range:[title rangeOfString:typeStr]];
    return attr;
}

+ (CGFloat)getContentH:(LSPremiumVideoDetailItemObject *)item isShowSub:(BOOL)isShow {
    
     CGRect rect = [[LSPremiumVideoDetailHeadView getTitleStr:item] boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 76, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    
    CGFloat subH = 0;
    if (isShow) {
        subH = [LSPremiumVideoDetailHeadView getsubH:item.describe];
    }
    
    return ceil(rect.size.height + SCREEN_WIDTH * (9.0/16.0) + subH + 42);
}

- (CGFloat)getTitleH:(LSPremiumVideoDetailItemObject *)item {
    CGRect rect = [[LSPremiumVideoDetailHeadView getTitleStr:item] boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 76, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    return ceil(rect.size.height);
}

+ (CGFloat)getsubH:(NSString *)subStr {
    CGRect rect = [subStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 40, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"ArialMT" size:14]} context:nil];
    return ceil(rect.size.height);
}

- (void)setVideoTitle:(LSPremiumVideoDetailItemObject *)item {
    self.titleLabel.attributedText = [LSPremiumVideoDetailHeadView getTitleStr:item];
    self.titleH.constant = [self getTitleH:item];
    
    self.subLabel.text = item.describe;
}

#pragma mark - VideoViewDelegate
- (void)onRecvVideoViewPlayDone {
    if (self.detailItem.lockStatus == LSLOCKSTATUS_UNLOCK) {
        self.nextVideoView.hidden = NO;
    }else {
      self.freeTipView.hidden = NO;
    }
}

- (void)premiumVideoViewDidFreePlay {
    
}

- (void)premiumVideoViewDidBigPlay {
    
}

- (void)premiumVideoViewDidPlay {
    
}

- (void)premiumVideoViewDidFollowBtn {
    if ([self.delegate respondsToSelector:@selector(premiumVideoDetailHeadViewDidFollowBtnDid)]) {
        [self.delegate premiumVideoDetailHeadViewDidFollowBtnDid];
    }
}
#pragma mark - MoveBtn点击事件
- (IBAction)moveBtnDid:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        sender.transform = CGAffineTransformMakeRotation(M_PI);
        self.subH.constant = [LSPremiumVideoDetailHeadView getsubH:self.subLabel.text];
    }else {
        sender.transform = CGAffineTransformIdentity;
        self.subH.constant = 0;
    }
    
    if ([self.delegate respondsToSelector:@selector(premiumVideoDetailHeadViewShowSub:)]) {
        [self.delegate premiumVideoDetailHeadViewShowSub:sender.selected];
    }
}

- (IBAction)closeBtnDid:(id)sender {
    self.freeTipView.hidden = YES;
}

- (IBAction)retryBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(premiumVideoDetailHeadViewDidRetryBtnDid)]) {
        [self.delegate premiumVideoDetailHeadViewDidRetryBtnDid];
    }
}

- (IBAction)backBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(premiumVideoDetailHeadViewDidBackBtnDid)]) {
        [self.delegate premiumVideoDetailHeadViewDidBackBtnDid];
    }
}

- (IBAction)replayBtnDid:(id)sender {
    self.nextVideoView.hidden = YES;
    [self.premiumVideoView replay];
}

- (IBAction)nextVideoBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(premiumVideoDetailHeadViewDidNextVideoBtnDid:)]) {
        [self.delegate premiumVideoDetailHeadViewDidNextVideoBtnDid:self.nextVideoId];
    }
}

- (NSString *)convertTime:(CGFloat)second {
    // 相对格林时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    NSString *showTimeNew = [formatter stringFromDate:date];
    return showTimeNew;
}
@end
