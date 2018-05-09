//
//  GiftStatisticsViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/4/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "GiftStatisticsViewCell.h"

@implementation GiftStatisticsViewCell

+ (NSString *)cellIdentifier {
    return @"GiftStatisticsViewCell";
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.backGroundView.layer.cornerRadius = self.backGroundView.frame.size.height * 0.5;
        self.backGroundView.layer.masksToBounds = YES;
        
        self.giftNumView.layer.cornerRadius = self.giftNumView.frame.size.height * 0.5;
        self.giftNumView.layer.masksToBounds = YES;
    }
    return self;
}


@end
