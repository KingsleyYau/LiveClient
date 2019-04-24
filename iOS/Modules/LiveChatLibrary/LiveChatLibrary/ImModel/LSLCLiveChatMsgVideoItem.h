//
//  LSLCLiveChatMsgVideoItem.h
//  dating
//
//  Created by Calvin on 19/3/15.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSLCLiveChatMsgVideoItem : NSObject

/** 视频ID */
@property (nonatomic,copy) NSString *videoId;
/** 发送ID */
@property (nonatomic,copy) NSString *sendId;
/** 视频描述 */
@property (nonatomic,copy) NSString *videoDesc;
/** 视频URL */
@property (nonatomic,copy) NSString *videoUrl;
/** 是否已付费 */
@property (nonatomic,assign) BOOL charge;
///** 小图路径 */
//@property (nonatomic,copy) NSString *thumbPhotoFilePath;
/** 大图路径 */
@property (nonatomic,copy) NSString *bigPhotoFilePath;
/** 视频路径 */
@property (nonatomic,copy) NSString *videoFilePath;

- (LSLCLiveChatMsgVideoItem *)init;


@end
