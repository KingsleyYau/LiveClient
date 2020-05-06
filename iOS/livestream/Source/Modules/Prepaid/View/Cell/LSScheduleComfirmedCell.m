//
//  LSScheduleComfirmedCell.m
//  livestream
//
//  Created by Calvin on 2020/4/16.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleComfirmedCell.h"

@implementation LSScheduleComfirmedCell

+ (NSString *)cellIdentifier {
    return @"LSScheduleComfirmedCell";
}

+ (NSInteger)cellHeight:(LSScheduleInviteListItemObject *)item{
    //已激活
    if (item.isActive) {
        return 128;
    }else {
        //可以激活
        if (item.startTime - [[NSDate new]timeIntervalSince1970] < 0) {
            return 193;
        }
        //即将激活
        else if (item.startTime - [[NSDate new]timeIntervalSince1970] < 1800) {
            return 168;
        }
    }
    return 128;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSScheduleComfirmedCell *cell = (LSScheduleComfirmedCell *)[tableView dequeueReusableCellWithIdentifier:[LSScheduleComfirmedCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSScheduleComfirmedCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headImage.layer.cornerRadius = self.headImage.tx_height/2;
    self.headImage.layer.masksToBounds = YES;
    
    self.imageLoader = [LSImageViewLoader loader];
    
    [self.scheduleIDBtn setImage:nil forState:UIControlStateNormal];
    self.scheduleIDWidth.constant = 80;
    
    self.startBtn.layer.cornerRadius = self.startBtn.tx_height/2;
    self.startBtn.layer.masksToBounds = YES;
    
    self.willLabel.layer.cornerRadius = self.willLabel.tx_height/2;
    self.willLabel.layer.masksToBounds = YES;
    
    self.startBtn.hidden = YES;
    self.willLabel.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUI:(LSScheduleInviteListItemObject *)item {
    
    self.nameLabel.text = item.anchorInfo.nickName;
    [self.imageLoader loadImageWithImageView:self.headImage options:0 imageUrl:item.anchorInfo.avatarImg placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {
        
    }];
    
    self.idLabel.text = item.inviteId;
    
    if (item.sendFlag == LSSCHEDULESENDFLAGTYPE_MAN) {
        self.fromLabel.text = @"To";
    }else{
        self.fromLabel.text = @"From";
    }
    
    self.statusLabel.textColor = COLOR_WITH_16BAND_RGB(0x04C456);
    self.statusLabel.text = @"Confirmed";
    
     NSString * startTime =[[LSPrePaidManager manager]getStartTimeAndEndTomeFromTimestamp:item.startTime timeFormat:@"MMM dd, HH:00" isDaylightSaving:item.isSummerTime andZone:item.timeZoneValue];
     
     self.startLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Start_Time"),startTime,item.timeZoneCity,item.timeZoneValue];

    NSString *localTime = [[LSPrePaidManager manager] getStartTimeAndEndTomeFromTimestamp:item.startTime timeFormat:@"MMM dd, HH:mm" isDaylightSaving:item.isSummerTime andZone:@""];
    self.localLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Local_Time"),localTime];
    
    if (item.isActive) {
        
        [self.scheduleIDBtn setImage:[UIImage imageNamed:@"LS_Schedule_Start"] forState:UIControlStateNormal];
        self.scheduleIDWidth.constant = 110;
        
        
    }else {
        //可以激活
        if (item.startTime - [[NSDate new]timeIntervalSince1970] < 0) {
             [self.scheduleIDBtn setImage:[UIImage imageNamed:@"Setting_Clock"] forState:UIControlStateNormal];
             self.scheduleIDWidth.constant = 110;
            
            self.startBtn.hidden = NO;
        }
        //即将激活
        else if (item.startTime - [[NSDate new]timeIntervalSince1970] < 1800) {
             [self.scheduleIDBtn setImage:[UIImage imageNamed:@"Setting_Soon"] forState:UIControlStateNormal];
             self.scheduleIDWidth.constant = 110;
            
            self.willLabel.hidden = NO;
            int time = (item.startTime - [[NSDate new]timeIntervalSince1970])/60;
            if (time < 1) {
                time = 1;
            }
            NSString * willTime = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"WILL_TIME"),time];
            NSMutableAttributedString * attr = [[NSMutableAttributedString alloc]initWithString:willTime];
            [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor systemYellowColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} range:[willTime rangeOfString:[NSString stringWithFormat:@"%d",time]]];
            self.willLabel.attributedText = attr;
            
        }
        else{
            
            if (!item.hasRead) {
                [self.scheduleIDBtn setImage:[UIImage imageNamed:@"LS_ScheduleList_New"] forState:UIControlStateNormal];
                self.scheduleIDWidth.constant = 120;
            }else {
                [self.scheduleIDBtn setImage:nil forState:UIControlStateNormal];
                self.scheduleIDWidth.constant = 85;
            }
        }
    }
   
}
- (IBAction)startBtnDid:(id)sender {
    if ([self.cellDeleagte respondsToSelector:@selector(scheduleComfirmedCellDidStartBtn:)]) {
        [self.cellDeleagte scheduleComfirmedCellDidStartBtn:self.tag];
    }
}

@end
