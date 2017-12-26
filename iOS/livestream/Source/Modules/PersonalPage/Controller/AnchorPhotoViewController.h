//
//  AnchorPhotoViewController.h
//  livestream
//
//  Created by alex shum on 17/9/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

@class AnchorPhotoViewController;
@protocol AnchorPhotoViewControllerDelegate <NSObject>

- (void)anchorPhotoCheckPhtoViewController:(AnchorPhotoViewController *)checkPhotoViewController didScrollToIndex:(NSInteger)index;

@end

@interface AnchorPhotoViewController : LSGoogleAnalyticsViewController

@property (weak, nonatomic) IBOutlet LSPZPagingScrollView *pagingScrollView;
// 主播封面url数组
@property (nonatomic, strong) NSArray *ladyListArray;
// 封面位置
@property (nonatomic, assign) NSInteger photoIndex;
/** 代理 */
@property (nonatomic,weak) id<AnchorPhotoViewControllerDelegate> delegate;

@end
