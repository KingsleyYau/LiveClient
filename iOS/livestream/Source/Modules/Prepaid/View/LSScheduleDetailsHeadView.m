//
//  LSScheduleDetailsHeadView.m
//  livestream
//
//  Created by Calvin on 2020/4/20.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleDetailsHeadView.h"
#import "LSPrePaidManager.h"
#import "LSDateTool.h"
#import "LSLoginManager.h"
#import "LSTimer.h"
@interface LSScheduleDetailsHeadView ()
@end

@implementation LSScheduleDetailsHeadView

- (instancetype)init {
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSScheduleDetailsHeadView" owner:self options:0].firstObject;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xe2e2e2).CGColor;
    self.contentView.layer.borderWidth = 1;
    
    self.headImage.layer.cornerRadius = self.headImage.tx_height/2;
    self.headImage.layer.masksToBounds = YES;
    
    self.imageViewLoader = [LSImageViewLoader loader];
    
    self.statusView.hidden = YES;
    self.cancelStatuView.hidden = YES;
    self.onlineIcon.hidden = YES;
    
    self.sentTimeLabel.text = @"";
    self.updateTimeLabel.text = @"";
}

- (void)updateSentTime:(LSScheduleInviteDetailItemObject *)item {
    self.statusView.hidden = NO;
    self.cancelStatuView.hidden = YES;
    self.arrowIcon.hidden = YES;
    self.durationLabel.hidden = NO;
    self.durationBtn.hidden = NO;
    self.durationBtnHeight.constant = 0;
    self.cancelBtnWidth.constant = 0;
    self.furtherViewHeight.constant = 0;
    
    if (item.sendFlag == LSSCHEDULESENDFLAGTYPE_MAN) {
        self.titleLabel.text = NSLocalizedStringFromSelf(@"TITLE_TIP");
    } else {
        self.titleLabel.text = NSLocalizedStringFromSelf(@"uxa-nc-dd9.text");
    }
    
    NSString *zone = [NSString stringWithFormat:@"%@(%@)",item.timeZoneCity,item.timeZoneValue];
    self.timeZoneLabel.text = zone;
    
    NSString *startTime =[[LSPrePaidManager manager] getDetailStartAndEndTimestamp:item.startTime timeFormat:@"MMM dd, YYYY HH:00" isDaylightSaving:item.isSummerTime andZone:item.timeZoneValue];
    self.startTimeLabel.text = startTime;
    
    NSString *localTime = [[LSPrePaidManager manager] getDetailStartAndEndTimestamp:item.startTime timeFormat:@"MMM dd, YYYY HH:mm" isDaylightSaving:item.isSummerTime andZone:@""];
    self.localTimeLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"gi5-6p-RgM.text"),localTime];
    
    NSString *duration = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"MINUTE"),item.duration];
    self.durationLabel.text = duration;
    
    NSString * statusStr = @"";
    switch (item.status) {
        // Pending
        case LSSCHEDULEINVITESTATUS_PENDING:{
            self.statusLabel.textColor =  COLOR_WITH_16BAND_RGB(0xFF8837);
            if (item.sendFlag == LSSCHEDULESENDFLAGTYPE_MAN) {
                self.statusLabel.text = NSLocalizedStringFromSelf(@"PENDING_HER");
            } else if (item.sendFlag == LSSCHEDULESENDFLAGTYPE_ANCHOR) {
                self.statusLabel.text = NSLocalizedStringFromSelf(@"PENDING_YOU");
                self.durationLabel.hidden = YES;
                self.arrowIcon.hidden = NO;
                self.durationBtnHeight.constant = 26;
                for (int i = 0;i<[LSPrePaidManager manager].creditsArray.count;i++) {
                    LSScheduleDurationItemObject * cItem = [LSPrePaidManager manager].creditsArray[i];
                    if (cItem.duration == item.duration) {
                        [self setDurationData:cItem];
                        break;
                    }
                }
            }
        }break;
        // Confirmed
        case LSSCHEDULEINVITESTATUS_CONFIRMED:{
            self.statusLabel.text = NSLocalizedStringFromSelf(@"ACCEPT_STATUS");
            self.statusLabel.textColor =  COLOR_WITH_16BAND_RGB(0x04c456);
            //开播前6小时可以取消
            NSInteger now = [[NSDate date] timeIntervalSince1970];
            if (item.startTime - now > 21600) {
                self.cancelBtnWidth.constant = 59;
            }else {
                 self.cancelBtnWidth.constant = 0;
            }
            
            self.furtherViewHeight.constant = 123;
            int day = 0;
            int hour = 0;
            int minute = 0;
            if (item.startTime > now) {
                NSDate *start = [NSDate dateWithTimeIntervalSince1970:item.startTime];
                NSDateComponents *delta = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:[NSDate date] toDate:start options:0];
                int totalMinute = (int)delta.minute;
                day = floor(totalMinute / (24 * 60));
                hour = floor((totalMinute - (day * 24 * 60)) / 60);
                minute = floor(totalMinute - (day * 24 * 60) - (hour * 60));
            }
            self.dayLabel.text = [NSString stringWithFormat:@"%d",day];
            self.hoursLabel.text = [NSString stringWithFormat:@"%d",hour];
            self.minutesLabel.text = [NSString stringWithFormat:@"%d",minute];
            
            statusStr = [NSString stringWithFormat:@"%@: ",NSLocalizedStringFromSelf(@"ACCEPT_STATUS")];
        }break;
        // Canceled
        case LSSCHEDULEINVITESTATUS_CANCELED:{
            self.statusView.hidden = YES;
            self.cancelStatuView.hidden = NO;
            self.canceledTipLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"CANCEL_BY"),item.cancelerName];
            statusStr = [NSString stringWithFormat:@"%@: ",NSLocalizedStringFromSelf(@"CANCEL_STATUS")];
        }break;
        // Declined
        case LSSCHEDULEINVITESTATUS_DECLINED:{
            self.statusLabel.text = NSLocalizedStringFromSelf(@"DECLINED_STATUS");
            self.statusLabel.textColor =  COLOR_WITH_16BAND_RGB(0xff4747);
            statusStr = [NSString stringWithFormat:@"%@: ",NSLocalizedStringFromSelf(@"DECLINED_STATUS")];
        }break;
        // Expired
        case LSSCHEDULEINVITESTATUS_EXPIRED:{
            self.statusLabel.text = NSLocalizedStringFromSelf(@"EXPIR_STATUS");
            self.statusLabel.textColor =  COLOR_WITH_16BAND_RGB(0xFE6903);
        }break;
        // Completed
        case LSSCHEDULEINVITESTATUS_COMPLETED:{
            self.statusLabel.text = NSLocalizedStringFromSelf(@"COMPLET_STATUS");
            self.statusLabel.textColor =  COLOR_WITH_16BAND_RGB(0x383838);
            statusStr = [NSString stringWithFormat:@"%@: ",NSLocalizedStringFromSelf(@"ACCEPT_STATUS")];
        }break;
        // Missed
        case LSSCHEDULEINVITESTATUS_MISSED:{
            self.statusLabel.text = NSLocalizedStringFromSelf(@"MISS_STATUS");
            self.statusLabel.textColor =  COLOR_WITH_16BAND_RGB(0x383838);
            statusStr = [NSString stringWithFormat:@"%@: ",NSLocalizedStringFromSelf(@"MISS_STATUS")];
        }break;

        default:{
        }break;
    }
    if (statusStr.length > 0) {
        self.updateTimeLabel.text = [NSString stringWithFormat:@"%@%@",statusStr,[[LSPrePaidManager manager] getGMTFromTimestamp:item.statusUpdateTime timeFormat:@"MMM dd, HH:mm"]];
    } else {
        if (item.status == LSSCHEDULEINVITESTATUS_PENDING) {
            self.updateTimeLabel.text = NSLocalizedStringFromSelf(@"PENDING_TIME");
        } else {
            self.updateTimeLabel.text = NSLocalizedStringFromSelf(@"EXPIRED_TIME");
        }
    }
    self.sentTimeLabel.text = [NSString stringWithFormat:@"Sent:%@",[[LSPrePaidManager manager] getGMTFromTimestamp:item.addTime timeFormat:@"MMM dd, HH:mm"]];
}
 
- (void)updateUI:(LSScheduleInviteListItemObject *)item {
    self.chatBtnWidth.constant = 25;
    self.chatBtnRight.constant = 12;
    
    self.idLabel.text = [NSString stringWithFormat:@"ID:%@",item.inviteId];
    self.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:item.anchorInfo.nickName attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
                    NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x2D89F9),
                    NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
    self.ladyIDLabel.text = [NSString stringWithFormat:@"(%@)",item.anchorInfo.anchorId];
    [self.imageViewLoader loadImageFromCache:self.headImage options:0 imageUrl:item.anchorInfo.avatarImg placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {
        
    }];
    self.yrsLabel.text = [NSString stringWithFormat:@"%dyrs / %@",item.anchorInfo.age,item.anchorInfo.country];
    if (item.anchorInfo.onlineStatus == ONLINE_STATUS_LIVE) {
        self.onlineIcon.hidden = NO;
    } else {
        self.onlineIcon.hidden = YES;
        self.chatBtnWidth.constant = 0;
        self.chatBtnRight.constant = 0;
    }
}

- (void)setDurationData:(LSScheduleDurationItemObject *)item {
    if (item.credit != item.originalCredit) {
          NSString * str = [NSString stringWithFormat:@"%d Minutes - %0.2f Credits %0.2f Credits",item.duration,item.credit,item.originalCredit];
             NSString * str1 = [NSString stringWithFormat:@"%0.2f Credits",item.originalCredit];
         NSMutableAttributedString * attrStr =  [[LSPrePaidManager manager] newCreditsStr:str credits:str1];
        [self.durationBtn setAttributedTitle:attrStr forState:UIControlStateNormal];
    } else {
        NSString * str = [NSString stringWithFormat:@"%d Minutes - %0.2f Credits",item.duration,item.credit];
        NSMutableAttributedString * attrStr =  [[LSPrePaidManager manager] newCreditsStr:str credits:@""];
       [self.durationBtn setAttributedTitle:attrStr forState:UIControlStateNormal];
    }
}

- (IBAction)nameAndHeadDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(scheduleDetailsHeadViewDidHeadAndNameBtn)]) {
        [self.delegate scheduleDetailsHeadViewDidHeadAndNameBtn];
    }
}
 
- (IBAction)giftBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(scheduleDetailsHeadViewDidGfitBtn)]) {
        [self.delegate scheduleDetailsHeadViewDidGfitBtn];
    }
}

- (IBAction)mailBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(scheduleDetailsHeadViewDidMailBtn)]) {
        [self.delegate scheduleDetailsHeadViewDidMailBtn];
    }
}

- (IBAction)chatBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(scheduleDetailsHeadViewDidChatBtn)]) {
        [self.delegate scheduleDetailsHeadViewDidChatBtn];
    }
}

- (IBAction)cancelTipBtnDid:(id)sender {
    if (self.canceledTipView.isHidden) {
        self.canceledTipView.hidden = NO;
        WeakObject(self, weakSelf);
        LSTimer *timer = [[LSTimer alloc] init];
        [timer startTimer:dispatch_get_main_queue() timeInterval:3.0 * NSEC_PER_SEC starNow:NO action:^{
            weakSelf.canceledTipView.hidden = YES;
            [timer stopTimer];
        }];
    }
}

- (IBAction)cancelBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(scheduleDetailsHeadViewDidCancelBtn)]) {
        [self.delegate scheduleDetailsHeadViewDidCancelBtn];
    }
}

- (IBAction)didChangeDuration:(id)sender {
    if ([self.delegate respondsToSelector:@selector(scheduleDetailsHeadViewDidDurationBtn)]) {
        [self.delegate scheduleDetailsHeadViewDidDurationBtn];
    }
}


@end
