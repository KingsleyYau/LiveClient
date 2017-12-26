//
//  IntroduceViewController.h
//  livestream
//
//  Created by test on 2017/9/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "IntroduceView.h"

@interface IntroduceViewController : LSListViewController

@property (weak, nonatomic) IBOutlet IntroduceView *introduceView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *introduceTop;

/** 链接 */
@property (nonatomic, copy) NSString* bannerUrl;
/** 标题 */
@property (nonatomic, copy) NSString *titleStr;
@end
