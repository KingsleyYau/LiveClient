//
//  VouchersCell.m
//  livestream
//
//  Created by Calvin on 17/10/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "VouchersCell.h"
#import "LiveBundle.h"

@implementation VouchersCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.unreadView.layer.cornerRadius = self.unreadView.frame.size.width / 2;
    self.unreadView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier {
    return @"VouchersCell";
}

+ (NSInteger)cellHeight {
    return 140;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    VouchersCell *cell = (VouchersCell *)[tableView dequeueReusableCellWithIdentifier:[VouchersCell cellIdentifier]];

    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[VouchersCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (NSString *)getTime:(NSInteger)time {
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *timeStr = [stampFormatter stringFromDate:timeDate];

    return timeStr;
}

@end
