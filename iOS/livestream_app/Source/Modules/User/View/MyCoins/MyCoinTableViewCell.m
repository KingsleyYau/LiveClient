//
//  MyCoinTableViewCell.m
//  livestream
//
//  Created by test on 2017/12/21.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "MyCoinTableViewCell.h"

@implementation MyCoinTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier {
    return @"MyCoinTableViewCell";
}

+ (NSInteger)cellHeight {
    return 60;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    MyCoinTableViewCell *cell = (MyCoinTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[MyCoinTableViewCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[MyCoinTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.coinCount.text = @"";
    }
    
    return cell;
}
@end
