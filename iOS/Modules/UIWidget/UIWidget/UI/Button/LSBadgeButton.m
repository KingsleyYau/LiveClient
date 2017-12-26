//
//  UIWBadgeButton.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSBadgeButton.h"

#define BADGE_TAG 62
#define BADGE_LABEL_TAG 63

@implementation LSBadgeButton
- (void)setBadgeValue:(NSString *)newValue {
    UIView *badgeView = [self viewWithTag:BADGE_TAG];

    _badgeValue = newValue;

    if (self.badgeValue) {
        UIFont *labelFont = [UIFont boldSystemFontOfSize:11.0f];

        if (!badgeView) {
            UIImage *stretchableImage = [self.imageBadge stretchableImageWithLeftCapWidth:floor(self.imageBadge.size.width / 2) - 1 topCapHeight:0];

            badgeView = [[UIImageView alloc] initWithImage:stretchableImage];
            badgeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            badgeView.tag = BADGE_TAG;
            badgeView.backgroundColor = [UIColor redColor];
            [self addSubview:badgeView];

            UILabel *badgeLabel = [[UILabel alloc] initWithFrame:badgeView.frame];
            badgeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            badgeLabel.backgroundColor = [UIColor clearColor];
            badgeLabel.textColor = [UIColor whiteColor];
            badgeLabel.font = labelFont;
            badgeLabel.textAlignment = NSTextAlignmentCenter;
            badgeLabel.tag = BADGE_LABEL_TAG;
            [badgeView addSubview:badgeLabel];
        }

        UILabel *badgeLabel = (UILabel *)[badgeView viewWithTag:BADGE_LABEL_TAG];
        //        CGSize size = [self.badgeValue sizeWithFont:labelFont];
        CGSize size = [self.badgeValue sizeWithAttributes:@{NSFontAttributeName : labelFont}];
        //        CGFloat paddingX = 7;
        //        CGFloat paddingY = 5;
        CGRect frame = CGRectZero;
        //        CGRect frame = CGRectMake(0, 0, 0, 0);
        //        badgeLabel.text = self.badgeValue;

        // place badgeView on top right corner
        if (size.width > 12) {
            frame.size = CGSizeMake(size.width + 12, 12);
        } else {
            frame.size = CGSizeMake(12, 12);
        }
        frame.origin = CGPointMake(self.frame.size.width - floor(frame.size.width / 2),
                                   floor(frame.size.height / 2) + 5);
        badgeView.frame = frame;

        badgeView.layer.cornerRadius = badgeView.frame.size.height * 0.5;
        badgeView.layer.masksToBounds = YES;

        //        UILabel *badgeLabel = (UILabel *)[badgeView viewWithTag:BADGE_LABEL_TAG];
        //        CGSize size = [self.badgeValue sizeWithFont:labelFont];
        //        CGFloat paddingX = 7;
        //        CGFloat paddingY = 5;
        badgeLabel.text = self.badgeValue;
        //        frame = CGRectMake(badgeView.center.x - badgeLabel.frame.size.width / 2, badgeView.center.y - badgeLabel.frame.size.height / 2, size.width + 2 * paddingX, size.height + 2 * paddingY);
        CGRect frameLabel = CGRectMake(badgeView.frame.size.width / 2 - size.width / 2, badgeView.frame.size.height / 2 - size.height / 2, size.width, size.height);
        //        CGRect frameLabel;
        //        frameLabel.origin = CGPointMake(badgeView.center.x - badgeLabel.frame.size.width / 2, badgeView.center.y - badgeLabel.frame.size.height / 2);
        badgeLabel.frame = frameLabel;

    } else {
        [badgeView removeFromSuperview];
    }
}

- (void)setUnreadCont:(NSString *)unreadCont
{
    _unreadCont = unreadCont;
     UIView *badgeView = [self viewWithTag:BADGE_TAG];
    if (self.unreadCont) {
        if (!badgeView) {
  
            badgeView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 4, self.frame.size.height - 8, 8, 8)];
            badgeView.tag = BADGE_TAG;
            badgeView.backgroundColor = [UIColor redColor];
            [self addSubview:badgeView];
            badgeView.layer.cornerRadius = badgeView.frame.size.height * 0.5;
            badgeView.layer.masksToBounds = YES;
        }
    }
    else
    {
      [badgeView removeFromSuperview];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
