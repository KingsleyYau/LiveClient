//
//  LSHomeScheduleItem.h
//  livestream
//
//  Created by test on 2020/3/25.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    HomeScheduleNoteTypeStart = 0,
    HomeScheduleNoteTypeWillStart
}HomeScheduleNoteType;


NS_ASSUME_NONNULL_BEGIN

@interface LSHomeScheduleItem : NSObject
/** 已经开始数量 */
@property (nonatomic, assign) int startNum;
/** 将要开始数量 */
@property (nonatomic, assign) int willStartNum;
/** 将要开始的时间 */
@property (nonatomic, assign) int startTime;
/** 剩余时间 */
@property (nonatomic, assign) int leftTime;

/** 已经开始标识 */
@property (nonatomic, copy) NSString *startNote;
/** 即将开始标识 */
@property (nonatomic, copy) NSString *willStartNote;

/** 通知类型 */
@property (nonatomic, assign) HomeScheduleNoteType type;
@end

NS_ASSUME_NONNULL_END
