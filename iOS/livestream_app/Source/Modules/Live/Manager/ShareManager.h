//
//  ShareManager.h
//  livestream
//
//  Created by randy on 2017/12/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSGetShareLinkRequest.h"

typedef void (^ShareHandler)(BOOL success, NSString *errmsg, NSString *shareId);
typedef void (^SystemsShareHandler)(BOOL success, NSError *error, UIActivityType *type);

@interface ShareManager : NSObject

@property (weak) UIViewController *presentVC;

+ (instancetype)manager;

- (void)sendShareForUserId:(NSString *)userId anchorId:(NSString *)anchorId shareType:(ShareType)shareType shareHandler:(ShareHandler)shareHandler;

- (BOOL)copyLinkToClipboard:(NSString *)shareLink;

- (void)systemsShareForShareLink:(NSString *)shareLink finishHandler:(SystemsShareHandler)finishHandler;

@end
