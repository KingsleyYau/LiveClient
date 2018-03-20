//
//  DriverView.h
//  livestream
//
//  Created by randy on 2017/9/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudienModel.h"
#import "RoomStyleItem.h"

@class DriverView;
@protocol DriverViewDelegate <NSObject>
@optional

- (void)canPlayDirve:(DriverView *)driverView driverModel:(AudienModel *)model offset:(int)offset ifError:(NSError *)error;

@end

@interface DriverView : UIView

@property (weak, nonatomic) IBOutlet UIView *driveBackgroundView;

@property (weak, nonatomic) IBOutlet UIImageView *driveImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *joinLabel;


@property (weak, nonatomic) id<DriverViewDelegate> delegate;

/**
 更新数据源

 @param model 观众模型
 */
- (void)audienceComeInLiveRoom:(AudienModel *)model;

- (void)setupViewColor:(RoomStyleItem *)item;

@end
