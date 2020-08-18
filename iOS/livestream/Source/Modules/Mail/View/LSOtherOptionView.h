//
//  LSOtherOptionView.h
//  livestream
//
//  Created by test on 2020/4/15.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class LSOtherOptionView;
@protocol LSOtherOptionViewDelegate <NSObject>
@optional
- (void)lsOtherOptionView:(LSOtherOptionView *)ohterOptionView declineAndSendMail:(UIButton *)declineAndSendMailbtn;
- (void)lsOtherOptionView:(LSOtherOptionView *)ohterOptionView decline:(UIButton *)declineBtn;
- (void)lsOtherOptionView:(LSOtherOptionView *)ohterOptionView sendMail:(UIButton *)sendMailBtn;
@end
@interface LSOtherOptionView : UIView
@property (weak, nonatomic) IBOutlet UIButton *declineSendMailBtn;
@property (weak, nonatomic) IBOutlet UIButton *decelineBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendMailBtn;
/** 代理 */
@property (nonatomic, weak) id<LSOtherOptionViewDelegate> delegate;
+ (LSOtherOptionView *)ohterOptionWithDelegate:(id<LSOtherOptionViewDelegate>)delegate;
- (void)setDetailDeclineBtnTitle;
@end

NS_ASSUME_NONNULL_END
