//
//  LiveChatTextView.h
//  livestream
//
//  Created by randy on 2017/8/8.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSChatEmotion.h"
#import "LSChatTextAttachment.h"

@class LiveChatTextView;
@protocol LiveChatTextViewDelegate <NSObject>
@optional;

- (void)liveChatTextViewDidBeginEditing:(LiveChatTextView *)textView;

- (void)liveChatTextViewDidChange:(LiveChatTextView *)textView;

- (void)liveChatTextViewDidEndEditing:(LiveChatTextView *)textView;

@end

@interface LiveChatTextView : UITextView

@property(nonatomic, copy) NSString* placeholder;

/**
 *   生成富文本,用以显示表情
 *
 *  @param emotion 表情模型
 */
- (void)insertEmotion:(LSChatEmotion* )emotion;

@property(nonatomic,weak) id<LiveChatTextViewDelegate> textViewdelegate;

- (void)setPlaceholderString:(NSAttributedString *)placeholder;

@end
