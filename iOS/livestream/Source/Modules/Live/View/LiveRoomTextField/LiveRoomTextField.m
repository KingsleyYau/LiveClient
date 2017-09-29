//
//  LiveRoomTextField.m
//  livestream
//
//  Created by randy on 2017/8/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveRoomTextField.h"

@implementation LiveRoomTextField

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
        NSAttributedString *imgAtt = [[NSAttributedString alloc]initWithString:emotion.text];
        
        // 插入
//        NSUInteger loc = [self selectedRange].location;
//        [attStr replaceCharactersInRange:[self selectedRange] withAttributedString:imgAtt];
        [attStr appendAttributedString:imgAtt];
        [attStr addAttributes:@{NSFontAttributeName : self.font} range:NSMakeRange(0, attStr.length)];
        self.attributedText = attStr;
//        [self setSelectedRange:NSMakeRange(loc + 1, 0)];
        
        // 刷新界面
        [self setNeedsDisplay];
    }
}

- (NSString *)fullText {
    NSMutableString *mtFullText = [NSMutableString string];
    
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, self.attributedText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        ChatTextAttachment *attachment = attrs[@"NSAttachment"];
        if( attachment ) {
            [mtFullText appendString:attachment.text];
            
        } else {
            NSAttributedString *str = [self.attributedText attributedSubstringFromRange:range];
            [mtFullText appendString:str.string];
        }
    }];
    
    return [mtFullText copy];
}

- (void)setFullText:(NSString *)fullText {
    if( fullText ) {
        self.attributedText = [[NSAttributedString alloc] initWithString:fullText attributes:nil];
    } else {
        self.attributedText = nil;
    }
}

// 获取当前Range  备注：UITextField必须为第一响应者才有效
- (NSRange)selectedRange
{
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

// 修改UITextField光标位置
- (void)setSelectedRange:(NSRange)range
{
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextPosition* startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition* endPosition = [self positionFromPosition:beginning offset:range.location + range.length];
    UITextRange* selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    
    [self setSelectedTextRange:selectionRange];
}

@end
