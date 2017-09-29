//
//  VerifyMobileNumberViewController.h
//  livestream
//
//  Created by Calvin on 17/9/29.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleAnalyticsViewController.h"
@interface VerifyMobileNumberViewController : GoogleAnalyticsViewController

@property (nonatomic, copy) NSString * phoneStr;

@property (nonatomic, copy) NSString * countryStr;

@property (nonatomic, copy) NSString * verifyCode;
@end
