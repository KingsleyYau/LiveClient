//
//  KKSearchBar.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKSearchBar : UISearchBar {
    UIImageView *_kkbackgroundImageView;
    UIImageView *_kkCancelButtonBackgroundView;
}
@property (nonatomic, readonly) UIImageView *kkbackgroundImageView;
- (void)setBackgroundImage:(UIImage *)backgroundImage;
- (void)setCancelBackgroundImage:(UIImage *)cancelButtonBackgroundImage;
@end
