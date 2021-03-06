//
//  LSHomeSettingHaedView.m
//  livestream
//
//  Created by Calvin on 2018/6/13.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSHomeSettingHaedView.h"
#import "LSLoginManager.h"
#import "LSImageViewLoader.h"
#import "LiveRoomCreditRebateManager.h"
#import "LSPersonalProfileItemObject.h"
@interface LSHomeSettingHaedView ()

@end

@implementation LSHomeSettingHaedView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"LSHomeSettingHaedView" owner:self options:nil].firstObject;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.headView.layer.cornerRadius = self.headView.frame.size.width / 2;
    self.headView.layer.masksToBounds = YES;
    self.headView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headView.layer.borderWidth = 4.0f;
    
    self.backgroundView.userInteractionEnabled = YES;
    self.headView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundClick:)];
    [self.backgroundView addGestureRecognizer:tap];

    self.changeSiteBtn.layer.cornerRadius = 5;
    self.changeSiteBtn.layer.masksToBounds = YES;
    self.changeSiteBtn.adjustsImageWhenHighlighted = NO;
    
    self.addBtn.layer.cornerRadius = 4;
    self.addBtn.layer.masksToBounds = YES;
    

    [self.changeSiteBtn setTitleColor:[LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x383838) orDark:[UIColor whiteColor]] forState:UIControlStateNormal];
    self.balanceLabel.textColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x383838) orDark:[UIColor whiteColor]];
    self.creditName.textColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x383838) orDark:[UIColor whiteColor]];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"LSHomeSettingHaedView" owner:self options:nil].firstObject;
    }
    return self;
}

- (void)updateUserInfo {
    
    if (IS_IPHONE_X) {
        self.settingBtnY.constant = 50;
    }
    
    self.nameLabel.text = [LSLoginManager manager].loginItem.nickName;
    
    
    NSString *photoUrl = [LSLoginManager manager].loginItem.photoUrl;
    LSPersonalProfileItemObject *item = [self getUserData];
    if (item) {
        photoUrl = item.photoUrl;
    }
    [[LSImageViewLoader loader] loadImageFromCache:self.headView options:0 imageUrl:photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"] finishHandler:^(UIImage *image) {
    }];
    
    
    self.userIdLabel.text = [LSLoginManager manager].loginItem.userId;
        
    self.balanceLabel.text = [NSString stringWithFormat:@"Balance：%.2f",[LiveRoomCreditRebateManager creditRebateManager].mCredit];
    __weak typeof(self) weakSelf = self;
    [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        if (success) {
            weakSelf.balanceLabel.text = [NSString stringWithFormat:@"Balance：%.2f",credit];
        }
    }];
}

- (IBAction)settingBtnDid:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(pushSettingInfoVC)]) {
        [self.delegate pushSettingInfoVC];
    }
}

- (IBAction)changeSiteAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didChangeSiteClick)]) {
        [self.delegate didChangeSiteClick];
    }
}

- (IBAction)manHeadImageClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didOpenPersonalCenter)]) {
        [self.delegate didOpenPersonalCenter];
    }
}

- (IBAction)addCrteditsAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(pushToCreditsVC)]) {
        [self.delegate pushToCreditsVC];
    }
}

- (void)backgroundClick:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(didOpenPersonalCenter)]) {
        [self.delegate didOpenPersonalCenter];
    }
}


- (LSPersonalProfileItemObject *)getUserData {
    NSString *manKey = [NSString stringWithFormat:@"LSManProfile_%@",[LSLoginManager manager].loginItem.userId];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:manKey];
    LSPersonalProfileItemObject *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return item;
}

@end
