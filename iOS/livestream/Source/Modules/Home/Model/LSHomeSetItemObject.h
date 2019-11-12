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
    SettingFirstTypeStroe = 4,
} SettingFirstType;

typedef enum SettingSecondType {
    SettingSecondTypeHangout = 0,
    SettingSecondTypeMyContacts = 1,
} SettingSecondType;

typedef enum SettingThirdType {
    SettingThirdTypeShow = 0,
    SettingThirdTypeBooks = 1,
    SettingThirdTypeBackpack = 2,
} SettingThirdType;

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

@property (nonatomic, assign) SettingThirdType thirdType;
@end

NS_ASSUME_NONNULL_END
