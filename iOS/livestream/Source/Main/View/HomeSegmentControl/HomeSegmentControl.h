//
//  HomeSegmentControl.h
//  livestream
//
//  Created by Calvin on 2018/6/27.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeSegmentControlDelegate <NSObject>

- (void)segmentControlSelectedTag:(NSInteger)tag;

@end

@interface HomeSegmentControl : UIView

@property (nonatomic, weak) id<HomeSegmentControlDelegate> delegate;


- (void)selectButtonTag:(NSInteger)tag;

- (instancetype)initWithNumberOfTitles:(NSArray *)titles andFrame:(CGRect)frame delegate:(id<HomeSegmentControlDelegate>)delegate;

@end
