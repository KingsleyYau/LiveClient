//
//  LSSendMailPhotoCell.m
//  livestream
//
//  Created by Calvin on 2018/12/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSSendMailPhotoCell.h"

@implementation LSSendMailPhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.photoImage.contentMode = UIViewContentModeScaleAspectFill;
    self.photoImage.autoresizingMask = UIViewAutoresizingNone;
    self.photoImage.clipsToBounds = YES;
}

- (void)updateMailPhotoStatus:(LSMailFileItem *)item {
    
    if (item.type == FileType_Add) {
        self.loadingView.hidden = YES;
        self.photoImage.hidden = YES;
        self.removeBtn.hidden = YES;
        self.errorView.hidden = YES;
        self.addView.hidden = NO;
    }
    else {
        self.addView.hidden = YES;
        self.photoImage.hidden = NO;
        self.removeBtn.hidden = NO;
        self.photoImage.image = item.image;
        if (item.uploadStatus == UploadStatus_uploading) {
            self.loadingView.hidden = NO;
            [self.loading startAnimating];
            self.errorView.hidden = YES;
        }
        else if (item.uploadStatus == UploadStatus_error){
            self.loadingView.hidden = YES;
            self.errorView.hidden = NO;
        }
        else {
            self.loadingView.hidden = YES;
            self.errorView.hidden = YES;
        }
    }
}

+ (NSString *)cellIdentifier {
    return @"LSSendMailPhotoCell";
}
@end
