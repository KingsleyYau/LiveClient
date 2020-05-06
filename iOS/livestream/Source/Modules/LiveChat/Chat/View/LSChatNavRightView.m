//
//  LSChatNavRightView.m
//  livestream
//
//  Created by Calvin on 2020/4/11.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSChatNavRightView.h"

@interface LSChatNavRightView ()

@end

@implementation LSChatNavRightView

- (instancetype)init {
    if (self = [super init]) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"LSChatNavRightView" owner:self options:nil].firstObject;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.countLabel.layer.cornerRadius = self.countLabel.tx_height/2;
    self.countLabel.layer.masksToBounds = YES;
    
    UIImage * image = [self imageWithColor:[UIColor whiteColor]];
    UIImage * selectImage = [self imageWithColor:COLOR_WITH_16BAND_RGB(0xECEEF1)];
    
    [self.endChatBtn setBackgroundImage:image forState:UIControlStateNormal];
    [self.schedleBtn setBackgroundImage:image forState:UIControlStateNormal];
    [self.recentBtn setBackgroundImage:image forState:UIControlStateNormal];
    
    [self.endChatBtn setBackgroundImage:selectImage forState:UIControlStateHighlighted];
    [self.schedleBtn setBackgroundImage:selectImage forState:UIControlStateHighlighted];
    [self.recentBtn setBackgroundImage:selectImage forState:UIControlStateHighlighted];
    
    self.endChatBtn.tag = 100;
    self.schedleBtn.tag = 101;
    self.recentBtn.tag = 102;
}

- (void)updateCount:(NSInteger)count {
    if (count > 0) {
        self.countLabel.hidden = NO;
         self.countLabel.text = [NSString stringWithFormat:@"%ld",count];
    }else {
        self.countLabel.hidden = YES;
    }
   
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
