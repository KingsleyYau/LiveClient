//
//  LSMailDetailFreePhotoCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/12/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSMailDetailFreePhotoCell.h"
#import "LSImageViewLoader.h"

@interface LSMailDetailFreePhotoCell()

@property (weak, nonatomic) IBOutlet UIImageView *contentImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;

@property (strong, nonatomic) LSMailAttachmentModel *model;

@end

@implementation LSMailDetailFreePhotoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if( self ) {
        // Initialization code
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:@"LSMailDetailFreePhotoCell" owner:nil options:nil];
        self = [nib objectAtIndex:0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.model = [[LSMailAttachmentModel alloc] init];
    }
    return self;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSMailDetailFreePhotoCell *cell = (LSMailDetailFreePhotoCell *)[tableView dequeueReusableCellWithIdentifier:[LSMailDetailFreePhotoCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSMailDetailFreePhotoCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)setupImageDetail:(LSMailAttachmentModel *)item {
    self.model = item;
    UIImage *placeholderImage = [self createImageWithColor:COLOR_WITH_16BAND_RGB(0xd8d8d8)];
    [[LSImageViewLoader loader] loadImageWithImageView:self.contentImage options:0 imageUrl:item.smallImgUrl placeholderImage:placeholderImage];
}

- (UIImage*)createImageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (IBAction)clickImageAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(freePhotoDidClick:)]) {
        [self.delegate freePhotoDidClick:self.model];
    }
}

+ (NSString *)cellIdentifier {
    return @"LSMailDetailFreePhotoCell";
}


@end
