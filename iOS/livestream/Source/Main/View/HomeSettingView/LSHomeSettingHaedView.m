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
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"LSHomeSettingHaedView" owner:self options:nil].firstObject;
        self.frame = frame;
        
        self.headView.layer.cornerRadius = self.headView.frame.size.width / 2;
        self.headView.layer.masksToBounds = YES;
        
        self.changeSiteBtn.layer.cornerRadius = 5;
        self.changeSiteBtn.layer.masksToBounds = YES;
    }
    return self;
}

- (void)updateUserInfo {
    self.nameLabel.text = [LSLoginManager manager].loginItem.nickName;
    
    [[LSImageViewLoader loader] refreshCachedImage:self.headView options:0 imageUrl:[LSLoginManager manager].loginItem.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
    
    self.userIdLabel.text = [LSLoginManager manager].loginItem.userId;
    
    UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"User_leave_%d",[LSLoginManager manager].loginItem.level]];
    [self.levelImageView setImage:image];
}

- (IBAction)changeSiteAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didChangeSiteClick)]) {
        [self.delegate didChangeSiteClick];
    }
}

- (IBAction)manHeadImageClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didOpenProfileClick)]) {
        [self.delegate didOpenProfileClick];
    }
}

- (IBAction)levelImageClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didOpenLevelExplain)]) {
        [self.delegate didOpenLevelExplain];
    }
}

@end
