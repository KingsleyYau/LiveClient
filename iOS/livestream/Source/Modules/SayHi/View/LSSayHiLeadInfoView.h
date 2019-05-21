//
//  LSSayHiLeadInfoView.h
//  livestream
//
//  Created by test on 2019/4/24.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class LSSayHiLeadInfoView;
@protocol LSSayHiLeadInfoViewDelegate <NSObject>
@optional
- (void)lsSayHiLeadInfoDidClose:(LSSayHiLeadInfoView *)view;
@end

@interface LSSayHiLeadInfoView : UIView
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
/** 代理 */
@property (nonatomic, weak) id<LSSayHiLeadInfoViewDelegate> leadInfoDelegate;
+ (LSSayHiLeadInfoView *)leadInfoView;
- (void)showSayHiLeadInfoView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
