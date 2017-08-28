//
//  ChatListModel.h
//  livestream
//
//  Created by randy on 2017/8/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatListModel : NSObject

@property (nonatomic, strong) NSString*  userId;

@property (nonatomic, strong) NSString *imgUrl;

@property (nonatomic, strong) NSString*  name;

@property (nonatomic, strong) NSString*  lasterMsg;

@property (nonatomic, assign) int unreadNum;

@end
