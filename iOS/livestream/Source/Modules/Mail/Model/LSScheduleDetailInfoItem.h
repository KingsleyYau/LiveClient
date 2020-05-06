//
//  LSScheduleDetailInfoItem.h
//  livestream
//
//  Created by test on 2020/3/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum  {
    LSScheduleDetailTypeHead,
    LSScheduleDetailTypeContent,
    LSScheduleDetailTypeAction,
    LSScheduleDetailTypeBottun,
    LSScheduleDetailTypeFoot,
    LSScheduleDetailTypeUnknow,
} LSScheduleDetailType;

@interface LSScheduleDetailInfoItem : NSObject

@property (nonatomic, copy) NSString *photoUrl;

@property (nonatomic, copy) NSString *anchorName;

@property (nonatomic, assign) LSScheduleDetailType detailType;

@end

NS_ASSUME_NONNULL_END
