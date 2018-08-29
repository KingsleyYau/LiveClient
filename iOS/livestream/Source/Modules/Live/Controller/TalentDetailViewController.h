//
//  TalentDetailViewController.h
//  livestream
//
//  Created by Calvin on 2018/5/28.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetTalentItemObject.h"
 #import "LSGoogleAnalyticsViewController.h"
#import "LiveRoom.h"

@protocol TalentDetailVCDelegate <NSObject>
@optional;
- (void)talentDetailVCButtonDid:(GetTalentItemObject *)item;

@end

@interface TalentDetailViewController : LSGoogleAnalyticsViewController

@property (nonatomic, weak) id<TalentDetailVCDelegate> delegates;

@property (nonatomic, strong) LiveRoom * liveRoom;

@property (nonatomic, strong) GetTalentItemObject * item;
@end
