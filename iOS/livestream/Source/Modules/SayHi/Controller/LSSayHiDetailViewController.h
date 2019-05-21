//
//  LSSayHiDetailViewController.h
//  livestream
//
//  Created by Calvin on 2019/4/18.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsPageViewController.h"
#import "LSSayHiDetailItemObject.h"

@interface LSSayHiDetailViewController : LSGoogleAnalyticsPageViewController

@property (nonatomic, copy) NSString * sayHiID;
@property (nonatomic, copy) NSString * responseId; //回复ID，不为空时展开该条回复
@property (nonatomic, strong) LSSayHiDetailItemObject * detail;
@end

 
