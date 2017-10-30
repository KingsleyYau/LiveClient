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

    self.numLabel.layer.cornerRadius = self.numLabel.frame.size.width / 2;
    self.numLabel.layer.masksToBounds = YES;

    self.unreadView.layer.cornerRadius = self.unreadView.frame.size.width / 2;
    self.unreadView.layer.masksToBounds = YES;

    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
}

+ (NSString *)cellIdentifier {
    return @"GiftListCell";
}

- (NSString *)getTime:(NSInteger)time {
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *timeStr = [stampFormatter stringFromDate:timeDate];

    return timeStr;
}
@end
