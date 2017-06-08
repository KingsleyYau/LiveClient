//
//  ChatEmotion.h
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatEmotion : NSObject
/**
*  文字
*/
@property (nonatomic, retain) NSString *text;

/**
 *  图片
 */
@property (nonatomic, retain) UIImage* image;

/**
 *  初始化实例
 *
 *  @param text  文字
 *  @param image 图片
 *
 *  @return 实例
 */
- (id)initWithTextImage:(NSString* )text image:(UIImage*)image;

@end
