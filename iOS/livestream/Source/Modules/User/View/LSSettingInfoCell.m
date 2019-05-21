//
//  LSSettingInfoCell.m
//  livestream
//
//  Created by Calvin on 2018/9/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSSettingInfoCell.h"

@implementation LSSettingInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier{
    return @"LSSettingInfoCell";
}


+ (NSInteger)cellHeight{
    return 50;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSSettingInfoCell *cell = (LSSettingInfoCell *)[tableView dequeueReusableCellWithIdentifier:[LSSettingInfoCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSSettingInfoCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

@end
