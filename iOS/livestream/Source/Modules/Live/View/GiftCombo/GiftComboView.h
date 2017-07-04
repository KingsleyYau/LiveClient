//
//  GiftComboView.h
//  LiveSendGift
//
//  Created by Calvin on 17/5/23.
//  Copyright © 2017年 com.wujh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GiftComboNumView.h"
#import "ImageViewLoader.h"
#import "GiftItem.h"

@class GiftComboView;
@protocol GiftComboViewDelegate <NSObject>
@optional
- (void)playComboFinish:(GiftComboView *)giftComboView;

@end

@interface GiftComboView : UIView

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView; /**< 背景图 */
@property (weak, nonatomic) IBOutlet UIImageViewTopFit *iconImageView; /**< 头像 */
@property (weak, nonatomic) ImageViewLoader* imageViewHeaderLoader;
@property (weak, nonatomic) IBOutlet UIImageView *giftImageView; /**< 礼物图片 */
@property (weak, nonatomic) ImageViewLoader* imageViewGiftLoader;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;/**< 名称 */
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;/**< 送出 */
@property (weak, nonatomic) IBOutlet GiftComboNumView *numberView;

@property (nonatomic, weak) id<GiftComboViewDelegate> delegate;

@property (nonatomic, assign) BOOL isAnimation;/**< 是否正处于动画，用于上下视图交换位置时使用 */
@property (nonatomic, assign) BOOL isLeavingAnimation;/**< 是否正处于动画，用于视图正在向右飞出时不要交换位置 */
@property (nonatomic, assign) NSInteger beginNum; //开始数字
@property (nonatomic, assign) NSInteger endNum;   //结束数字
@property (nonatomic, assign) CGFloat playTime;   //播放时间 最小0.1s

@property (nonatomic, assign, readonly) BOOL playing;
@property (nonatomic, strong) GiftItem* item;

+ (instancetype)giftComboView:(id)owner;
- (void)reset;
- (void)start;
- (void)playGiftCombo;
- (void)stopGiftCombo;

@end
