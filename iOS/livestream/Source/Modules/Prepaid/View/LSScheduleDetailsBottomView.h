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

@property (weak, nonatomic) IBOutlet UILabel *onePromptLabel;

@property (weak, nonatomic) IBOutlet UILabel *threePromptLabel;

@property (nonatomic, weak) id<LSScheduleDetailsBottomViewDelegate> delegate;

+ (CGFloat)viewHeight;

- (void)setupPrompt:(NSString *)name startTime:(NSInteger)startTime isSummerTime:(BOOL)isSummerTime;

@end

NS_ASSUME_NONNULL_END
