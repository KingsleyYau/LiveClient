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
}

- (void)showMainHangoutTip {
    self.closeButton.hidden = YES;
    self.closeImageView.hidden = NO;
    self.hangoutTipLabel.text = [LSConfigManager manager].item.hangoutCredirMsg;
}

- (void)showLiveRoomHangoutTip {
    self.closeButton.hidden = NO;
    self.closeImageView.hidden = YES;
    self.hangoutTipLabel.text = [LSConfigManager manager].item.hangoutCredirMsg;
}

- (IBAction)hangoutAction:(id)sender {
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
