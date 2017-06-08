//
//  MsgItem.h
//  livestream
//
//  Created by Max on 2017/5/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MsgItem : NSObject

@property (assign) NSInteger level;
@property (strong) NSString* name;
@property (strong) NSString* text;
@property (strong) NSAttributedString* attText;

@end
