//
//  ManDetailView.h
//  livestream
//
//  Created by randy on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoom.h"
#import "AudienModel.h"

@class ManDetailView;
@protocol ManDetailViewDelegate <NSObject>
- (void)manDetailViewCloseAction:(ManDetailView *)manDetailView;
- (void)inviteToOneAction:(NSString *)userId userName:(NSString *)userName;
@end

@interface ManDetailView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *userHeadImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIButton *inviteToOneBtn;

@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;

@property (weak, nonatomic) IBOutlet UIImageView *riderImageView;

/** 代理 */
@property (nonatomic, weak) id<ManDetailViewDelegate> delegate;

+ (ManDetailView *) manDetailView;

- (void)updateManDataInfo:(AudienModel *)userInfo;

@end
