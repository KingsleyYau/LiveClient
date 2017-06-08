//
//  Country.h
//
//  Created by lance on 16/6/15.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Country : NSObject
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *zipCode;
@property (nonatomic, copy) NSString *firstLetter;
@property (nonatomic, copy) NSString *shortName;



- (instancetype)initWithDict:(NSDictionary *)dict;
@end
