//
//  LSSayHiThemeListViewController.m
//  livestream
//
//  Created by Randy_Fan on 2019/4/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiThemeListViewController.h"

#import "LSSayHiThemeListCollectionViewCell.h"
#import "LSSayHiTextListTableViewCell.h"

#import "LSSelectThemeView.h"
#import "LSSelectWordView.h"

#import <YYText.h>

@interface LSSayHiThemeListViewController ()<LSPZPagingScrollViewDelegate, LSSelectWordViewDelegate, LSSelectThemeViewDelegate, JTSegmentControlDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet LSPZPagingScrollView *pagingScrollView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIView *segmentView;

@property (weak, nonatomic) IBOutlet UIView *buttonView;

@property (strong, nonatomic) NSMutableArray <LSSayHiThemeItemObject *>*themeList;

@property (strong, nonatomic) NSMutableArray <LSSayHiTextListItem *>*textList;

@property (strong, nonatomic) NSMutableArray *views;

@property (strong, nonatomic) LSSayHiManager *sayhiManager;

@property (nonatomic, strong) JTSegmentControl *segment;

@property (nonatomic, strong) NSArray<JTSegmentItem *> *sliderArray;

@property (nonatomic, assign) NSInteger curIndex;

@end

@implementation LSSayHiThemeListViewController

- (void)dealloc {
    
}

- (void)initCustomParam {
    [super initCustomParam];
    
    self.curIndex = -1;
    
    self.sayhiManager = [LSSayHiManager manager];
    
    self.themeList = [[NSMutableArray alloc] init];
    self.textList = [[NSMutableArray alloc] init];
    
    self.views = [[NSMutableArray alloc] init];
    
    self.sliderArray = [[NSArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pagingScrollView.pagingViewDelegate = self;
    self.pagingScrollView.bounces = NO;
    self.pagingScrollView.scrollEnabled = NO;
    
    [self setupSegment];
    
    LSSelectThemeView *themeView = [[LSSelectThemeView alloc] initWithFrame:self.pagingScrollView.frame];
    themeView.delegate = self;
    LSSelectWordView *wordView = [[LSSelectWordView alloc] initWithFrame:self.pagingScrollView.frame];
    wordView.delegate = self;
    [self.views addObject:themeView];
    [self.views addObject:wordView];
    
    self.bottomView.layer.shadowOffset = CGSizeMake(0, -3);
    self.bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bottomView.layer.shadowOpacity = 0.2;
    self.bottomView.layer.shadowRadius = 3;
}

- (void)setupSegment {
    self.segmentView.hidden = YES;
    // TODO:初始化分栏控件
    self.segment = [[JTSegmentControl alloc] init];
    self.segment.backgroundColor = [UIColor clearColor];
    self.segment.sliderViewColor = [UIColor clearColor];
    self.segment.font = [UIFont systemFontOfSize:14];
    self.segment.selectedFont = [UIFont boldSystemFontOfSize:14];
    self.segment.itemTextColor = COLOR_WITH_16BAND_RGB(0x297af3);
    self.segment.itemSelectedTextColor = COLOR_WITH_16BAND_RGB(0x383838);
    self.segment.itemBackgroundColor = COLOR_WITH_16BAND_RGB(0xddf5ff);
    self.segment.itemSelectedBackgroundColor = COLOR_WITH_16BAND_RGB(0xffffff);
    
    self.segment.bounces = NO;
    self.segment.autoAdjustWidth = NO;
    self.segment.delegate = self;
    
    [self.segmentView addSubview:self.segment];
    [self.segment mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.segmentView);
    }];
    
    NSMutableArray<JTSegmentItem *> *array = [NSMutableArray array];
    JTSegmentItem *item = nil;
    item = [[JTSegmentItem alloc] initWithImage:[UIImage imageNamed:@"Select_Theme_Normal"] selectedImage:[UIImage imageNamed:@"Select_Theme_Selected"] title:NSLocalizedStringFromSelf(@"SELECT_THEME")];
    [array addObject:item];
    item = [[JTSegmentItem alloc] initWithImage:[UIImage imageNamed:@"Select_Note_Normal"] selectedImage:[UIImage imageNamed:@"Select_Note_Selected"] title:NSLocalizedStringFromSelf(@"SELECT_NOTE")];
    [array addObject:item];
    self.sliderArray = array;
}

- (void)reloadSegment {
    [self.segment layoutIfNeeded];
    self.segment.items = self.sliderArray;
    [self.segment setupViewOpen];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadSegment];
    
    [self reloadData];
}

- (void)reloadData {
    [self.themeList removeAllObjects];
    [self.textList removeAllObjects];
    if (self.sayhiManager.sayHiTextList.count > 0 && self.sayhiManager.sayHiThemeList.count > 0) {
        NSInteger selectIndex = -1;
        for (NSInteger index = 0; index < self.sayhiManager.sayHiThemeList.count; index++) {
            LSSayHiThemeItemObject *obj = self.sayhiManager.sayHiThemeList[index];
            [self.themeList addObject:obj];
            if (self.sayhiManager.item && self.sayhiManager.item.themeId == obj.themeId) {
                selectIndex = index;
            }
        }
        LSSelectThemeView *themeView = self.views[0];
        [themeView loadThemeCollection:self.themeList selectIndex:selectIndex];
        
        selectIndex = -1;
        for (NSInteger index = 0; index < self.sayhiManager.sayHiTextList.count; index++) {
            LSSayHiTextItemObject *obj = self.sayhiManager.sayHiTextList[index];
            LSSayHiTextListItem *item = [[LSSayHiTextListItem alloc] init];
            item.textItem = obj;
            item.cellHeight = [self computeContainerHeight:obj.text];
            [self.textList addObject:item];
            if (self.sayhiManager.item && self.sayhiManager.item.textId == obj.textId) {
                selectIndex = index;
            }
        }
        LSSelectWordView *wordView = self.views[1];
        [wordView loadWordTableView:self.textList selectIndex:selectIndex];
        
    } else {
        [self.sayhiManager getSayHiConfig:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiResourceConfigItemObject *item) {
            if (success) {
                if (item.themeList.count > 0) {
                    self.sayhiManager.sayHiThemeList = item.themeList;
                    NSInteger selectIndex = -1;
                    for (NSInteger index = 0; index < item.themeList.count; index++) {
                        LSSayHiThemeItemObject *obj = item.themeList[index];
                        [self.themeList addObject:obj];
                        if (self.sayhiManager.item && self.sayhiManager.item.themeId == obj.themeId) {
                            selectIndex = index;
                        }
                    }
                    LSSelectThemeView *view = self.views[0];
                    [view loadThemeCollection:self.themeList selectIndex:selectIndex];
                }
                
                if (item.textList.count > 0) {
                    self.sayhiManager.sayHiThemeList = item.textList;
                    NSInteger selectIndex = -1;
                    for (NSInteger index = 0; index < item.textList.count; index++) {
                        LSSayHiTextItemObject *obj = item.textList[index];
                        LSSayHiTextListItem *item = [[LSSayHiTextListItem alloc] init];
                        item.textItem = obj;
                        item.cellHeight = [self computeContainerHeight:obj.text];
                        [self.textList addObject:item];
                        if (self.sayhiManager.item && self.sayhiManager.item.textId == obj.textId) {
                            selectIndex = index;
                        }
                    }
                    LSSelectWordView *view = self.views[1];
                    [view loadWordTableView:self.textList selectIndex:selectIndex];
                }
                
            } else {
                
            }
        }];
    }
}

- (CGFloat)computeContainerHeight:(NSString *)string {
    CGFloat height = 0;
    CGFloat width = SCREEN_WIDTH - 70;
    YYTextContainer *container = [[YYTextContainer alloc] init];
    container.size = CGSizeMake(width, CGFLOAT_MAX);
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attributeStr addAttributes:@{
                                     NSFontAttributeName : [UIFont systemFontOfSize:15],
                                     }
                             range:NSMakeRange(0, attributeStr.length)];
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:attributeStr];
    height = layout.textBoundingSize.height + 35;
    return height;
}

- (void)showButtonViewOrSegmentView:(BOOL)isShow {
    self.buttonView.hidden = isShow;
    self.segmentView.hidden = !isShow;
}

#pragma mark - JTSegmentControlDelegate
- (void)didSelectedWithSegement:(JTSegmentControl *_Nonnull)segement index:(NSInteger)index {
    if (self.curIndex != index) {
        self.curIndex = index;
        // 刷新分页
        [self.pagingScrollView displayPagingViewAtIndex:index animated:YES];
    }
}

- (void)changeSegementSelect:(NSInteger)index {
    [self.segment setSelectedIndex:index];
    [self.segment moveTo:index];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - LSPZPagingScrollViewDelegate
- (Class)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    return [UIView class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(LSPZPagingScrollView *)pagingScrollView {
    return self.views.count;
}

- (UIView *)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pagingScrollView.frame.size.width, pagingScrollView.frame.size.width)];
    return view;
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    
    UIView *view = [self.views objectAtIndex:index];
    
    [pageView removeAllSubviews];
    
    [pageView addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pageView);
        make.left.equalTo(pageView);
        make.width.equalTo(pageView);
        make.bottom.equalTo(pageView);
    }];
    // 使约束生效
    [view layoutSubviews];
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    
}

#pragma mark - LSSelectWordViewDelegate
- (void)didSelectRowAtIndexPath:(LSSayHiTextListItem *)item {
    if ([self.delegate respondsToSelector:@selector(didSelectWordWithItem:)]) {
        [self.delegate didSelectWordWithItem:item.textItem];
    }
}

#pragma mark - LSSelectThemeViewDelegate
- (void)didSelectItemAtIndexPath:(LSSayHiThemeItemObject *)item {
    if ([self.delegate respondsToSelector:@selector(didSelectThemeWithItem:)]) {
        [self.delegate didSelectThemeWithItem:item];
    }
}

#pragma mark - Action
- (IBAction)didSelectTheme:(id)sender {
    [self showButtonViewOrSegmentView:YES];
    if ([self.delegate respondsToSelector:@selector(didShowSelectThemeWord:index:)]) {
        [self.delegate didShowSelectThemeWord:self index:0];
    }
}

- (IBAction)didSelectWord:(id)sender {
    [self showButtonViewOrSegmentView:YES];
    if ([self.delegate respondsToSelector:@selector(didShowSelectThemeWord:index:)]) {
        [self.delegate didShowSelectThemeWord:self index:1];
    }
}

- (IBAction)submitAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSubmitSayHi)]) {
        [self.delegate didSubmitSayHi];
    }
}


@end
