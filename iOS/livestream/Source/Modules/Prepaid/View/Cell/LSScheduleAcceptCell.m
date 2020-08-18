//
//  LSScheduleAcceptCell.m
//  livestream
//
//  Created by Calvin on 2020/4/16.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleAcceptCell.h"

@implementation LSScheduleAcceptCell


+ (NSString *)cellIdentifier {
    return @"LSScheduleAcceptCell";
}

+ (NSInteger)cellHeight:(LSScheduleInviteListItemObject*)item{
    CGFloat h = 0;
    if (item.sendFlag == LSSCHEDULESENDFLAGTYPE_MAN) {
        h = 168;
    }else{
        h = 234;
    }
    return h;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSScheduleAcceptCell *cell = (LSScheduleAcceptCell *)[tableView dequeueReusableCellWithIdentifier:[LSScheduleAcceptCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSScheduleAcceptCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.acceptBtn.layer.cornerRadius = self.acceptBtn.tx_height/2;
    self.acceptBtn.layer.masksToBounds = YES;
    
    self.viewBtn.layer.cornerRadius = self.viewBtn.tx_height/2;
    self.viewBtn.layer.masksToBounds = YES;
    
    self.viewBtn.layer.borderColor = COLOR_WITH_16BAND_RGB(0x999999).CGColor;
    self.viewBtn.layer.borderWidth = 1;
    
    self.headImage.layer.cornerRadius = self.headImage.tx_height/2;
    self.headImage.layer.masksToBounds = YES;
    
    
    self.imageLoader = [LSImageViewLoader loader];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUI:(LSScheduleInviteListItemObject*)item {
    self.nameLabel.text = item.anchorInfo.nickName;
    [self.imageLoader loadImageFromCache:self.headImage options:0 imageUrl:item.anchorInfo.avatarImg placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {
        
    }];
    
    self.idLabel.text = item.inviteId;
    
    self.statusLabel.textColor = COLOR_WITH_16BAND_RGB(0xFF8837);
    
    if (item.sendFlag == LSSCHEDULESENDFLAGTYPE_MAN) {
        self.fromLabel.text = @"To";
        self.statusLabel.text = NSLocalizedStringFromSelf(@"STATUS_TIP_HER");
        self.acceptBtn.hidden = YES;
        self.viewBtn.hidden = YES;
    }else{
        self.statusLabel.text = NSLocalizedStringFromSelf(@"STATUS_TIP_YOUR");
        self.fromLabel.text = @"From";
        self.acceptBtn.hidden = NO;
        self.viewBtn.hidden = NO;
    }
  
    NSString * startTime =[[LSPrePaidManager manager]getStartTimeAndEndTomeFromTimestamp:item.startTime timeFormat:@"MMM dd, HH:00" isDaylightSaving:item.isSummerTime andZone:item.timeZoneValue];
    
    self.startLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Start_Time"),startTime,item.timeZoneCity,item.timeZoneValue];

   NSString *localTime = [[LSPrePaidManager manager] getLocalTimeBeginTiemAndEndTimeFromTimestamp:item.startTime timeFormat:@"MMM dd, HH:mm"];
   self.localLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Local_Time"),localTime];
    
    self.durationLabel.text = [NSString stringWithFormat:@"%d Minutes",item.duration];
}

- (IBAction)acceptBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(scheduleAcceptCellDidAcceptBtn:)]) {
        [self.cellDelegate scheduleAcceptCellDidAcceptBtn:self.tag];
    }
}

- (IBAction)viewBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(scheduleAcceptCellDidViewBtn:)]) {
        [self.cellDelegate scheduleAcceptCellDidViewBtn:self.tag];
    }
}

@end
