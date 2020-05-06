//
//  LSScheduleRequestCell.m
//  livestream
//
//  Created by Randy_Fan on 2020/4/13.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleRequestCell.h"
#import "LSPrePaidManager.h"
@interface LSScheduleRequestCell()

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmedLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *localTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;

@end

@implementation LSScheduleRequestCell

+ (NSString *)cellIdentifier {
    return @"LSScheduleRequestCell";
}

+ (NSInteger)cellHeight {
    return 187;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSScheduleRequestCell *cell = (LSScheduleRequestCell *)[tableView dequeueReusableCellWithIdentifier:[LSScheduleRequestCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSScheduleRequestCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.bgView.layer.borderWidth = 1;
    cell.bgView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xda9fd7).CGColor;
    
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setupData:(LSScheduleLiveInviteItemObject *)item {
    self.idLabel.text = item.inviteId;

    NSString * sendTime =  [[LSPrePaidManager manager] getGMTFromTimestamp:item.addTime timeFormat:@"MMM dd, HH:mm"];
    self.sendLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"b15-OK-qXD.text"),[sendTime stringByAppendingString:@" (GMT)"]];
    
    if (item.status == LSSCHEDULEINVITESTATUS_PENDING) {
        self.statusLabel.textColor = COLOR_WITH_16BAND_RGB(0xff8837);
        self.statusLabel.text = NSLocalizedStringFromSelf(@"Pending");
        self.confirmedLabel.font = [UIFont italicSystemFontOfSize:12];
        self.confirmedLabel.text = NSLocalizedStringFromSelf(@"No_Confirmation");
    } else {
        self.statusLabel.textColor = COLOR_WITH_16BAND_RGB(0x04c456);
        self.statusLabel.text = NSLocalizedStringFromSelf(@"Confirmed");
        NSString * updateTime =  [[LSPrePaidManager manager] getGMTFromTimestamp:item.statusUpdateTime timeFormat:@"MMM dd, HH:mm"];
        self.confirmedLabel.font = [UIFont systemFontOfSize:12];
        self.confirmedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"jaw-31-PAx.text"),[updateTime stringByAppendingString:@" (GMT)"]];
    }
    
    NSString *startTime = [[LSPrePaidManager manager] getStartTimeAndEndTomeFromTimestamp:item.startTime timeFormat:@"MMM dd, HH:00" isDaylightSaving:item.isSummerTime andZone:item.timeZoneValue];
    self.startTimeLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Start_Time"),startTime,item.timeZoneCity,item.timeZoneValue];
    
    NSString *localTime = [[LSPrePaidManager manager] getStartTimeAndEndTomeFromTimestamp:item.startTime timeFormat:@"MMM dd, HH:mm" isDaylightSaving:item.isSummerTime andZone:@""];
    
    self.localTimeLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Local_Time"),localTime];
    
    self.minLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Minutes"),item.duration];
}

@end
