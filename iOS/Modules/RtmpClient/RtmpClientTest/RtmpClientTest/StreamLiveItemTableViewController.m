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
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.viewDidAppearEver) {
        [self.tableView reloadData];
    }
    [super viewDidAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Default"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Default"];
    }
    LiveItem *liveItem = [self.items objectAtIndex:indexPath.row];
    cell.imageView.image = liveItem.logo;
    cell.textLabel.text = liveItem.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

@end
