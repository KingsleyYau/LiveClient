//
//  LSFollowingViewController.h
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

//#import "LSGoogleAnalyticsViewController.h"
#import "LSViewController.h"
#import "LSHomeCollectionView.h"

@protocol LSFollowingViewControllerDelegate
- (void)followingVCBrowseToHot;
@end

@interface LSFollowingViewController : LSListViewController
@property (weak, nonatomic) IBOutlet LSHomeCollectionView *collectionView;@property (weak, nonatomic) id<LSFollowingViewControllerDelegate> followVCDelegate;

@end
