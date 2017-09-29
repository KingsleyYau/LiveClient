//
//  HomePageViewController.h
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"



@interface HomePageViewController : KKViewController <PZPagingScrollViewDelegate>

@property (nonatomic, weak) IBOutlet PZPagingScrollView* pagingScrollView;



@end
