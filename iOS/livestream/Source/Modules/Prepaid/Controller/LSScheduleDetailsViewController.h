//
//  LSScheduleDetailsViewController.h
//  livestream
//
//  Created by Calvin on 2020/4/20.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"
#import "LSScheduleInviteListItemObject.h"

@interface LSScheduleDetailsViewController : LSGoogleAnalyticsViewController

@property (nonatomic, strong) LSScheduleInviteListItemObject * listItem;

@property (nonatomic, copy) NSString *inviteId;
@property (nonatomic, copy) NSString *refId;
@property (nonatomic, copy) NSString *anchorId;

@end

 
