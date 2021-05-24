//
//  StreamLiveItemTableViewController.m
//  RtmpClientTest
//
//  Created by Max on 2021/5/21.
//  Copyright © 2021 net.qdating. All rights reserved.
//

#import "StreamLiveItemTableViewController.h"

@interface StreamLiveItemTableViewController ()
@property (weak) IBOutlet UITableView *tableView;
@end

@implementation StreamLiveItemTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 18, 18);
    [button setImage:[UIImage imageNamed:@"Nav-CloseButton"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.title = @"频道列表";
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.viewDidAppearEver) {
        [self.tableView reloadData];
    }
    [super viewDidAppear:animated];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.categories.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.categories[section].name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories[section].items.count;
}

- (IBAction)closeAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Default"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Default"];
    }
    
    LiveCategory *category = self.categories[indexPath.section];
    LiveItem *liveItem = [category.items objectAtIndex:indexPath.row];
    cell.imageView.image = liveItem.logo;
    cell.textLabel.text = liveItem.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(streamTableView:didSelectLiveItem:category:)]) {
        LiveCategory *category = self.categories[indexPath.section];
        LiveItem *liveItem = [category.items objectAtIndex:indexPath.row];
        [self.delegate streamTableView:self didSelectLiveItem:liveItem category:category];
    }
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

@end
