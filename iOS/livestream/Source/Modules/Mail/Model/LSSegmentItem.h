//
//  LSSegmentItem.h
//  livestream
//
//  Created by test on 2020/4/3.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kSelectedColor      COLOR_WITH_16BAND_RGB(0x297AF3)
#define kTextSelectedColor  COLOR_WITH_16BAND_RGB(0x1A1A1A)
#define kNormalColor        COLOR_WITH_16BAND_RGB(0x666666)
#define kNormalBgColor      COLOR_WITH_16BAND_RGB(0xE2E2E2)
#define kSelectBgColor      COLOR_WITH_16BAND_RGB(0xF9DE87)

NS_ASSUME_NONNULL_BEGIN

@interface LSSegmentItem : NSObject

/** 选择颜色 */
@property (nonatomic, strong) UIColor *lineSelectColor;
/** 文字选择颜色 */
@property (nonatomic, strong) UIColor *textSelectColor;
/** 平常颜色 */
@property (nonatomic, strong) UIColor *normalColor;
/** 背景颜色 */
@property (nonatomic, strong) UIColor *normalBgColor;
/** 选择颜色 */
@property (nonatomic, strong) UIColor *selectBgColor;


@end

NS_ASSUME_NONNULL_END
