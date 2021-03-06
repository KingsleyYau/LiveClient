//
//  LSMailPrivateVideoCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/12/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSMailPrivateVideoCell.h"
#import "LSImageViewLoader.h"

@interface LSMailPrivateVideoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;

@property (weak, nonatomic) IBOutlet UIButton *buyPlayBtn;

@property (weak, nonatomic) IBOutlet UIImageView *unlockImageView;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIImageView *playImageView;

@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (strong, nonatomic) LSMailAttachmentModel *model;
@property (strong, nonatomic) LSImageViewLoader *loader;

@end

@implementation LSMailPrivateVideoCell

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSMailPrivateVideoCell *cell = (LSMailPrivateVideoCell *)[tableView dequeueReusableCellWithIdentifier:[LSMailPrivateVideoCell cellIdentifier]];

    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSMailPrivateVideoCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.buyPlayBtn.layer.cornerRadius = cell.buyPlayBtn.frame.size.height / 2;
        cell.buyPlayBtn.layer.masksToBounds = YES;

        cell.model = [[LSMailAttachmentModel alloc] init];
        if (!cell.loader) {
            cell.loader = [LSImageViewLoader loader];
        }
    }
    return cell;
}

- (void)setupVideoDetail:(LSMailAttachmentModel *)model {
    self.model = model;
    switch (model.expenseType) {
        case ExpenseTypeNo: {
            self.lockImageView.hidden = NO;
            self.lockImageView.image = [UIImage imageNamed:@"EMF_Private_Lock"];
            self.buyPlayBtn.hidden = NO;
            self.tipLabel.hidden = YES;
            self.playImageView.hidden = YES;
            self.unlockImageView.hidden = YES;
        } break;

        case ExpenseTypeYes: {
            self.lockImageView.hidden = YES;
            self.buyPlayBtn.hidden = YES;
            self.tipLabel.hidden = YES;
            self.playImageView.hidden = NO;
            self.unlockImageView.hidden = NO;
        } break;

        default: {
            self.lockImageView.hidden = NO;
            self.lockImageView.image = [UIImage imageNamed:@"Mail_Private_Photo_Expired"];
            self.buyPlayBtn.hidden = YES;
            self.tipLabel.hidden = NO;
            self.playImageView.hidden = YES;
            self.unlockImageView.hidden = YES;
        } break;
    }

    UIImage *placeholderImage = [self createImageWithColor:COLOR_WITH_16BAND_RGB(0xd8d8d8)];
    [self.loader stop];
    [self.loader loadImageWithImageView:self.coverImageView options:0 imageUrl:model.videoCoverUrl placeholderImage:placeholderImage finishHandler:nil];

    self.descLabel.text = model.videoDesc;
}

- (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (IBAction)clickVideoAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(privateVideoDidClick:)]) {
        [self.delegate privateVideoDidClick:self.model];
    }
}

+ (NSString *)cellIdentifier {
    return @"LSMailPrivateVideoCell";
}

+ (CGFloat)cellHeight {
    return 317;
}

@end
