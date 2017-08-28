//
//  GiftPresentView.h
//  livestream
//
//  Created by randy on 2017/8/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountTimeButton.h"
#import "PresentSendView.h"
#import "SelectNumButton.h"

@class GiftPresentView;
@protocol GiftPresentViewDelegate <NSObject>
@optional
- (Class)giftPresentView:(GiftPresentView *)giftPresentView classForIndex:(NSUInteger)index;
- (NSUInteger)chooseGiftPageViewCount:(GiftPresentView *)giftPresentView;
- (UIView *)giftPresentView:(GiftPresentView *)giftPresentView pageViewForIndex:(NSUInteger)index;
- (void)giftPresentView:(GiftPresentView *)giftPresentView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index;
- (void)giftPresentView:(GiftPresentView *)giftPresentView didShowPageViewForDisplay:(NSUInteger)index;
@end

@interface GiftPresentView : UIView <PZPagingScrollViewDelegate>

@property (assign, nonatomic) IBOutlet id<GiftPresentViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *buttonsView;

@property (weak, nonatomic) IBOutlet PZPagingScrollView *chooseGiftScrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chooseGiftScrollViewHeight;

/**
 切换分页按钮
 */
@property (strong, nonatomic) NSArray<UIButton*>* buttons;


/**
 实例
 */
+ (instancetype)giftPresentView:(id)owner;


- (void)reloadData;

@end
