//
//  LiveFansListRequest.h
//  dating
//  3.4.获取直播间观众头像列表接口
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface LiveFansListRequest : SessionRequest
/**
 * roomId                        直播间ID
 * page                          页数（可0， 0则表示获取所有， ）
 * number                        每页的元素数量（可0， 0则表示获取所有）
 */

@property (nonatomic, copy) NSString * _Nullable roomId;
@property (nonatomic, assign)int page;
@property (nonatomic, assign)int number;
@property (nonatomic, strong) LiveFansListFinishHandler _Nullable finishHandler;
@end
