//
//  LiveItem.h
//  RtmpClientTest
//
//  Created by Max on 2021/5/21.
//  Copyright © 2021 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveItem : NSObject
@property (strong) NSString *name;
@property (strong) NSString *url;
@property (strong) UIImage *logo;
@end

NS_ASSUME_NONNULL_END
