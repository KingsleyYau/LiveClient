//
//  LSChatListViewController.h
//  livestream
//
//  Created by test on 2018/11/12.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSViewController.h"

@interface QNChatListViewController : LSViewController
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
- (void)reloadContactList;
@end
