//
//  LSScheduleTipsCell.m
//  livestream
//
//  Created by test on 2020/4/20.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleTipsCell.h"

@implementation LSScheduleTipsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    

}

+ (CGFloat)cellHeight {
    return 230;
}


+ (id)getUITableViewCell:(UITableView *)tableView {
    LSScheduleTipsCell *cell = (LSScheduleTipsCell *)[tableView dequeueReusableCellWithIdentifier:[LSScheduleTipsCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSScheduleTipsCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
    }

    return cell;
}

+ (NSString *)cellIdentifier {
    return @"LSScheduleTipsCell";
}

@end
