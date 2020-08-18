//
//  LSSlidingCell.m
//  calvinTest
//
//  Created by Calvin on 2018/10/17.
//  Copyright © 2018年 dating. All rights reserved.
//

#import "LSSlidingCell.h"

@interface LSSlidingCell ()<LSSlidingViewDelegate>
@property (nonatomic, strong) NSArray * moreArray;
@end

@implementation LSSlidingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.moreArray = [NSArray array];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UISwipeGestureRecognizer *swipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRGestureRecognizerDidPan:)];
    swipeR.delegate = self;
    [swipeR setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:swipeR];
    
    UISwipeGestureRecognizer *swipeL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLGestureRecognizerDidPan:)];
    swipeL.delegate = self;
    [swipeL setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:swipeL                                                                                                                                                                                                                                       ];
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.slidingView = [[LSSlidingView alloc]initWithFrame:CGRectMake(screenSize.width - 35, 0, 35, self.frame.size.height)];
        self.slidingView.backgroundColor = [UIColor whiteColor];
        self.slidingView.delegate = self;
        [self addSubview:self.slidingView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.slidingView = [[LSSlidingView alloc]initWithFrame:CGRectMake(screenSize.width - 35, 0, 35, frame.size.height)];
        self.slidingView.backgroundColor = [UIColor whiteColor];
        self.slidingView.delegate = self;
        [self addSubview:self.slidingView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier {
    return @"LSSlidingCell";
}

+ (NSInteger)cellHeight {
    return 72;
}

- (void)slidingViewBtnDidRow:(NSString *)row {
    
}

- (void)slidingViewMoreBtnDid {
    
    if (self.isShowMoreBtn) {
        [self hideMoreBtns];
    }else {
        [self showMoreBtns];
    }
}

- (void)showMoreView:(NSArray *)array {
    [self restMoreBtnView];
    self.moreArray = array;
    [self.slidingView setMoreBtns:array];
}
 
- (void)showMoreBtns {
    if (!self.isShowMoreBtn) {
        self.isShowMoreBtn = YES;
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect rect = self.slidingView.frame;
                             rect.origin.x = rect.origin.x - (self.moreArray.count * [LSSlidingCell cellHeight]);
                             self.slidingView.frame = rect;
                         }];
    }
}

- (void)hideMoreBtns {
    if (self.isShowMoreBtn) {
        self.isShowMoreBtn = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect rect = self.slidingView.frame;
                             rect.origin.x = rect.origin.x + (self.moreArray.count * [LSSlidingCell cellHeight]);
                             self.slidingView.frame = rect;
                         }];
    }
}

- (void)restMoreBtnView {
    self.isShowMoreBtn = NO;
    CGRect rect = self.slidingView.frame;
    rect.origin.x = screenSize.width - 35;
    self.slidingView.frame = rect;
}

- (void)showMoreBtnView {
    self.isShowMoreBtn = YES;
    CGRect rect = self.slidingView.frame;
    rect.origin.x = rect.origin.x - (self.moreArray.count * [LSSlidingCell cellHeight]);
    self.slidingView.frame = rect;
}

- (void)swipeRGestureRecognizerDidPan:(UISwipeGestureRecognizer *)recognizer {
    
    [self hideMoreBtns];
}

- (void)swipeLGestureRecognizerDidPan:(UISwipeGestureRecognizer *)recognizer {
    [self showMoreBtns];
}

@end
