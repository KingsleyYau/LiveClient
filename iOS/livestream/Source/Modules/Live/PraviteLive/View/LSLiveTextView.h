//
//  LSLiveTextView.h
//  livestream
//
//  Created by Calvin on 2019/9/3.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSChatTextAttachment.h"
@class LSLiveTextView;
@protocol LSLiveTextViewDelegate <NSObject>
@optional
- (void)textViewChangeHeight:(LSLiveTextView *)textView height:(CGFloat)height;

@end

@interface LSLiveTextView : UITextView

@property(nonatomic, assign) CGFloat height;
@property(nonatomic, copy) NSString*  placeholder;
@property(nonatomic, strong) UIColor*  placeholderColor;
@property(nonatomic, weak) id<LSLiveTextViewDelegate>  liveTextViewDelegate;


/**
 *   生成富文本,用以显示表情
 *
 *  @param emotion 表情模型
 */
- (void)insertEmotion:(LSChatEmotion* )emotion;
@end

 
