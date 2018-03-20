//
//  ManDetailView.m
//  livestream
//
//  Created by randy on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ManDetailView.h"
#import "LSLoginManager.h"
#import "LSImageViewLoader.h"
#import "LiveBundle.h"
#import "LiveModule.h"
#import <objc/runtime.h>


@interface ManDetailView()

@property (nonatomic, strong) LSImageViewLoader *imageLoader;
@property (nonatomic, strong) LSImageViewLoader *mountImageLoader;

@end

@implementation ManDetailView

+ (ManDetailView *) manDetailView {
    
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    ManDetailView* view = [nibs objectAtIndex:0];
    view.userHeadImageView.layer.cornerRadius = view.userHeadImageView.frame.size.height / 2;
    view.userHeadImageView.layer.masksToBounds = YES;
    view.imageLoader = [LSImageViewLoader loader];
    view.mountImageLoader = [LSImageViewLoader loader];
    return view;
}

- (void)updateManDataInfo:(AudienModel *)userInfo {
    
    self.nameLabel.text = userInfo.nickName;
    
    UIImage *levelImage = [UIImage imageNamed:[NSString stringWithFormat:@"User_leave_%d",userInfo.level]];
    self.levelImageView.image = levelImage;
    
    [self.imageLoader refreshCachedImage:self.userHeadImageView options:SDWebImageRefreshCached imageUrl:userInfo.photoUrl
                        placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
    
    if (userInfo.mountId.length) {
        self.riderImageView.hidden = NO;
        [self.mountImageLoader loadImageWithImageView:self.riderImageView options:0 imageUrl:userInfo.mountUrl
                                     placeholderImage:[UIImage imageNamed:@"Live_Rider_Normal"]];
    } else {
        self.riderImageView.hidden = YES;
    }
    
    objc_setAssociatedObject(self.inviteToOneBtn, @"userid", userInfo.userId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self.inviteToOneBtn, @"username", userInfo.nickName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (IBAction)inviteToOneClick:(id)sender {
    
    UIButton *btn = sender;
    NSString *userid = objc_getAssociatedObject(btn, @"userid");
    NSString *username = objc_getAssociatedObject(btn, @"username");
    
    if ([self.delegate respondsToSelector:@selector(inviteToOneAction:userName:)]) {
        [self.delegate inviteToOneAction:userid userName:username];
    }
}

- (IBAction)closeAction:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(manDetailViewCloseAction:)]) {
        [self.delegate manDetailViewCloseAction:self];
    }
}

@end
