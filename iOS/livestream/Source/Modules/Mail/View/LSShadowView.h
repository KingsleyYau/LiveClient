//
//  LSShadowView.h
//  livestream
//
//  Created by Calvin on 2019/1/5.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSShadowView : UIView
@property (nonatomic, strong) UIColor * shadowColor;
- (void)showShadowAddView:(UIView*)view;
@end

NS_ASSUME_NONNULL_END
