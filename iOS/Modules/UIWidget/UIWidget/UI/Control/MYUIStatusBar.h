//
//  MYUIStatusBar.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MYUIStatusBar : NSObject{

}
@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, retain) NSMutableArray* messages;
@property (nonatomic, retain) UIWindow* statusWindow;
@property (nonatomic, retain) UILabel* messageLabel;
@property (nonatomic) BOOL isShow;

- (void)showMessage:(NSString*)message;

// 是否显示的总开关
- (void)show;
- (void)hide;
@end
