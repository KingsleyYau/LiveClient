//
//  HangoutSendBarView.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/15.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangoutSendBarView.h"
#import "LiveBundle.h"

#define PlaceholderFontSize 13
#define PlaceholderFont [UIFont boldSystemFontOfSize:PlaceholderFontSize]

#define MaxInputCount 70

@implementation HangoutSendBarView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        NSBundle *bundle = [LiveBundle mainBundle];
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle] instantiateWithOwner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        [self addSubview:containerView];
        
        self.inputTextField.bottomLine.hidden = YES;
        self.inputTextField.font = PlaceholderFont;
        self.inputTextField.delegate = self;
        
        self.emotionBtn.adjustsImageWhenHighlighted = NO;
        [self.emotionBtn setImage:[UIImage imageNamed:@"Send_Emotion_Btn"] forState:UIControlStateNormal];
        [self.emotionBtn setImage:[UIImage imageNamed:@"Live_Chat_Keyboard"] forState:UIControlStateSelected];
        
        self.emotionBtn.selectedChangeDelegate = self;
    }
    return self;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    [self.inputTextField setValue:placeholderColor forKeyPath:@"_placeholderLabel.textColor"];
}

#pragma mark - 文本输入回调 (UITextFieldDelegate)
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    bool bFlag = YES;
    
    NSString *wholeString = textField.text;
    NSInteger wholeStringLength = wholeString.length - range.length + string.length;
    
    if (wholeStringLength >= MaxInputCount) {
        // 超过字符限制
        bFlag = NO;
    }
    
    return bFlag;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    bool bFlag = NO;
    
    if (self.inputTextField.fullText.length > 0) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendBarSendAction:)]) {
            [self.delegate sendBarSendAction:self];
        }
        
        bFlag = YES;
    }
    return bFlag;
}

@end
