//
//  LSChatTextView.h
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSChatEmotion.h"
#import "LSChatTextAttachment.h"

@class LSChatTextView;
@protocol LSChatTextViewDelegate <NSObject>
@optional
- (void)textViewChangeHeight:(LSChatTextView * _Nonnull)textView height:(CGFloat)height;
- (void)textViewChangeWord:(LSChatTextView * _Nonnull)textView;
@end

@interface LSChatTextView : UITextView

@property(nonatomic, assign) CGFloat height;
@property(nonatomic, copy) NSString* _Nullable placeholder;
@property(nonatomic, strong) UIColor* _Nullable placeholderColor;
@property(nonatomic, weak) IBOutlet id<LSChatTextViewDelegate> _Nullable chatTextViewDelegate;

/**
 *   生成富文本,用以显示表情
 *
 *  @param emotion 表情模型
 */
- (void)insertEmotion:(LSChatEmotion* _Nonnull)emotion;

@end
