//
//  LSChatTextView.m
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSChatTextView.h"
#import "LSChatTextAttachment.h"
#import "LSSendMessageManager.h"

@interface LSChatTextView ()

@property (nonatomic, assign) BOOL isPaste;

@end

@implementation LSChatTextView

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"text"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

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
    self.isPaste = YES;
}

- (void)insertEmotion:(LSChatEmotion *)emotion {
    if( emotion ) {
        // 生成富文本
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        
        // 计算表情位置
        LSChatTextAttachment *attachment = [[LSChatTextAttachment alloc] init];
        attachment.bounds = CGRectMake(0, -4, 21, 21);
        attachment.text = emotion.text;
        attachment.image = emotion.image;
        NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:attachment];
        
        // 插入
        NSUInteger loc = self.selectedRange.location;
        [attStr replaceCharactersInRange:self.selectedRange withAttributedString:imgAtt];
        [attStr addAttributes:@{NSFontAttributeName : self.font} range:NSMakeRange(0, attStr.length)];
        self.attributedText = attStr;
        self.selectedRange = NSMakeRange(loc + 1, 0);
        
        // 刷新界面
        [self setNeedsDisplay];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.isPaste = NO;
    // KVO监听(settext方法)
    [self addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerDidHide) name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void)menuControllerDidHide {
    [self scrollRangeToVisible:self.selectedRange];
}

- (void)textChange:(NSNotification* )notice {
    // 刷新界面
    [self setNeedsDisplay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object == self && [keyPath isEqualToString:@"text"]) {
        // 刷新界面
        [self setNeedsDisplay];
    }
}

- (NSString* )text {
    NSMutableString *fullText = [NSMutableString string];
    
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, self.attributedText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSObject *obj = attrs[NSAttachmentAttributeName];
        if( obj && [obj isKindOfClass:[LSChatTextAttachment class]] ) {
            // 替换样式
            LSChatTextAttachment *attachment = (LSChatTextAttachment *)obj;
            [fullText appendString:attachment.text];
        } else {
            if (!obj) {
                NSAttributedString *str = [self.attributedText attributedSubstringFromRange:range];
                [fullText appendString:str.string];
            }
        }
    }];
    return [fullText copy];
}

- (void)cleanText {
    self.text = nil;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat x = 8;
    CGFloat w = rect.size.width - 2 * x;
    CGFloat y = 8;
    CGFloat h;
    
    CGRect textRect;
    CGRect drawRect;
    NSMutableAttributedString* attributedText = nil;
    
    // 加入默认提示
    if( self.attributedText.length == 0 && self.placeholder ) {
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        attrs[NSFontAttributeName] = self.font;
        attrs[NSForegroundColorAttributeName] = self.placeholderColor?self.placeholderColor:[UIColor grayColor];

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
    if (self.isPaste) {
        self.isPaste = NO;
        [self scrollRangeToVisible:self.selectedRange];
    }
}



@end
