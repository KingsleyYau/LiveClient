//
//  LSHomeSetItemObject.h
//  livestream
//
//  Created by test on 2019/4/18.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum SettingFirstType {
    SettingFirstTypeChat = 0,
    SettingFirstTypeMail = 1,
    SettingFirstTypeSayHi = 2,
    SettingFirstTypeGreeting = 3,
    SettingFirstTypeHangout = 4,
} SettingFirstType;

typedef enum SettingSecondType {
    SettingSecondTypeShow = 0,
    SettingSecondTypeBooks = 1,
    SettingSecondTypeBackpack = 2,
} SettingSecondType;
NS_ASSUME_NONNULL_BEGIN

@interface LSHomeSetItemObject : NSObject

/** 图片名字 */
@property (nonatomic, copy) NSString *iconName;
/** 标题名字 */
@property (nonatomic, copy) NSString *titleName;
/** section1 */
@property (nonatomic, assign) SettingFirstType firstType;
/** section2 */
@property (nonatomic, assign) SettingSecondType secondType;
@end

NS_ASSUME_NONNULL_END
