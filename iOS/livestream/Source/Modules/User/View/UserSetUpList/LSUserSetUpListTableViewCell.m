//
//  LSUserSetUpListTableViewCell.m
//  livestream
//
//  Created by test on 2018/9/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSUserSetUpListTableViewCell.h"

@implementation LSUserSetUpListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.settingTitle.textColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x333333) orDark:[UIColor whiteColor]];
    self.settingDetail.textColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x666666) orDark:[UIColor whiteColor]];
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
    return @"LSUserSetUpListTableViewCell";
}
//高度
+ (NSInteger)cellHeight{
    return 50;
}


//根据标识符生成
+ (id)getUITableViewCell:(UITableView *)tableView {
    LSUserSetUpListTableViewCell *cell = (LSUserSetUpListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSUserSetUpListTableViewCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSUserSetUpListTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    
    return cell;
}


+ (UIEdgeInsets)defaultInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


@end
