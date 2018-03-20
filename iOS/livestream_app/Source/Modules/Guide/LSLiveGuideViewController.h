//
//  LiveGuideViewController.h
//  dating
//
//  Created by test on 2017/10/10.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LSLoginItemObject.h"

@class LSLiveGuideViewController;
@protocol LSLiveGuideViewControllerDelegate <NSObject>

- (void)lsLiveGuideViewControllerDidFinishGuide:(LSLiveGuideViewController *)guideViewController;

@end



@interface LSLiveGuideViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet UIButton *startBtn;


/** 导航页类型 */
@property (nonatomic, assign) UserType guideType;
/** 导航页数量 */
@property (nonatomic, strong) NSArray* guideListArray;
/** 导航页位置 */
@property (nonatomic,assign) NSInteger guideIndex;
@property (weak, nonatomic) IBOutlet UIScrollView *guideScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

/** 是否列表导航 */
@property (nonatomic, assign) BOOL listGuide;

/** 代理 */
@property (nonatomic, weak) id<LSLiveGuideViewControllerDelegate> guideDelegate;
@end
