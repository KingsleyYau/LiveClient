//
//  NewInvitesCell.m
//  livestream
//
//  Created by Calvin on 17/10/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "NewInvitesCell.h"
#import "LiveBundle.h"

@implementation NewInvitesCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.comfirmBtn.layer.cornerRadius = 5;
    self.comfirmBtn.layer.masksToBounds = YES;

    self.declineBtn.layer.cornerRadius = 5;
    self.declineBtn.layer.masksToBounds = YES;

    self.cancelBtn.layer.cornerRadius = 5;
    self.cancelBtn.layer.masksToBounds = YES;

    self.headImage.layer.cornerRadius = self.headImage.frame.size.width / 2;
    self.headImage.layer.masksToBounds = YES;

    self.redIcon.layer.cornerRadius = self.redIcon.frame.size.width / 2;
    self.redIcon.layer.masksToBounds = YES;

    self.scheduledTimeView.layer.cornerRadius = 5;
    self.scheduledTimeView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier {
    return @"NewInvitesCell";
}

+ (NSInteger)cellHeight {
    return 70;
}

+ (id)getUITableViewCell:(UITableView *)tableView forRow:(NSInteger)row {
    NewInvitesCell *cell = (NewInvitesCell *)[tableView dequeueReusableCellWithIdentifier:[NewInvitesCell cellIdentifier]];

    if (nil == cell) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[NewInvitesCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.haedTap.view.tag = row;
        cell.comfirmBtn.tag = row;
        cell.declineBtn.tag = row;
        cell.cancelBtn.tag = row;
        cell.startNowTap.view.tag = row;
    }

    return cell;
}

- (IBAction)declineBtnDid:(UIButton *)sender {

    if ([self.delegate respondsToSelector:@selector(myReservationsDeclineBtnDidForRow:)]) {
        [self.delegate myReservationsDeclineBtnDidForRow:sender.tag];
    }
}

- (IBAction)comfirmBtnDid:(UIButton *)sender {

    if ([self.delegate respondsToSelector:@selector(myReservationsComfirmBtnDidForRow:)]) {
        [self.delegate myReservationsComfirmBtnDidForRow:sender.tag];
    }
}

- (IBAction)cancelBtnDid:(UIButton *)sender {

    if ([self.delegate respondsToSelector:@selector(myReservationsCancelBtnDidForRow:)]) {
        [self.delegate myReservationsCancelBtnDidForRow:sender.tag];
    }
}

- (IBAction)startNowDid:(UITapGestureRecognizer *)sender {
    
    if ([self.delegate respondsToSelector:@selector(myReservationsStartNowDidForRow:)]) {
        [self.delegate myReservationsStartNowDidForRow:sender.view.tag];
    }
}

- (IBAction)headTap:(UITapGestureRecognizer *)sender {
    
    if ([self.delegate respondsToSelector:@selector(myReservationsHeadDidForRow:)]) {
        [self.delegate myReservationsHeadDidForRow:sender.view.tag];
    }
}

- (void)setTimeStr:(NSString *)time {
    NSString *timeStr = [NSString stringWithFormat:@"%@\n%@", NSLocalizedStringFromSelf(@"START_IN"), time];
    NSMutableAttributedString *mAttStr = [[NSMutableAttributedString alloc] initWithString:timeStr];

    NSRange timeRange = [timeStr rangeOfString:time];
    [mAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:timeRange];
    [mAttStr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x297AF3) range:timeRange];

    NSRange strRange = [timeStr rangeOfString:NSLocalizedStringFromSelf(@"START_IN")];
    [mAttStr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x3c3c3c) range:strRange];
    [mAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:strRange];

    self.historyLabel.attributedText = mAttStr;
}

#pragma mark 时间格式转换
- (NSString *)getTime:(NSInteger)time {
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"MMM dd. HH:mm"];
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *timeStr = [stampFormatter stringFromDate:timeDate];

    return timeStr;
}

- (NSString *)compareCurrentTime:(NSInteger)time {
    NSDate *nowDate = [NSDate date]; // 当前日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDate *creat = [formatter dateFromString:[formatter stringFromDate:date]]; // 将传入的字符串转化成时间
    NSTimeInterval timeInterval = [creat timeIntervalSinceDate:nowDate];        // 计算出相差多少秒
    NSInteger seconds = timeInterval;

    //format of hour
    NSString *str_day = [NSString stringWithFormat:@"%d", (int)(seconds / 3600 / 24)];
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%d", (int)(seconds / 3600)];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%d", (int)((seconds % 3600) / 60)];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%d", (int)(seconds % 60)];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@-%@:%@:%@", str_day, str_hour, str_minute, str_second];
    //1s内
    if (seconds <= 1) {
        
        return [NSString stringWithFormat:@"%ld", (long)seconds];
    } else {
        //1小时内
        if (seconds < 60 * 60) {
            str_minute = [NSString stringWithFormat:@"%ld", (seconds % 3600) / 60];
            str_second = [NSString stringWithFormat:@"%ld", seconds % 60];
            format_time = [NSString stringWithFormat:@"%@m %@s", str_minute, str_second];
        } else {
            //1天内
            if (seconds < 60 * 60 * 24) {
                str_hour = [NSString stringWithFormat:@"%ld", seconds / 3600];
                str_minute = [NSString stringWithFormat:@"%ld", (seconds % 3600) / 60];
                format_time = [NSString stringWithFormat:@"%@h %@m", str_hour, str_minute];
            } else {
                str_day = [NSString stringWithFormat:@"%ld", seconds / 3600 / 24];
                str_hour = [NSString stringWithFormat:@"%ld", (seconds - [str_day integerValue] * 86400) / 3600];
                format_time = [NSString stringWithFormat:@"%@d %@h", str_day, str_hour];
            }
        }
    }

    return format_time;
}

- (void)startCountdown:(NSInteger)time {
    
    self.time = time + 180;
    self.countdownTime = [[NSDate date] timeIntervalSince1970];
    
    [self countdown];
}

- (void)countdown {
 
    CGFloat percent = self.scheduledTimeView.frame.size.width / 180.0;

    NSInteger times = self.time - self.countdownTime;
    
    self.colorView.frame = CGRectMake(0, 0, (180 - times) * percent, self.scheduledTimeView.frame.size.height);
    
    if (self.time == self.countdownTime) {
        if ([self.delegate respondsToSelector:@selector(myReservationsCountdownEnd)]) {
            [self.delegate myReservationsCountdownEnd];
        }
    }
}

@end
