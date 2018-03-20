//
//  ChardTipView.h
//  livestream
//
//  Created by randy on 2017/9/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoom.h"

@interface ChardTipView : UIView

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIButton *gotBtn;

- (void)setTipWithRoomPrice:(double)roomPrice roomTip:(NSString *)roomtip creditText:(NSString *)creditTexe;

- (BOOL)hiddenChardTip;

@end
