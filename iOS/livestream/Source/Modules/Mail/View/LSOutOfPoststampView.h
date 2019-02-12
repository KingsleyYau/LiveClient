//
//  LSOutOfCreditsView.h
//  livestream
//
//  Created by test on 2018/12/17.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSOutOfPoststampView;
@protocol LSOutOfPoststampViewDelegate <NSObject>
@optional
- (void)lsOutOfPoststampView:(LSOutOfPoststampView *)addView  didSelectAddCredit:(UIButton *)creditBtn;
- (void)lsOutOfPoststampViewDidClose;
@end

@interface LSOutOfPoststampView : UIView
@property (weak, nonatomic) IBOutlet UIButton *addCreditBtn;
/** 代理 */
@property (nonatomic, weak) id<LSOutOfPoststampViewDelegate> delegate;
+ (LSOutOfPoststampView *)initWithActionViewDelegate:(id<LSOutOfPoststampViewDelegate>)delegate;
- (void)outOfPoststampShowCreditView:(UIView *)view balanceCount:(NSString *)balanceCount;
- (void)hideAnimation;
@end
