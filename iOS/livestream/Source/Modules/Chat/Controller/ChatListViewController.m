//
//  ChatListViewController.m
//  livestream
//
//  Created by randy on 2017/8/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ChatListViewController.h"
#import "ChatListTableViewCell.h"
#import "ChatListModel.h"
#import "NoChatListView.h"
#import "ChatViewController.h"
#import "LiveSDKHeader.h"



@interface ChatListViewController ()<UITableViewDelegate, UITableViewDataSource, NoChatListViewDelagate>

@property (nonatomic,strong) NSMutableArray *listArray;

@property (nonatomic, strong) NoChatListView *nolistView;




@end

@implementation ChatListViewController

- (void)initCustomParam {
    [super initCustomParam];
    
    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // 设置导航栏返回按钮
    [self setBackleftBarButtonItemOffset:15];
    
    UIButton *searchBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [searchBtn setFrame:CGRectMake(0, 0, 40, 40)];
    [searchBtn setImage:[UIImage imageNamed:@"Home_Nav_Btn_Search"] forState: UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(createMessage:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItem = barButtonItem;

    [self setNavigationTitle:@"Private Message"];
    
    
    

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
//    self.listArray = [[NSMutableArray alloc] init];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setupContainView {
    
    [super setupContainView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.chatListTableView.backgroundColor = [UIColor clearColor];
    
    self.chatListTableView.delegate = self;
    self.chatListTableView.dataSource = self;
    UINib *nib = [UINib nibWithNibName:@"ChatListTableViewCell" bundle:nil];
    [self.chatListTableView registerNib:nib forCellReuseIdentifier:[ChatListTableViewCell cellIdentifier]];
    self.chatListTableView.tableFooterView = [[UIView alloc] init];
    
    self.nolistView = [NoChatListView initNoChatListViewXib];
    self.nolistView.delegate = self;
    self.nolistView.hidden = YES;
    [self.nolistView isHavePrivateList:YES];
    [self.view addSubview:self.nolistView];
    [self.nolistView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupNavigationBar {
    
    [super setupNavigationBar];
}

// 创建私信
- (void)createMessage:(id)sender {

}

#pragma mark - NoChatListViewDelagate
- (void)reloadNewList:(NoChatListView *)noChatListView{
    
    // 转菊花
    [self showLoading];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = self.listArray.count;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ChatListTableViewCell cellIdentifier]
                                                                  forIndexPath:indexPath];
    
    ChatListModel *model = self.listArray[indexPath.row];
    
    [cell setListCellModel:model];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    
    ChatListModel *model = self.listArray[indexPath.row];
    
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    chatVC.firstname = model.name;
    [self.navigationController pushViewController:chatVC animated:YES];
    
//    [LiveModuleManager pushToLivestreamWithController:self];
}

- (NSMutableArray *)listArray{
    
    if (!_listArray) {
     
        _listArray = [[NSMutableArray alloc] init];
        
        ChatListModel *model1 = [[ChatListModel alloc] init];
        model1.userId = @"6565245";
        model1.imgUrl = @"http://images3.charmdate.com/woman_photo/C2248/161/C235829-f007f8438f8b56a94575f68f655e788b-1.jpg";
        model1.name = @"Mariey";
        model1.lasterMsg = @"I want to sleep with you, Please love me!";
        [_listArray addObject:model1];
        
        ChatListModel *model2 = [[ChatListModel alloc] init];
        model2.userId = @"6565245";
        model2.imgUrl = @"http://images3.charmdate.com/woman_photo/C3069/169/C251959-754b69462fe0ae1268256e3ba8b712cf-7.jpg";
        model2.name = @"Lancer";
        model2.lasterMsg = @"I hate those clever tactics!I want to go to the battlefield myself.";
        [_listArray addObject:model2];
        
        ChatListModel *model3 = [[ChatListModel alloc] init];
        model3.userId = @"6565245";
        model3.imgUrl = @"http://images3.charmdate.com/woman_photo/C1407/163/C946042-6007062e802e2a3c163be04210ccc0ca-1.jpg";
        model3.name = @"Saber";
        model3.lasterMsg = @"you mast be soutb nvsour shfh sjakf sahfkh ";
        [_listArray addObject:model3];
    }
    return _listArray;
}




@end
