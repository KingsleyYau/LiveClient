//
//  MyRidesCell.m
//  livestream
//
//  Created by Calvin on 17/10/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "MyRidesCell.h"

@implementation MyRidesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    self.ridesBtn.layer.cornerRadius = 6;
    self.ridesBtn.layer.masksToBounds = YES;
    
    self.unreadView.layer.cornerRadius = self.unreadView.frame.size.width/2;
    self.unreadView.layer.masksToBounds = YES;
    
     self.nameLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(10)];
    self.timeLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(7)];
}

+ (NSString *)cellIdentifier {
    return @"MyRidesCell";
}

- (IBAction)ridesBtnDid:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(myRidesBtnDid:)]) {
        [self.delegate myRidesBtnDid:sender.tag];
    }
}

- (void)setRidesBtnBG:(BOOL)isRides
{
    if (isRides) {
        self.ridesBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x297AF3);
        [self.ridesBtn setTitle:NSLocalizedStringFromSelf(@"Riding") forState:UIControlStateNormal];
        [self.ridesBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        self.ridesBtn.backgroundColor = [UIColor whiteColor];
        [self.ridesBtn setTitle:NSLocalizedStringFromSelf(@"Ride") forState:UIControlStateNormal];
        [self.ridesBtn setTitleColor:COLOR_WITH_16BAND_RGB(0x3C3C3C) forState:UIControlStateNormal];
        self.ridesBtn.layer.borderColor = COLOR_WITH_16BAND_RGB(0x297AF3).CGColor;
        self.ridesBtn.layer.borderWidth = 1;
    }
}

- (NSString *)getTime:(NSInteger)time
{
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"MMM dd HH:mm"];
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *timeStr = [stampFormatter stringFromDate:timeDate];
    
    return timeStr;
}

@end
