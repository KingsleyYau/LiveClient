//
//  LSStoreListSectionView.m
//  livestream
//
//  Created by Calvin on 2019/10/9.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSStoreListSectionView.h"

@interface LSStoreListSectionView ()

@end

@implementation LSStoreListSectionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSStoreListSectionView" owner:self options:0].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (CGFloat)getStrW:(NSString *)str {
     CGFloat strW = [str sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].width;
    return strW;
}

- (void)updateContent:(NSString *)str isShowFreeCard:(BOOL)isShow {
    if (isShow) {
        
        NSString * cardStr = @"Free Greeting Card";
        
        NSString * string = [NSString stringWithFormat:@"%@ - %@",str,cardStr];
        
        //长度过长需要截取
        if ([self getStrW:string] > SCREEN_WIDTH - 40) {
            for (int i = 1; i < str.length; i++) {
            string = [NSString stringWithFormat:@"%@... - %@",[str substringToIndex:str.length - i],cardStr];
                if ([self getStrW:string] < SCREEN_WIDTH - 40) {
                    break;
                }
            }
        }
        
        NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc]initWithString:string];
        [attStr addAttributes:@{NSForegroundColorAttributeName:COLOR_WITH_16BAND_RGB(0xF2661C)} range:[string rangeOfString:cardStr]];
        
        self.titleLabel.attributedText = attStr;
    }else {
        self.titleLabel.text = str;
    }
}
@end
