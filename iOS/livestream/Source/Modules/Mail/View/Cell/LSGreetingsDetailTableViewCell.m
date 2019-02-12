//
//  LSGreetingsDetailTableViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/12/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGreetingsDetailTableViewCell.h"
#import "LSImageViewLoader.h"

@interface LSGreetingsDetailTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *backGroundView;

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@property (weak, nonatomic) IBOutlet UIImageView *playImageView;

@property (weak, nonatomic) IBOutlet UIImageView *placeholderImageView;

@end

@implementation LSGreetingsDetailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if( self ) {
        // Initialization code
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:@"LSGreetingsDetailTableViewCell" owner:nil options:nil];
        self = [nib objectAtIndex:0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSGreetingsDetailTableViewCell *cell = (LSGreetingsDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSGreetingsDetailTableViewCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSGreetingsDetailTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)setupGreetingContent:(LSMailAttachmentModel *)obj tableView:(UITableView *)tableView {
    NSString *url = @"";
    if (obj.attachType == AttachmentTypeFreePhoto) {
        self.backGroundView.backgroundColor = COLOR_WITH_16BAND_RGB(0xd8d8d8);
        self.playImageView.hidden = YES;
        self.placeholderImageView.hidden = NO;
        url = obj.originImgUrl;
    } else if (obj.attachType == AttachmentTypeGreetingVideo) {
        self.backGroundView.backgroundColor = COLOR_WITH_16BAND_RGB(0x383838);
        self.playImageView.hidden = NO;
        self.placeholderImageView.hidden = YES;
        url = obj.videoCoverUrl;
    }
    
    if (url.length > 0) {
        [[LSImageViewLoader loader] sdWebImageLoadView:self.contentImageView options:0 imageUrl:url placeholderImage:nil finishHandler:^(UIImage *image) {
            WeakObject(self, weakSelf);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    if (!weakSelf.placeholderImageView.hidden) {
                        weakSelf.placeholderImageView.hidden = YES;
                    }
                    CGFloat height = (tableView.frame.size.width * image.size.height) / image.size.width + 10;
                    
                    if ([weakSelf.delegate respondsToSelector:@selector(greetingsDetailCellLoadImageSuccess:model:)]) {
                        [weakSelf.delegate greetingsDetailCellLoadImageSuccess:height model:obj];
                    }
                }
            });
        }];
    }
}

+ (NSString *)cellIdentifier {
    return @"LSGreetingsDetailIdentifier";
}


@end
