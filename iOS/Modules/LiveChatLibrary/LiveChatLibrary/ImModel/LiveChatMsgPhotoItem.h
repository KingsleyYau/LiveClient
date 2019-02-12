//
//  LiveChatMsgPhotoItem.h
//  dating
//
//  Created by lance on 16/7/12.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveChatMsgPhotoItem : NSObject

/** 图片ID */
@property (nonatomic,strong) NSString *photoId;
/** 图片描述 */
@property (nonatomic,strong) NSString *photoDesc;
/** 发送Id */
@property (nonatomic,strong) NSString *sendId;
/** 不清晰图路径 */
@property (nonatomic,strong) NSString *showFuzzyFilePath;
/** 拇指不清晰图路径 */
@property (nonatomic,strong) NSString *thumbFuzzyFilePath;
/** 原图路径 */
@property (nonatomic,strong) NSString *srcFilePath;
/** 显示原图的路径 */
@property (nonatomic,strong) NSString *showSrcFilePath;
/** 拇指图原图路径 */
@property (nonatomic,strong) NSString *thumbSrcFilePath;
/** 是否付费 */
@property (nonatomic,assign,getter=isGetCharge) BOOL charge;


- (LiveChatMsgPhotoItem *)init;


@end
