//
//  LiveGuideViewController.h
//  dating
//
//  Created by test on 2017/10/10.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

@interface LSLiveGuideViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet UIButton *startBtn;


/** 导航页类型 */
@property (nonatomic, assign) int guideType;
/** 导航页数量 */
@property (nonatomic, strong) NSArray* guideListArray;
/** 导航页位置 */
@property (nonatomic,assign) NSInteger guideIndex;
@property (weak, nonatomic) IBOutlet UIScrollView *guideScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@end
