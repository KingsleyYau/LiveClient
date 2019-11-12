//
//  LSAddresseeItem.h
//  livestream
//
//  Created by Randy_Fan on 2019/10/12.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSAddresseeItem : NSObject

@property (nonatomic, copy) NSString *anchorId;

@property (nonatomic, copy) NSString *anchorName;

@property (nonatomic, copy) NSString *anchorHeadUrl;

@property (nonatomic, copy) NSString *anchorCoverUrl;
@end

NS_ASSUME_NONNULL_END
