//
//  VerifyMobileNumberViewController.h
//  livestream
//
//  Created by Calvin on 17/9/29.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"
#import "Country.h"

@interface VerifyMobileNumberViewController : LSGoogleAnalyticsViewController

@property (nonatomic, copy) NSString * phoneStr;
@property (nonatomic, strong) Country * country;

@end
