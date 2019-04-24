//
//  HangOutFinshViewController.h
//  livestream
//
//  Created by Randy_Fan on 2018/6/4.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"
#import "LSImManager.h"
#import "LSRoomUserInfoManager.h"

typedef enum {
    HANGOUTERROR_NORMAL,
    HANGOUTERROR_BACKSTAGE,
    HANGOUTERROR_NOCREDIT
} HANGOUTERROR;

@interface HangOutFinshViewController : LSGoogleAnalyticsViewController

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

- (void)showError:(HANGOUTERROR)error errMsg:(NSString *)errMsg;

- (void)anchorArrayAddObject:(LSUserInfoModel *)obj;

@end
