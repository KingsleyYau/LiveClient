//
//  LSUserSettingHeadView.m
//  livestream
//
//  Created by Calvin on 2018/9/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSUserSettingHeadView.h"
#import "LSLoginManager.h"
#import "LSImageViewLoader.h"
 
@interface LSUserSettingHeadView ()

@end

@implementation LSUserSettingHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"LSUserSettingHeadView" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headImage.layer.cornerRadius = self.headImage.tx_height/2;
    self.headImage.layer.masksToBounds = YES;
    self.headImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headImage.layer.borderWidth = 5.0f;
    
    self.nameLabel.text = [LSLoginManager manager].loginItem.nickName;
    self.ageLabel.text = [LSLoginManager manager].loginItem.userId;
    
    self.userInteractionEnabled = YES;
    self.headImage.userInteractionEnabled = YES;
    self.headBackground.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgClickAction)];
    UITapGestureRecognizer *tapBg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgClickAction)];
    [self.headBackground addGestureRecognizer:tapBg];
    [self.headImage addGestureRecognizer:tap];
    
    [[LSImageViewLoader loader] refreshCachedImage:self.headImage options:0 imageUrl:[LSLoginManager manager].loginItem.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
}

- (IBAction)backBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(settingHeadViewBackDid)]) {
        [self.delegate settingHeadViewBackDid];
    }
}

- (void)bgClickAction {
    if ([self.delegate respondsToSelector:@selector(settingBackgroundDid)]) {
        [self.delegate settingBackgroundDid];
    }
}

@end
