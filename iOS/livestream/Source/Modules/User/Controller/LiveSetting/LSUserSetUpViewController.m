//
//  LSUserSetUpViewController.m
//  livestream
//
//  Created by test on 2018/9/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSUserSetUpViewController.h"
#import "LSUserSetUpItemObject.h"
#import "LSUserSetUpGroupItemObject.h"
#import "LSUserSetUpListTableViewCell.h"
#import "LSUserSetUpListLogoutTableViewCell.h"
#import "LiveModule.h"
#import "LSPushNoticeViewController.h"
#import "LSChangePasswordViewController.h"
#import "LSLoginManager.h"
typedef enum {
    SectionTypeFirst,
    SectionTypeSecond,
    SectionTypeThird
} SectionType;

typedef enum {
    FirstSectionTypePush,
    FirstSectionTypePassword
} FirstSectionType;

typedef enum {
    SecondSectionTypeCleanCache,
    SecondSectionTypeVersion
} SecondSectionType;

@interface LSUserSetUpViewController ()<UITableViewDataSource,UITableViewDelegate>
/** 版本号 */
@property (nonatomic, copy) NSString *versionCode;

/** 文件大小 */
@property (nonatomic, assign) NSInteger fileSize;
@end

@implementation LSUserSetUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    self.title = @"Settings";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self reloadData:YES];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    
    NSMutableArray *dataArray = [NSMutableArray array];
    

    LSUserSetUpGroupItemObject *group1 = [[LSUserSetUpGroupItemObject alloc] init];
    
    LSUserSetUpItemObject *user1Item = [[LSUserSetUpItemObject alloc] init];
    user1Item.userSettingTitle = @"Push Notifications";
    
    LSUserSetUpItemObject *user1Item1 = [[LSUserSetUpItemObject alloc] init];
    user1Item1.userSettingTitle = @"Change Password";
    
    group1.groupItems = @[ user1Item, user1Item1 ];
    
    [dataArray addObject:group1];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.fileSize = [self folderSizeAtPath:path];
    
    LSUserSetUpGroupItemObject *group2 = [[LSUserSetUpGroupItemObject alloc] init];
    
    LSUserSetUpItemObject *user2Item = [[LSUserSetUpItemObject alloc] init];
    user2Item.userSettingTitle = @"Clean Cache";
    user2Item.userSettingDetail = [NSString stringWithFormat:@"%ldm", (long)self.fileSize];
    
    LSUserSetUpItemObject *user2Item1 = [[LSUserSetUpItemObject alloc] init];
    user2Item1.userSettingTitle = @"Version";
    user2Item1.userSettingDetail = [NSString stringWithFormat:@"v%@", [LiveModule module].appStringVerCode];
    
    group2.groupItems = @[ user2Item, user2Item1 ];
    [dataArray addObject:group2];
    
    LSUserSetUpGroupItemObject *group3 = [[LSUserSetUpGroupItemObject alloc] init];
    LSUserSetUpItemObject *user3Item1 = [[LSUserSetUpItemObject alloc] init];
    user3Item1.userSettingTitle = @"Log out";
    group3.groupItems = @[ user3Item1 ];
    [dataArray addObject:group3];
    
    self.items = dataArray;
    
    if (isReloadView) {
        [self.tableView reloadData];
    }
}


#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 8;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 0;
    if ([tableView isEqual:self.tableView]) {
        if (self.items) {
            count = self.items.count;
        }
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger dataCount = 0;
    if ([tableView isEqual:self.tableView]) {
        
        LSUserSetUpGroupItemObject *groupData = self.items[section];
        dataCount = groupData.groupItems.count;
    }
    return dataCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = 0;
    if (indexPath.section == SectionTypeSecond) {
        rowHeight = [LSUserSetUpListLogoutTableViewCell cellHeight];
    }else {
        rowHeight = [LSUserSetUpListTableViewCell cellHeight];
    }
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = [[UITableViewCell alloc] init];
    
    if ([tableView isEqual:self.tableView]) {
        LSUserSetUpGroupItemObject *groupItem = [self.items objectAtIndex:indexPath.section];
        LSUserSetUpItemObject *item = groupItem.groupItems[indexPath.row];

        
        
        if (indexPath.section == SectionTypeFirst) {
            LSUserSetUpListTableViewCell *cell = [LSUserSetUpListTableViewCell getUITableViewCell:tableView];
            cell.settingTitle.text = item.userSettingTitle;
            cell.settingDetail.text = item.userSettingDetail;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.settingDetail.hidden = YES;
            result = cell;
        }
        
        if (indexPath.section == SectionTypeSecond) {
            LSUserSetUpListTableViewCell *cell = [LSUserSetUpListTableViewCell getUITableViewCell:tableView];
            cell.settingTitle.text = item.userSettingTitle;
            cell.settingDetail.text = item.userSettingDetail;
            cell.settingDetail.hidden = NO;
            
            if (indexPath.row == SecondSectionTypeCleanCache) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            result = cell;
            
        }
        
        if (indexPath.section == SectionTypeThird) {
            LSUserSetUpListLogoutTableViewCell *cell = [LSUserSetUpListLogoutTableViewCell getUITableViewCell:tableView];
            cell.settingTitle.text = item.userSettingTitle;
            cell.accessoryType = UITableViewCellAccessoryNone;
            result = cell;
        }

    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == SectionTypeFirst) {
        if (indexPath.row == FirstSectionTypePush) {
            LSPushNoticeViewController *vc = [[LSPushNoticeViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == FirstSectionTypePassword) {
            LSChangePasswordViewController *vc = [[LSChangePasswordViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (indexPath.section == SectionTypeSecond) {
        if (indexPath.row == SecondSectionTypeCleanCache) {
            NSString *tips = @"Are you sure you wish to clean the app cache";
           UIAlertController *cleanAlert = [UIAlertController alertControllerWithTitle:tips message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self clearCache];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [cleanAlert addAction:okAction];
            [cleanAlert addAction:cancelAction];
            [self presentViewController:cleanAlert animated:YES completion:nil];
            
        }
    }else if (indexPath.section == SectionTypeThird) {
        UIAlertController *cleanAlert = [UIAlertController alertControllerWithTitle:@"Do you wish to log out" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[LSLoginManager manager] logout:LogoutTypeActive];
            [[LiveModule module].analyticsManager reportActionEvent:ClickLiveLogout eventCategory:EventCategorySettings];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [cleanAlert addAction:okAction];
        [cleanAlert addAction:cancelAction];
        [self presentViewController:cleanAlert animated:YES completion:nil];
    }
}


#pragma mark - clean cache

// 计算一下 单个文件的大小

- (CGFloat)fileSizeAtPath:(NSString *)filePath {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]) {
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    
    return 0;
}

// 遍历文件夹获得文件夹大小
- (CGFloat)folderSizeAtPath:(NSString *)folderPath {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:folderPath]) return 0;
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    
    NSString *fileName;
    
    long long folderSize = 0;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil) {
        
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    
    return folderSize / (1024.0 * 1024.0);
}



- (void)clearCache {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        BOOL isDirectoty = NO;
        
        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:path];
        
        for (NSString *fileName in files) {
            
            NSError *error = nil;
            
            NSString *cachesPath = [path stringByAppendingPathComponent:fileName];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:cachesPath isDirectory:&isDirectoty]) {
                if (!isDirectoty) {
                    [[NSFileManager defaultManager] removeItemAtPath:cachesPath error:&error];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData:YES];
        });
    });
}
@end
