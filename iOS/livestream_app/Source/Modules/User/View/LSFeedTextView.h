//
//  LSFeedTextView.h
//  livestream
//
//  Created by test on 2017/12/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSFeedTextView;
@protocol LSFeedTextViewDelegate <NSObject>
@optional
- (void)textViewChangeHeight:(LSFeedTextView * _Nonnull)textView height:(CGFloat)height;
- (void)textViewChangeWord:(LSFeedTextView * _Nonnull)textView;
@end

@interface LSFeedTextView : UITextView
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, copy) NSString* _Nullable placeholder;
@property(nonatomic, strong) UIColor* _Nullable placeholderColor;
@property(nonatomic, weak) id<LSFeedTextViewDelegate> _Nullable chatTextViewDelegate;
@end
