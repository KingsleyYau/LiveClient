//
//  LSPremiumRequestFooterView.m
//  livestream
//
//  Created by Albert on 2020/7/30.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPremiumRequestFooterView.h"

@implementation LSPremiumRequestFooterView

-(void)initialize
{
    [self.tipLabel setFont:[UIFont fontWithName:@"ArialMT" size:12]];
    [self.tipLabel setTextColor:Color(153, 153, 153, 1)];
    [self.clickLabel setFont:[UIFont fontWithName:@"ArialMT" size:12]];
    
    NSString *tStr = NSLocalizedString(@"Premium_Video_Tip_Access", nil);
    [self.tipLabel setText:tStr];

    CGRect rect = [tStr boundingRectWithSize:CGSizeMake(self.tipLabel.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.tipLabel.font,NSFontAttributeName, nil] context:nil];
    CGFloat height = ceil(rect.size.height);
    self.tipLabelH.constant = height;
    
    NSString *str = @"Click here to see How it works >";
    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange range = [str  rangeOfString:@"How it works"];
    
    [richText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];//设置下划线
    [richText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:56/255.0 green:56/255.0 blue:56/255.0 alpha:  1.0] range:NSMakeRange(0, str.length)];
    [richText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:45/255.f green:137/255.f blue:249./255.f alpha:1] range:range];

    [self.clickLabel setAttributedText:richText];
    self.clickLabelH.constant =  ceil([self.clickLabel font].lineHeight);
    
    if([self.clickLabel gestureRecognizers].count == 0){
        //防止重复添加事件
        [self.clickLabel addTapGesture:self sel:@selector(tap)];
    }
    
    totalHeight = self.clickLabelH.constant + self.tipLabelH.constant + 30.f;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
       self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPremiumRequestFooterView" owner:self options:0].firstObject;

        self.frame = frame;
        [self initialize];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)setTipText:(NSString *)txt
{
    [self.tipLabel setText:txt];
    CGRect rect = [txt boundingRectWithSize:CGSizeMake(self.tipLabel.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.tipLabel.font,NSFontAttributeName, nil] context:nil];
    CGFloat height = ceil(rect.size.height);
    self.tipLabelH.constant = height;
    
    totalHeight = self.clickLabelH.constant + self.tipLabelH.constant + 30.f;
}

-(void)setRichText:(NSString *)txt RangeText:(NSString *)rText
{
    NSString *str = txt;//@"Click here to see How it works >";
    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange range = [str  rangeOfString:rText];
    
    [richText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];//设置下划线
    [richText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:102/255.f green:102/255.f blue:102/255.f alpha:1] range:NSMakeRange(0, str.length)];
    [richText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:45/255.f green:137/255.f blue:249./255.f alpha:1] range:range];

    [self.clickLabel setAttributedText:richText];
    self.clickLabelH.constant =  ceil([self.clickLabel font].lineHeight);
    
    totalHeight = self.clickLabelH.constant + self.tipLabelH.constant + 20.f;
}

-(CGFloat)getContentHeight
{
    return totalHeight;
}

-(void)tap
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
