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

@interface FollowingViewController : KKViewController
@property (weak, nonatomic) IBOutlet FollowCollectionView *collectionView;
@property (nonatomic, weak) HomePageViewController* homePageVC;
@end
