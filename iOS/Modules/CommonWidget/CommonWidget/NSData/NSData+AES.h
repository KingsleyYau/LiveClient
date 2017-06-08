//
//  NSData+AES.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSString;
@interface NSData (AES)
- (NSData *)AES256EncryptWithKey:(NSString *)key;   //加密256
- (NSData *)AES256DecryptWithKey:(NSString *)key;   //解密256
- (NSData *)AES128EncryptWithKey:(NSString *)key;   //加密128
- (NSData *)AES128DecryptWithKey:(NSString *)key;   //解密128
- (NSString *)toStringInBase64;            //追加64编码
+ (NSString*)base64encode:(NSString*)str;           //同上64编码
@end
