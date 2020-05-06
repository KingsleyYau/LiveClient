//
//  LSScheduleMailHeadCell.m
//  livestream
//
//  Created by test on 2020/4/13.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleMailHeadCell.h"
#import "LSImageViewLoader.h"

@interface LSScheduleMailHeadCell()
@end

@implementation LSScheduleMailHeadCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    

}

+ (CGFloat)cellHeight {
    return 165;
}


+ (id)getUITableViewCell:(UITableView *)tableView {
    LSScheduleMailHeadCell *cell = (LSScheduleMailHeadCell *)[tableView dequeueReusableCellWithIdentifier:[LSScheduleMailHeadCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSScheduleMailHeadCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
    }
    cell.headImageView.layer.cornerRadius = cell.headImageView.frame.size.width * 0.5f;
    cell.headImageView.layer.masksToBounds = YES;
    cell.onlineView.layer.cornerRadius = cell.onlineView.frame.size.width * 0.5f;
    cell.onlineView.layer.masksToBounds = YES;
    return cell;
}

+ (NSString *)cellIdentifier {
    return @"LSScheduleMailHeadCell";
}


@end
