//
//  StartHangOutTipView.m
//  livestream
//
//  Created by Randy_Fan on 2018/6/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "StartHangOutTipView.h"
#import "LiveBundle.h"
#import "LSConfigManager.h"
#import "LSShadowView.h"

@implementation StartHangOutTipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.hangoutButton.layer.cornerRadius = self.hangoutButton.frame.size.height / 2;
    self.hangoutButton.layer.masksToBounds = YES;
    self.bottomView.layer.cornerRadius = 5;
    self.bottomView.layer.masksToBounds = YES;
    LSShadowView *shadowView = [[LSShadowView alloc] init];
    [shadowView showShadowAddView:self.bottomView];
}

- (void)showMainHangoutTip:(UIView *)view {
    self.hangoutTipLabel.text = [LSConfigManager manager].item.hangoutCredirMsg;
    [view addSubview:self];
    [view bringSubviewToFront:self];

    if (self && view) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view.mas_centerY);
            make.centerX.equalTo(view.mas_centerX);
            make.height.width.equalTo(@(310));
            make.height.height.equalTo(@(222));
        }];
        
    }

}

- (void)showLiveRoomHangoutTip {
    self.closeButton.hidden = NO;
    self.closeImageView.hidden = YES;
    self.hangoutTipLabel.text = [LSConfigManager manager].item.hangoutCredirMsg;
}

- (IBAction)hangoutAction:(id)sender {
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(requestHangout:)]) {
        [self.delegate requestHangout:self];
    }
}

- (IBAction)closeAction:(id)sender {
  
    if ([self.delegate respondsToSelector:@selector(closeHangoutTip:)]) {
        [self.delegate closeHangoutTip:self];
    }
}



@end
