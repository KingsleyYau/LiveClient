//
//  HotTopViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/7/10.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HotTopViewCell.h"

@implementation HotTopViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.unreadView.hidden = YES;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.unreadView.layer.cornerRadius = self.unreadView.frame.size.height / 2;
    self.unreadView.layer.masksToBounds = YES;
}

- (void)setUnreadNum:(int)num {
    if (num) {
        self.unreadView.hidden = NO;
        if (num > 99) {
            self.unreadNumLabel.text =@"99+";
        }
        else {
            self.unreadNumLabel.text = [NSString stringWithFormat:@"%d",num];
        }
        
    } else {
        self.unreadView.hidden = YES;
    }
}

+ (NSString *)cellIdentifier {
    return @"HotTopViewCellIdentifier";
}

@end
