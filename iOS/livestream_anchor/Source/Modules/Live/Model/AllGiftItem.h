//
//  AllGiftItem.h
//  livestream
//
//  Created by randy on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBGiftInfoItemObject.h"

@interface AllGiftItem : NSObject

@property (nonatomic, strong) ZBGiftInfoItemObject *infoItem;

@property (nonatomic, assign) BOOL isDownloading;

@end
