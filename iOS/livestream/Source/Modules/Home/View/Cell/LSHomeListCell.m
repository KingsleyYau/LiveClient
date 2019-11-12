//
//  LSHomeListCell.m
//  livestream
//
//  Created by Calvin on 2019/6/14.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSHomeListCell.h"

@implementation LSHomeListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    self.liveStatusView.layer.cornerRadius = self.liveStatusView.tx_height/2;
    self.liveStatusView.layer.masksToBounds = YES;
    
    self.onlineStatus.layer.cornerRadius = self.onlineStatus.tx_height/2;
    self.onlineStatus.layer.masksToBounds = YES;
    
    self.vipPrivateBtn.layer.cornerRadius = self.vipPrivateBtn.tx_height/2;
    self.vipPrivateBtn.layer.masksToBounds = YES;
    
    self.watchNowBtn.layer.cornerRadius = self.watchNowBtn.tx_height/2;
    self.watchNowBtn.layer.masksToBounds = YES;
    
    self.chatNowBtn.layer.cornerRadius = self.chatNowBtn.tx_height/2;
    self.chatNowBtn.layer.masksToBounds = YES;
    
    self.sendMailBtn.layer.cornerRadius = self.sendMailBtn.tx_height/2;
    self.sendMailBtn.layer.masksToBounds = YES;
    
    self.sayHiFreeIcon.layer.cornerRadius = 3;
    self.sayHiFreeIcon.layer.masksToBounds = YES;
    // 创建新的
    self.imageViewLoader = [LSImageViewLoader loader];
    
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0xD4000000).CGColor,(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x25000000).CGColor, (__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x00000000).CGColor];
    gradientLayer.locations = @[@0,@0.75,@1.0];
    gradientLayer.startPoint = CGPointMake(0, 1.0);
    gradientLayer.endPoint = CGPointMake(0, 0.0);
    gradientLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH/2, 100);
    [self.bottomView.layer addSublayer:gradientLayer];
    
    if (screenSize.width == 320) {
        self.vipPrivateBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    }
}

+ (NSString *)cellIdentifier {
    return @"LSHomeListCell";
}

- (void)setBtnType:(BottomBtnType)btnType {
    _btnType = btnType;
    NSString * imageName = @"LS_Home_Chat";
    if (btnType == BottomBtnType_Chat) {
        imageName =@"LS_Home_Chat";
    }else if (btnType == BottomBtnType_Mail) {
        imageName =@"LS_Home_Mail";
    }
    else {
        imageName =@"LS_Home_Book";
    }
     [self.chatBtn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (IBAction)watchNowBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(homeListCellWatchNowBtnDid:)]) {
        [self.cellDelegate homeListCellWatchNowBtnDid:self.tag];
    }
}

- (IBAction)inviteBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(homeListCellInviteBtnDid:)]) {
        [self.cellDelegate homeListCellInviteBtnDid:self.tag];
    }
}

- (IBAction)chatNowBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(homeListCellChatNowBtnDid:)]) {
        [self.cellDelegate homeListCellChatNowBtnDid:self.tag];
    }
}

- (IBAction)sendMailBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(homeListCellSendMailBtnDid:)]) {
        [self.cellDelegate homeListCellSendMailBtnDid:self.tag];
    }
}

- (IBAction)sayHiBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(homeListCellSayHiBtnDid:)]) {
        [self.cellDelegate homeListCellSayHiBtnDid:self.tag];
    }
}

- (IBAction)focusBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(homeListCellFocusBtnDid:)]) {
        [self.cellDelegate homeListCellFocusBtnDid:self.tag];
    }
}

- (IBAction)chatBtnDid:(id)sender {
    if (self.btnType == BottomBtnType_Chat) {
        if ([self.cellDelegate respondsToSelector:@selector(homeListCellChatNowBtnDid:)]) {
            [self.cellDelegate homeListCellChatNowBtnDid:self.tag];
        }
    }
    else if (self.btnType == BottomBtnType_Mail) {
        if ([self.cellDelegate respondsToSelector:@selector(homeListCellSendMailBtnDid:)]) {
            [self.cellDelegate homeListCellSendMailBtnDid:self.tag];
        }
    }
    else {
        if ([self.cellDelegate respondsToSelector:@selector(homeListCellBookingBtnDid:)]) {
            [self.cellDelegate homeListCellBookingBtnDid:self.tag];
        }
    }
}


@end
