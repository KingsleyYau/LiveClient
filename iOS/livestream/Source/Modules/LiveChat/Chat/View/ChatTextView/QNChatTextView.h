//
//  ChatTextView.h
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QNChatEmotion.h"
#import "QNChatTextAttachment.h"

@class QNChatTextView;
@protocol ChatTextViewDelegate <NSObject>
@optional
- (void)textViewChangeHeight:(QNChatTextView * _Nonnull)textView height:(CGFloat)height;
- (void)textViewChangeWord:(QNChatTextView * _Nonnull)textView;
@end

@interface QNChatTextView : UITextView

@property(nonatomic, assign) CGFloat height;
@property(nonatomic, copy) NSString* _Nullable placeholder;
@property(nonatomic, strong) UIColor* _Nullable placeholderColor;
@property(nonatomic, weak) id<ChatTextViewDelegate> _Nullable chatTextViewDelegate;


/**
 *   生成富文本,用以显示表情
 *
 *  @param emotion 表情模型
 */
- (void)insertEmotion:(QNChatEmotion* _Nonnull)emotion;


@end
