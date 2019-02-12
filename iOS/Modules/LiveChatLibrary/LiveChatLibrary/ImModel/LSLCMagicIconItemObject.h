//
//  LSLCMagicIconItemObject.h
//  dating
//
//  Created by alex on 16/9/12.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSLCMagicIconItemObject : NSObject

/** 小高级表情名 */
@property (nonatomic,strong) NSString *iconId;
/** 小高级表情内容 */
@property (nonatomic,strong) NSString *iconTitle;
/** 所需点数 */
@property (nonatomic,assign) double price;
/** 是否有hot标志 */
@property (nonatomic,assign) NSInteger hotflog;
/** 分类ID */
@property (nonatomic,strong) NSString *typeId;
/** 更新时间 */
@property (nonatomic,assign) NSInteger updatetime;

//初始化
- (LSLCMagicIconItemObject *)init;


@end
