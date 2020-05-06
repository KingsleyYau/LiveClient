//
//  LSRecepientItem.h
//  livestream
//
//  Created by test on 2020/4/8.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSRecepientItem : NSObject
/** 昵称 */
@property (nonatomic, copy) NSString *anchorName;
/** 头像 */
@property (nonatomic, copy) NSString *anchorPhoto;
/** 头像 */
@property (nonatomic, copy) NSString *anchorId;
@end

NS_ASSUME_NONNULL_END
