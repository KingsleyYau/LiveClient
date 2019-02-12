//
//  AnchorPersonalViewController.h
//  livestream
//
//  Created by alex shum on 17/9/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveRoomInfoItemObject.h"
#import "LSWKWebViewController.h"

@interface AnchorPersonalViewController : LSWKWebViewController

@property (nonatomic, copy) NSString *anchorId;
// 0 不需要显示立即私密邀请按钮 1 显示立即私密邀请按钮
@property (nonatomic, assign) int enterRoom;
//0:Album 1:MyCalender 2:Profile
@property (nonatomic, assign) NSInteger tabType;
@end
