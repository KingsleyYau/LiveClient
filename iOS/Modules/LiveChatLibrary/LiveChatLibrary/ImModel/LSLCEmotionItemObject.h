//
//  LSLCEmotionItemObject.h
//  dating
//
//  Created by alex on 16/9/6.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSLCEmotionItemObject : NSObject

/** 文件名 */
@property (nonatomic,strong) NSString *emotionId;
/** 所需点数 */
@property (nonatomic,assign) double price;
/** 是否有new标志 */
@property (nonatomic,assign) BOOL isNew;
/** 是否打折 */
@property (nonatomic,assign) BOOL isSale;
/** 排序字段（降序） */
@property (nonatomic,assign) NSInteger sortId;
/** 分类ID */
@property (nonatomic,strong) NSString *typeId;
/** tagID */
@property (nonatomic,strong) NSString *tagId;
/** 表情标题 */
@property (nonatomic,strong) NSString *title;

//初始化
- (LSLCEmotionItemObject *)init;


@end
