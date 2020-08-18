//
//  LSChatPrepaidTipView.h
//  livestream
//
//  Created by Calvin on 2020/4/10.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSChatPrepaidTipViewDelegate <NSObject>

- (void)prepaidTipViewDidConfirm;
- (void)prepaidTipViewDidPending;
- (void)prepaidTipViewDidSendRequest;
@end

@interface LSChatPrepaidTipView : UIView

@property (weak, nonatomic) IBOutlet UIView *confirmView;
@property (weak, nonatomic) IBOutlet UIView *pendingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pendingViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *confirmUnCount;
@property (weak, nonatomic) IBOutlet UILabel *pendingUnCount;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) id<LSChatPrepaidTipViewDelegate> delegate;

- (void)updateCount:(NSInteger)count pcount:(NSInteger)pcount;
@end
 
