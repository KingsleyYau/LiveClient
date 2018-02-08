//
//  LSUITabBarItem.m
//  UIWidget
//
//  Created by Max on 2018/1/26.
//  Copyright © 2018年 drcom. All rights reserved.
//

#import "LSUITabBarItem.h"

#define BADGE_IMAGEVIEW_DEFAULT_HEIGHT 13

@interface LSUITabBarItem ()
@property (strong) UIImageView *badgeImageView;
@property (strong) UILabel *badgeLabel;
@end

@implementation LSUITabBarItem

@dynamic badgeValue;

- (void)setBadgeValue:(NSString *)badgeValue {
    // Show default _UIBadgeView
    super.badgeValue = @"";
    
    // Get UITabBarButton
    UIView *tabBarButton = [self valueForKey:@"view"];
    
    // Hide default badge background for iOS 10
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 10) {
        self.badgeColor = [UIColor clearColor];
    }

    // Get _UIBadgeView
    for (UIView *subview in tabBarButton.subviews) {
        NSString *clsName = NSStringFromClass([subview class]);
        if ([clsName isEqualToString:@"_UIBadgeView"]) {
            UIView *badgeViewDefault = subview;

            for( UIView *view in badgeViewDefault.subviews ) {
                // Hide default badge background before iOS 10
                if ([UIDevice currentDevice].systemVersion.doubleValue < 10) {
                    NSString *badgeBgClsName = NSStringFromClass([view class]);
                    if ([badgeBgClsName isEqualToString:@"_UIBadgeBackground"]) {
                        [view setValue:nil forKey:@"image"];
                    }
                }
            }
            
            if( !self.badgeImageView ) {
                // Create custom badge view
                UIImageView *badgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
                badgeImageView.backgroundColor = [UIColor redColor];
                badgeImageView.layer.masksToBounds = YES;
                [badgeViewDefault addSubview:badgeImageView];
                
                self.badgeImageView = badgeImageView;
            }
            
            if( !self.badgeLabel ) {
                UILabel *badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 1, 0, 0)];
                badgeLabel.textColor = [UIColor whiteColor];
                badgeLabel.font = [UIFont systemFontOfSize:self.isShowNum?9:5];
                badgeLabel.textAlignment = NSTextAlignmentCenter;
                [badgeViewDefault addSubview:badgeLabel];
                self.badgeLabel = badgeLabel;
            }
        }
    }
    
    self.badgeLabel.text = badgeValue;
    if( badgeValue.length == 0 ) {
        self.badgeLabel.text = @" ";
    }
    [self.badgeLabel sizeToFit];
    self.badgeImageView.hidden = !badgeValue;
    
    // Calculate frame
    CGFloat width = MAX(self.badgeLabel.frame.size.width, self.badgeLabel.frame.size.height);
    CGFloat height = self.badgeLabel.frame.size.height;
    
    // Reset badgeLabel frame
    CGRect labelFrame = self.badgeLabel.frame;
    labelFrame.size = CGSizeMake(width, height);
    self.badgeLabel.frame = labelFrame;
    
    // Reset badgeImageView frame
    CGRect imageViewFrame = self.badgeImageView.frame;
    imageViewFrame.size = CGSizeMake(width + 2, height + 2);
    self.badgeImageView.frame = imageViewFrame;
    self.badgeImageView.layer.cornerRadius = self.badgeImageView.frame.size.height / 2;
}

@end
