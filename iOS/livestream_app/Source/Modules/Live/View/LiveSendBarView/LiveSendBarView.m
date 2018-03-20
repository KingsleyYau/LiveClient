//
//  LiveSendBarView.m
//  livestream
//
//  Created by randy on 2017/8/28.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveSendBarView.h"
#import "LiveBundle.h"

#define PlaceholderFontSize DESGIN_TRANSFORM_3X(14)
#define PlaceholderFont [UIFont boldSystemFontOfSize:PlaceholderFontSize]

#define MaxInputCount 70

@implementation LiveSendBarView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];

    if (self) {
        NSBundle *bundle = [LiveBundle mainBundle];
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle] instantiateWithOwner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        [self addSubview:containerView];

        [self.louderBtn setImage:[UIImage imageNamed:@"Pubilc_Pop_Btn"] forState:UIControlStateSelected];

        self.inputTextField.bottomLine.hidden = YES;
        self.inputTextField.font = PlaceholderFont;
        self.inputTextField.delegate = self;

        self.emotionBtn.adjustsImageWhenHighlighted = NO;
        [self.emotionBtn setImage:[UIImage imageNamed:@"Send_Emotion_Btn"] forState:UIControlStateNormal];
        [self.emotionBtn setImage:[UIImage imageNamed:@"Live_Chat_Keyboard"] forState:UIControlStateSelected];

        self.emotionBtn.selectedChangeDelegate = self;
        self.louderBtn.selectedChangeDelegate = self;

        [self changePlaceholder:NO];
    }
    return self;
}

#pragma mark - 选择按钮回调
- (void)selectedChanged:(id)sender {
    if (sender == self.louderBtn) {
        [self changePlaceholder:self.louderBtn.selected];
    }

    if (sender == self.emotionBtn) {

        [self.inputTextField endEditing:YES];
        UIButton *emotionBtn = (UIButton *)sender;

        if (self.delegate && [self.delegate respondsToSelector:@selector(sendBarEmotionAction:isSelected:)]) {
            [self.delegate sendBarEmotionAction:self isSelected:emotionBtn.selected];
        }
    }
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

    if (wholeStringLength > 0) {
        // 可发送
        [self sendButtonCanUser];
    } else {
        // 不可发送
        [self sendButtonNotUser];
    }

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

#pragma mark - 事件管理
- (IBAction)sendAction:(id)sender {

    if (self.delegate && [self.delegate respondsToSelector:@selector(sendBarSendAction:)]) {
        [self.delegate sendBarSendAction:self];
    }
}

#pragma mark - 界面管理
- (void)sendButtonNotUser {
    //    self.sendBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0xbfbfbf);
    self.sendBtn.userInteractionEnabled = NO;
}

- (void)sendButtonCanUser {
    //    self.sendBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x0CEDF5);
    self.sendBtn.userInteractionEnabled = YES;
}

- (void)changePlaceholder:(BOOL)louder {
    UIFont *font = PlaceholderFont;

    if (louder) {
        // 切换成弹幕
        NSNumber *popPrice = @(self.liveRoom.imLiveRoom.popPrice);
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"INPUT_LOUDER_PLACEHOLDER"),popPrice]];
        [attributeString addAttributes:@{
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : self.placeholderColor
        }
                                 range:NSMakeRange(0, attributeString.length)];
        self.inputTextField.attributedPlaceholder = attributeString;
        [self.louderBtn setImage:self.louderBtnImage forState:UIControlStateSelected];

    } else {
        // 切换成功普通
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"INPUT_PLACEHOLDER")];
        [attributeString addAttributes:@{
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0xb5b5b5)
        }
                                 range:NSMakeRange(0, attributeString.length)];
        self.inputTextField.attributedPlaceholder = attributeString;
        [self.louderBtn setImage:[UIImage imageNamed:@"Send_Pop_Close"] forState:UIControlStateNormal];
    }
}


@end
