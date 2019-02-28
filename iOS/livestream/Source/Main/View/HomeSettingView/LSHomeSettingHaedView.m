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
    
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 1, screenSize.width -70, 1)];
    lineView.backgroundColor = COLOR_WITH_16BAND_RGB(0xC7D2E3);
    [self addSubview:lineView];
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
    self.nameLabel.text = [LSLoginManager manager].loginItem.nickName;
    
    [[LSImageViewLoader loader] refreshCachedImage:self.headView options:0 imageUrl:[LSLoginManager manager].loginItem.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"] finishHandler:^(UIImage *image) {
    }];
    
    self.userIdLabel.text = [LSLoginManager manager].loginItem.userId;
    
    UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"User_leave_%d",[LSLoginManager manager].loginItem.level]];
    [self.levelImageView setImage:image];
    
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

- (IBAction)levelImageClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didOpenLevelExplain)]) {
        [self.delegate didOpenLevelExplain];
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

@end
