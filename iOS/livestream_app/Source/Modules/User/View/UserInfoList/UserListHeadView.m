//
//  UserListHeadView.m
//  livestream
//
//  Created by Calvin on 2017/12/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "UserListHeadView.h"
#import "LSLoginManager.h"
#import "LSImageViewLoader.h"
#import "UserInfoManager.h"
@interface UserListHeadView ()
@property (nonatomic, strong) LSLoginManager * loginManager;
@end

@implementation UserListHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"UserListHeadView" owner:self options:nil].firstObject;
        self.frame = frame;
        //[self reloadHeaderView];
    }
    return self;
}

- (void)reloadHeaderView {
    self.loginManager = [LSLoginManager manager];
    
    self.nameLabel.text = self.loginManager.loginItem.nickName;
    self.idLabel.text = [NSString stringWithFormat:@"ID:%@",self.loginManager.loginItem.userId];
    
    [[LSImageViewLoader loader] stop];
    [[LSImageViewLoader loader] refreshCachedImage:self.headImage options:SDWebImageRefreshCached imageUrl:self.loginManager.loginItem.photoUrl placeholderImage:[UIImage imageNamed:@"UserHead_bg"]];
    [self updateNameFrame];

    [self updateLevel:self.loginManager.loginItem.userlevel];
}


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (IBAction)backBtnDid:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(headViewBackBtnDid)]) {
        [self.delegate headViewBackBtnDid];
    }
}

- (IBAction)editBtnDid:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(headViewEditBtnDid)]) {
        [self.delegate headViewEditBtnDid];
    }
}

- (void)updateNameFrame
{
    CGSize size = [self.nameLabel.text sizeWithAttributes:@{NSFontAttributeName:self.nameLabel.font}];
    
    CGRect nameRect = self.nameLabel.frame;
    nameRect.size.width = size.width;
    self.nameLabel.frame = nameRect;
    
    CGRect levelRect = self.levelImage.frame;
    levelRect.origin.x = nameRect.origin.x + nameRect.size.width + 10;
    self.levelImage.frame = levelRect;
}

- (void)updateLevel:(NSInteger)level
{
    if (level > 10) {
        level = 10;
    }
    UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"User_leave_%ld",level]];
    self.levelImage.image = image;
}

@end
