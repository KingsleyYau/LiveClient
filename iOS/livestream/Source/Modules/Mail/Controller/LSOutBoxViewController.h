//
//  LSOutBoxViewController.h
//  livestream
//
//  Created by Randy_Fan on 2018/12/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LSSessionRequest.h"

@interface LSOutBoxViewController : LSGoogleAnalyticsViewController

/** 意向信信息 */
@property (nonatomic, strong) LSHttpLetterListItemObject *letterItem;

@end
