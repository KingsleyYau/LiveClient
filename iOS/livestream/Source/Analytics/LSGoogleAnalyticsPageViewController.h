//
//  LSGoogleAnalyticsPageViewController.h
//  livestream
//
//  Created by Max on 2018/10/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

@interface LSGoogleAnalyticsPageViewController : LSGoogleAnalyticsViewController
/**
 显示分页
 
 @param index 分页下标
 */
- (void)reportDidShowPage:(NSUInteger)index;
@end
