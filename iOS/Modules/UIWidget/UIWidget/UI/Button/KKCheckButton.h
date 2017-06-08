//
//  KKCheckButton.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKCheckButtonDelegate <NSObject>
@optional
- (void)selectedChanged:(id)sender;
@end

@interface KKCheckButton : UIButton
@property (nonatomic, assign) IBOutlet id<KKCheckButtonDelegate> selectedChangeDelegate;
@end
