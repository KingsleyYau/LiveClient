//
//  PromptView.h
//  livestream
//
//  Created by randy on 17/6/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PromptView;
@protocol PromptViewDelegate <NSObject>
@optional

- (void)pushToLogin;

@end

@interface PromptView : UIView

@property (nonatomic,weak) id<PromptViewDelegate> promptDelegate;

- (void)cancelPrompt;

- (void)promptViewShow;

@end
