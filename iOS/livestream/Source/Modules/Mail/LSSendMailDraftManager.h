//
//  LSSendMailDraftManager.h
//  livestream
//
//  Created by Calvin on 2018/12/24.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSSendMailDraftManager : NSObject

@property (nonatomic, assign) BOOL isEdit;

+ (instancetype)manager;

- (void)initMailDraftLadyId:(NSString *)ladyId name:(NSString *)name;
/**
 获取草稿箱内容
 */
- (NSString *)getDraftContent:(NSString *)ladyId;
/**
 判断是否显示草稿弹窗
 */
- (BOOL)isShowDraftDialogLadyId:(NSString *)ladyId name:(NSString *)ladyName content:(NSString *)text;
/**
 保存草稿箱
 */
- (void)saveMailDraftFromLady:(NSString *)ladyId content:(NSString *)text;
/**
 删除草稿箱
 */
- (void)deleteMailDraft:(NSString *)ladyId;
/**
 保存预约草稿箱
 */
- (void)saveScheduleMailDraftFromLady:(NSString *)ladyId content:(NSString *)text;
/**
 删除草稿箱
 */
- (void)deleteScheduleMailDraft:(NSString *)ladyId;

/**
删除所有草稿箱
*/
- (void)removeAllScheduleMailDraft;
/**
获取预约草稿箱
*/
- (NSString *)getScheduleMailDraft:(NSString *)ladyId;
@end

NS_ASSUME_NONNULL_END
