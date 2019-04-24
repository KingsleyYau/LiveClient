//
//  HangoutGiftHighlightButton.h
//  livestream
//
//  Created by Randy_Fan on 2019/3/7.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "LSHighlightedButton.h"

@class HangoutGiftHighlightButton;
@protocol HangoutGiftHighlightButtonDelegate <NSObject>
- (void)HangoutGiftHighlightButtonIsHighlight;
- (void)HangoutGiftHighlightButtonCancleHighlight;
@end

@interface HangoutGiftHighlightButton : LSHighlightedButton

@property (nonatomic, weak) id<HangoutGiftHighlightButtonDelegate> delegate;

@end
