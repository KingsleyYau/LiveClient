//
//  LSChatPrepaidSuccessedCell.m
//  livestream
//
//  Created by Calvin on 2020/4/1.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSChatPrepaidSuccessedCell.h"

@implementation LSChatPrepaidSuccessedCell

+ (NSString *)cellIdentifier {
    return @"LSChatPrepaidSuccessedCell";
}

+ (NSInteger)cellHeight{
    return 175;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSChatPrepaidSuccessedCell *cell = (LSChatPrepaidSuccessedCell *)[tableView dequeueReusableCellWithIdentifier:[LSChatPrepaidSuccessedCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSChatPrepaidSuccessedCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.acceptView.layer.cornerRadius = 4;
    self.acceptView.layer.masksToBounds = YES;
    
    self.acceptView.layer.borderColor = COLOR_WITH_16BAND_RGB(0x04C456).CGColor;
    self.acceptView.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateScheduleId:(NSString *)scheduleId isFormME:(BOOL)isMe {
    
    if (isMe) {
        self.acceptLabel.text =NSLocalizedStringFromSelf(@"MAN_ACCEPT");
    }else {
       self.acceptLabel.text = NSLocalizedStringFromSelf(@"LADY_ACCEPT");
    }
    
    NSString * str = [NSString stringWithFormat:@"(ID:%@)",scheduleId];
    NSString * text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SCHEDULE_TITLE"),str];
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc]initWithString:text];
    [attrStr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x999999) range:[text rangeOfString:str]];
    self.requestLabel.attributedText = attrStr;
}
@end
