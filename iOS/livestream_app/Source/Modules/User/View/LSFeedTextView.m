//
//  LSFeedTextView.m
//  livestream
//
//  Created by test on 2017/12/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSFeedTextView.h"

@implementation LSFeedTextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copy:) || action == @selector(selectAll:) || action == @selector(cut:) || action == @selector(paste:));
}

- (void)selectAll:(id)sender {
    [super selectAll:sender];
}

- (void)copy:(id)sender {

    [super copy:sender];
}

- (void)cut:(id)sender {

    
    [super cut:sender];
}

- (void)paste:(id)sender {

    [super paste:sender];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextViewTextDidChangeNotification object:nil];
    
}

- (void)textChange:(NSNotification* )notice {

    // 刷新界面
    [self setNeedsDisplay];
    if( [self.chatTextViewDelegate respondsToSelector:@selector(textViewChangeWord:)] ) {
        [self.chatTextViewDelegate textViewChangeWord:self];
    }
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat x = 5;
    CGFloat w = rect.size.width - 2 * x;
    CGFloat y = 8;
    CGFloat h;
    
    CGRect textRect;
    CGRect drawRect;
    NSMutableAttributedString* attributedText = nil;
    
//    self.attributedText = @{NSForegroundColorAttributeName:COLOR_WITH_16BAND_RGB_ALPHA(0x995d0e86)};
    self.textColor = COLOR_WITH_16BAND_RGB_ALPHA(0x995d0e86);
    
    // 加入默认提示
    if( self.attributedText.length == 0 && self.placeholder ) {
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        attrs[NSFontAttributeName] = self.font;
        attrs[NSForegroundColorAttributeName] = self.placeholderColor?self.placeholderColor:COLOR_WITH_16BAND_RGB_ALPHA(0x995d0e86);
        
        attributedText = [[NSMutableAttributedString alloc] initWithString:self.placeholder attributes:attrs];
        
        // 计算高度
        textRect = [attributedText boundingRectWithSize:CGSizeMake(self.frame.size.width - 2 * x, MAXFLOAT)
                                                options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        h = ceil(textRect.size.height);
        
        drawRect = CGRectMake(x, y, w, h);
        [attributedText drawInRect:drawRect];
        
        h += y * 2;
        
    } else {
        attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        
        // 计算高度
        textRect = [attributedText boundingRectWithSize:CGSizeMake(self.frame.size.width - 2 * x, MAXFLOAT)
                                                options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        h = ceil(textRect.size.height);
        
        h += y * 2;
    }
    
    if( self.height != h ) {
        if( [self.chatTextViewDelegate respondsToSelector:@selector(textViewChangeHeight:height:)] ) {
            [self.chatTextViewDelegate textViewChangeHeight:self height:h];
        }
        self.height = h;
    }
    
}


@end
