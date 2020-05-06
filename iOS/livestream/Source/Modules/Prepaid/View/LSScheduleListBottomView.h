//
//  LSScheduleListBottomView.h
//  livestream
//
//  Created by Randy_Fan on 2020/4/13.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LSScheduleListBottomViewDelegate <NSObject>

- (void)didHowWorkAction;

@end

@interface LSScheduleListBottomView : UIView

@property (nonatomic, weak) id<LSScheduleListBottomViewDelegate> delegate;

+ (CGFloat)viewHeight;

@end

NS_ASSUME_NONNULL_END
