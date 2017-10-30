//
//  LiveGuideViewController.m
//  dating
//
//  Created by test on 2017/10/10.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSLiveGuideViewController.h"
#import "LiveModule.h"


@interface LSLiveGuideViewController ()<UIScrollViewDelegate>

@end

@implementation LSLiveGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    switch (self.guideType) {
        case 1:{
            self.guideListArray = [NSArray arrayWithObjects:@"LiveGuide_Fee",@"LiveGuide_Fee_1",@"LiveGuide_Fee_2",@"LiveGuide_All_4", nil];
        }break;
        case 2:{
             self.guideListArray = [NSArray arrayWithObjects:@"LiveGuide_All",@"LiveGuide_All_1",@"LiveGuide_All_2",@"LiveGuide_All_3",@"LiveGuide_All_4", nil];
        }break;

            
        default:
            break;
    }
    

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
   
 
}

- (void)setupContainView {
    [super setupContainView];

    [self setupScrollView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //testData
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
    

    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offsetofScrollView = scrollView.contentOffset;
    [scrollView setContentOffset:offsetofScrollView];
}

#pragma mark - 点击按钮事件
- (IBAction)startAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];


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
                guideView.contentMode = UIViewContentModeScaleAspectFit;
                
                [self.guideScrollView addSubview:guideView];
            }
        }
        
        [self.guideScrollView setContentOffset:CGPointMake(self.guideScrollView.frame.size.width * self.guideIndex, 0) animated:NO];
    }
}

- (void)closeGuide:(UIGestureRecognizer *)gesture {
            LSNavigationController *nvc = (LSNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController* vc = [LiveModule module].moduleVC;
     [nvc pushViewController:vc animated:YES gesture:NO];
//    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)scrollToNext:(UITapGestureRecognizer *)geture {
    NSInteger index = geture.view.tag;
    CGPoint offset = CGPointMake(SCREEN_WIDTH * index, 0);
    [self.guideScrollView setContentOffset:offset animated:YES];
}
@end
