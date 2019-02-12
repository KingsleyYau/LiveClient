//
//  LSChatEmotionViewController.h
//  livestream
//
//  Created by Randy_Fan on 2018/10/22.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

@class LSChatEmotionViewController;
@protocol LSChatEmotionViewControllerDelegate <NSObject>
@optional

- (void)didStandardEmotionViewItem:(NSInteger)index;

- (void)emotionKeyboardViewClickSend;

@end

@interface LSChatEmotionViewController : LSGoogleAnalyticsViewController


@property (nonatomic, weak) id<LSChatEmotionViewControllerDelegate> emotionDelegate;

- (void)keyboardViewReload;

@end
