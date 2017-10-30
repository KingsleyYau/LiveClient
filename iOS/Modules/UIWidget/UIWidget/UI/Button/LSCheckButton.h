//
//  LSCheckButton.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSCheckButtonDelegate <NSObject>
@optional
- (void)selectedChanged:(id)sender;
@end

@interface LSCheckButton : UIButton
@property (nonatomic, assign) IBOutlet id<LSCheckButtonDelegate> selectedChangeDelegate;
@end
