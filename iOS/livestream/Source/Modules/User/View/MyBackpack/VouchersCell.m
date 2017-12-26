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
    
    self.ladyHeadView.layer.cornerRadius = self.ladyHeadView.frame.size.width/2;
    self.ladyHeadView.layer.masksToBounds = YES;
    
//    UIImage * image = [UIImage imageNamed:@"Vouchers_BG"];
//    
//    CGFloat top = 30; // 顶端盖高度
//    CGFloat bottom = 30; // 底端盖高度
//    CGFloat left = 165; // 左端盖宽度
//    CGFloat right = 30; // 右端盖宽度
//    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
//    
//    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
//    
//    self.vouchersBGView.image = image;
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
    [stampFormatter setDateFormat:@"MMM dd HH:mm"];
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *timeStr = [stampFormatter stringFromDate:timeDate];

    return timeStr;
}

@end
