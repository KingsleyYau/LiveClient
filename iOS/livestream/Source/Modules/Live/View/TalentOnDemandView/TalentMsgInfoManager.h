//
//  TalentMsgInfoManager.h
//  testApp
//
//  Created by Calvin on 2018/5/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface TalentMsgInfoManager : NSObject

+ (NSMutableAttributedString *)showUnderlineString:(NSString *)name AndTitle:(NSString *)str andTitleFont:(UIFont*)font inMaxWidth:(CGFloat)width;

+ (NSMutableAttributedString *)showImageString:(NSString *)name AndTitle:(NSString *)str andTitleFont:(UIFont*)font inMaxWidth:(CGFloat)width giftImage:(NSString *)url isShowGift:(BOOL)isShow;

+(NSMutableAttributedString *)showTitleString:(NSString *)title Andunderline:(NSString *)str;
@end
