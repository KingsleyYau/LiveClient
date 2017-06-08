//
//  SearchTableView.h
//  livestream
//
//  Created by randy on 17/6/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchTableView;
@protocol SearchTableViewDelegate <NSObject>
@optional

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end


@interface SearchTableView : UITableView<UITableViewDelegate,UITableViewDataSource>

@property (strong ,nonatomic) NSArray *items;

@property (weak ,nonatomic) IBOutlet id<SearchTableViewDelegate> searchDelegate;

@end
