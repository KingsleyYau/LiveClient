//
//  EditInterestViewController.h
//  dating
//
//  Created by test on 2018/9/17.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LSAllTagListCollectionView.h"
#import "LSPersonalProfileItemObject.h"

@class LSEditInterestViewController;
@protocol LSEditInterestViewControllerDelegate <NSObject>
@optional
- (void)lsEditInterestViewController:(LSEditInterestViewController *)vc didSaveInterest:(NSMutableArray *)selectInteset;

@end


@interface LSEditInterestViewController : LSGoogleAnalyticsViewController
/** 兴趣列表 */
@property (nonatomic, strong) NSMutableArray* allTagList;
@property (weak, nonatomic) IBOutlet LSAllTagListCollectionView *interestContentView;
/** 个人详情模型 */
@property (nonatomic,strong) LSPersonalProfileItemObject *personalItem;
/** 代理 */
@property (nonatomic, weak) id<LSEditInterestViewControllerDelegate> editInterestDelegate;
/**
 已选择的列表
 */
@property (nonatomic, strong) NSMutableArray* selectInterestList;

@end
