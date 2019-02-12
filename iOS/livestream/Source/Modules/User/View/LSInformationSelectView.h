//
//  InformationSelectView.h
//  dating
//
//  Created by test on 2018/9/18.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSInformationSelectView;
@protocol LSInformationSelectViewDelegate <NSObject>
@optional

- (void)lsInformationSelectView:(LSInformationSelectView *)view didSaveInformationForIndex:(NSInteger)index;

@end

@interface LSInformationSelectView : UIView
/** 个人信息数据 */
@property (nonatomic, copy) NSArray *dataArray;
/** 代理 */
@property (nonatomic, weak) id<LSInformationSelectViewDelegate> informationDelegate;
/** 当前信息 */
@property (nonatomic, copy) NSString *currentDetail;

+ (instancetype)initInformationSelectViewXib;
- (void)reloadCurrentIndex;
- (void)showAnimation;
- (void)hideAnimation;
@end
