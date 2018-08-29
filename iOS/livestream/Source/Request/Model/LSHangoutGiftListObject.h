//
// LSHangoutGiftListObject.h
//  dating
//
//  Created by Alex on 18/5/8.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LSHangoutGiftListObject : NSObject

/**
 * 可发送的礼物列表信息
 * buyforList           吧台礼物列表
 * normalList           连击礼物及大礼物列表
 * celebrationList      庆祝礼物列表
 */
@property (nonatomic, strong)NSMutableArray<NSString*>* _Nullable buyforList;
@property (nonatomic, strong)NSMutableArray<NSString*>* _Nullable normalList;
@property (nonatomic, strong)NSMutableArray<NSString*>* _Nullable celebrationList;
@end
