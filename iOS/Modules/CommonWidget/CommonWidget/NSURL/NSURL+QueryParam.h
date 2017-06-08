//
//  NSURL+QueryParam.h
//  CommonWidget
//
//  Created by Max on 16/10/19.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL(QueryParam)
- (NSString *)parameterForKey:(NSString *)key;
- (NSDictionary *)parameters;
@end
