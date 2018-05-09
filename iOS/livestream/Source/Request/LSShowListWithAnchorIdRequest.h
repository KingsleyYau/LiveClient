//
// LSShowListWithAnchorIdRequest.h
//  dating
//  9.6.获取节目推荐列表
//  Created by Max on 18/04/27.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSShowListWithAnchorIdRequest : LSSessionRequest
/**
 *  9.6.获取节目推荐列表接口
 *
 * anchorId                      主播ID
 * start                         起始，用于分页，表示从第几个元素开始获取
 * step                          步长，用于分页，表示本次请求获取多少个元素
 * sortType                      列表类型（SHOWRECOMMENDLISTTYPE_ENDRECOMMEND：直播结束推荐<包括指定主播及其它主播>，SHOWRECOMMENDLISTTYPE_PERSONALRECOMMEND：主播个人节目推荐<仅包括指定主播>，SHOWRECOMMENDLISTTYPE_NOHOSTRECOMMEND：不包括指定主播）
 *  finishHandler    接口回调
 *
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, assign) int start;
@property (nonatomic, assign) int step;
@property (nonatomic, assign) ShowRecommendListType sortType;
@property (nonatomic, strong) GetProgramListFinishHandler _Nullable finishHandler;
@end
