//
//  DriveView.h
//  livestream
//
//  Created by randy on 2017/9/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudienceModel.h"
#import "RoomStyleItem.h"

@class DriveView;
@protocol DriveViewDelegate <NSObject>
@optional

- (void)canPlayDirve:(DriveView *)driveView audienceModel:(AudienceModel *)model offset:(int)offset ifError:(NSError *)error;

@end

@interface DriveView : UIView

@property (weak, nonatomic) IBOutlet UIView *driveBackgroundView;

@property (weak, nonatomic) IBOutlet UIImageView *driveImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *joinLabel;


@property (weak, nonatomic) id<DriveViewDelegate> delegate;

/**
 更新数据源

 @param model 观众模型
 */
- (void)audienceComeInLiveRoom:(AudienceModel *)model;

- (void)setupViewColor:(RoomStyleItem *)item;

@end
