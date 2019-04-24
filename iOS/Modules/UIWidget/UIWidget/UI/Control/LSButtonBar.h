//
//  LSButtonBar.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSButtonBar;
@protocol LSButtonBarDelegete <NSObject>
@optional
- (void)itemsDidLayout:(LSButtonBar *)LSButtonBar;
@end

@interface LSButtonBar : UIView;
@property (nonatomic, strong) UIView *containView;
@property (nonatomic, assign) IBOutlet id<LSButtonBarDelegete> delegate;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) CGFloat blanking;
@property (nonatomic, assign) BOOL isVertical;

- (void)reloadData:(BOOL)animated;

- (void)sendDelegate;

- (void)removeAllButton;

@end
