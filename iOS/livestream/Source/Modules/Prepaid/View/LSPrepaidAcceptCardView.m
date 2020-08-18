//
//  LSPrepaidAcceptCardView.m
//  livestream
//
//  Created by Calvin on 2020/4/1.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPrepaidAcceptCardView.h"
#import "LSShadowView.h"
#import "LSLoginManager.h"
#import "LSPrePaidManager.h"
@interface LSPrepaidAcceptCardView ()

@end

@implementation LSPrepaidAcceptCardView

//- (instancetype)initWithCoder:(NSCoder *)coder {
//    self = [super initWithCoder:coder];
//    if (self) {
//        UIView *containerView = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPrepaidAcceptCardView" owner:self options:0].firstObject;
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
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPrepaidAcceptCardView" owner:self options:0].firstObject;
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    
    self.bigTitleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bigTitleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    self.bigTitleLabel.layer.shadowOpacity = 0.5;
    
    self.defaultTimeView.layer.cornerRadius = 4;
    self.defaultTimeView.layer.masksToBounds = YES;
    LSShadowView * view1 = [[LSShadowView alloc]init];
    [view1 showShadowAddView:self.defaultTimeView];

    
    self.detailsTimeView.layer.cornerRadius = 4;
    self.detailsTimeView.layer.masksToBounds = YES;
    LSShadowView * view2 = [[LSShadowView alloc]init];
    [view2 showShadowAddView:self.detailsTimeView];
    
    self.defaultAcceptBtn.layer.cornerRadius = self.defaultAcceptBtn.tx_height/2;
    self.defaultAcceptBtn.layer.masksToBounds = YES;
    LSShadowView * view3 = [[LSShadowView alloc]init];
    [view3 showShadowAddView:self.defaultAcceptBtn];
    
    self.acceptBtn.layer.cornerRadius = self.acceptBtn.tx_height/2;
    self.acceptBtn.layer.masksToBounds = YES;
    LSShadowView * view4 = [[LSShadowView alloc]init];
    [view4 showShadowAddView:self.acceptBtn];

    self.defaultView.hidden = YES;
    self.detailsView.hidden = YES;
    
    NSMutableArray * images = [NSMutableArray array];
    for (int i = 1; i <= 7; i++) {
        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"Prelive_Loading%d",i]];
        [images addObject:image];
    }
    self.loadingIcon.animationImages = images;
    self.loadingIcon.animationDuration = 0.6;
    [self.loadingIcon startAnimating];
}

- (void)updateUI:(QNMessage *)item {
    self.loadingView.hidden = YES;
     if (item.isScheduleMore) {
         self.defaultView.hidden = YES;
         self.detailsView.hidden = NO;
     }
     else {
         self.defaultView.hidden = NO;
         self.detailsView.hidden = YES;
     }
    self.titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SCHEDULE_TITLE"),[LSLoginManager manager].loginItem.nickName];
    
     LSLCLiveChatScheduleMsgItemObject* msgItem = item.liveChatMsgItemObject.scheduleMsg;
    
    int duration = msgItem.duration;
    if (duration == 0) {
        duration = msgItem.origintduration;
    }
    for (int i = 0;i<[LSPrePaidManager manager].creditsArray.count;i++) {
        LSScheduleDurationItemObject * cItem = [LSPrePaidManager manager].creditsArray[i];
        if (cItem.duration == duration) {
            [self setDurationData:cItem];
            break;
        }
    }
    
     NSString * sentTime =  [[LSPrePaidManager manager]getGMTFromTimestamp:msgItem.sendTime timeFormat:@"MMM dd, HH:mm"];
    self.timeSentLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SENT_TIME"),sentTime];
    
    self.statusLabel.text = NSLocalizedStringFromSelf(@"PENDING");
    self.startTimeLabel.text =NSLocalizedStringFromSelf(@"NO_CONFIMATION");
    
    self.scheduleIDLabel.text = msgItem.scheduleInviteId;
        
    NSString * startTime = [NSString stringWithFormat:@"%@ %@",msgItem.period,msgItem.timeZone];
    
    self.defaultStartTimeLabel.text = startTime;
    self.startTimeLabel.text = startTime;
    
    NSString * localBeginTime = [[LSPrePaidManager manager]getLocalTimeFromTimestamp:msgItem.startTime timeFormat:@"MMM dd, HH:mm"];
    
    NSString * endTime =  [[LSPrePaidManager manager]getLocalTimeFromTimestamp:msgItem.startTime timeFormat:@"HH:mm"];

    endTime = [[LSPrePaidManager manager]getEndTime:endTime];
    
    NSString * localTime = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"LOCAL_TIME"),localBeginTime,endTime];
    
    self.localTimeLabel.text = localTime;
    self.defaultLocalTimeLabel.text = localTime;
}

- (void)updateInfo:(MsgItem *)item {
    self.loadingView.hidden = YES;
     if (item.isScheduleMore) {
         self.defaultView.hidden = YES;
         self.detailsView.hidden = NO;
     }
     else {
         self.defaultView.hidden = NO;
         self.detailsView.hidden = YES;
     }
    self.titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SCHEDULE_TITLE"),[LSLoginManager manager].loginItem.nickName];
    
     ImScheduleRoomInfoObject* msgItem = item.scheduleMsg;
    int duration = msgItem.msg.duration;
    if (duration == 0) {
        duration = msgItem.msg.origintduration;
    }
    for (int i = 0;i<[LSPrePaidManager manager].creditsArray.count;i++) {
        LSScheduleDurationItemObject * cItem = [LSPrePaidManager manager].creditsArray[i];
        if (cItem.duration == duration) {
            [self setDurationData:cItem];
            break;
        }
    }
    NSString * sentTime =  [[LSPrePaidManager manager] getGMTFromTimestamp:msgItem.msg.sendTime timeFormat:@"MMM dd,HH:mm"];
    self.timeSentLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SENT_TIME"),sentTime];
    
    self.onconfirmLabel.text = NSLocalizedStringFromSelf(@"NO_CONFIMATION");
    self.statusLabel.text = NSLocalizedStringFromSelf(@"PENDING");
    self.startTimeLabel.text = @"";
    
    self.scheduleIDLabel.text = msgItem.msg.scheduleInviteId;
        
    NSString * startTime = [NSString stringWithFormat:@"%@",msgItem.msg.period];
    
    self.defaultStartTimeLabel.text = startTime;
    self.startTimeLabel.text = startTime;
    
    NSString * localBeginTime = [[LSPrePaidManager manager] getLocalTimeFromTimestamp:msgItem.msg.startTime timeFormat:@"MMM dd, HH:mm"];
    
    NSString * endTime =  [[LSPrePaidManager manager] getLocalTimeFromTimestamp:msgItem.msg.startTime timeFormat:@"HH:mm"];

    endTime = [[LSPrePaidManager manager] getEndTime:endTime];
    
    NSString * localTime = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"LOCAL_TIME"),localBeginTime,endTime];
    
    self.localTimeLabel.text = localTime;
    self.defaultLocalTimeLabel.text = localTime;
}

- (void)setDurationData:(LSScheduleDurationItemObject *)item {
    if (item.credit != item.originalCredit) {
          NSString * str = [NSString stringWithFormat:@"%d Minutes - %0.2f Credits %0.2f Credits",item.duration,item.credit,item.originalCredit];
             NSString * str1 = [NSString stringWithFormat:@"%0.2f Credits",item.originalCredit];
         NSMutableAttributedString * attrStr =  [[LSPrePaidManager manager] newCreditsStr:str credits:str1];
        [self.durationBtn setAttributedTitle:attrStr forState:UIControlStateNormal];
        [self.defaultDurationBtn setAttributedTitle:attrStr forState:UIControlStateNormal];
    } else {
        NSString * str = [NSString stringWithFormat:@"%d Minutes - %0.2f Credits",item.duration,item.credit];
        NSMutableAttributedString * attrStr =  [[LSPrePaidManager manager] newCreditsStr:str credits:@""];
       [self.durationBtn setAttributedTitle:attrStr forState:UIControlStateNormal];
       [self.defaultDurationBtn setAttributedTitle:attrStr forState:UIControlStateNormal];
    }
}

- (IBAction)durationBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(prepaidAcceptCardViewDidDuration)]) {
        [self.delegate prepaidAcceptCardViewDidDuration];
    }
}

- (IBAction)acceptBtnDid:(UIButton *)sender {
    self.loadingView.hidden = NO;
    if ([self.delegate respondsToSelector:@selector(prepaidAcceptCardViewDidAcceptBtn)]) {
        [self.delegate prepaidAcceptCardViewDidAcceptBtn];
    }
}

- (IBAction)moreBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(prepaidAcceptCardViewShowDetalis)]) {
        [self.delegate prepaidAcceptCardViewShowDetalis];
    }
}

- (IBAction)arrowBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(prepaidAcceptCardViewHidenDetalis)]) {
        [self.delegate prepaidAcceptCardViewHidenDetalis];
    }
}

- (IBAction)leamBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(prepaidAcceptCardViewDidLearnHowWorks)]) {
        [self.delegate prepaidAcceptCardViewDidLearnHowWorks];
    }
}

- (IBAction)scheduleTap:(id)sender {
    if ([self.delegate respondsToSelector:@selector(prepaidAcceptCardViewDidOpenScheduleList)]) {
        [self.delegate prepaidAcceptCardViewDidOpenScheduleList];
    }
}

@end
