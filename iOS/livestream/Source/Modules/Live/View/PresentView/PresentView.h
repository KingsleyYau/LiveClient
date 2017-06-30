//
//  PresentView.h
//  UIWidget
//
//  Created by test on 2017/6/9.
//  Copyright © 2017年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresentSendView.h"


@class PresentView;
@protocol PresentViewDelegate <NSObject>
- (void)presentViewDidScroll:(PresentView *)PresentViewView currentPageNumber:(NSInteger)page;

@end

@interface PresentView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;
@property (weak, nonatomic) IBOutlet UIButton *comboBtn;
@property (weak, nonatomic) IBOutlet PresentSendView *sendView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;


/** 代理 */
@property (nonatomic, weak) id<PresentViewDelegate> presentDelegate;
@end
