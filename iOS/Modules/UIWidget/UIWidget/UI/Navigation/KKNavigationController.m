//
//  KKNavigationController.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKNavigationController.h"
#import <objc/runtime.h>

@interface KKNavigationController () <UINavigationControllerDelegate, UINavigationBarDelegate, UIGestureRecognizerDelegate>
/**
 *  增加手势
 *
 *  @param viewController 界面控制器
 */
- (void)setUpGestureRecognizers:(UIViewController *)viewController;

/**
 *  去除手势
 *
 *  @param viewController 界面控制器
 */
- (void)removeGestureRecognizers:(UIViewController *)viewController;

/**
 *  自定义导航栏
 *
 *  @param viewController 界面控制器
 */
- (void)setupNavigationBar:(UIViewController *)viewController;

@end

@implementation KKNavigationController

#pragma mark - 界面旋转控制
- (BOOL)shouldAutorotate {
    return [[self.viewControllers lastObject] shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

#pragma mark - 重载父类
- (void)viewDidLoad {
    [super viewDidLoad];
    self.canReceiveTouch = YES;
    [self initDelegate];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)initDelegate {
    self.delegate = (id<UINavigationControllerDelegate>)self;
    self.interactivePopGestureRecognizer.delegate = self;
}

- (id)init {
    if(self = [super init]) {
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    if(self = [super initWithRootViewController:rootViewController]) {
        [self setupNavigationBar:rootViewController];
    }
    return self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 改变KKNavigationControllerDelegate回调对象为最顶层界面
    self.kkDelegate = (id<KKNavigationControllerDelegate>) viewController;
    if(self.kkDelegate && [self.kkDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]){
        [self.kkDelegate navigationController:self willShowViewController:viewController animated:animated];
    }
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if(self.kkDelegate && [self.kkDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]){
        [self.kkDelegate navigationController:self didShowViewController:viewController animated:animated];
    }
    
    self.canReceiveTouch = YES;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated gesture:(BOOL)gesture {
    if(gesture) {
        // 加入栈之前先添加手势
        [self setUpGestureRecognizers:viewController];
    }
    [self pushViewController:viewController animated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSString* title = nil;
    if( viewController.customBackTitle ) {
        title = viewController.customBackTitle;
    } else if( self.customDefaultBackTitle ){
        title = self.customDefaultBackTitle;
    }
    
    if( (viewController.navigationItem.hidesBackButton == NO) &&
        (self.customDefaultBackImage || title) ) {
        // 自定义默认返回按钮
        UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [backButton setTitle:title forState:UIControlStateNormal];
        [backButton setImage:self.customDefaultBackImage forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor colorWithRed:179 / 255.0 green:179 / 255.0 blue:179 / 255.0 alpha:0.7] forState:UIControlStateHighlighted];
        [backButton setImage:self.customDefaultBackHighlightImage forState:UIControlStateHighlighted];
        backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        backButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [backButton sizeToFit];
        [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UINavigationItem *item = viewController.navigationItem;
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        item.leftBarButtonItem = leftBarButtonItem;
    }

    self.canReceiveTouch = NO;
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    // 出栈之后先去除手势
    self.kkDelegate = nil;
    UIViewController *uIViewController = [super popViewControllerAnimated:animated];
    [self removeGestureRecognizers:uIViewController];
    
    return uIViewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.kkDelegate = nil;
    // 出栈之后先去除手势
    NSArray *array = [super popToViewController:viewController animated:animated];
    for(UIViewController *uIViewController in array) {
        [self removeGestureRecognizers:uIViewController];
    }

    return array;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    // 出栈之后先去除手势
    NSArray *array = [super popToRootViewControllerAnimated:animated];
    for(UIViewController *uIViewController in array) {
        [self removeGestureRecognizers:uIViewController];
    }

    return array;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL bFlag = NO;
    if( self.canReceiveTouch ) {
        // 关闭手势右滑返回
        if ( self.viewControllers.count == 1 ) {
            bFlag = NO;
            
        } else {
            // 开启手势右滑返回
            bFlag = YES;
            
        }
    }

    return bFlag;
}

#pragma mark - 添加手势
- (void)setUpGestureRecognizers:(UIViewController *)viewController {
    // 加入向右边滑动手势
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeGesture:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [viewController.view addGestureRecognizer:rightSwipeGesture];
    
    // 加入向左边滑动手势
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeGesture:)];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [viewController.view addGestureRecognizer:leftSwipeGesture];

}

- (void)removeGestureRecognizers:(UIViewController *)viewController {
    for (UIGestureRecognizer *gestureRecognizer in [viewController.view gestureRecognizers]) {
        [viewController.view removeGestureRecognizer:gestureRecognizer];
    }
}

#pragma mark - 手势回调
- (void)leftSwipeGesture:(UIGestureRecognizer *)gestureRecognizer {
    // 向左边滑动手势回调
}

- (void)rightSwipeGesture:(UIGestureRecognizer *)gestureRecognizer {
    // 向右边滑动手势回调
    [self popViewControllerAnimated:YES];
}

#pragma mark - 导航栏默认布局风格
- (void)setupNavigationBar:(UIViewController *)viewController {
    // 导航栏默认背景

}

#pragma mark - 导航栏控件回调
- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item {
    if( !self.customDefaultBackImage && !self.customDefaultBackTitle ) {
        // 重定义默认后退按钮事件触发
        UINavigationItem *backItem = navigationBar.backItem;
        backItem.backBarButtonItem.target = self;
        backItem.backBarButtonItem.action = @selector(backAction:);
    }
}

- (void)backAction:(id)sender {
    // ViewController自己处理是否返回
    if(self.kkDelegate && [self.kkDelegate respondsToSelector:@selector(backAction)]) {
        [self.kkDelegate backAction];
        
    } else {
        [self popViewControllerAnimated:YES];
    }
}

@end

@implementation UIViewController (KKNavigationControllerNavigationBarItem)
@dynamic customBackTitle;
static NSString *customBackTitle = @"customBackTitle";

- (void)setCustomBackTitle:(NSString* )title {
    objc_setAssociatedObject(self, &customBackTitle, title, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)customBackTitle {
    return objc_getAssociatedObject(self, &customBackTitle);
}

@end