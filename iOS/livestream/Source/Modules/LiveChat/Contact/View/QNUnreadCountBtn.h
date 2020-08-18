//
//  UnreadCountBtn.h
//  testSegment
//
//  Created by test on 2018/11/22.
//  Copyright © 2018年 test. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QNUnreadCountBtn;
@protocol QNUnreadCountBtnDelegate<NSObject>

@optional

- (void)unreadCountBtnDidTap:(QNUnreadCountBtn *)btn;

@end


@interface QNUnreadCountBtn : UIView
@property (weak, nonatomic) IBOutlet UILabel *unreadNameText;
@property (weak, nonatomic) IBOutlet UILabel *unreadCountTips;
@property (weak, nonatomic) IBOutlet UIView *lineView;
/** 代理 */
@property (nonatomic, weak) id<QNUnreadCountBtnDelegate> delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unreadLabelWidth;
@property (weak, nonatomic) IBOutlet UILabel *noNumUnreadTips;

@property (weak, nonatomic) IBOutlet UIView *statusView;

- (void)updateUnreadCount:(NSString *)count;
- (void)updateUnreadStatus:(BOOL)show;
@end
