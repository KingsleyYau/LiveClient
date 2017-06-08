//
//  SearchViewController.h
//  livestream
//
//  Created by randy on 17/6/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchTableView.h"

@interface SearchViewController : KKViewController

@property (strong, nonatomic) UITextField *textField;

@property (weak, nonatomic) IBOutlet SearchTableView *tableView;

@property (nonatomic, strong) NSMutableArray *items;

@end
