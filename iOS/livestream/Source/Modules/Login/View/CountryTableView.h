//
//  CountryTableView.h
//  UIWidget
//
//  Created by test on 2017/5/24.
//  Copyright © 2017年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CountryTableView;
@class Country;
@protocol CountryTableViewDelegate <NSObject>
@optional
- (void)tableView:(CountryTableView *)tableView didSelectCountry:(Country *)item;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end
@interface CountryTableView : UITableView<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, weak) IBOutlet id <CountryTableViewDelegate> tableViewDelegate;
@property (nonatomic, copy) NSArray *items;

@property (nonatomic, copy) NSArray *indexTitles;

@end
