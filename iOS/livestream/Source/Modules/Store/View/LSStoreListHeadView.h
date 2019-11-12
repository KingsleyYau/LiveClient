//
//  LSStoreListHeadView.h
//  livestream
//
//  Created by Calvin on 2019/10/10.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSStoreListHeadViewDelegate <NSObject>

- (void)storeListHeadViewDidChooseBtn;
- (void)storeListHeadViewSelectSection:(NSInteger)section;
@end

@interface LSStoreListHeadView : UIView 
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray * titleArray;
@property (nonatomic, assign) NSInteger selectRow;
@property (weak, nonatomic) id<LSStoreListHeadViewDelegate> delegate;
- (void)reloadData;
@end

 
