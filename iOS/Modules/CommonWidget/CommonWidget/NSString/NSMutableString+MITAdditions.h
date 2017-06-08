//
//  NSString+MITAdditions.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSMutableString (MITAdditions)
- (void)replaceOccurrencesOfStrings:(NSArray *)targets withStrings:(NSArray *)replacements options:(NSStringCompareOptions)options;
@end
