//
//  LiveHeaderScrollview.h
//  ScrollviewDemo
//
//  Created by zzq on 2018/2/8.
//  Copyright © 2018年 zzq. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LiveHeaderScrollviewDelegate<NSObject>
@required
- (void)header_disSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface LiveHeaderScrollview : UIView

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) id<LiveHeaderScrollviewDelegate> delegate;

- (void)scrollCollectionItemToDesWithDesIndex:(NSInteger)index;

- (void)reloadHeaderScrollview:(BOOL)isShowUnread;
@end
