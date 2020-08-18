//
//  LSPremiumTipsTableViewCell.m
//  livestream
//  自定义底部提示cell
//  Created by Albert on 2020/8/5.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPremiumTipsTableViewCell.h"

@interface LSPremiumTipsTableViewCell()
{
    CGFloat totalHeight;
}

@end

@implementation LSPremiumTipsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initialize];
}

-(void)initialize
{
    [self.tipsLabel setFont:[UIFont fontWithName:@"ArialMT" size:12]];
    [self.tipsLabel setTextColor:Color(153, 153, 153, 1)];
    [self.richLabel setFont:[UIFont fontWithName:@"ArialMT" size:12]];
    
    NSString *tStr = NSLocalizedString(@"Premium_Video_Tip_Access", nil);
    [self.tipsLabel setText:tStr];

    CGRect rect = [tStr boundingRectWithSize:CGSizeMake(self.tipsLabel.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.tipsLabel.font,NSFontAttributeName, nil] context:nil];
    CGFloat height = ceil(rect.size.height);
    
    NSString *str = @"Click here to see How it works >";
    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange range = [str  rangeOfString:@"How it works"];
    
    [richText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];//设置下划线
    [richText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:56/255.0 green:56/255.0 blue:56/255.0 alpha:  1.0] range:NSMakeRange(0, str.length)];
    [richText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:45/255.f green:137/255.f blue:249./255.f alpha:1] range:range];

    [self.richLabel setAttributedText:richText];
    self.richLabelH.constant =  ceil([self.richLabel font].lineHeight);
        
    totalHeight = height + 47.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(NSString *)cellIdentifier
{
    return @"LSPremiumTipsTableViewCell";
}

-(void)setTipText:(NSString *)txt
{
    [self.tipsLabel setText:txt];
    CGRect rect = [txt boundingRectWithSize:CGSizeMake(self.tipsLabel.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.tipsLabel.font,NSFontAttributeName, nil] context:nil];
    CGFloat height = ceil(rect.size.height);
    //self.tipLabelH.constant = height;
    
    totalHeight = height + 47.f;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSPremiumTipsTableViewCell *cell = (LSPremiumTipsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSPremiumTipsTableViewCell cellIdentifier]];
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPremiumTipsTableViewCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return cell;
}

@end
