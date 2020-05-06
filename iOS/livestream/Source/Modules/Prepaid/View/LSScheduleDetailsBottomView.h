//
//  LSScheduleDetailsBottomView.h
//  livestream
//
//  Created by Randy_Fan on 2020/4/20.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LSScheduleDetailsBottomViewDelegate <NSObject>

- (void)didHowWorkAction;

@end

@interface LSScheduleDetailsBottomView : UIView

@property (nonatomic, weak) id<LSScheduleDetailsBottomViewDelegate> delegate;

+ (CGFloat)viewHeight;

@end

NS_ASSUME_NONNULL_END
