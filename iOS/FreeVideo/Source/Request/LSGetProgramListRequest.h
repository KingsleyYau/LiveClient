//
// LSGetProgramListRequest.h
//  dating
//  9.2.获取节目列表
//  Created by Max on 18/04/18.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetProgramListRequest : LSSessionRequest
/**
 *  9.2.获取节目列表接口
 *
 *  @sortType          列表类型（PROGRAMLISTTYPE_STARTTIEM：按节目开始时间排序，PROGRAMLISTTYPE_VERIFYTIEM：按节目审核时间排序，PROGRAMLISTTYPE_FEATURE：按广告排序，，PROGRAMLISTTYPE_BUYTICKET：已购票列表， PROGRAMLISTTYPE_HISTORY: 购票历史列表）
 *  @start                         起始，用于分页，表示从第几个元素开始获取
 *  @step                          步长，用于分页，表示本次请求获取多少个元素
 *  finishHandler    接口回调
 *
 */
@property (nonatomic, assign) ProgramListType sortType;
@property (nonatomic, assign) int start;
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetProgramListFinishHandler _Nullable finishHandler;
@end
