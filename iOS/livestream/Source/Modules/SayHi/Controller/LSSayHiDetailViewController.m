//
//  LSSayHiDetailViewController.m
//  livestream
//
//  Created by Calvin on 2019/4/18.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiDetailViewController.h"
#import "LSSayHiDetailHeadView.h"
#import "LSSayHiReadReplyCell.h"
#import "LSSayHiUnreadReplyCell.h"
#import "LSSayHiNoReplyCell.h"
#import "LSSayHiResponseNumCell.h"
#import "LSSayHiDetailAddCreditsCell.h"
#import "LSSayHiDetailErrorCell.h"
#import "LSSayHiGetDetailRequest.h"
#import "LSSendMailViewController.h"
#import "LSSayHiCardDetailsViewController.h"
#import "LSAddCreditsViewController.h"
#import "LSSayHiReadResponseRequest.h"
@interface LSSayHiDetailViewController ()<UITableViewDelegate,UITableViewDataSource,LSSayHiDetailHeadViewDelegate,LSSayHiReadReplyCellDelegate,LSSayHiDetailAddCreditsCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) LSSayHiDetailHeadView * headView;
@property (nonatomic, strong) NSMutableArray * items;
@property (nonatomic, assign) BOOL isLoadImage;
@property (nonatomic, assign) BOOL isNoCredits;
@property (nonatomic, assign) NSInteger responseTime;
@end

@implementation LSSayHiDetailViewController

- (void)dealloc {
    NSLog(@"LSSayHiDetailViewController::dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    
    [self setTableViewBGView];
    //[self test];
}

- (void)reflashNavigationBar {
    
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    self.navigationTitle = @"My Say Hi";
}

- (void)setTableViewBGView {
    UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"SayHi_Info_Bg"]];
    imageView.frame = self.tableView.frame;
    self.tableView.backgroundView = imageView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)tableViewScrollTop {
    self.isLoadImage = NO;
    [self.tableView reloadData];
}

- (LSSayHiDetailResponseListItemObject *)newDeailItem:(SayHiDetailLoadingType)type {
    LSSayHiDetailResponseListItemObject * itemModel = [[LSSayHiDetailResponseListItemObject alloc]init];
    itemModel.type = type;
    return itemModel;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.viewDidAppearEver) {
        
        if (!self.headView) {
            self.headView = [[LSSayHiDetailHeadView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 105)];
            self.headView.delegate = self;
            [self.tableView setTableHeaderView:self.headView];
        }
        [self.headView loadData:self.detail];
        
        [self getSayHiDetail:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - 接口请求

- (void)getSayHiDetail:(BOOL)isUnread {
    [self showLoading];
    LSSayHiGetDetailRequest * request = [[LSSayHiGetDetailRequest alloc]init];
    request.sayHiId = self.sayHiID;
    request.type = isUnread?LSSAYHIDETAILTYPE_LATEST:LSSAYHIDETAILTYPE_EARLIEST;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiDetailInfoItemObject *item) {
         dispatch_async(dispatch_get_main_queue(), ^{
             NSLog(@"LSSayHiDetailViewController::getSayHiDetail( [%@], Count : %d)", BOOL2SUCCESS(success), (int)item.responseList.count);
             [self hideLoading];
             if (success) {
                 [self.headView loadData:item.detail];
                 self.detail =item.detail;
                 self.items = item.responseList;
                
                 if (self.items.count > 0) {
                     self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                     
                     for (int i = 0; i < self.items.count; i++) {
                         LSSayHiDetailResponseListItemObject * obj = self.items[i];
                         obj.type = SayHiDetailLoadingType_Successed;
                     }
                     
                     if (self.items.count > 1) {
                         LSSayHiDetailResponseListItemObject * itemModel = nil;
                         for (LSSayHiDetailResponseListItemObject * obj  in self.items) {
                             //Say Hi只有单个回复，默认展开
                             if ([self.responseId isEqualToString:obj.responseId] || obj.isFree) {
                                 obj.isUnfold = YES;
                                 obj.contentH = [self calculateContentH:obj.content];
                                 itemModel = obj;
                                 break;
                             }
                         }
                         
                         [self.items insertObject:[self newDeailItem:SayHiDetailLoadingType_Successed] atIndex:0];
                         
                         [self.items insertObject:itemModel atIndex:0];
                         
                         if (!itemModel.hasRead) {
                             [self buyMail:itemModel.responseId];
                         }
                         
                     }else {
                         LSSayHiDetailResponseListItemObject * itemModel = [self.items firstObject];
                         itemModel.isUnfold = YES;
                         itemModel.contentH = [self calculateContentH:itemModel.content];
                         
                         if (!itemModel.hasRead) {
                             [self buyMail:itemModel.responseId];
                         }
                     }                 }
                 else {
                     [self.items removeAllObjects];
                     [self.items addObject:[self newDeailItem:SayHiDetailLoadingType_NoData]];
                     [self setTableViewBGView];
                 }
                 
                 [self.tableView setContentOffset:CGPointMake(0,0) animated:YES];
                 [self performSelector:@selector(tableViewScrollTop) withObject:nil afterDelay:0.5];
                 
             }
             else {
                 [self.items removeAllObjects];
                 [self.items addObject:[self newDeailItem:errnum ==HTTP_LCC_ERR_NO_CREDIT?SayHiDetailLoadingType_NoCredits:SayHiDetailLoadingType_Fail]];
                 [self.tableView reloadData];
             }
         });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

- (void)buyMail:(NSString *)responseId {
    [self showLoading];
    LSSayHiReadResponseRequest * request = [[LSSayHiReadResponseRequest alloc]init];
    request.sayHiId =self.sayHiID;
    request.responseId =responseId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiDetailResponseListItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSayHiDetailViewController::buyMail( [%@])", BOOL2SUCCESS(success));
            [self hideLoading];
            if (success) {
                self.responseId = responseId;
                [self getSayHiDetail:YES];
            }
            else {
                @synchronized (self) {
                    [self.items removeObjectAtIndex:0];
                    [self.items insertObject:[self newDeailItem:errnum ==HTTP_LCC_ERR_SAYHI_READ_NO_CREDIT?SayHiDetailLoadingType_NoCredits:SayHiDetailLoadingType_Fail] atIndex:0];
                    [self.tableView reloadData];
                }
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}


- (void)sayHiDetailHeadViewDidNoteBtn {
    LSSayHiCardDetailsViewController * vc = [[LSSayHiCardDetailsViewController alloc]init];
    vc.ladyName = self.detail.nickName;
    vc.contentStr = self.detail.text;
    vc.photoUrl = self.detail.img;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellH = 0;
    LSSayHiDetailResponseListItemObject * obj = [self.items objectAtIndex:indexPath.row];
    if (obj.type == SayHiDetailLoadingType_Successed) {
        if (indexPath.row == 0) {
            cellH = [LSSayHiReadReplyCell cellHeight:obj];
        }else if (indexPath.row == 1)
        {
            cellH = [LSSayHiResponseNumCell cellHeight];
        }
        else {
           cellH = [LSSayHiUnreadReplyCell cellHeight];
        }
    }
    else if (obj.type == SayHiDetailLoadingType_NoData){
        cellH = [LSSayHiNoReplyCell cellHeight];
    }
    else if (obj.type == SayHiDetailLoadingType_NoCredits) {
         cellH = [LSSayHiDetailAddCreditsCell cellHeight];
    }
    else {
        cellH = [LSSayHiDetailErrorCell cellHeight];
    }

    return cellH;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = nil;
    LSSayHiDetailResponseListItemObject * obj = [self.items objectAtIndex:indexPath.row];
    if (obj.type == SayHiDetailLoadingType_Successed) {
        if (indexPath.row == 0) {
            LSSayHiReadReplyCell * cell = [LSSayHiReadReplyCell getUITableViewCell:tableView];
                cell.cellDelegate = self;
                tableViewCell = cell;
                cell.timeLabel.text =[NSString stringWithFormat:@"ID:%@ %@",obj.responseId,[self getTime:obj.responseTime type:@"dd MMM,yyyy"]];
                cell.nameLabel.text = self.detail.nickName;
                cell.freeW.constant = obj.isFree?35:0;
                cell.contentLabel.text = obj.content;
                
                if (obj.hasImg) {
                    cell.replyBtnY.constant = 23;
                    [cell.imageLoader loadImageWithImageView:cell.contentImage options:0 imageUrl:obj.img placeholderImage:nil finishHandler:^(UIImage *image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (image) {
                                CGFloat imageW = image.size.width;
                                CGFloat proportion = cell.contentImage.tx_width/imageW;
                                CGFloat height = proportion * image.size.height;
                                obj.imageH =height;
                            }
                            else {
                                obj.imageH = cell.contentImage.tx_width;
                            }
                            if (!self.isLoadImage) {
                                self.isLoadImage = YES;
                                [self.tableView reloadData];
                            }
                        });
                    }];
                } else {
                    cell.replyBtnY.constant = 0;
                }
                
                cell.contentLabelH.constant = obj.contentH;
                cell.imageViewH.constant =obj.imageH;
                
                [cell layoutIfNeeded];

        }
        else if (indexPath.row == 1) {
            LSSayHiResponseNumCell * cell = [LSSayHiResponseNumCell getUITableViewCell:tableView];
            tableViewCell = cell;
            [cell setContentText:self.detail];
        }
        else {
            LSSayHiUnreadReplyCell * cell = [LSSayHiUnreadReplyCell getUITableViewCell:tableView];
            tableViewCell = cell;
            cell.url = self.detail.avatar;
            [cell loadUI:obj];
        }
    }
    else if (obj.type == SayHiDetailLoadingType_NoData) {
        LSSayHiNoReplyCell * cell = [LSSayHiNoReplyCell getUITableViewCell:tableView];
        tableViewCell = cell;
        if (self.detail.nickName.length > 0) {
            cell.contentLabel.text = [NSString stringWithFormat:@"Awaiting %@'s response.",self.detail.nickName];
        }
    }
    else if (obj.type == SayHiDetailLoadingType_NoCredits) {
        LSSayHiDetailAddCreditsCell * cell = [LSSayHiDetailAddCreditsCell getUITableViewCell:tableView];
        tableViewCell = cell;
        cell.cellDelegate = self;
        [cell setLadyName:self.detail.nickName];
        cell.timeLabel.text = [NSString stringWithFormat:@"ID:%@ %@",self.responseId,[self getTime:self.responseTime type:@"dd MMM,yyyy"]];
    }
    else {
        LSSayHiDetailErrorCell * cell = [LSSayHiDetailErrorCell getUITableViewCell:tableView];
        tableViewCell = cell;
    }
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
         LSSayHiDetailResponseListItemObject * obj = [self.items objectAtIndex:indexPath.row];
    if (obj.type == SayHiDetailLoadingType_Fail) {
        [self getSayHiDetail:YES];
    }
    else {
        if (indexPath.row > 1) {
            [self sayHiUnreadReplyCellReadNowBtnDid:indexPath.row];
        }
    }
}

- (void)sayHiReadReplyCellReplyBtnDid {
     LSSayHiDetailResponseListItemObject * obj = [self.items objectAtIndex:0];
    LSSendMailViewController * vc = [[LSSendMailViewController alloc]initWithNibName:nil bundle:nil];
    vc.anchorId = self.detail.anchorId;
    vc.anchorName = self.detail.nickName;
    vc.photoUrl =self.detail.avatar;
    vc.sayHiResponseId = obj.responseId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)sayHiDetailAddCreditsCellBtnDid {
    LSAddCreditsViewController * vc = [[LSAddCreditsViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)sayHiUnreadReplyCellReadNowBtnDid:(NSInteger)row {
     LSSayHiDetailResponseListItemObject * obj = [self.items objectAtIndex:row];
    self.responseTime = obj.responseTime;
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"SayHiAgainTip"]) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedStringFromSelf(@"BUY_TIP") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self buyMail:obj.responseId];
        }];
        UIAlertAction * aginAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"AGAIN_TIP") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"SayHiAgainTip"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }];
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:okAction];
        [alertController addAction:aginAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else {
        [self buyMail:obj.responseId];
    }
}

- (NSString *)getTime:(NSInteger)time type:(NSString *)type {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:type];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *TimespStr = [formatter stringFromDate:confromTimesp];
    return TimespStr;
}

- (CGFloat)calculateContentH:(NSString *)text {
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.tableView.tx_width - 40, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:16] }  context:nil];
    return ceil(rect.size.height);
}

@end
