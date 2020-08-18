//
//  LSScheduleDetailsBottomView.m
//  livestream
//
//  Created by Randy_Fan on 2020/4/20.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleDetailsBottomView.h"
#import "LSPrePaidManager.h"

@implementation LSScheduleDetailsBottomView

+ (CGFloat)viewHeight {
    CGFloat height = 380;
    if (SCREEN_WIDTH > 320) {
        height = 350;
    }
    return height;;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSScheduleDetailsBottomView" owner:self options:0].firstObject;
    }
    return self;
}

- (IBAction)didHowWork:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didHowWorkAction)]) {
        [self.delegate didHowWorkAction];
    }
}

- (void)setupPrompt:(NSString *)name startTime:(NSInteger)startTime isSummerTime:(BOOL)isSummerTime {
    NSString *onePrompt = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SoC-EL-YXf.text"),name];
    NSRange range1 = [onePrompt rangeOfString:name];
    NSMutableAttributedString *oneAtrPrompt = [[NSMutableAttributedString alloc] initWithString:onePrompt attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12],
        NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x666666)}];
    [oneAtrPrompt setAttributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)} range:range1];
    
    NSString *localTime = [[LSPrePaidManager manager] getDetailStartAndEndTimestamp:startTime timeFormat:@"MMM dd, YYYY HH:mm" isDaylightSaving:isSummerTime andZone:@""];
    NSAttributedString *timeStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"gi5-6p-RgM.text"),localTime] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x666666)}];
    [oneAtrPrompt appendAttributedString:timeStr];
    self.onePromptLabel.attributedText = oneAtrPrompt;
    
    NSString *threePrompt = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"vX5-kK-nKi.text"),name];
    NSRange range2 = [threePrompt rangeOfString:name];
    NSMutableAttributedString *threeAtrPrompt = [[NSMutableAttributedString alloc] initWithString:threePrompt attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12],
        NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x666666)}];
    [threeAtrPrompt setAttributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)} range:range2];
    self.threePromptLabel.attributedText = threeAtrPrompt;
}



@end
