//
//  DeliveryStatusView.h
//  livestream
//
//  Created by test on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeliveryStatusView : UIView
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoHeight;
@property (weak, nonatomic) IBOutlet UILabel *pendingTips;
@property (weak, nonatomic) IBOutlet UILabel *deliveryTips;
@property (weak, nonatomic) IBOutlet UILabel *cancelTips;
@property (weak, nonatomic) IBOutlet UILabel *shippedTips;

+ (DeliveryStatusView *)deliveryStatusView;
- (void)showDeliveryStatusView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
