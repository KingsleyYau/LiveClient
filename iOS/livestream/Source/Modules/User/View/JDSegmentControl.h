//
//  JDSegmentControl.h
//  livestream
//
//  Created by Calvin on 17/10/9.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JDSegmentControlDelegate <NSObject>

- (void)segmentControlSelectedTag:(NSInteger)tag;

@end

@interface JDSegmentControl : UIView

@property (nonatomic, weak) id<JDSegmentControlDelegate> delegate;

@property (nonatomic, strong) UIColor * textSelectedColor;

@property (nonatomic, strong) UIColor * textNormalColor;

+ (CGFloat)getSegmentControlW:(NSArray *)titles;

- (void)selectButtonTag:(NSInteger)tag;

- (instancetype)initWithNumberOfTitles:(NSArray *)titles andFrame:(CGRect)frame delegate:(id<JDSegmentControlDelegate>)delegate isSymmetry:(BOOL)isSymmetry isShowbottomLine:(BOOL)isBottom;
//是否对称 是否显示底部线

//显示未读数
- (void)updateBtnUnreadCount:(NSArray * )countArray;

//显示红点
- (void)updateBtnUnreadNum:(NSArray * )countArray;
@end
