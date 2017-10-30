//
//  LSURLQueryParam.h
//  CommonWidget
//
//  Created by Max on 16/10/19.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSURLQueryParam : NSObject
+ (NSString *)urlParamForKey:(NSString *)key url:(NSURL *)url;
+ (NSDictionary *)urlParameters:(NSURL *)url;
@end
