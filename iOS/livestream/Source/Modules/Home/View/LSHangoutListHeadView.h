//
//  LSHangoutListHeadView.h
//  livestream
//
//  Created by test on 2019/1/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSHangoutListHeadView;
@protocol LSHangoutListHeadViewDelegate <NSObject>
@optional
- (void)LSHangoutListHeadViewDidShowMore:(LSHangoutListHeadView *)view;
- (void)LSHangoutListHeadViewDidHideMore:(LSHangoutListHeadView *)view;
- (void)LSHangoutListHeadViewDidGetTips:(LSHangoutListHeadView *)view;
@end
@interface LSHangoutListHeadView : UIView
@property (weak, nonatomic) IBOutlet UIView *moreContentView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreContentViewHeight;
@property (weak, nonatomic) IBOutlet LSCheckButton *showMoreBtn;
@property (weak, nonatomic) IBOutlet UIButton *notShowBtn;
/** 代理 */
@property (weak, nonatomic) IBOutlet UILabel *notShowLabel;
@property (weak, nonatomic) IBOutlet UIButton *getItBtn;
@property (weak, nonatomic) IBOutlet UILabel *creditTips;
@property (nonatomic, weak) id<LSHangoutListHeadViewDelegate> hangoutHeadDelegate;
@end
