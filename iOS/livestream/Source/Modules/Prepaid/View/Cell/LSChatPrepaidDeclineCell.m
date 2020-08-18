//
//  LSChatPrepaidDeclineCell.m
//  livestream
//
//  Created by Calvin on 2020/4/1.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSChatPrepaidDeclineCell.h"

@implementation LSChatPrepaidDeclineCell


+ (NSString *)cellIdentifier {
    return @"LSChatPrepaidDeclineCell";
}

+ (NSInteger)cellHeight{
    return 175;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSChatPrepaidDeclineCell *cell = (LSChatPrepaidDeclineCell *)[tableView dequeueReusableCellWithIdentifier:[LSChatPrepaidDeclineCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSChatPrepaidDeclineCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.declineView.layer.cornerRadius = 4;
    self.declineView.layer.masksToBounds = YES;
    
    self.declineView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xF7D2C0).CGColor;
    self.declineView.layer.borderWidth = 1;
}

- (void)updateScheduleId:(NSString *)scheduleId isFormME:(BOOL)isMe {
    
    if (isMe) {
        self.declineLabel.text =NSLocalizedStringFromSelf(@"MAN_ACCEPT");
    }else {
        self.declineLabel.text = NSLocalizedStringFromSelf(@"LADY_ACCEPT");
    }
    
    NSString * str = [NSString stringWithFormat:@"(ID:%@)",scheduleId];
    NSString * text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SCHEDULE_TITLE"),str];
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc]initWithString:text];
    [attrStr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x999999) range:[text rangeOfString:str]];
    self.requestLabel.attributedText = attrStr;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
