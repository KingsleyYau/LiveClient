//
//  PushSettingTableViewCell.m
//  livestream
//
//  Created by test on 2018/9/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSPushSettingTableViewCell.h"

@implementation LSPushSettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
        self.pushSettingTitle.textColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x383838) orDark:[UIColor whiteColor]];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

//标识符
+ (NSString *)cellIdentifier{
    return @"LSPushSettingTableViewCell";
}
//高度
+ (NSInteger)cellHeight{
    return 50;
}


//根据标识符生成
+ (id)getUITableViewCell:(UITableView *)tableView {
    LSPushSettingTableViewCell *cell = (LSPushSettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSPushSettingTableViewCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSPushSettingTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.pushSettingTitle.text = @"";
    
    return cell;
}


+ (UIEdgeInsets)defaultInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (IBAction)setupPushSettingStatus:(UISwitch *)sender {
    if ([self.pushSettingDelegate respondsToSelector:@selector(lsPushSettingTableViewCellDelegate:didChangeStatus:)]) {
        [self.pushSettingDelegate lsPushSettingTableViewCellDelegate:self didChangeStatus:sender];
    }
}


@end
