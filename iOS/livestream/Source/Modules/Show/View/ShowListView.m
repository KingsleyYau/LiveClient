//
//  ShowListView.m
//  livestream
//
//  Created by Calvin on 2018/4/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "ShowListView.h"
#import "LSYYWebImage/Categories/UIImageView+LSYYWebImage.h"

@interface ShowListView ()
//type 1是进入直播间，2是买点 3女士详情
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) LSProgramItemObject * item;
@end

@implementation ShowListView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.button.layer.cornerRadius = self.button.frame.size.height/2;
    self.button.layer.masksToBounds = YES;
    
    self.subButton.layer.cornerRadius = self.subButton.frame.size.height/2;
    self.subButton.layer.masksToBounds = YES;
    
    self.onGingView.layer.cornerRadius = self.onGingView.frame.size.height/2;
    self.onGingView.layer.masksToBounds = YES;
    
    self.otherShowBtn.layer.cornerRadius = self.otherShowBtn.frame.size.height/2;
    self.otherShowBtn.layer.masksToBounds = YES;
    
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
    
    if ([self.delegates respondsToSelector:@selector(showListViewBtnDid: fromItem:)]) {
        [self.delegates showListViewBtnDid:self.type fromItem:self.item];
    }
}

- (void)loadLadyInfo:(LSProgramItemObject *)item
{
    //[self.imageViewLoader stop];
    if (!self.imageViewLoader) {
        self.imageViewLoader = [LSImageViewLoader loader];
    }
    [self.imageViewLoader loadImageFromCache:self.headImage options:0 imageUrl:item.anchorAvatar placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {
    }];

    [self.bgImageViewLoader stop];
    if (!self.bgImageViewLoader) {
        self.bgImageViewLoader = [LSImageViewLoader loader];
    }

    [self.bgImageViewLoader loadImageWithImageView:self.showBGView options:0 imageUrl:item.cover placeholderImage:[UIImage imageNamed:@"ShowBG"] finishHandler:nil];

    self.showBGView.layer.masksToBounds = YES;
 

    self.nameLabel.text = item.anchorNickName;
    
    self.titleLabel.text = item.showTitle;
}

- (void)updateUI:(LSProgramItemObject *)item
{
    self.item = item;
    [self loadLadyInfo:item];
    //更新节目时间，节目时长，节目价格
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    stampFormatter.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    [stampFormatter setDateFormat:@"MMM dd,HH:mm"];
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:item.startTime];
    NSString *timeStr = [stampFormatter stringFromDate:timeDate];
    self.dataLabel.text = timeStr;
    
    self.minLabel.text = [NSString stringWithFormat:@"%d min",item.duration];
    
    self.priceLabel.text = [NSString stringWithFormat:@"%0.1f credits",item.price];
    //是否关注
    if (item.isHasFollow) {
        self.notifiIcon.image = [UIImage imageNamed:@"ShowNoticeIconBlack"];
    }
    else
    {
        self.notifiIcon.image = [UIImage imageNamed:@"ShowNoticeIcon"];
    }
    
    self.button.userInteractionEnabled = NO;
    self.subButton.hidden = YES;
    self.otherShowBtn.hidden = YES;
    self.onGingView.hidden = YES;
    BOOL isShowGoing = NO;
    //审核通过
    if (item.status == PROGRAMSTATUS_VERIFYPASS) {
        //未开始
        NSInteger time = item.leftSecToEnter;
        if (time > 0) {
            self.infoLabel.text = @"";
            self.onGingView.hidden = YES;
            
            //是否已买票
            if (item.ticketStatus == PROGRAMTICKETSTATUS_BUYED) {
                //未开始，已购票的节目，点击可查看详情
                //reserved按钮禁用
                [self updateButtonTitle:@"Reserved" AndColor:COLOR_WITH_16BAND_RGB(0xFDB75E)];
            }
            else
            {
                //是否已满座
                if (!item.isTicketFull) {
                    //未开始，可购票的节目
                    [self updateButtonTitle:@"Get Ticket" AndColor:COLOR_WITH_16BAND_RGB(0xFC8707)];
                    self.type = 2;
                    self.button.userInteractionEnabled = YES;
                }
                else
                {
                    //满座
                    //未开始，门票已购完的节目，置灰禁用按钮
                    self.type = 3;
                    self.infoLabel.text = @"";
                    self.subButton.hidden = NO;
                    self.otherShowBtn.hidden = NO;
                    self.button.userInteractionEnabled = YES;
                }
            }
        }
        else
        {
            //开始节目
            self.onGingView.hidden = NO;
            self.onGingLabel.text = @"On Going Show";
            self.infoLabel.text = @"";
            self.onGingIcon.image = [UIImage imageNamed:@"ShowOnGoingIcon"];
            self.type = 1;
             isShowGoing = YES;
            //是否已买票
            if (item.ticketStatus == PROGRAMTICKETSTATUS_BUYED) {
                //已购票且可以进入的节目
                self.infoLabel.text = @"You have reserved";
            }
            
            [self updateButtonTitle:@"Watch Now" AndColor:COLOR_WITH_16BAND_RGB(0x30C603)];
            
            self.button.userInteractionEnabled = YES;
        }
        
        NSInteger startTime = item.leftSecToStart;
        //开播前30分钟
        if (!isShowGoing && startTime <= 30 * 60) {
            self.onGingView.hidden = NO;
            self.onGingLabel.text = [NSString stringWithFormat:@"Starting in %0.fmin",ceilf(startTime/60.0)];
            self.onGingIcon.image = [UIImage imageNamed:@"ShowTimeIcon"];
        }
    }
    //取消或者失约
    else if (item.status == PROGRAMSTATUS_PROGRAMCALCEL ||
             item.status == PROGRAMSTATUS_OUTTIME)
    {
        //当前节目时间已开始但主播失约或节目被取消，置灰禁用按钮
        self.onGingView.hidden = YES;
        self.infoLabel.text = @"";
        //是否已买票
        if (item.ticketStatus == PROGRAMTICKETSTATUS_BUYED ||
            item.ticketStatus == PROGRAMTICKETSTATUS_OUT) {
            //已购票且可以进入的节目
            self.infoLabel.text = @"Ticket Refunded";
        }
        //置灰禁用按钮
        [self updateButtonTitle:@"Cancelled" AndColor:COLOR_WITH_16BAND_RGB(0xA3A3A3)];
    }
    else
    {
        self.onGingView.hidden = YES;
        self.infoLabel.text = @"";
        //置灰禁用按钮
        [self updateButtonTitle:@"Cancelled" AndColor:COLOR_WITH_16BAND_RGB(0xA3A3A3)];
    }

}

- (void)updateHistoryUI:(LSProgramItemObject *)item {
    
    self.item = item;
    [self loadLadyInfo:item];
    //更新节目时间，节目时长，节目价格
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    stampFormatter.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    [stampFormatter setDateFormat:@"MMM dd,HH:mm"];
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:item.startTime];
    NSString *timeStr = [stampFormatter stringFromDate:timeDate];
    self.dataLabel.text = timeStr;
    
    self.minLabel.text = [NSString stringWithFormat:@"%d min",item.duration];
    
    self.priceLabel.text = [NSString stringWithFormat:@"%0.1f credits",item.price];
    //是否关注
    if (item.isHasFollow) {
        self.notifiIcon.image = [UIImage imageNamed:@"ShowNoticeIconBlack"];
    }
    else
    {
        self.notifiIcon.image = [UIImage imageNamed:@"ShowNoticeIcon"];
    }
    
    self.button.userInteractionEnabled = NO;
    self.subButton.hidden = YES;
    self.otherShowBtn.hidden = YES;
    self.onGingView.hidden = YES;
    
    if (item.ticketStatus == PROGRAMTICKETSTATUS_OUT) {
        //置灰禁用按钮
        [self updateButtonTitle:@"Refunded" AndColor:COLOR_WITH_16BAND_RGB(0xA3A3A3)];
    }
    else
    {
        //置灰禁用按钮
        [self updateButtonTitle:@"Finished" AndColor:COLOR_WITH_16BAND_RGB(0xA3A3A3)];
    }
}
@end
