//
//  SearchViewController.m
//  livestream
//
//  Created by randy on 17/6/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchListObject.h"

@interface SearchViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate,SearchTableViewDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation SearchViewController

- (void)initCustomParam {
    [super initCustomParam];
    
    self.items = [NSMutableArray array];
    
}

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 设置导航栏返回按钮
    [self setBackleftBarButtonItemOffset:0];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setFrame:CGRectMake(0, 0, 60, 40)];
    [searchBtn setTitle:@"Search" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchUserAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addSingleTap];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeSingleTap];
    
    // 关闭输入
    [self closeAllInputView];
}

- (void)setupContainView {
    
    [super setupContainView];
    
    [self setSearchView];
}

- (void)setupNavigationBar {
    
    [super setupNavigationBar];
}

- (void)setSearchView {
    
    self.textField = [[UITextField alloc]init];
    UIImageView *imageVIew = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Home_Nav_Btn_Search"]];
    imageVIew.frame = CGRectMake(0, 0, 30, 30);
    self.textField.leftView = imageVIew;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.placeholder = @"Search username/ID";
    [self.textField setBackgroundColor:COLOR_WITH_16BAND_RGB(0xf1f1f1)];
    self.textField.frame = CGRectMake(0, 0, 260, 30);
    self.textField.delegate = self;
    self.textField.font = [UIFont systemFontOfSize:15];
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.navigationItem.titleView = self.textField;
    [self.textField becomeFirstResponder];
    
    [self initDataModel];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.items = self.items;
    self.tableView.searchDelegate = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView reloadData];
}

- (void)addSingleTap {
    if( self.singleTap == nil ) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAllInputView)];
        [self.view addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if( self.singleTap ) {
        [self.view removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
    }
}


- (void)closeAllInputView {
    [self.textField resignFirstResponder];
}

// 搜索按钮
- (IBAction)searchUserAction:(id)sender {
    
    
}


// 返回按钮
- (IBAction)popBackToController:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)initDataModel {

    SearchListObject *list1 = [[SearchListObject alloc]init];
    list1.userHeadUrl = @"http://images3.charmdate.com/woman_photo/C2248/161/C235829-f007f8438f8b56a94575f68f655e788b-1.jpg";
    list1.userNameStr = @"jhsel";
    list1.userIDStr = @"5648";
    list1.lvStr = @"12";
    list1.isFollow = YES;
    list1.isMale = NO;
    [self.items addObject:list1];
    
    SearchListObject *list2 = [[SearchListObject alloc]init];
    list2.userHeadUrl = @"http://images3.charmdate.com/woman_photo/C1251/132/C615703-84398ccb04629db648dfb7ee8b64b03c-4.jpg";
    list2.userNameStr = @"brefy";
    list2.userIDStr = @"1234";
    list2.lvStr = @"56";
    list2.isFollow = NO;
    list2.isMale = YES;
    [self.items addObject:list2];
    
    SearchListObject *list3 = [[SearchListObject alloc]init];
    list3.userHeadUrl = @"http://images3.charmdate.com/woman_photo/C3069/169/C251959-754b69462fe0ae1268256e3ba8b712cf-7.jpg";
    list3.userNameStr = @"uerol";
    list3.userIDStr = @"7864";
    list3.lvStr = @"72";
    list3.isFollow = NO;
    list3.isMale = NO;
    [self.items addObject:list3];
    
    SearchListObject *list4 = [[SearchListObject alloc]init];
    list4.userHeadUrl = @"http://images3.charmdate.com/woman_photo/C1407/163/C946042-89cec41b94eb0e66d5c37083914f1e2c-2.jpg";
    list4.userNameStr = @"nkhf";
    list4.userIDStr = @"9654";
    list4.lvStr = @"85";
    list4.isFollow = YES;
    list4.isMale = NO;
    [self.items addObject:list4];
    
    SearchListObject *list5 = [[SearchListObject alloc]init];
    list5.userHeadUrl = @"http://images3.charmdate.com/woman_photo/C2248/161/C235829-f007f8438f8b56a94575f68f655e788b-1.jpg";
    list5.userNameStr = @"liias";
    list5.userIDStr = @"8694";
    list5.lvStr = @"90";
    list5.isFollow = YES;
    list5.isMale = YES;
    [self.items addObject:list5];
    
    SearchListObject *list6 = [[SearchListObject alloc]init];
    list6.userHeadUrl = @"http://images3.charmdate.com/woman_photo/C2248/161/C235829-f007f8438f8b56a94575f68f655e788b-1.jpg";
    list6.userNameStr = @"klah";
    list6.userIDStr = @"4568";
    list6.lvStr = @"80";
    list6.isFollow = YES;
    list6.isMale = NO;
    [self.items addObject:list6];
}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    // Ensures that all pending layout operations have been completed
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:duration animations:^{
        // Make all constraint changes here, Called on parent view
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self closeAllInputView];
}

@end
