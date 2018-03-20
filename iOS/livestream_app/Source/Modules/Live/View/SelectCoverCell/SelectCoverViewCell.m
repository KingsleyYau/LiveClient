//
//  SelectCoverViewCell.m
//  livestream
//
//  Created by randy on 17/6/19.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "SelectCoverViewCell.h"
#import "LSImageViewLoader.h"

@interface SelectCoverViewCell ()
@property (nonatomic, strong) LSImageViewLoader *loader;
@end

@implementation SelectCoverViewCell

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];

    if (self) {

        self.backgroundColor = [UIColor clearColor];
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
        [self addSubview:_imageView];
        self.clipsToBounds = YES;

        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"Liveend_Close_btn"] forState:UIControlStateNormal];
        _deleteBtn.frame = CGRectMake(self.frame.size.width - 26, 0, 29, 29);
        [self addSubview:_deleteBtn];

        _userButton = [[UIButton alloc] init];
        _userButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_userButton setTitleColor:COLOR_WITH_16BAND_RGB(0x5d0e86) forState:UIControlStateNormal];
        [_userButton setTitle:@"use" forState:UIControlStateNormal];
        _userButton.backgroundColor = [UIColor whiteColor];
        _userButton.layer.borderWidth = 1;
        _userButton.layer.borderColor = COLOR_WITH_16BAND_RGB(0x5d0e86).CGColor;
        _userButton.frame = CGRectMake((self.frame.size.width - DESGIN_TRANSFORM_3X(80)) * 0.5, self.frame.size.width + DESGIN_TRANSFORM_3X(5), DESGIN_TRANSFORM_3X(80), DESGIN_TRANSFORM_3X(20));
        _userButton.layer.cornerRadius = DESGIN_TRANSFORM_3X(10);
        _userButton.layer.masksToBounds = YES;
        _userButton.hidden = YES;
        [self addSubview:_userButton];

        _maskView = [[UIView alloc] init];
        [self addSubview:_maskView];
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self);
            make.width.height.equalTo(@(self.frame.size.width));
        }];

        self.label = [[UILabel alloc] init];
        self.label.textColor = COLOR_WITH_16BAND_RGB(0x434343);
        self.label.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(12)];
        self.label.text = @"Auditing";
        [_maskView addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_maskView);
        }];

        self.loader = [LSImageViewLoader loader];
    }

    return self;
}

+ (NSString *)cellIdentifier {
    return @"SelectCoverViewCell";
}

- (void)setRow:(NSInteger)row {
    _row = row;
    _deleteBtn.tag = row;
}

//  按钮正在使用状态
- (void)imageisUsingCover {

    self.userButton.userInteractionEnabled = NO;
    [_userButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_userButton setTitle:@"using" forState:UIControlStateNormal];
    _userButton.backgroundColor = COLOR_WITH_16BAND_RGB(0x5d0e86);
}

//  按钮未使用状态
- (void)imageisnoUseCover {

    self.userButton.userInteractionEnabled = YES;
    [_userButton setTitleColor:COLOR_WITH_16BAND_RGB(0x5d0e86) forState:UIControlStateNormal];
    [_userButton setTitle:@"use" forState:UIControlStateNormal];
    _userButton.backgroundColor = [UIColor whiteColor];
}

- (void)setCellCoverImage:(CoverPhotoItemObject *)object {

    //    NSString *imageId = object.photoId;
    NSString *imageUrl = object.photoUrl;
    NSInteger statu = object.status;
    BOOL isUse = object.in_use;

    if (statu == 2 && !isUse) {

        self.deleteBtn.hidden = NO;

    } else {
        self.deleteBtn.hidden = YES;
    }

    if (statu == 1) {
        self.userButton.hidden = YES;
        self.maskView.hidden = NO;
        self.label.hidden = NO;

    } else {
        self.userButton.hidden = NO;
        self.maskView.hidden = YES;
        self.label.hidden = YES;
    }

    if (isUse) {
        self.userButton.hidden = NO;
        [self imageisUsingCover];

    } else {

        if (statu == 2) {
            self.userButton.hidden = NO;
            [self imageisnoUseCover];

        } else {
            self.userButton.hidden = YES;
        }
    }

    [self.loader loadImageWithImageView:self.imageView options:0 imageUrl:imageUrl placeholderImage:nil];
}

- (UIView *)snapshotView {
    UIView *snapshotView = [[UIView alloc] init];

    UIView *cellSnapshotView = nil;

    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]) {
        cellSnapshotView = [self snapshotViewAfterScreenUpdates:NO];
    } else {
        CGSize size = CGSizeMake(self.bounds.size.width + 20, self.bounds.size.height + 20);
        UIGraphicsBeginImageContextWithOptions(size, self.opaque, 0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *cellSnapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cellSnapshotView = [[UIImageView alloc] initWithImage:cellSnapshotImage];
    }

    snapshotView.frame = CGRectMake(0, 0, cellSnapshotView.frame.size.width, cellSnapshotView.frame.size.height);
    cellSnapshotView.frame = CGRectMake(0, 0, cellSnapshotView.frame.size.width, cellSnapshotView.frame.size.height);

    [snapshotView addSubview:cellSnapshotView];
    return snapshotView;
}

@end
