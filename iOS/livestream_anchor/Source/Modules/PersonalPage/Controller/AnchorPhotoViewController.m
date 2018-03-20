//
//  AnchorPhotoViewController.m
//  livestream
//
//  Created by alex shum on 17/9/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "AnchorPhotoViewController.h"
#import "LSImageViewLoader.h"
#import <objc/runtime.h>
#import "LSFileCacheManager.h"

@interface AnchorPhotoViewController () <LSPZPagingScrollViewDelegate, LSPZPhotoViewDelegate>

@end

@implementation AnchorPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.pagingScrollView.pagingViewDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    [self.pagingScrollView displayPagingViewAtIndex:self.photoIndex animated:YES];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (Class)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    return [LSPZPhotoView class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(LSPZPagingScrollView *)pagingScrollView {
    //    NSUInteger count = 0;
    //    count = self.ladyListArray.count;
    //    CGSize size = pagingScrollView.contentSize;
    //    size.height = CGRectGetHeight(pagingScrollView.frame);
    //    size.width = CGRectGetWidth(pagingScrollView.frame) * count;
    //    pagingScrollView.contentSize = size;
    //    pagingScrollView.alwaysBounceHorizontal = NO;
    
    NSUInteger count = 0;
    count = self.ladyListArray.count;
    CGSize size = pagingScrollView.contentSize;
    size.height = CGRectGetHeight(pagingScrollView.frame) ;
    size.width = CGRectGetWidth(pagingScrollView.frame) * count;
    pagingScrollView.contentSize = size;
    //     pagingScrollView.alwaysBounceHorizontal = NO;
    return count;
}

- (UIView *)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    //    CGFloat photoSizeHeight = CGRectGetHeight(pagingScrollView.frame);
    //    CGFloat photoSizeWidth = CGRectGetWidth(pagingScrollView.frame);
    //    PZPhotoView *photoView = [[PZPhotoView alloc] initWithFrame:CGRectMake(0, 0, photoSizeWidth, photoSizeHeight)];
    //
    ////    PZPhotoView *photoView = [[PZPhotoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    //
    //    photoView.imageViewContentMode = UIViewContentModeScaleAspectFit;
    
    CGFloat photoSizeHeight = CGRectGetHeight(pagingScrollView.frame);
    CGFloat photoSizeWidth = CGRectGetWidth(pagingScrollView.frame);
    LSPZPhotoView *photoView = [[LSPZPhotoView alloc] initWithFrame:CGRectMake(0, 0, photoSizeWidth, photoSizeHeight)];
    
    // PZPhotoView *photoView = [[PZPhotoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    photoView.imageViewContentMode = UIViewContentModeScaleAspectFit;
    return photoView;
    
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    
    if (self.ladyListArray.count - 1 >= index) {
        // 还原默认图片
        LSPZPhotoView* photoView = (LSPZPhotoView *)pageView;
        [photoView prepareForReuse];
        photoView.photoViewDelegate = self;
        photoView.pagingEnabled = YES;
        
        // 图片路径
        NSString* url = [self.ladyListArray objectAtIndex:index];
        // 停止旧的
        static NSString *imageViewLoaderKey = @"imageViewLoaderKey";
        LSImageViewLoader *imageViewLoader = objc_getAssociatedObject(pageView, &imageViewLoaderKey);
        [imageViewLoader stop];
        
        // 创建新的
        imageViewLoader = [LSImageViewLoader loader];
        objc_setAssociatedObject(pageView, &imageViewLoaderKey, imageViewLoader, OBJC_ASSOCIATION_RETAIN);
        
        [self showLoading];
        
        // 加载图片
        [imageViewLoader sdWebImageLoadView:photoView options:0 imageUrl:url placeholderImage:nil finishHandler:^(UIImage *image) {
            [self hideAndResetLoading];
        }];
        
//        imageViewLoader.delegate = self;
//        imageViewLoader.view = photoView;
//        imageViewLoader.url = url;
//        imageViewLoader.path = [[LSFileCacheManager manager] imageCachePathWithUrl:imageViewLoader.url];
//        [imageViewLoader loadImage];

    }
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
        self.photoIndex = index;
    //        NSLog(@"visiblePageView %@",pagingScrollView.visiblePageView);
    //    PZPhotoView *vc = (PZPhotoView *)pagingScrollView.visiblePageView;
    //    NSLog(@"visiblePageView %@",vc.imageView.image);
    //    if (!vc.imageView.image) {
    //        [self hideAndResetLoading];
    //    }
        [self hideAndResetLoading];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(ladyDetailCheckPhtoViewController:didScrollToIndex:)]) {
//        [self.delegate ladyDetailCheckPhtoViewController:self didScrollToIndex:index];
//    }
    
}

#pragma mark - 照片手势处理回调

- (void)photoViewDidSingleTap:(LSPZPhotoView *)photoView {
    [self dismissViewControllerAnimated:NO completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)photoViewDidDoubleTap:(LSPZPhotoView *)photoView {
    
}

- (void)photoViewDidTwoFingerTap:(LSPZPhotoView *)photoView {
    
}

- (void)photoViewDidDoubleTwoFingerTap:(LSPZPhotoView *)photoView {
    
}

- (void)retryLabelTap:(UITapGestureRecognizer *)gesture {
//    RetryLabel * label = (RetryLabel *)gesture.view;
//    // 停止旧的
//    static NSString *imageViewLoaderKey = @"imageViewLoaderKey";
//    LSImageViewLoader *imageViewLoader = objc_getAssociatedObject(label.superview, &imageViewLoaderKey);
//    [LSImageViewLoader stop];
//    
//    // 创建新的
//    LSImageViewLoader = [LSImageViewLoader loader];
//    objc_setAssociatedObject(label.superview, &imageViewLoaderKey, LSImageViewLoader, OBJC_ASSOCIATION_RETAIN);
//    
//    LSImageViewLoader.delegate = self;
//    LSImageViewLoader.view =label.superview;
//    LSImageViewLoader.url = label.imageUrl;
//    LSImageViewLoader.path = [[LSFileCacheManager manager] imageCachePathWithUrl:LSImageViewLoader.url];
//    [gesture.view removeFromSuperview];
//    [LSImageViewLoader loadImage];
}

- (void)lockPhotoViewDidClick:(UITapGestureRecognizer *)gesture {
    [self dismissViewControllerAnimated:NO completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}




@end
