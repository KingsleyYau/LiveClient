//
//  URLShortener.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface URLShortener : NSObject {

}

+ (NSString *) compressedIdFromNumber: (NSNumber *)number;
@end
