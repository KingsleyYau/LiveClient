//
//  LSLCLiveChatMagicIconItemObject.h
//  dating
//
//  Created by alex on 16/9/12.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSLCLiveChatMagicIconItemObject : NSObject

/** 小高级表情ID */
@property (nonatomic,strong) NSString *magicIconId;
/** 小高级表情拇子图路径 */
@property (nonatomic,strong) NSString *thumbPath;
/** 小高级表情原图路径 */
@property (nonatomic,strong) NSString *sourcePath;

- (LSLCLiveChatMagicIconItemObject *)init;


@end
