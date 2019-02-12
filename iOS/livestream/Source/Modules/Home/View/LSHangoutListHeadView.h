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

@end
@interface LSHangoutListHeadView : UIView
@property (weak, nonatomic) IBOutlet UIView *moreContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreContentViewHeight;
/** 代理 */
@property (nonatomic, weak) id<LSHangoutListHeadViewDelegate> hangoutHeadDelegate;
@end
