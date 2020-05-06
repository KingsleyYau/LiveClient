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
    self.titleLabel.textColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x383838) orDark:[UIColor whiteColor]];
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
        
        UIColor *modelColor = [LSColor colorWithLight:[UIColor blackColor] orDark:[UIColor whiteColor]];
        cell.titleLabel.textColor = modelColor;


    }
    
    return cell;
}

@end
