//
//  StreamLiveItemTableViewController.h
//  RtmpClientTest
//
//  Created by Max on 2021/5/21.
//  Copyright © 2021 net.qdating. All rights reserved.
//

#import "BaseViewController.h"
#import "LiveItem.h"
#import "LiveCategory.h"

NS_ASSUME_NONNULL_BEGIN
@class StreamLiveItemTableViewController;
@protocol StreamLiveItemTableViewControllerDelegate <NSObject>
@optional
- (void)streamTableView:(StreamLiveItemTableViewController*)vc didSelectLiveItem:(LiveItem *)liveItem category:(LiveCategory *)category;
@end

@interface StreamLiveItemTableViewController : BaseViewController
@property (strong) NSArray<LiveCategory *> *categories;
@property (weak) id<StreamLiveItemTableViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
