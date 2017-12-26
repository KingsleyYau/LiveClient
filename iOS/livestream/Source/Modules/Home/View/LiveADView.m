//
//  LiveADView.m
//  livestream
//
//  Created by Calvin on 2017/10/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveADView.h"
#import "LSBannerRequest.h"
#import "LSImageViewLoader.h"
@interface LiveADView ()
@property (nonatomic, strong) UIImageView * adView;
@property (nonatomic, copy) NSString * adURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) LSImageViewLoader *imageLoader;
@end

@implementation LiveADView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        self.imageLoader = [LSImageViewLoader loader];
        self.adView = [[UIImageView alloc]initWithFrame:frame];
        self.adView.image = [UIImage imageNamed:@"Home_HotAndFollow_TableViewHeader_Banner"];
        self.adView.userInteractionEnabled = YES;
        [self.adView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bannerDid:)]];
        self.adView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.adView];
        [self loadAD];
    }
    return self;
}

- (void)loadAD
{
    LSBannerRequest * request = [[LSBannerRequest alloc]init];
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull bannerImg, NSString * _Nonnull bannerLink, NSString * _Nonnull bannerName)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self.imageLoader loadImageWithImageView:self.adView options:0 imageUrl:bannerImg placeholderImage:[UIImage imageNamed:@"Home_HotAndFollow_TableViewHeader_Banner"]];
                self.adURL = bannerLink;
                self.title = bannerName;
            }
        });
    };
    
    [[LSSessionRequestManager manager] sendRequest:request];
    
}

- (void)bannerDid:(UITapGestureRecognizer *)tap
{
    if (self.adURL.length > 0) {
        if ([self.delegate respondsToSelector:@selector(liveADViewBannerURL:title:)]) {
            [self.delegate liveADViewBannerURL:self.adURL title:self.title];
        }
    }
}
@end
