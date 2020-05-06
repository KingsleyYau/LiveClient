//
//  LSScheduleExpiredCell.m
//  livestream
//
//  Created by Calvin on 2020/4/16.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleExpiredCell.h"

@implementation LSScheduleExpiredCell

+ (NSString *)cellIdentifier {
    return @"LSScheduleExpiredCell";
}

+ (NSInteger)cellHeight{
    return 168;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSScheduleExpiredCell *cell = (LSScheduleExpiredCell *)[tableView dequeueReusableCellWithIdentifier:[LSScheduleExpiredCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSScheduleExpiredCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.headImage.layer.cornerRadius = self.headImage.tx_height/2;
    self.headImage.layer.masksToBounds = YES;
    
    self.imageLoader = [LSImageViewLoader loader];
}

- (void)updateUI:(LSScheduleInviteListItemObject*)item {
    self.nameLabel.text = item.anchorInfo.nickName;
    [self.imageLoader loadImageWithImageView:self.headImage options:0 imageUrl:item.anchorInfo.avatarImg placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {
        
    }];
    
    self.idLabel.text = item.inviteId;
    
       switch (item.status) {
           case LSSCHEDULEINVITESTATUS_COMPLETED:{
               self.statusLabel.textColor = [UIColor blackColor];
               self.statusLabel.text = @"Completed";
           }break;
           case LSSCHEDULEINVITESTATUS_CANCELED:{
               self.statusLabel.textColor = COLOR_WITH_16BAND_RGB(0xFF8837);
               self.statusLabel.text = @"Canceled";
           }break;
           case LSSCHEDULEINVITESTATUS_MISSED:{
                self.statusLabel.textColor = [UIColor blackColor];
                self.statusLabel.text = @"Missed";
           }break;
        case LSSCHEDULEINVITESTATUS_DECLINED:{
            self.statusLabel.textColor = [UIColor redColor];
            self.statusLabel.text = @"Declined";
           }break;
        case LSSCHEDULEINVITESTATUS_EXPIRED:{
            self.statusLabel.textColor = [UIColor redColor];
            self.statusLabel.text = @"Expired";
        }break;
        default:
            break;
    }
    
    if (item.sendFlag == LSSCHEDULESENDFLAGTYPE_MAN) {
        self.fromLabel.text = @"To";
    }else{
        self.fromLabel.text = @"From";
    }
    
    NSString * startTime =[[LSPrePaidManager manager]getStartTimeAndEndTomeFromTimestamp:item.startTime timeFormat:@"MMM dd, HH:00" isDaylightSaving:item.isSummerTime andZone:item.timeZoneValue];
    
    self.startLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Start_Time"),startTime,item.timeZoneCity,item.timeZoneValue];

   NSString *localTime = [[LSPrePaidManager manager] getStartTimeAndEndTomeFromTimestamp:item.startTime timeFormat:@"MMM dd, HH:mm" isDaylightSaving:item.isSummerTime andZone:@""];
   self.localLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Local_Time"),localTime];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
