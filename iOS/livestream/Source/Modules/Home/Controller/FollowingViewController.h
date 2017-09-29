//
//  FollowingViewController.h
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"
#import "FollowCollectionView.h"
#import "HomePageViewController.h"
#import "FollowTableView.h"

@interface FollowingViewController : ListViewController
@property (weak, nonatomic) IBOutlet FollowCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet FollowTableView *tableView;

@property (nonatomic, weak) HomePageViewController* homePageVC;
@end
