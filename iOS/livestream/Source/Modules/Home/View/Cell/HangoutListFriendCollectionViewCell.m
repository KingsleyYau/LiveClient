//
//  HangoutListFriendCollectionViewCell.m
//  livestream
//
//  Created by test on 2019/2/28.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "HangoutListFriendCollectionViewCell.h"
#import "HangoutGiftHighlightButton.h"

//@interface HangoutListFriendCollectionViewCell()<HangoutGiftHighlightButtonDelegate>
//@property (nonatomic, strong) HangoutGiftHighlightButton *highlightButton;
//@end


@implementation HangoutListFriendCollectionViewCell

+ (NSString *)cellIdentifier {
    return @"HangoutListFriendCollectionViewCell";
}

+ (NSInteger)cellWidth {
    return 66;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.imageViewLoader = [LSImageViewLoader loader];

        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 2;

//        self.highlightButton = [[HangoutGiftHighlightButton alloc] init];
//        self.highlightButton.delegate = self;
//        [self.highlightButton addTarget:self action:@selector(didClickHighlightButton) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    [self addSubview:self.highlightButton];
//    [self bringSubviewToFront:self.highlightButton];
//    [self.highlightButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self);
//    }];
}

//- (void)didClickHighlightButton {
//    if ([self.friendCellDelegate respondsToSelector:@selector(hangoutListFriendCollectionViewCell:didSelectIndex:)]) {
//        [self.friendCellDelegate hangoutListFriendCollectionViewCell:self didSelectIndex:self.highlightButton.tag];
//    }
//}

//- (void)HangoutGiftHighlightButtonIsHighlight {
//    self.layer.borderWidth = 2;
//    self.layer.borderColor = COLOR_WITH_16BAND_RGB(0xFF6D00).CGColor;
//}
//
//- (void)HangoutGiftHighlightButtonCancleHighlight {
//    self.layer.borderWidth = 2;
//    self.layer.borderColor = [UIColor clearColor].CGColor;
//}
//
//- (void)setHighlightButtonTag:(NSInteger)tag {
//    self.highlightButton.tag = tag;
//}
@end
