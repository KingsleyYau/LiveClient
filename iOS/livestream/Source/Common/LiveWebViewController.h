//
//  LiveWebViewController.h
//  livestream
//
//  Created by randy on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSListViewController.h"

@interface LiveWebViewController : LSListViewController

@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) BOOL isIntimacy;

@property (nonatomic, copy) NSString *anchorId;

/** 是否协议 */
@property (nonatomic, assign) BOOL isUserProtocol;

@end
