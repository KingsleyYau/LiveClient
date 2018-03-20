//
//  LiveBundle.h
//  livestream
//
//  Created by Max on 2017/10/13.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveBundle : NSBundle
+ (void)gobalInit;
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;
@end
