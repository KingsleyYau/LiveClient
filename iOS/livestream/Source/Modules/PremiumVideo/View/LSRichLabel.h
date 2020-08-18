//
//  LSRichLabel.h
//  livestream
//
//  Created by Albert on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSRichLabel : UILabel
{
    CGFloat totalHeight;
    UIColor *normalColor;
    UIColor *rangeColor;
    UIFont *textFont;
    CGFloat lineSpace;
}

-(CGFloat)getTotalHeight;
-(void)setAttributedText:(NSString *)text RangeText:(NSString *)sText NormalColor:(UIColor *)nColor RangeColor:(UIColor *)rColor WithFont:(UIFont *)font UnderLine:(BOOL)under LineSpace:(CGFloat)space;

@end

NS_ASSUME_NONNULL_END
