//
//  MsgItem.h
//  livestream
//
//  Created by Max on 2017/5/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MsgType {
    MsgType_Chat,
    MsgType_Join,
} MsgType;

@interface MsgItem : NSObject

@property (assign) MsgType type;
@property (assign) NSInteger level;
@property (strong) NSString* name;
@property (strong) NSString* text;
@property (strong) NSAttributedString* attText;
@property (nonatomic, strong) YYTextLayout *layout;

@end
