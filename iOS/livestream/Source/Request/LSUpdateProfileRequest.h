//
//  LSUpdateProfileRequest.h
//  dating
//  6.19.修改个人信息
//  Created by Alex on 18/6/22
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

/**
 * 6.19.修改个人信息接口
 *
 *  weight        体重
 *  height        高度
 *  language      语言
 *  ethnicity     人种
 *  religion      宗教
 *  education     教育程度
 *  profession    职业
 *  income        收入
 *  children      孩子
 *  smoke         吸烟
 *  drink         喝酒
 *  resume        详情
 *  interests     兴趣爱好
 *  zodiac        星座
 *  finishHandler    接口回调

 */
@interface LSUpdateProfileRequest : LSSessionRequest

@property (nonatomic,assign) int weight;
@property (nonatomic,assign) int height;
@property (nonatomic,assign) int language;
@property (nonatomic,assign) int ethnicity;
@property (nonatomic,assign) int religion;
@property (nonatomic,assign) int education;
@property (nonatomic,assign) int profession;
@property (nonatomic,assign) int income;
@property (nonatomic,assign) int children;
@property (nonatomic,assign) int smoke;
@property (nonatomic,assign) int drink;
@property (nonatomic,strong) NSString * _Nullable resume;
@property (nonatomic,strong) NSArray *interests;
@property (nonatomic, assign) int zodiac;
@property (nonatomic, strong) UpdateProfileFinishHandler _Nullable finishHandler;
@end
