//
//  LSLiveTextView.m
//  livestream
//
//  Created by Calvin on 2019/9/3.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSLiveTextView.h"

@implementation LSLiveTextView

 
- (void)dealloc {
        [[NSNotificationCenter defaultCenter]removeObserver:self];
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
}

- (void)insertEmotion:(LSChatEmotion *)emotion {
    if( emotion ) {
        // 生成富文本
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        
        // 计算表情位置
        LSChatTextAttachment *attachment = [[LSChatTextAttachment alloc] init];
        attachment.bounds = CGRectMake(0, -4, self.font.lineHeight, self.font.lineHeight);
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

    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)textChange:(NSNotification* )notice {
    // 刷新界面
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
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
        NSObject *obj = attrs[NSAttachmentAttributeName];//attrs[@"NSAttachment"];
        if( obj && [obj isKindOfClass:[LSChatTextAttachment class]] ) {
            // 替换样式
            LSChatTextAttachment *attachment = (LSChatTextAttachment *)obj;
            [fullText appendString:attachment.text];
        } else {
            // 保持原来样式
            NSAttributedString *str = [self.attributedText attributedSubstringFromRange:range];
            [fullText appendString:str.string];
        }
    }];
    
    return [fullText copy];
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
        
        // 防止语音听写输入高度会修改导致offset改变
        CGSize contentSize = self.contentSize;
        UIEdgeInsets offset;
        CGSize newSize = contentSize;
        
        //如果文字内容高度没有超过textView的高度
        if(contentSize.height <= self.frame.size.height) {
            //textView的高度减去文字高度除以2就是Y方向的偏移量，也就是textView的上内边距
            //            CGFloat offsetY = (self.frame.size.height - contentSize.height) / 2;
            offset = UIEdgeInsetsMake(0, 0, 0, 0);
            [self setContentInset:offset];
        }
        
        //根据前面计算设置textView的ContentSize和Y方向偏移量
        [self setContentSize:newSize];
    }
    
    if( self.height != h ) {
        if( [self.liveTextViewDelegate respondsToSelector:@selector(textViewChangeHeight:height:)] ) {
            [self.liveTextViewDelegate textViewChangeHeight:self height:h];
        }
        self.height = h;
    }
}
@end
