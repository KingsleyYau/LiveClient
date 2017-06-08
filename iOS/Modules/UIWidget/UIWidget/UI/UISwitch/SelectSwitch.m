//
//  SelectSwitch.m
//  自定义UISwitch
//
//  Created by test on 16/5/12.
//  Copyright © 2016年 lance. All rights reserved.
//

#import "SelectSwitch.h"

#define appleBackgroundColor [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0]
#define lightGrayColor [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0]



@implementation SelectSwitch

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        CGFloat cornerRadius = 5.0;
        CGFloat firstTitleW = self.frame.size.width / 2;
        CGFloat firstTitleH = self.frame.size.height - 5;
        CGFloat firstTitleY = 5;
        
        self.yesLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, firstTitleY, firstTitleW - 10, firstTitleH - 5)];
        self.noLabel = [[UILabel alloc] initWithFrame:CGRectMake(firstTitleW + 5, firstTitleY, firstTitleW - 10, firstTitleH - 5)];
        
        self.noLabel.textAlignment = NSTextAlignmentCenter;
        self.yesLabel.textAlignment = NSTextAlignmentCenter;
        self.noLabel.font = [UIFont boldSystemFontOfSize:9];
        self.yesLabel.font = [UIFont boldSystemFontOfSize:9];
        
        self.yesLabel.textColor = [UIColor grayColor];
        self.noLabel.textColor = [UIColor whiteColor];
        
        [self addSubview:self.noLabel];
        [self addSubview:self.yesLabel];
        
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = cornerRadius;
        
        self.noLabel.layer.masksToBounds = YES;
        self.noLabel.layer.cornerRadius = cornerRadius;
        
        self.yesLabel.layer.masksToBounds = YES;
        self.yesLabel.layer.cornerRadius = cornerRadius;
        

        self.yesLabel.backgroundColor = lightGrayColor;
        self.noLabel.backgroundColor = appleBackgroundColor;

        self.isYes = NO;

    }
    return self;
}

-(void)setIsYes:(BOOL)isYes{
    if (!_isYes) {
        _isYes = YES;
        self.yesLabel.backgroundColor = appleBackgroundColor;
        self.noLabel.backgroundColor = lightGrayColor;
        self.yesLabel.textColor = [UIColor whiteColor];
        self.noLabel.textColor = [UIColor grayColor];

    }else{
        _isYes = NO;
        self.yesLabel.backgroundColor = lightGrayColor;
        self.noLabel.backgroundColor = appleBackgroundColor;
        self.yesLabel.textColor = [UIColor grayColor];
        self.noLabel.textColor = [UIColor whiteColor];
    }
}



#pragma mark - UIControl Override -

/** Tracking is started **/
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    
    //We need to track continuously
    return YES;
}

/** Track continuos touch event (like drag) **/
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    

    return YES;
}

/** Track is finished **/
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    if (self.isYes) {
        self.isYes = NO;
        //设置成功
        self.yesLabel.hidden = NO;
        self.noLabel.hidden = NO;
        self.yesLabel.backgroundColor = lightGrayColor;
        self.noLabel.backgroundColor = appleBackgroundColor;
        self.yesLabel.textColor = [UIColor grayColor];
        self.noLabel.textColor = [UIColor whiteColor];

    }else{
        self.isYes = YES;
        self.yesLabel.hidden = NO;
        self.noLabel.hidden = NO;
        self.yesLabel.backgroundColor = appleBackgroundColor;
        self.noLabel.backgroundColor = lightGrayColor;
        self.yesLabel.textColor = [UIColor whiteColor];
        self.noLabel.textColor = [UIColor grayColor];
   
    }
    
    //Control value has changed, let's notify that
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}
@end
