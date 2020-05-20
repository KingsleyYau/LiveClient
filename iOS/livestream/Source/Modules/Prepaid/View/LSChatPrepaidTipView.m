//
//  LSChatPrepaidTipView.m
//  livestream
//
//  Created by Calvin on 2020/4/10.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSChatPrepaidTipView.h"

@interface LSChatPrepaidTipView ()

@end

@implementation LSChatPrepaidTipView

- (instancetype)init {
 self = [super init];
 if (self) {
     self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSChatPrepaidTipView" owner:self options:0].firstObject;
 }
 return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.confirmUnCount.layer.cornerRadius = self.confirmUnCount.tx_height/2;
    self.confirmUnCount.layer.masksToBounds = YES;
    
    self.pendingUnCount.layer.cornerRadius = self.pendingUnCount.tx_height/2;
    self.pendingUnCount.layer.masksToBounds = YES;
    
    self.sendBtn.layer.cornerRadius = self.sendBtn.tx_height/2;
    self.sendBtn.layer.masksToBounds = YES;
}

- (void)updateCount:(NSInteger)count pcount:(NSInteger)pcount{
    
    if (count > 0) {
        self.confirmUnCount.hidden = NO;
        self.confirmUnCount.text = [NSString stringWithFormat:@"%ld",count];
    }
    if (pcount) {
        self.pendingUnCount.hidden = NO;
        self.pendingUnCount.text = [NSString stringWithFormat:@"%ld",pcount];
    }
}

- (IBAction)confirmBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(prepaidTipViewDidConfirm)]) {
        [self.delegate prepaidTipViewDidConfirm];
    }
}

- (IBAction)pendingBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(prepaidTipViewDidPending)]) {
        [self.delegate prepaidTipViewDidPending];
    }
}

- (IBAction)sendBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(prepaidTipViewDidSendRequest)]) {
        [self.delegate prepaidTipViewDidSendRequest];
    }
}
@end