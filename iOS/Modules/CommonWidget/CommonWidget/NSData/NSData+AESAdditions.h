//
//  NSData.h
//  TestMemory
//
//  Created by admin on 11-4-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(AESAdditions)
- (NSData*)AES256EncryptWithKey:(NSString*)key;
- (NSData*)AES256DecryptWithKey:(NSString*)key;
@end
