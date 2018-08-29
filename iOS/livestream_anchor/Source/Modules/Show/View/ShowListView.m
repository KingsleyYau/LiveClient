//
//  ShowListView.m
//  livestream
//
//  Created by Calvin on 2018/4/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "ShowListView.h"
#import "LSYYWebImage/Categories/UIImageView+LSYYWebImage.h"
#import "LSLoginManager.h"
@interface ShowListView ()
@property (nonatomic, strong) LSAnchorProgramItemObject * item;
@property (nonatomic, assign) BOOL isShowGoing;
@end

@implementation ShowListView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.button.layer.cornerRadius = self.button.frame.size.height/2;
    self.button.layer.masksToBounds = YES;
    
    self.onGingView.layer.cornerRadius = self.onGingView.frame.size.height/2;
    self.onGingView.layer.masksToBounds = YES;
    
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    
    self.headImage.layer.cornerRadius = self.headImage.frame.size.height/2;
    self.headImage.layer.masksToBounds = YES;
    self.headImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headImage.layer.borderWidth = 1;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        
        self.frame = frame;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        NSBundle *bundle = [LiveBundle mainBundle];
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle] instantiateWithOwner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        [self addSubview:containerView];
    }
    return self;
}

- (void)updateButtonTitle:(NSString *)str AndColor:(UIColor *)color
{
    self.button.backgroundColor = color;
    [self.button setTitle:str forState:UIControlStateNormal];
}

- (IBAction)buttonDid:(UIButton *)sender {
    
    if (self.isShowGoing && [self.delegates respondsToSelector:@selector(showListViewBtnDidFromItem:)]) {
        [self.delegates showListViewBtnDidFromItem:self.item];
    }
}

- (void)loadLadyInfo:(LSAnchorProgramItemObject *)item
{
    [self.imageViewLoader stop];
    if (!self.imageViewLoader) {
        self.imageViewLoader = [LSImageViewLoader loader];
    }
    [self.imageViewLoader refreshCachedImage:self.headImage options:0 imageUrl:[LSLoginManager manager].loginItem.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];

    [self.bgImageViewLoader stop];
    if (!self.bgImageViewLoader) {
        self.bgImageViewLoader = [LSImageViewLoader loader];
    }

    [self.bgImageViewLoader loadImageWithImageView:self.showBGView options:0 imageUrl:item.cover placeholderImage:[UIImage imageNamed:@"ShowBG"]];

    self.showBGView.layer.masksToBounds = YES;

    self.nameLabel.text = [LSLoginManager manager].loginItem.nickName;
    
    self.titleLabel.text = item.showTitle;
    
    //更新节目时间，节目时长，节目价格
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    stampFormatter.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    [stampFormatter setDateFormat:@"MMM dd,HH:mm"];
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:item.startTime];
    NSString *timeStr = [stampFormatter stringFromDate:timeDate];
    self.dataLabel.text = timeStr;
    
    self.minLabel.text = [NSString stringWithFormat:@"%d min",item.duration];
    
    self.priceLabel.text = [NSString stringWithFormat:@"%d ",item.ticketNum];
}

- (void)updateUI:(LSAnchorProgramItemObject *)item
{
    self.item = item;
    [self loadLadyInfo:item];
    
    //审核通过
    if (item.status == ANCHORPROGRAMSTATUS_VERIFYPASS) {
        self.isShowGoing = NO;
        //未开始
        NSInteger enterTime = item.leftSecToEnter;
        if (enterTime > 0) {
            self.onGingView.hidden = YES;
            [self updateButtonTitle:@"Start Show" AndColor:COLOR_WITH_16BAND_RGB(0xA3A3A3)];
        }
        else
        {
            //开始节目
            self.onGingView.hidden = NO;
            self.onGingLabel.text = @"On Going Show";
            self.onGingIcon.image = [UIImage imageNamed:@"ShowOnGoingIcon"];
            [self updateButtonTitle:@"Start Show" AndColor:COLOR_WITH_16BAND_RGB(0x297AF3)];
            self.isShowGoing = YES;
        }


        NSInteger startTime = item.leftSecToStart;
        //开播前30分钟开始倒数
        if (!self.isShowGoing && startTime <= 30 * 60) {
            self.onGingView.hidden = NO;
            self.onGingLabel.text = [NSString stringWithFormat:@"Starting in %0.fmin",ceilf(startTime/60.0)];
            self.onGingIcon.image = [UIImage imageNamed:@"ShowTimeIcon"];
        }
    }
} 

- (void)updateHistoryUI:(LSAnchorProgramItemObject *)item {
    
    self.item = item;
    [self loadLadyInfo:item];

    self.onGingView.hidden = YES;
    if (item.status == ANCHORPROGRAMSTATUS_PROGRAMCALCEL ||
        item.status == ANCHORPROGRAMSTATUS_OUTTIME) {
        //置灰禁用按钮
        [self updateButtonTitle:@"Cancelled" AndColor:COLOR_WITH_16BAND_RGB(0xA3A3A3)];
    }
    else
    {
        //置灰禁用按钮
        [self updateButtonTitle:@"Finished" AndColor:COLOR_WITH_16BAND_RGB(0xA3A3A3)];
    }
}
@end
