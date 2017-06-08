//
//  KKButtonBar.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KKButtonBar;

@protocol KKButtonBarDelegete <NSObject>
@optional

- (void)itemsDidLayout:(KKButtonBar *)kkButtonBar;

@end

@interface KKButtonBar : UIView {
    
}

@property (nonatomic, assign) IBOutlet id<KKButtonBarDelegete> delegate;
@property (nonatomic, retain) NSArray* items;
@property (nonatomic, assign) CGFloat blanking;
@property (nonatomic, assign) BOOL isVertical;

- (void)reloadData:(BOOL)animated;

@end
