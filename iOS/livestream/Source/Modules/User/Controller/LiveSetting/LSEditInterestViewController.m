//
//  EditInterestViewController.m
//  dating
//
//  Created by test on 2018/9/17.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSEditInterestViewController.h"
#import "LSSessionRequestManager.h"
#import "LSUpdateProfileRequest.h"
#import "DialogIconTips.h"
#import "DialogTip.h"

@interface LSEditInterestViewController ()<LSAllTagListCollectionViewDelegate>
/** 任务管理 */
@property (nonatomic,strong) LSDomainSessionRequestManager *sessionManager;
@end

@implementation LSEditInterestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedStringFromSelf(@"Your_Interests");
    UIBarButtonItem *item = [UIBarButtonItem itemWithTarget:self action:@selector(saveAction:) title:NSLocalizedStringFromSelf(@"Save")];
    UIBarButtonItem *itemPlaceholder = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    
    self.navigationItem.rightBarButtonItems = @[itemPlaceholder,item];
    self.interestContentView.allTagDelegate = self;
    self.sessionManager = [LSDomainSessionRequestManager manager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadTagListContentView];
}

- (void)reloadTagListContentView {
    self.interestContentView.allTags = self.allTagList;
    self.interestContentView.selectTags = self.selectInterestList;

    [self.interestContentView.collectionView reloadData];
}


/**
 点击cell回调
 
 @param cell cell
 @param item cell对应的item
 */
- (void)lsAllTagListCollectionView:(LSAllTagListCollectionView *)cell didClickViewItem:(LSManInterestItem *)item {
    
    if ([cell.selectTags containsObject:item]) {
        [self.selectInterestList removeObject:item];
    }else {
        [self.selectInterestList addObject:item];
    }
    self.interestContentView.selectTags = self.selectInterestList;
    [self.interestContentView.collectionView reloadData];
    
}

- (void)saveAction:(UIButton *)btn {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (LSManInterestItem *item in self.selectInterestList) {
        for (int i = 0; i < self.allTagList.count; i++) {
            if ([item isEqual:self.allTagList[i]]) {
                [tempArray addObject:[NSString stringWithFormat:@"%d",(i + 1)]];
            }
        }
    }
    self.personalItem.interests = tempArray;
    [self updateProfile:self.personalItem];
}


/**
 更新详情
 
 @param item 个人信息
 @return 成功
 */
- (BOOL)updateProfile:(LSPersonalProfileItemObject * _Nullable)item{
    LSUpdateProfileRequest *request = [[LSUpdateProfileRequest alloc] init];
    request.resume = item.resume;
    request.height = item.height;
    request.weight = item.weight;
    request.smoke = item.smoke;
    request.drink = item.drink;
    request.religion = item.religion;
    request.education = item.education;
    request.profession = item.profession;
    request.ethnicity = item.ethnicity;
    request.income = item.income;
    request.children = item.children;
    request.language = item.language;
    request.zodiac = item.zodiac;
    request.interests = item.interests;
    [self showLoading];
    request.finishHandler  = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, BOOL isModify){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if( success ) {
                NSLog(@"EditInterestViewController::updateProfile( 更新男士详情成功 )");
//                [[FinishView initFinishViewXib] showDialogTip:self.view tipText:@"Done"];
                [[DialogIconTips dialogIconTips] showDialogIconTips:self.view tipText:@"Done" tipIcon:nil];
                if ([self.editInterestDelegate respondsToSelector:@selector(lsEditInterestViewController:didSaveInterest:)]) {
                    [self.editInterestDelegate lsEditInterestViewController:self didSaveInterest:self.selectInterestList];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
               
            } else {
                [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            }
            
        });
        
    };
    
    return [self.sessionManager sendRequest:request];
}

@end
