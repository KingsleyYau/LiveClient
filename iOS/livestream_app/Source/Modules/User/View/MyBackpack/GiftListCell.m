//
//  GiftListCell.m
//  livestream
//
//  Created by Calvin on 17/10/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "GiftListCell.h"

@implementation GiftListCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.unreadView.layer.cornerRadius = self.unreadView.frame.size.width / 2;
    self.unreadView.layer.masksToBounds = YES;
    self.timeLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(7)];
    self.giftNameLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(10)];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
}

+ (NSString *)cellIdentifier {
    return @"GiftListCell";
}

- (NSString *)getTime:(NSInteger)time {
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"MMM dd HH:mm"];
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *timeStr = [stampFormatter stringFromDate:timeDate];

    return timeStr;
}
@end
