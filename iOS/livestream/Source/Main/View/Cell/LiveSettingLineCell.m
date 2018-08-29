//
//  LiveSettingLineCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/7/12.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LiveSettingLineCell.h"

@implementation LiveSettingLineCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (NSInteger)cellHeight {
    return 13;
}

+ (NSString *)cellIdentifier {
    return @"LiveSettingLineCell";
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LiveSettingLineCell *cell = (LiveSettingLineCell *)[tableView dequeueReusableCellWithIdentifier:[LiveSettingLineCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LiveSettingLineCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

@end
