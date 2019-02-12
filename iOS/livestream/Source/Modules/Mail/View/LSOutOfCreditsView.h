//
//  LSOutOfCreditsView.h
//  livestream
//
//  Created by test on 2018/12/19.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSOutOfCreditsView;
@protocol LSOutOfCreditsViewDelegate <NSObject>
@optional
- (void)lsOutOfCreditsView:(LSOutOfCreditsView *)addView didSelectAddCredit:(UIButton *)creditBtn;
- (void)lsOutOfCreditsView:(LSOutOfCreditsView *)addView didSelectSendPoststamp:(UIButton *)SendPoststampBtn;
- (void)lsOutOfCreditsViewDidClose;
@end
@interface LSOutOfCreditsView : UIView
@property (weak, nonatomic) IBOutlet UIButton *addCreditBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendPoststampBtn;
/** 代理 */
@property (nonatomic, weak) id<LSOutOfCreditsViewDelegate> delegate;
+ (LSOutOfCreditsView *)initWithActionViewDelegate:(id<LSOutOfCreditsViewDelegate>)delegate;
- (void)outOfCreditShowPoststampAndAddCreditView:(UIView *)view poststampCount:(NSString *)poststampCount;
- (void)hideAnimation;
@end
