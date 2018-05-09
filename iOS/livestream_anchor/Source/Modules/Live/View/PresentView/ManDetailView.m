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

@interface ManDetailView()

@property (nonatomic, strong) LSImageViewLoader *imageLoader;
@property (nonatomic, strong) LSImageViewLoader *mountImageLoader;
@property (nonatomic, strong) AudienModel *audienceItem;
@end

@implementation ManDetailView

+ (ManDetailView *) manDetailView {
    
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    ManDetailView* view = [nibs objectAtIndex:0];
    view.userHeadImageView.layer.cornerRadius = view.userHeadImageView.frame.size.height / 2;
    view.userHeadImageView.layer.masksToBounds = YES;
    view.imageLoader = [LSImageViewLoader loader];
    view.mountImageLoader = [LSImageViewLoader loader];
    view.audienceItem = [[AudienModel alloc] init];
    return view;
}

- (void)updateManDataInfo:(AudienModel *)userInfo {
    
    self.audienceItem = userInfo;
    
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
}

- (IBAction)inviteToOneClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(inviteToOneAction:userName:)]) {
        [self.delegate inviteToOneAction:self.audienceItem.userId userName:self.audienceItem.nickName];
    }
}

- (IBAction)closeAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(manDetailViewCloseAction:)]) {
        [self.delegate manDetailViewCloseAction:self];
    }
}

- (IBAction)manDetailAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(pushManDetailAction:)]) {
        [self.delegate pushManDetailAction:self.audienceItem.userId];
    }
}



@end
