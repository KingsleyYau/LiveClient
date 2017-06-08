//
//  NSDictionary+property.m
//  runtime-kvc字典转模型
//
//  Created by lance.
//  Copyright © 2014年 lee. All rights reserved.
//


#import "NSDictionary+property.h"

@implementation NSDictionary (property)


- (void)propertyCode{
    
    //属性跟字典的key一一对应
    NSMutableString *codes = [NSMutableString string];
    
    //遍历字典中的属性
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //key是属性名
        NSString *code;
        if ([obj isKindOfClass:[NSString class]]) {
            code = [NSString stringWithFormat:@"@property (nonatomic,strong) NSString *%@",key];
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFBoolean")]){
            code = [NSString stringWithFormat:@"@property (nonatomic,assign) BOOL %@",key];
        }else if ([obj isKindOfClass:[NSNumber class]]){
            code = [NSString stringWithFormat:@"@property (nonatomic,assign) NSInterger %@",key];
        }else if ([obj isKindOfClass:[NSArray class]]){
              code = [NSString stringWithFormat:@"@property (nonatomic,strong) NSArray *%@",key];
        }else {
              code = [NSString stringWithFormat:@"@property (nonatomic,strong) NSDictionary *%@",key];
        }
        
        
        [codes appendFormat:@"\n%@;\n",code];
        
    }];

}


@end
