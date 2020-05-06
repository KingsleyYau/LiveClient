//
//  LSScheduleInvitedCell.m
//  livestream
//
//  Created by Randy_Fan on 2020/4/13.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleInvitedCell.h"
#import "LSPrePaidManager.h"

@interface LSScheduleInvitedCell()

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmedLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *localTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *creditsBtn;
@property (weak, nonatomic) IBOutlet UIButton *accpetBtn;

@property (nonatomic, strong) LSScheduleLiveInviteItemObject *item;

@property (nonatomic, assign) int origintduration;
 
@property (nonatomic, copy) NSString *startPeriod;

@end

@implementation LSScheduleInvitedCell

+ (NSString *)cellIdentifier {
    return @"LSScheduleInvitedCell";
}

+ (NSInteger)cellHeight {
    return 268;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSScheduleInvitedCell *cell = (LSScheduleInvitedCell *)[tableView dequeueReusableCellWithIdentifier:[LSScheduleInvitedCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSScheduleInvitedCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.origintduration = 0;
    }
    cell.bgView.layer.borderWidth = 1;
    cell.bgView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xda9fd7).CGColor;
    
    cell.accpetBtn.layer.masksToBounds = YES;
    cell.accpetBtn.layer.cornerRadius = cell.accpetBtn.tx_height/2;
    
    cell.item = [[LSScheduleLiveInviteItemObject alloc] init];

    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setupData:(LSScheduleLiveInviteItemObject *)item {
    self.item = item;
    
    if (!self.origintduration) {
        self.origintduration = item.duration;
    }
    
    self.idLabel.text = item.inviteId;
    
    NSString * sendTime =  [[LSPrePaidManager manager] getGMTFromTimestamp:item.addTime timeFormat:@"MMM dd, HH:mm"];
    self.sendLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"saO-Ud-9ob.text"),[sendTime stringByAppendingString:@" (GMT)"]];
    
    NSString * updateTime =  [[LSPrePaidManager manager] getGMTFromTimestamp:item.statusUpdateTime timeFormat:@"MMM dd, HH:mm"];
    self.confirmedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"FTj-Su-Bwy.text"),[updateTime stringByAppendingString:@" (GMT)"]];
    
    self.startPeriod = [[LSPrePaidManager manager] getStartTimeAndEndTomeFromTimestamp:item.startTime timeFormat:@"MMM dd, HH:00" isDaylightSaving:item.isSummerTime andZone:item.timeZoneValue];
    self.startPeriod = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Start_Time"),self.startPeriod,item.timeZoneCity,item.timeZoneValue];
    self.startTimeLabel.text = self.startPeriod;
    
    NSString *localTime = [[LSPrePaidManager manager] getStartTimeAndEndTomeFromTimestamp:item.startTime timeFormat:@"MMM dd, HH:mm" isDaylightSaving:item.isSummerTime andZone:@""];
    self.localTimeLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Local_Time"),localTime];
    
    for (LSScheduleDurationItemObject *obj  in [LSPrePaidManager manager].creditsArray) {
        if (obj.duration == item.duration) {
            [self setDurationData:obj];
            break;
        }
    }
}

- (void)setDurationData:(LSScheduleDurationItemObject *)item {
    NSMutableAttributedString *attrStr;
    if (item.credit != item.originalCredit) {
        NSString *minCredit = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Minutes_Credits"),item.duration,item.credit];
        NSString *originalCredit = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Original_Credits"),item.originalCredit];
        NSString *title = [NSString stringWithFormat:@"%@ %@",minCredit,originalCredit];
        attrStr =  [[LSPrePaidManager manager] newCreditsStr:title credits:originalCredit];
    } else {
        NSString *minCredit = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Minutes_Credits"),item.duration,item.credit];
        attrStr = [[LSPrePaidManager manager] newCreditsStr:minCredit credits:@""];
    }
    [self.creditsBtn setAttributedTitle:attrStr forState:UIControlStateNormal];
}

- (IBAction)changeMinute:(id)sender {
    if ([self.delegate respondsToSelector:@selector(selectDurationWithRow:)]) {
        [self.delegate selectDurationWithRow:self];
    }
}

- (IBAction)acceptDid:(id)sender {
    LSScheduleInviteItem *item = [[LSScheduleInviteItem alloc] init];
    item.origintduration = self.origintduration;
    item.period = self.startPeriod;
    item.gmtStartTime = self.item.startTime;
    item.sendTime = self.item.addTime;
    if ([self.delegate respondsToSelector:@selector(acceptScheduleInvite:duration:item:)]) {
        [self.delegate acceptScheduleInvite:self.item.inviteId duration:self.item.duration item:item];
    }
}


@end
