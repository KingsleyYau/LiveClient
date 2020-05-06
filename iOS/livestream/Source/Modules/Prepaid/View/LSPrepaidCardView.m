//
//  LSPrepaidCardView.m
//  livestream
//
//  Created by Calvin on 2020/3/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPrepaidCardView.h"
#import "LSShadowView.h"
@interface LSPrepaidCardView ()

@end

@implementation LSPrepaidCardView

//- (instancetype)initWithCoder:(NSCoder *)coder {
//    self = [super initWithCoder:coder];
//    if (self) {
//        UIView *containerView = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPrepaidCardView" owner:self options:0].firstObject;
//        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//        containerView.frame = newFrame;
//        [self addSubview:containerView];
//        
//    }
//    return self;
//}

- (instancetype)init {
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPrepaidCardView" owner:self options:0].firstObject;
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    
    self.wartingView.layer.cornerRadius = 2;
    self.wartingView.layer.masksToBounds = YES;
    LSShadowView * wView = [[LSShadowView alloc]init];
    [wView showShadowAddView:self.wartingView];
    
    self.acceptView.layer.cornerRadius = 2;
    self.acceptView.layer.masksToBounds = YES;
    LSShadowView * aView = [[LSShadowView alloc]init];
    [aView showShadowAddView:self.acceptView];
    
    self.declineView.layer.cornerRadius = 2;
    self.declineView.layer.masksToBounds = YES;
    LSShadowView * dView = [[LSShadowView alloc]init];
    [dView showShadowAddView:self.declineView];
    
    self.timeView.layer.cornerRadius = 4;
    self.timeView.layer.masksToBounds = YES;
    LSShadowView * tView = [[LSShadowView alloc]init];
    [tView showShadowAddView:self.timeView];
    
    self.localView.layer.cornerRadius = 4;
    self.localView.layer.masksToBounds = YES;
    LSShadowView * lView = [[LSShadowView alloc]init];
    [lView showShadowAddView:self.localView];
    
    self.wartingInfoView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xFF8837).CGColor;
    self.wartingInfoView.layer.borderWidth = 1;
    
    self.acceptInfoView.layer.borderColor = COLOR_WITH_16BAND_RGB(0x04C456).CGColor;
    self.acceptInfoView.layer.borderWidth = 1;
    
    self.declineInfoView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xFF8837).CGColor;
    self.declineInfoView.layer.borderWidth = 1;
    
    self.wartingView.hidden = YES;
    self.acceptView.hidden = YES;
    self.declineView.hidden = YES;
    self.timeView.hidden = YES;
    self.localTimeView.hidden = YES;
}

- (void)updateUI:(QNMessage *)item ladyName:(NSString *)name {
    
    //是的显示全部
    if (item.isScheduleMore) {
        self.timeView.hidden = NO;
        self.bottomView.hidden = NO;
        self.localTimeView.hidden = YES;
    }else {
        self.timeView.hidden = YES;
        self.bottomView.hidden = YES;
        self.localTimeView.hidden = NO;
    }
    
    self.wartingView.hidden = YES;
    self.acceptView.hidden = YES;
    self.declineView.hidden = YES;
    BOOL isMeSent = NO;
    if ([item.liveChatMsgItemObject.fromId isEqualToString:[LSLoginManager manager].loginItem.userId]) {
        isMeSent = YES;
    }
    
    
    LSLCLiveChatScheduleMsgItemObject* msgItem = item.liveChatMsgItemObject.scheduleMsg;
    
    int duration = msgItem.duration;
    if (duration == 0) {
        duration = msgItem.origintduration;
    }
    
    //发送
    if (msgItem.type == SCHEDULEINVITE_PENDING) {
        self.wartingView.hidden = NO;
        self.wartingLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"WAITING_TITLE"),name];
        
        self.statusLabel.textColor = COLOR_WITH_16BAND_RGB(0xFF8837);
        self.statusLabel.text = NSLocalizedStringFromSelf(@"PENDING");
        
        self.durationLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"DURATION"),duration];
        
        self.comfirmLabel.text =NSLocalizedStringFromSelf(@"NO_CONFIMATION");
        self.updateTimeLabel.text = @"";
     //接受
    }else if (msgItem.type == SCHEDULEINVITE_CONFIRMED) {
        self.acceptView.hidden = NO;
        
        if (isMeSent) {
            self.acceptLabel.text = NSLocalizedStringFromSelf(@"LADY_ACCEPT");
            self.acceptInfoLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"ACCEPTED_TITLE"),name];
        }else {
            self.acceptLabel.text = NSLocalizedStringFromSelf(@"ME_ACCEPT");
            self.acceptInfoLabel.text = NSLocalizedStringFromSelf(@"ACCEPTED_TITLE_ME");
        }
        
        self.statusLabel.textColor = COLOR_WITH_16BAND_RGB(0x04C456);
        self.statusLabel.text = NSLocalizedStringFromSelf(@"CONFIRMED");
        
        NSString * updateTime =  [[LSPrePaidManager manager]getGMTFromTimestamp:msgItem.statusUpdateTime timeFormat:@"MMM dd,HH:mm"];
        self.comfirmLabel.text = @"";
        self.updateTimeLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"TIME_CONFIRMED"),updateTime];
        
        self.durationLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"DURATION"),duration];
        
    }else {
    //拒绝
       self.declineView.hidden = NO;
    
        if (isMeSent) {
            self.declineLabel.text = NSLocalizedStringFromSelf(@"LADY_DECLINE");
            self.declineInfoLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"DECLINED_TITLE"),name];
            
            
        }else {
           self.declineLabel.text = NSLocalizedStringFromSelf(@"ME_DECLINE");
           self.declineInfoLabel.text = NSLocalizedStringFromSelf(@"DECLINED_TITLE_ME");
        }
        
        self.statusLabel.textColor = [UIColor redColor];
        self.statusLabel.text = NSLocalizedStringFromSelf(@"DECLINED");
        
        NSString * updateTime =  [[LSPrePaidManager manager]getGMTFromTimestamp:msgItem.statusUpdateTime timeFormat:@"MMM dd,HH:mm"];
        self.comfirmLabel.text = @"";
        self.updateTimeLabel.text =[NSString stringWithFormat:NSLocalizedStringFromSelf(@"TIME_DECLINED"),updateTime];
        
        self.durationLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"DURATION"),duration];
    }
    
    self.scheduleIDLabel.text = msgItem.scheduleInviteId;
        
     NSString * sentTime =  [[LSPrePaidManager manager]getGMTFromTimestamp:msgItem.sendTime timeFormat:@"MMM dd,HH:mm"];
    self.timeSentLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SENT_TIME"),sentTime];
        
    NSString * startTime = [NSString stringWithFormat:@"%@ %@",msgItem.period,msgItem.timeZone];
    
    self.startTimeViewLabel.text = startTime;
    self.startTimeLabel.text = startTime;
    
    NSString * localBeginTime = [[LSPrePaidManager manager]getLocalTimeFromTimestamp:msgItem.startTime timeFormat:@"MMM dd, HH:mm"];
    
    NSString * endTime =  [[LSPrePaidManager manager]getLocalTimeFromTimestamp:msgItem.startTime timeFormat:@"HH:mm"];

    endTime = [[LSPrePaidManager manager]getEndTime:endTime];
    
    NSString * localTime = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"LOCAL_TIME"),localBeginTime,endTime];
    
    self.localTimeLabel.text = localTime;
    self.localTimeViewLabel.text = localTime;
    
}

- (void)updataInfo:(MsgItem *)item ladyName:(NSString *)name {
    //是的显示全部
    if (item.isScheduleMore) {
        self.timeView.hidden = NO;
        self.bottomView.hidden = NO;
        self.localTimeView.hidden = YES;
    }else {
        self.timeView.hidden = YES;
        self.bottomView.hidden = YES;
        self.localTimeView.hidden = NO;
    }
    
    self.wartingView.hidden = YES;
    self.acceptView.hidden = YES;
    self.declineView.hidden = YES;
    
    BOOL isMe = YES;
    if (item.usersType == UsersType_Me) {
        isMe = NO;
    }

    ImScheduleRoomInfoObject* msgItem = item.scheduleMsg;
    
    int duration = msgItem.msg.duration;
    if (duration == 0) {
        duration = msgItem.msg.origintduration;
    }
    //发送
    if (msgItem.msg.status == IMSCHEDULESENDSTATUS_PENDING) {
        self.wartingView.hidden = NO;
        self.wartingLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"WAITING_TITLE"),name];
        
        self.statusLabel.textColor = COLOR_WITH_16BAND_RGB(0xFF8837);
        self.statusLabel.text = NSLocalizedStringFromSelf(@"PENDING");
        
        self.durationLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"DURATION"),duration];
        
        self.updateTimeLabel.text = @"";
        self.comfirmLabel.text =NSLocalizedStringFromSelf(@"NO_CONFIMATION");
     //接受
    } else if (msgItem.msg.status == IMSCHEDULESENDSTATUS_CONFIRMED) {
        self.acceptView.hidden = NO;
        if (isMe) {
            self.acceptLabel.text = NSLocalizedStringFromSelf(@"LADY_ACCEPT");
            self.acceptInfoLabel.text = NSLocalizedStringFromSelf(@"ACCEPTED_TITLE_ME");
        }else {
            self.acceptLabel.text = NSLocalizedStringFromSelf(@"ME_ACCEPT");
            self.acceptInfoLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"ACCEPTED_TITLE"),name];
        }
        
        self.statusLabel.textColor = COLOR_WITH_16BAND_RGB(0x04C456);
        self.statusLabel.text = NSLocalizedStringFromSelf(@"CONFIRMED");
        
        NSString * updateTime =  [[LSPrePaidManager manager]getGMTFromTimestamp:msgItem.msg.statusUpdateTime timeFormat:@"MMM dd,HH:mm"];
        self.comfirmLabel.text = @"";
        self.updateTimeLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"TIME_CONFIRMED"),updateTime];
        
        self.durationLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"DURATION"),duration];
        
    } else {
    //拒绝
       self.declineView.hidden = NO;
       if (isMe) {
           self.declineLabel.text = NSLocalizedStringFromSelf(@"LADY_DECLINE");
           self.declineInfoLabel.text = NSLocalizedStringFromSelf(@"DECLINED_TITLE_ME");
       }else {
          self.declineLabel.text = NSLocalizedStringFromSelf(@"ME_DECLINE");
          self.declineInfoLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"DECLINED_TITLE"),name];
       }
        
        self.statusLabel.textColor = [UIColor redColor];
        self.statusLabel.text = NSLocalizedStringFromSelf(@"DECLINED");
        
        NSString * updateTime =  [[LSPrePaidManager manager]getGMTFromTimestamp:msgItem.msg.statusUpdateTime timeFormat:@"MMM dd,HH:mm"];
        self.comfirmLabel.text = @"";
        self.updateTimeLabel.text =[NSString stringWithFormat:NSLocalizedStringFromSelf(@"TIME_DECLINED"),updateTime];
        
        self.durationLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"DURATION"),duration];
    }
    
    self.scheduleIDLabel.text = msgItem.msg.scheduleInviteId;
    
     NSString * sentTime =  [[LSPrePaidManager manager]getGMTFromTimestamp:msgItem.msg.sendTime timeFormat:@"MMM dd,HH:mm"];
    self.timeSentLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SENT_TIME"),sentTime];
        
    NSString * startTime = [NSString stringWithFormat:@"%@",msgItem.msg.period];
    
    self.startTimeViewLabel.text = startTime;
    self.startTimeLabel.text = startTime;
    
    NSString * localBeginTime = [[LSPrePaidManager manager]getLocalTimeFromTimestamp:msgItem.msg.startTime timeFormat:@"MMM dd, HH:mm"];
    
    NSString * endTime =  [[LSPrePaidManager manager]getLocalTimeFromTimestamp:msgItem.msg.startTime timeFormat:@"HH:mm"];

    endTime = [[LSPrePaidManager manager]getEndTime:endTime];
    
    NSString * localTime = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"LOCAL_TIME"),localBeginTime,endTime];
    
    self.localTimeLabel.text = localTime;
    self.localTimeViewLabel.text = localTime;
    
}

- (IBAction)subLabelDid:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(prepaidCardViewDidOpenScheduleList)]) {
        [self.delegate prepaidCardViewDidOpenScheduleList];
    }
}

- (IBAction)learnBtnDid:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(prepaidCardViewDidLearnHowWorks)]) {
        [self.delegate prepaidCardViewDidLearnHowWorks];
    }
}

- (IBAction)moreBtnDid:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(prepaidCardViewHidenDetalis)]) {
        [self.delegate prepaidCardViewHidenDetalis];
    }
}

- (IBAction)moreDetailsBtnDid:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(prepaidCardViewShowDetalis)]) {
        [self.delegate prepaidCardViewShowDetalis];
    }
}

@end
