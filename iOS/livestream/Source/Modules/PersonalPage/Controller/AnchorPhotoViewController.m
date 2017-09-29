//
//  AnchorPhotoViewController.m
//  livestream
//
//  Created by alex shum on 17/9/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "AnchorPhotoViewController.h"
#import "ImageViewLoader.h"
#import <objc/runtime.h>
#import "FileCacheManager.h"

@interface AnchorPhotoViewController () <PZPagingScrollViewDelegate, ImageViewLoaderDelegate, PZPhotoViewDelegate>

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

- (Class)pagingScrollView:(PZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    return [PZPhotoView class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(PZPagingScrollView *)pagingScrollView {
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

- (UIView *)pagingScrollView:(PZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    //    CGFloat photoSizeHeight = CGRectGetHeight(pagingScrollView.frame);
    //    CGFloat photoSizeWidth = CGRectGetWidth(pagingScrollView.frame);
    //    PZPhotoView *photoView = [[PZPhotoView alloc] initWithFrame:CGRectMake(0, 0, photoSizeWidth, photoSizeHeight)];
    //
    ////    PZPhotoView *photoView = [[PZPhotoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    //
    //    photoView.imageViewContentMode = UIViewContentModeScaleAspectFit;
    
    CGFloat photoSizeHeight = CGRectGetHeight(pagingScrollView.frame);
    CGFloat photoSizeWidth = CGRectGetWidth(pagingScrollView.frame);
    PZPhotoView *photoView = [[PZPhotoView alloc] initWithFrame:CGRectMake(0, 0, photoSizeWidth, photoSizeHeight)];
    
    // PZPhotoView *photoView = [[PZPhotoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    photoView.imageViewContentMode = UIViewContentModeScaleAspectFit;
    return photoView;
    
}

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    
    if (self.ladyListArray.count - 1 >= index) {
        // 还原默认图片
        PZPhotoView* photoView = (PZPhotoView *)pageView;
        [photoView prepareForReuse];
        photoView.photoViewDelegate = self;
        photoView.pagingEnabled = YES;
        
        // 图片路径
        NSString* url = [self.ladyListArray objectAtIndex:index];
        // 停止旧的
        static NSString *imageViewLoaderKey = @"imageViewLoaderKey";
        ImageViewLoader* imageViewLoader = objc_getAssociatedObject(pageView, &imageViewLoaderKey);
        [imageViewLoader stop];
        
        // 创建新的
        imageViewLoader = [ImageViewLoader loader];
        objc_setAssociatedObject(pageView, &imageViewLoaderKey, imageViewLoader, OBJC_ASSOCIATION_RETAIN);
        
        // 加载图片
        imageViewLoader.delegate = self;
        imageViewLoader.view = photoView;
        imageViewLoader.url = url;
        imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:imageViewLoader.url];
        
        [self showLoading];
        [imageViewLoader loadImage];
    }
}

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
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

- (void)photoViewDidSingleTap:(PZPhotoView *)photoView {
    [self dismissViewControllerAnimated:NO completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)photoViewDidDoubleTap:(PZPhotoView *)photoView {
    
}

- (void)photoViewDidTwoFingerTap:(PZPhotoView *)photoView {
    
}

- (void)photoViewDidDoubleTwoFingerTap:(PZPhotoView *)photoView {
    
}

#pragma mark - 下载完成回调
- (void)loadImageFinish:(ImageViewLoader *)imageViewLoader success:(BOOL)success {
    [self hideAndResetLoading];
    if (success) {
        
    }else {
        
//        RetryLabel * label = [[RetryLabel alloc] init];
//        label.imageUrl = imageViewLoader.url;
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
//        [imageViewLoader.view addSubview:label];
//        label.userInteractionEnabled = YES;
//        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retryLabelTap:)]];
    }
    
}



- (void)retryLabelTap:(UITapGestureRecognizer *)gesture {
//    RetryLabel * label = (RetryLabel *)gesture.view;
//    // 停止旧的
//    static NSString *imageViewLoaderKey = @"imageViewLoaderKey";
//    ImageViewLoader* imageViewLoader = objc_getAssociatedObject(label.superview, &imageViewLoaderKey);
//    [imageViewLoader stop];
//    
//    // 创建新的
//    imageViewLoader = [ImageViewLoader loader];
//    objc_setAssociatedObject(label.superview, &imageViewLoaderKey, imageViewLoader, OBJC_ASSOCIATION_RETAIN);
//    
//    imageViewLoader.delegate = self;
//    imageViewLoader.view =label.superview;
//    imageViewLoader.url = label.imageUrl;
//    imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:imageViewLoader.url];
//    [gesture.view removeFromSuperview];
//    [imageViewLoader loadImage];
}


- (void)lockPhotoViewDidClick:(UITapGestureRecognizer *)gesture {
    [self dismissViewControllerAnimated:NO completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}




@end
