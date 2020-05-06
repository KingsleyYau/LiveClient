//
//  LSSendScheduleViewController.h
//  livestream
//
//  Created by test on 2020/3/24.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSSendScheduleViewController : LSViewController
/** 主播id */
@property (nonatomic, copy) NSString *anchorId;
/** 主播名字 */
@property (nonatomic, copy) NSString *anchorName;
@end

NS_ASSUME_NONNULL_END
