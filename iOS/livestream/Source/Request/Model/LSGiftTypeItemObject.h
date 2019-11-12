//
//  LSGiftTypeItemObject.h
//  dating
//
//  Created by Alex on 19/8/27.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSGiftTypeItemObject : NSObject
{

}
/**
 * 虚拟礼物分类列表结构体
 * typeId     类型ID
 * typeName   类型名称
 */

@property (nonatomic, copy) NSString* typeId;
@property (nonatomic, copy) NSString* typeName;

@end
