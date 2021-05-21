//
//  StreamLiveItemTableViewController.h
//  RtmpClientTest
//
//  Created by Max on 2021/5/21.
//  Copyright © 2021 net.qdating. All rights reserved.
//

#import "BaseViewController.h"
#import "LiveItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface StreamLiveItemTableViewController : BaseViewController
@property (strong) NSArray<LiveItem *> *items;
@end

NS_ASSUME_NONNULL_END
