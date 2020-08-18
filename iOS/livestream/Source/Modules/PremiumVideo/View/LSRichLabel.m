//
//  LSRichLabel.m
//  livestream
//
//  Created by Albert on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSRichLabel.h"

@implementation LSRichLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
        
    }
    return self;
}

- (void)initialize {
    totalHeight = 20.f;
    normalColor = Color(102, 102, 102, 1);
    rangeColor = Color(0, 102, 255, 1);
    textFont = [UIFont systemFontOfSize:15.f];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

-(void)setAttributedText:(NSString *)text RangeText:(NSString *)sText NormalColor:(UIColor *)nColor RangeColor:(UIColor *)rColor WithFont:(UIFont *)font UnderLine:(BOOL)under LineSpace:(CGFloat)space
{
    if (font != nil) {
        textFont = font;
    }
    if (rColor != nil) {
        rangeColor = rColor;
    }
    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:text];
    [richText addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, text.length)];
    [richText addAttribute:NSForegroundColorAttributeName value:normalColor range:NSMakeRange(0, text.length)];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = space;
    style.alignment = NSTextAlignmentCenter;
    [richText addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    
    if (sText != nil) {
        NSRange range = [text rangeOfString:sText];
        
        if (under) {
            [richText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];//设置下划线
        }
        [richText addAttribute:NSForegroundColorAttributeName value:rangeColor range:range];
        [richText addAttribute:NSLinkAttributeName value:@"GoNow://" range:range];
    }

    [self setAttributedText:richText];
    
    CGRect rect = [richText boundingRectWithSize:CGSizeMake(self.bounds.size.width, MAXFLOAT)
                                         options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    CGFloat height = ceil(rect.size.height);
    totalHeight = height;
}

-(CGFloat)getTotalHeight
{
    return totalHeight;
}

@end
