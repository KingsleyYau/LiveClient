//
//  LSOutBoxViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/12/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSOutBoxViewController.h"
#import "LSMailAttachmentViewController.h"
#import "LSGetEmfDetailRequest.h"
#import "IntroduceView.h"
#import "LSDateTool.h"
#import "LSImageViewLoader.h"
#import "LSSessionRequestManager.h"
#import "LSMailAttachmentModel.h"
#import "LSMailCellHeightItem.h"
#import "LSMailAttachmentsCollectionView.h"
#import "DialogTip.h"
#define NavNormalHeight 64
#define NavIphoneXHeight 88
@interface LSOutBoxViewController () <WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, LSMailAttachmentsCollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *nodataView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *onlineImageView;
@property (nonatomic, strong) UILabel *navTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet IntroduceView *wkWebView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;

@property (weak, nonatomic) IBOutlet UILabel *sendTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *attachmentsTip;

@property (weak, nonatomic) IBOutlet LSMailAttachmentsCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;

// 数据源
@property (strong, nonatomic) NSMutableArray<LSMailAttachmentModel *> *items;
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topDistance;

@end

@implementation LSOutBoxViewController

- (void)dealloc {
    NSLog(@"LSOutBoxViewController::dealloc()");
}

- (void)initCustomParam {
    [super initCustomParam];

    self.isShowNavBar = NO;

    self.items = [[NSMutableArray alloc] init];
    self.sessionManager = [[LSSessionRequestManager alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.wkWebView.UIDelegate = self;
    self.wkWebView.navigationDelegate = self;
    self.scrollView.delegate = self;
    self.collectionView.collectionViewDelegate = self;

    self.wkWebView.scrollView.scrollEnabled = NO;

    //    [self.navigationController.navigationBar setHidden:NO];
    //    self.navigationController.navigationBarHidden = NO;

    [self setupNavTitle];

    [self setupCornerRadius];

    // 头像
    [[LSImageViewLoader loader] loadImageFromCache:self.headImageView
                                           options:SDWebImageRefreshCached
                                          imageUrl:self.letterItem.anchorAvatar
                                  placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]
                                     finishHandler:^(UIImage *image){
                                     }];
    // 姓名
    self.nameLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"TO_NAME"), self.letterItem.anchorNickName];
    // 发信时间信件ID
    LSDateTool *tool = [[LSDateTool alloc] init];
    NSString *time = [tool showGreetingDetailTimeOfDate:[NSDate dateWithTimeIntervalSince1970:self.letterItem.letterSendTime]];
    self.sendTimeLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"MAIL_ID"), time, self.letterItem.letterId];

//    if (IS_IPHONE_X) {
//        self.topDistance.constant = -NavIphoneXHeight;
//    }
//    else {
//        self.topDistance.constant = -NavNormalHeight;
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 11, *)) {
        // translucent为yes防止在ios11系统上,透明会失效
        self.navigationController.navigationBar.translucent = YES;
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.navigationController.navigationBar.translucent = NO;
    }

    if (self.letterItem.letterId.length > 0 && !self.viewDidAppearEver) {
        [self getMailDetail:self.letterItem.letterId];
    }

    // 透明度不生效,重新设置当前透明度
    [self setupAlphaStatus:self.scrollView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navTitleLabel.text = NSLocalizedStringFromSelf(@"Mail_Viewer");
    // 透明度不生效,重新设置当前透明度
    self.navigationController.navigationBar.hidden = NO;
    [self setupAlphaStatus:self.scrollView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setupNavTitle {
    self.navTitleLabel = [[UILabel alloc] init];
    CGRect frame = self.navTitleLabel.frame;
    frame.size = CGSizeMake(100, 44);
    self.navTitleLabel.frame = frame;
    self.navTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.navTitleLabel.font = [UIFont systemFontOfSize:19];
    self.navigationItem.titleView = self.navTitleLabel;

    UIButton *navLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [navLeftBtn addTarget:self action:@selector(backToAction:) forControlEvents:UIControlEventTouchUpInside];
    [navLeftBtn setImage:[UIImage imageNamed:@"LS_Nav_Back_b"] forState:UIControlStateNormal];
    navLeftBtn.frame = CGRectMake(0, 0, 30, 44);
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftBtn];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
}

- (void)backToAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupCornerRadius {
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    self.headImageView.layer.borderWidth = 1;
    self.headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headImageView.layer.masksToBounds = YES;

    self.onlineImageView.layer.cornerRadius = self.onlineImageView.frame.size.height / 2;
    self.onlineImageView.layer.borderWidth = 2;
    self.onlineImageView.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self setupAlphaStatus:scrollView];
}

#pragma mark - 图片点击事件
- (void)mailAttachmentsCollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LSMailAttachmentViewController *vc = [[LSMailAttachmentViewController alloc] initWithNibName:nil bundle:nil];
    vc.attachmentsArray = self.items;
    vc.photoIndex = indexPath.row;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [nvc.navigationBar setTranslucent:self.navigationController.navigationBar.translucent];
    [nvc.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
    [nvc.navigationBar setBarTintColor:self.navigationController.navigationBar.barTintColor];
    [self presentViewController:nvc
                       animated:NO
                     completion:nil];
}

#pragma mark - 显示意向信文本内容
- (void)loadMailContentWebView:(NSString *)contentStr {
    NSString *path = [[LiveBundle mainBundle] pathForResource:@"Mail_Content" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    NSRange startRange = [html rangeOfString:@"<div class=\"content\">"];
    NSRange endRange = [html rangeOfString:@"</div>"];
    NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    NSString *result = [html substringWithRange:range];
    NSString *tempContent = [html stringByReplacingOccurrencesOfString:result withString:contentStr];

    NSURL *url = [[LiveBundle mainBundle] URLForResource:@"Mail_Content.html" withExtension:nil];
    [self.wkWebView loadHTMLString:tempContent baseURL:url];
}

#pragma mark - HTTP请求
- (void)getMailDetail:(NSString *)mailId {
    [self showAndResetLoading];
    LSGetEmfDetailRequest *request = [[LSGetEmfDetailRequest alloc] init];
    request.emfId = mailId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSHttpLetterDetailItemObject *item) {
        NSLog(@"LSMailDetailViewController::getMailDeatail (请求信件详情 success : %@, errnum : %d, errmsg : %@, letterId : %@)", BOOL2SUCCESS(success), errnum, errmsg, item.letterId);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAndResetLoading];
            if (success) {
                [self setupMailDetail:item];
            } else {
                [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)setupMailDetail:(LSHttpLetterDetailItemObject *)item {
    self.nodataView.hidden = YES;

    [self.items removeAllObjects];

    // 在线状态
    if (item.onlineStatus) {
        self.onlineImageView.hidden = NO;
    } else {
        self.onlineImageView.hidden = YES;
    }
    // 信件内容
    NSString *contentStr = [item.letterContent stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    [self loadMailContentWebView:contentStr];

    if (item.letterImgList.count > 0) {
        CGFloat itemSize = (screenSize.width - 42) / 3;
        if (item.letterImgList.count > 3) {
            self.collectionViewHeight.constant = itemSize * 2 + 40;
        } else if (item.letterImgList.count >= 1) {
            self.collectionViewHeight.constant = itemSize + 20;
        }

        for (LSHttpLetterImgItemObject *obj in item.letterImgList) {
            LSMailAttachmentModel *model = [[LSMailAttachmentModel alloc] init];
            model.attachType = AttachmentTypeFreePhoto;
            model.mailId = item.letterId;
            model.originImgUrl = obj.originImg;
            model.smallImgUrl = obj.smallImg;
            model.blurImgUrl = obj.blurImg;
            [self.items addObject:model];
        }
        self.collectionView.items = self.items;
        [self.collectionView reloadData];
    } else {
        self.attachmentsTip.hidden = YES;
        self.collectionViewHeight.constant = 0;
    }
}

#pragma mark - WKWebViewDelegate
// 加载完webview (当main frame导航完成时，会回调)
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"LSMailDetailViewController::didFinishNavigation()");
    WeakObject(self, weakSelf);
    [webView evaluateJavaScript:@"document.body.offsetHeight;"
              completionHandler:^(id _Nullable height, NSError *_Nullable error) {
                  NSString *heightStr = [NSString stringWithFormat:@"%@", height];
                  weakSelf.contentViewHeight.constant = heightStr.floatValue;
              }];
}

// 设置透明状态
- (void)setupAlphaStatus:(UIScrollView *)scrollView {
    CGFloat navHeight = NavNormalHeight;

    if (IS_IPHONE_X) {
        navHeight = NavIphoneXHeight;
    }

    CGFloat per = scrollView.contentOffset.y / navHeight;
    if (scrollView.contentOffset.y >= navHeight) {
        [self setNeedsNavigationBackground:1];
    } else {
        [self setNeedsNavigationBackground:per];
    }
}

- (void)setNeedsNavigationBackground:(CGFloat)alpha {
    // 导航栏背景透明度设置

    NSArray *views = [self.navigationController.navigationBar subviews];
    UIView *barBackgroundView = [views objectAtIndex:0];
    UIImageView *backgroundImageView = [[barBackgroundView subviews] objectAtIndex:0];
    BOOL result = self.navigationController.navigationBar.isTranslucent;
    NSLog(@"navigationBar.isTranslucent %@  barBackgroundView %@", BOOL2SUCCESS(result), [barBackgroundView subviews]);
    if (result) {
        if (backgroundImageView != nil && backgroundImageView.image != nil) {
            barBackgroundView.alpha = alpha;
        } else {
            NSArray *subViews = [barBackgroundView subviews];
            if (subViews.count > 1) {
                UIView *backgroundEffectView = [subViews objectAtIndex:1];
                if (backgroundEffectView != nil) {
                    backgroundEffectView.alpha = alpha;
                }
            }else {
                barBackgroundView.alpha = alpha;
            }
        }
    } else {
        barBackgroundView.alpha = alpha;
    }
    self.navTitleLabel.alpha = alpha;
}

@end
