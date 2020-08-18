//
//  LSScheduleContentCell.m
//  livestream
//
//  Created by test on 2020/4/14.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleContentCell.h"
#import "LSDateTool.h"

@implementation LSScheduleContentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.layer.zPosition = 1;
}

+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSString *)detailString {
    
    NSInteger height = 350;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0;  //设置行间距
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:14], NSParagraphStyleAttributeName : paragraphStyle };;
    if(detailString.length > 0) {

        CGRect rect = [detailString boundingRectWithSize:CGSizeMake(width - 93, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
        height += ceil(rect.size.height) + 25;
    }else {
        height += 17;
    }

    return height;
}

- (NSInteger)getLetterHeight:(NSString *)letterContent {
    NSInteger height = 0;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0;  //设置行间距
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:14], NSParagraphStyleAttributeName : paragraphStyle };;
    if(letterContent.length > 0) {

        CGRect rect = [letterContent boundingRectWithSize:CGSizeMake(screenSize.width - 93, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
        height += ceil(rect.size.height) + 20;
    }else {
        height = 17;
    }
    return height;
}



+ (NSInteger)cellHeight {
    return 426;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSScheduleContentCell *cell = (LSScheduleContentCell *)[tableView dequeueReusableCellWithIdentifier:[LSScheduleContentCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSScheduleContentCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
    }
    cell.letterBorder.layer.borderColor = COLOR_WITH_16BAND_RGB(0xC6C6C6).CGColor;
    cell.letterBorder.layer.borderWidth = 1;
    cell.letterBorder.layer.cornerRadius = 4;
    cell.letterBorder.layer.masksToBounds = YES;
    
    cell.timeViewBorder.layer.borderColor = COLOR_WITH_16BAND_RGB(0xC6C6C6).CGColor;
    cell.timeViewBorder.layer.borderWidth = 1;
    cell.timeViewBorder.layer.cornerRadius = 4;
//    cell.timeViewBorder.layer.masksToBounds = YES;
    
    cell.cancelInfoTipNote.userInteractionEnabled = NO;
    cell.cancelInfoTipNote.hidden = YES;

    cell.bgView.layer.cornerRadius = 4;
    cell.bgView.layer.masksToBounds = YES;

    return cell;
}

+ (NSString *)cellIdentifier {
    return @"LSScheduleContentCell";
}



- (void)setupData:(LSHttpLetterDetailItemObject *)item isInbox:(BOOL)isInbox{
    self.ownerMessage.text = isInbox ? [NSString stringWithFormat:@"%@’s Message",item.anchorNickName] :@"Your Message";
    self.letterContentHeight.constant = [self getLetterHeight:item.letterContent];
    self.letterContent.text = item.letterContent;
    self.scheduleBookID.text = item.scheduleInfo.inviteId;
    // 发信时间信件ID
    LSDateTool *tool = [[LSDateTool alloc] init];
    NSString *time = [tool showGreetingDetailTimeOfDate:[NSDate dateWithTimeIntervalSince1970:item.letterSendTime]];
    self.mailDateInfo.text = [NSString stringWithFormat:@"%@ (Mail ID : %@)", time, item.letterId];

    // 发送时间为gtm时间
    NSString *sendTime =  [[LSPrePaidManager manager] getGMTFromTimestamp:item.scheduleInfo.addTime timeFormat:@"MMM dd, HH:mm"];
    self.schdeduleTimeSend.text = [NSString stringWithFormat:@"Time Sent: %@",[sendTime stringByAppendingString:@" (GMT)"]];
    self.scheduleStatusNote.textColor = COLOR_WITH_16BAND_RGB(0x999999);
    self.scheduleStatusNote.font = [UIFont systemFontOfSize:14];
    self.cancelInfoBtn.hidden = YES;
    NSString *infoTipNote = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"CanceledByWho"),item.scheduleInfo.cancelerName];
    [self.cancelInfoTipNote setTitle:infoTipNote forState:UIControlStateNormal];
    switch (item.scheduleInfo.status) {
        case LSSCHEDULEINVITESTATUS_PENDING:{
            // Pending
            self.scheduleStatus.text = isInbox ? NSLocalizedStringFromSelf(@"Pending_Inbox") : NSLocalizedStringFromSelf(@"Pending_Outbox");
            self.scheduleStatus.textColor = COLOR_WITH_16BAND_RGB(0xFF8837);
            self.scheduleStatusNote.text = NSLocalizedStringFromSelf(@"NO_CONFIMATION");
            self.scheduleStatusNote.font = [UIFont italicSystemFontOfSize:14];
            if (isInbox) {
                [self showTimeChooseView];
            }else {
                [self hideTimeChooseView];
            }

        }break;
            
        case LSSCHEDULEINVITESTATUS_CONFIRMED:{
            // Confirmed
            self.scheduleStatus.text = NSLocalizedStringFromSelf(@"Confirmed");
            self.scheduleStatus.textColor = COLOR_WITH_16BAND_RGB(0x04C456);
            NSString * updateTime =  [[LSPrePaidManager manager] getGMTFromTimestamp:item.scheduleInfo.statusUpdateTime timeFormat:@"MMM dd,HH:mm"];
            self.scheduleStatusNote.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"TIME_CONFIRMED"),updateTime];
            [self hideTimeChooseView];
        }break;
        case LSSCHEDULEINVITESTATUS_CANCELED:{
            // Canceled
              self.scheduleStatus.text = NSLocalizedStringFromSelf(@"Canceled");
            self.scheduleStatus.textColor = COLOR_WITH_16BAND_RGB(0xFF8837);
            NSString * updateTime =  [[LSPrePaidManager manager] getGMTFromTimestamp:item.scheduleInfo.statusUpdateTime timeFormat:@"MMM dd,HH:mm"];
            self.scheduleStatusNote.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"TIME_CANCELED"),updateTime];
            self.cancelInfoBtn.hidden = NO;
            [self hideTimeChooseView];
        }break;
        case LSSCHEDULEINVITESTATUS_EXPIRED:{
            // Expired
            self.scheduleStatus.text = NSLocalizedStringFromSelf(@"Expired");
            self.scheduleStatus.textColor = COLOR_WITH_16BAND_RGB(0xFF8837);
            self.scheduleStatusNote.text = NSLocalizedStringFromSelf(@"ExpiredNote");
            [self hideTimeChooseView];
        }break;
        case LSSCHEDULEINVITESTATUS_COMPLETED:{
            // Completed
            self.scheduleStatus.text = NSLocalizedStringFromSelf(@"Completed");
            self.scheduleStatus.textColor = COLOR_WITH_16BAND_RGB(0x1A1A1A);
            NSString * updateTime =  [[LSPrePaidManager manager] getGMTFromTimestamp:item.scheduleInfo.statusUpdateTime timeFormat:@"MMM dd,HH:mm"];
            self.scheduleStatusNote.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"TIME_COMPLETED"),updateTime];
            [self hideTimeChooseView];
        }break;
        case LSSCHEDULEINVITESTATUS_DECLINED:{
            // Declined
            self.scheduleStatus.text = NSLocalizedStringFromSelf(@"Declined");
            self.scheduleStatus.textColor = COLOR_WITH_16BAND_RGB(0xFF4747);
             NSString * updateTime =  [[LSPrePaidManager manager] getGMTFromTimestamp:item.scheduleInfo.statusUpdateTime timeFormat:@"MMM dd,HH:mm"];
            self.scheduleStatusNote.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"TIME_DECLINED"),updateTime];
            [self hideTimeChooseView];
        }break;
        case LSSCHEDULEINVITESTATUS_MISSED:{
            // Missed
            self.scheduleStatus.text = NSLocalizedStringFromSelf(@"Missed");
            self.scheduleStatus.textColor = COLOR_WITH_16BAND_RGB(0x1A1A1A);
            NSString * updateTime =  [[LSPrePaidManager manager] getGMTFromTimestamp:item.scheduleInfo.statusUpdateTime timeFormat:@"MMM dd,HH:mm"];
            self.scheduleStatusNote.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"TIME_MISSED"),updateTime];
            [self hideTimeChooseView];
        }break;
            
        default:
            break;
    }
    
    
    NSString *startTime = [[LSPrePaidManager manager] getStartTimeAndEndTomeFromTimestamp:item.scheduleInfo.startTime timeFormat:@"MMM dd, HH:mm" isDaylightSaving:item.scheduleInfo.isSummerTime andZone:item.scheduleInfo.timeZoneValue];
    self.scheduleGMTTime.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Start_Time"),startTime,item.scheduleInfo.timeZoneCity,item.scheduleInfo.timeZoneValue];
    
    NSString *localTime = [[LSPrePaidManager manager] getLocalTimeBeginTiemAndEndTimeFromTimestamp:item.scheduleInfo.startTime timeFormat:@"MMM dd, HH:mm"];
    self.scheduleLocalTime.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Local_Time"),localTime];
    
    self.minuteTime.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Minutes"),item.scheduleInfo.duration];
    
    for (int i = 0;i<[LSPrePaidManager manager].creditsArray.count;i++) {
        LSScheduleDurationItemObject * cItem = [LSPrePaidManager manager].creditsArray[i];
        if (cItem.duration == item.scheduleInfo.duration) {
            [self setDurationData:cItem];
            break;
        }
    }
}

- (void)setDurationData:(LSScheduleDurationItemObject *)item {
    if (item.credit != item.originalCredit) {
          NSString * str = [NSString stringWithFormat:@"%d Minutes - %0.2f Credits %0.2f Credits",item.duration,item.credit,item.originalCredit];
             NSString * str1 = [NSString stringWithFormat:@"%0.2f Credits",item.originalCredit];
         NSMutableAttributedString * attrStr =  [[LSPrePaidManager manager] newCreditsStr:str credits:str1];
        [self.timeChoose setAttributedTitle:attrStr forState:UIControlStateNormal];
    } else {
        NSString * str = [NSString stringWithFormat:@"%d Minutes - %0.2f Credits",item.duration,item.credit];
        NSMutableAttributedString * attrStr =  [[LSPrePaidManager manager] newCreditsStr:str credits:@""];
       [self.timeChoose setAttributedTitle:attrStr forState:UIControlStateNormal];
    }
}


- (void)showTimeChooseView {
    self.timeChoose.hidden = NO;
    self.chooseItem.hidden = NO;
    self.minuteTime.hidden = YES;
}


- (void)hideTimeChooseView {
    self.timeChoose.hidden = YES;
    self.chooseItem.hidden = YES;
    self.minuteTime.hidden = NO;
}

- (IBAction)timeChooseAction:(UIButton *)sender {
    if ([self.contentDelegate respondsToSelector:@selector(lsScheduleContentCell:didChooseTime:)]) {
        [self.contentDelegate lsScheduleContentCell:self didChooseTime:sender];
    }
}

- (IBAction)cancelInfoAction:(id)sender {
    self.cancelInfoTipNote.hidden = NO;
    self.cancelInfoTipNote.alpha = 1;
    [UIView animateWithDuration:3 animations:^{
        self.cancelInfoTipNote.alpha = 0;
    }];
}

@end
