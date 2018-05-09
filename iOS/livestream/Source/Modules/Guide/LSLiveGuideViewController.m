//
//  LiveGuideViewController.m
//  dating
//
//  Created by test on 2017/10/10.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSLiveGuideViewController.h"
#import "LiveModule.h"
#import "LSLoginManager.h"
#import "LSConfigManager.h"
#import "LiveWebViewController.h"



@interface LSLiveGuideViewController ()<UIScrollViewDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *tipInfo;


@end

@implementation LSLiveGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tipInfo.delegate = self;
    self.tipInfo.editable = NO;
    self.tipInfo.dataDetectorTypes = UIDataDetectorTypeLink;
    [self.tipInfo textContainer].lineBreakMode = NSLineBreakByWordWrapping;
    self.tipInfo.delaysContentTouches = YES;
    self.tipInfo.textColor = [UIColor whiteColor];
    self.tipInfo.hidden = YES;
   
    NSString *tips = NSLocalizedString(@"POLICY",@"POLICY");
    NSString *linkTips = NSLocalizedString(@"LINK_POLICY",@"LINK_POLICY");
    
    self.tipInfo.attributedText = [self AllString:tips ChangeString:linkTips ChangeStrColor:[UIColor whiteColor] StrStyle:NSUnderlineStyleSingle font:[UIFont systemFontOfSize:12]];
    self.tipInfo.linkTextAttributes = @{NSForegroundColorAttributeName :[UIColor whiteColor]};
    switch ([LSLoginManager manager].loginItem.userType) {
        case USERTYPEA1:{
            // A1会员
            if (self.listGuide) {
                self.guideListArray = [NSArray arrayWithObjects:@"LiveGuide_List_Fee",@"LiveGuide_List_All_1",@"LiveGuide_List_All_2",@"LiveGuide_List_All_3", nil];
            }else {
                self.guideListArray = [NSArray arrayWithObjects:@"LiveGuide_Person_Fee",@"LiveGuide_Person_All_1",@"LiveGuide_Person_All_2",@"LiveGuide_Person_All_3", nil];

            }
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }break;
        case USERTYPEA2:{
            // A2会员
            if (self.listGuide) {
                self.guideListArray = [NSArray arrayWithObjects:@"LiveGuide_List_All",@"LiveGuide_List_All_1",@"LiveGuide_List_All_2",@"LiveGuide_List_All_3", nil];

            }else {
                self.guideListArray = [NSArray arrayWithObjects:@"LiveGuide_Person_All",@"LiveGuide_Person_All_1",@"LiveGuide_Person_All_2",@"LiveGuide_Person_All_3", nil];

            }
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }break;
            
            
        default:
            break;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏状态栏在隐藏导航栏之前,放在之后可能会导致计算位置少了状态栏的高度
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];

}

- (void)setupContainView {
    [super setupContainView];
    [self setupScrollView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadData:YES dataArray:self.guideListArray];
}

- (void)setupScrollView {
    self.guideScrollView.delegate = self;
    self.guideScrollView.pagingEnabled = YES;
    self.guideScrollView.showsVerticalScrollIndicator = NO;
    self.guideScrollView.showsHorizontalScrollIndicator = NO;
    
    self.startBtn.backgroundColor = [UIColor clearColor];
    self.startBtn.contentEdgeInsets = UIEdgeInsetsMake(6, 20, 8, 20);
    [self.startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.startBtn.layer.borderWidth = 1;
    self.startBtn.layer.cornerRadius = 5.0f;
    self.startBtn.layer.masksToBounds = YES;
    self.startBtn.alpha = 0;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int pageNum =(int)(scrollView.contentOffset.x / scrollView.frame.size.width + 0.5);
    self.pageControl.currentPage = pageNum;
    self.guideIndex = pageNum;
    if (pageNum == self.pageControl.numberOfPages - 1) {
        self.tipInfo.hidden = NO;
    }else {
        self.tipInfo.hidden = YES;
    }
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offsetofScrollView = scrollView.contentOffset;
    [scrollView setContentOffset:offsetofScrollView];
}

#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView dataArray:(NSArray *)array{
    if( isReloadView ) {
        // 刷新指示器
        self.pageControl.numberOfPages = array.count;
        
        // 引导页
        self.guideScrollView.contentSize =  CGSizeMake(array.count * screenSize.width, 0);
        
        if (array.count > 0) {
            for (int i = 0; i < array.count; i++) {
                CGRect frame = CGRectMake(screenSize.width * i, 0, screenSize.width, screenSize.height);
                
                UIImageView *guideView = [[UIImageView alloc] initWithFrame:frame];
                guideView.image = [UIImage imageNamed:array[i]];
                guideView.userInteractionEnabled = YES;
                if (i == array.count - 1) {
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeGuide:)];
                    [guideView addGestureRecognizer:tap];
                }else {
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToNext:)];
                    
                    [guideView addGestureRecognizer:tap];
                    tap.view.tag = i + 1;
                }
                guideView.contentMode = UIViewContentModeScaleToFill;
                guideView.clipsToBounds = YES;
                
                [self.guideScrollView addSubview:guideView];
            }
        }
        
        [self.guideScrollView setContentOffset:CGPointMake(self.guideScrollView.frame.size.width * self.guideIndex, 0) animated:NO];
    }
}

- (void)closeGuide:(UIGestureRecognizer *)gesture {
    if ([self.guideDelegate respondsToSelector:@selector(lsLiveGuideViewControllerDidFinishGuide:)]) {
        [self.guideDelegate lsLiveGuideViewControllerDidFinishGuide:self];
    }
}


- (void)scrollToNext:(UITapGestureRecognizer *)geture {
    NSInteger index = geture.view.tag;
    CGPoint offset = CGPointMake(SCREEN_WIDTH * index, 0);
    [self.guideScrollView setContentOffset:offset animated:YES];
}



- (NSMutableAttributedString *)AllString:(NSString *)allStr ChangeString:(NSString *)changeStr ChangeStrColor:(UIColor *)changeStrColor StrStyle:(NSInteger)style font:(UIFont* )font{
    
    NSString *str = [NSString stringWithFormat:@"%@", allStr];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:str]; 
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    paragraphStyle.lineSpacing = 0;
    NSRange allRange = [str rangeOfString:allStr];
    NSRange urlRange = [str rangeOfString:changeStr];
    // 修改整体字体的颜色
    [string addAttribute:NSForegroundColorAttributeName
                   value:[UIColor whiteColor]
                   range:allRange];
    // 添加指定位置的下划线
    [string addAttribute:NSUnderlineStyleAttributeName
                   value:@(style)
                   range:urlRange];
    // 添加链接跳转
    [string addAttribute:NSLinkAttributeName
                   value:changeStr
                   range:urlRange];
    // 添加链接跳转文字颜色
    [string addAttribute:NSForegroundColorAttributeName
                   value:changeStrColor
                   range:urlRange];

    
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.length)];
    [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.length)];
    [string endEditing];
    
    
    
    return string;
    
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 跳转用户
        NSString *url = [LSConfigManager manager].item.userProtocol;
        
        LiveWebViewController *webViewController = [[LiveWebViewController alloc] init];
        webViewController.url = url;
        self.navigationController.navigationBar.hidden = NO;
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController pushViewController:webViewController animated:YES];
        
    });
    return YES;
}



@end
