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

@interface AnchorPhotoViewController () <LSPZPagingScrollViewDelegate, ImageViewLoaderDelegate, LSPZPhotoViewDelegate>

@end

@implementation AnchorPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
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
        
        // 加载图片
        imageViewLoader.delegate = self;
        imageViewLoader.view = photoView;
        imageViewLoader.url = url;
        imageViewLoader.path = [[LSFileCacheManager manager] imageCachePathWithUrl:imageViewLoader.url];
        
        [self showLoading];
        [imageViewLoader loadImage];
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

#pragma mark - 下载完成回调
- (void)loadImageFinish:(LSImageViewLoader *)LSImageViewLoader success:(BOOL)success {
    [self hideAndResetLoading];
    if (success) {
        
    }else {
        
//        RetryLabel * label = [[RetryLabel alloc] init];
//        label.imageUrl = LSImageViewLoader.url;
//        label.numberOfLines = 0;
//        label.font = [UIFont systemFontOfSize:14];
//        label.textColor = [UIColor whiteColor];
//        label.text = @"Photo load failed. Reload";
//        [label sizeToFit];
//        label.center = self.view.center;
//        
//        NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:label.text];
//        [richText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:[label.text rangeOfString:@"Reload"]];//设置下划线
//        [richText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithIntRGB:0 green:102 blue:255 alpha:255] range:[label.text rangeOfString:@"Reload"]];
//        label.attributedText = richText;
//        
//        [LSImageViewLoader.view addSubview:label];
//        label.userInteractionEnabled = YES;
//        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retryLabelTap:)]];
    }
    
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
