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
        self.noNumUnreadView.hidden = YES;
        [self setExclusiveTouch:YES];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.unreadView.layer.cornerRadius = self.unreadView.frame.size.height / 2.0f;
    self.unreadView.layer.masksToBounds = YES;
    self.noNumUnreadView.layer.cornerRadius = self.noNumUnreadView.frame.size.height / 2.0f;
    self.noNumUnreadView.layer.masksToBounds = YES;
    [self setExclusiveTouch:YES];
}

- (void)setUnreadNum:(int)num {
    if (num) {
        self.unreadView.hidden = NO;
        if (num > 99) {
            self.unreadNumLabel.text =@"...";
        }
        else {
            self.unreadNumLabel.text = [NSString stringWithFormat:@"%d",num];
        }
        self.noNumUnreadView.hidden = YES;
    } else {
        self.unreadView.hidden = YES;
        self.noNumUnreadView.hidden = YES;
    }
}

- (void)showChatListUnreadNum:(int)num {
    if (num > 0) {
        if (num > 99) {
            self.unreadNumLabel.text = @"...";
        }
        else {
            self.unreadNumLabel.text = [NSString stringWithFormat:@"%d",num];
        }
        
        self.unreadView.hidden = NO;
        self.noNumUnreadView.hidden = YES;

    } else if(num < 0) {
        self.unreadView.hidden = YES;
        self.noNumUnreadView.hidden = NO;
    }else {
        self.unreadView.hidden = YES;
        self.noNumUnreadView.hidden = YES;
    }
}


+ (NSString *)cellIdentifier {
    return @"HotTopViewCellIdentifier";
}

@end
