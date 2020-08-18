//
//  LSPremiumVideoDetailCell.m
//  livestream
//
//  Created by Calvin on 2020/8/5.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPremiumVideoDetailCell.h"
#import "LSShadowView.h"
@interface LSPremiumVideoDetailCell ()<UITextFieldDelegate>

@end

@implementation LSPremiumVideoDetailCell

+ (NSInteger)cellHeight:(LSPremiumVideoDetailItemObject*)item {
    CGFloat h = 0;
    if (item.videoId.length == 0) {
        return 0;
    }
    switch (item.lockStatus) {
        case LSLOCKSTATUS_LOCK_NOREQUEST:// 未解锁，未发过解锁请求
            h = 416;
            break;
        case LSLOCKSTATUS_LOCK_UNREPLY:// 未解锁，解锁请求未回复
            h = 573;
            break;
        case LSLOCKSTATUS_LOCK_REPLY:// 未解锁，解锁请求已回复
            h = 581;
            break;
        default:
            break;
    }
    return h;
}

+ (NSString *)cellIdentifier {
    return @"LSPremiumVideoDetailCell";
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSPremiumVideoDetailCell *cell = (LSPremiumVideoDetailCell *)[tableView dequeueReusableCellWithIdentifier:[LSPremiumVideoDetailCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPremiumVideoDetailCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)loadUI:(LSPremiumVideoDetailItemObject *)item {
    if (item.videoId.length == 0) {
        self.hidden = YES;
        return;
    }
    self.notUnlockView.hidden = YES;
    self.accessKeyView.hidden = YES;
    self.sendReminderView.hidden = YES;
    self.congratsView.hidden = YES;
    switch (item.lockStatus) {
        case LSLOCKSTATUS_LOCK_NOREQUEST:// 未解锁，未发过解锁请求
             self.notUnlockView.hidden = NO;
            break;
        case LSLOCKSTATUS_LOCK_UNREPLY:// 未解锁，解锁请求未回复
            self.accessKeyView.hidden = NO;
            self.sendReminderView.hidden = NO;
            break;
        case LSLOCKSTATUS_LOCK_REPLY:// 未解锁，解锁请求已回复
            self.accessKeyView.hidden = NO;
            self.congratsView.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.contentBGView.layer.cornerRadius = 8;
    self.contentBGView.layer.masksToBounds = YES;
    self.contentBGView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xFCD21E).CGColor;
    self.contentBGView.layer.borderWidth = 1;
    
    self.notUnlockTipView.layer.cornerRadius = 4;
    self.notUnlockTipView.layer.masksToBounds = YES;
    self.notUnlockTipView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xFFE993).CGColor;
    self.notUnlockTipView.layer.borderWidth = 1;
    
     self.notUnlockCreditsTipView.layer.cornerRadius = 4;
     self.notUnlockCreditsTipView.layer.masksToBounds = YES;
     self.notUnlockCreditsTipView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xFFE993).CGColor;
     self.notUnlockCreditsTipView.layer.borderWidth = 1;
    
    self.sendKeyBtn.layer.cornerRadius = self.sendKeyBtn.tx_height/2;
    self.sendKeyBtn.layer.masksToBounds = YES;
    
    LSShadowView * sendKeyBtnS = [[LSShadowView alloc]init];
    [sendKeyBtnS showShadowAddView:self.sendKeyBtn];
    
    self.watchBtn.layer.cornerRadius = self.watchBtn.tx_height/2;
    self.watchBtn.layer.masksToBounds = YES;
    
    LSShadowView * watchBtnS = [[LSShadowView alloc]init];
    [watchBtnS showShadowAddView:self.watchBtn];
    
    self.accessKeyTipView.layer.cornerRadius = 4;
    self.accessKeyTipView.layer.masksToBounds = YES;
    self.accessKeyTipView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xFFE993).CGColor;
    self.accessKeyTipView.layer.borderWidth = 1;
    
    self.sendReminderView.layer.cornerRadius = 2;
    self.sendReminderView.layer.masksToBounds = YES;
    self.sendReminderView.layer.borderColor = COLOR_WITH_16BAND_RGB(0x68CA77).CGColor;
    self.sendReminderView.layer.borderWidth = 1;
    
    self.inputKeyView.layer.cornerRadius = 4;
    self.inputKeyView.layer.masksToBounds = YES;
    self.inputKeyView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xFFE993).CGColor;
    self.inputKeyView.layer.borderWidth = 1;
    
    self.congratsView.layer.cornerRadius = 2;
    self.congratsView.layer.masksToBounds = YES;
    self.congratsView.layer.borderColor = COLOR_WITH_16BAND_RGB(0x68CA77).CGColor;
    self.congratsView.layer.borderWidth = 1;
    
    self.textFiled.delegate = self;
    self.textFiled.leftViewMode = UITextFieldViewModeAlways;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textFieldTextChange:(NSNotification *)notifi {
    UITextField * textf = notifi.object;
    [self setKeyCode:textf.text];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setKeyCode:(NSString *)str {
    if (str.length > 0) {
        [self.watchKeyBtn setBackgroundImage:[UIImage imageNamed:@"LS_WatchVideo_G"] forState:UIControlStateNormal];
        [self.watchKeyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            NSDictionary *attrsDictionary =@{
                            NSFontAttributeName: self.textFiled.font,
                            NSKernAttributeName:[NSNumber numberWithFloat:5.0f]//这里修改字符间距
                            };
        self.textFiled.attributedText = [[NSAttributedString alloc]initWithString:str attributes:attrsDictionary];
    }else {
        [self.watchKeyBtn setBackgroundImage:[UIImage imageNamed:@"LS_WatchVideo"] forState:UIControlStateNormal];
        [self.watchKeyBtn setTitleColor:COLOR_WITH_16BAND_RGB(0x999999) forState:UIControlStateNormal];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
 
    return YES;
}


- (IBAction)sendAccessKeyBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(premiumVideoDetailCellDidSendAccessKeyBtn)]) {
        [self.cellDelegate premiumVideoDetailCellDidSendAccessKeyBtn];
    }
}

- (IBAction)sendReminderBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(premiumVideoDetailCellDidSendReminderBtn)]) {
        [self.cellDelegate premiumVideoDetailCellDidSendReminderBtn];
    }
}

- (IBAction)watchKeyBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(premiumVideoDetailCellDidDidWatchVideo:)]) {
        [self.cellDelegate premiumVideoDetailCellDidDidWatchVideo:self.textFiled.text];
    }
    
}

- (IBAction)checkNewBtn:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(premiumVideoDetailCellDidDidCheckNowBtn)]) {
        [self.cellDelegate premiumVideoDetailCellDidDidCheckNowBtn];
    }
}

- (IBAction)watchBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(premiumVideoDetailCellDidCreditsWatchVideo)]) {
        [self.cellDelegate premiumVideoDetailCellDidCreditsWatchVideo];
    }
}
@end
