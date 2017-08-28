//
//  LiveChatTextView.m
//  livestream
//
//  Created by randy on 2017/8/8.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveChatTextView.h"

#define MaxInputCount 70

@interface LiveChatTextView() <UITextViewDelegate>


@end

@implementation LiveChatTextView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.delegate = self;
    
    self.contentSize = CGSizeMake(MAXFLOAT, 0);
}

- (void)insertEmotion:(ChatEmotion *)emotion {
    if( emotion ) {
        // 生成富文本
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        
        // 计算表情位置
        ChatTextAttachment *attachment = [[ChatTextAttachment alloc] init];
        attachment.bounds = CGRectMake(0, -4, self.font.lineHeight, self.font.lineHeight);
        attachment.text = emotion.text;
        attachment.image = emotion.image;
        //        attachment.emotion = emotion;
        NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:attachment];
        
        // 插入
        NSUInteger loc = [self selectedRange].location;
        [attStr replaceCharactersInRange:[self selectedRange] withAttributedString:imgAtt];
        [attStr addAttributes:@{NSFontAttributeName : self.font,
                                NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, attStr.length)];
        self.attributedText = attStr;
        [self setSelectedRange:NSMakeRange(loc + 1, 0)];
        
        // 刷新界面
        [self setNeedsDisplay];
    }
}


- (NSString* )text {
    NSMutableString *fullText = [NSMutableString string];
    
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, self.attributedText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        ChatTextAttachment *attachment = attrs[@"NSAttachment"];
        if( attachment ) {
            [fullText appendString:attachment.text];
            
        } else {
            NSAttributedString *str = [self.attributedText attributedSubstringFromRange:range];
            [fullText appendString:str.string];
        }
    }];
    
    return [fullText copy];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([self.textViewdelegate respondsToSelector:@selector(liveChatTextViewDidBeginEditing:)]) {
        [self.textViewdelegate liveChatTextViewDidBeginEditing:self];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if([self.textViewdelegate respondsToSelector:@selector(liveChatTextViewDidChange:)]) {
        [self.textViewdelegate liveChatTextViewDidChange:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if([self.textViewdelegate respondsToSelector:@selector(liveChatTextViewDidEndEditing:)]) {
        [self.textViewdelegate liveChatTextViewDidEndEditing:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    bool bFlag = YES;
    
    NSString *wholeString = textView.text;
    NSInteger wholeStringLength = wholeString.length - range.length + text.length;
    if( wholeStringLength >= MaxInputCount ) {
        // 超过字符限制
        bFlag = NO;
    }
    
    
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        
        bFlag = NO;
    }
    
    return bFlag;
}



- (void)setPlaceholderString:(NSAttributedString *)placeholder {
    
    self.attributedText = placeholder;
    self.textColor = [UIColor whiteColor];
}

@end
