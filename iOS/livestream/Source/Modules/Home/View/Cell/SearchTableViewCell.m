//
//  SearchTableViewCell.m
//  livestream
//
//  Created by randy on 17/6/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "SearchTableViewCell.h"
#import "FileCacheManager.h"

@implementation SearchTableViewCell

+ (NSString *)cellIdentifier{
 
    return @"searchCellIdentifier";
}

+ (NSInteger)cellHeight{
    
    return 80;
}


+ (id)getUITableViewCell:(UITableView*)tableView{
    
    SearchTableViewCell *cell = (SearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[SearchTableViewCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:@"SearchTableViewCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    return cell;
}

- (void)setTheUserMessage:(SearchListObject *)lists{
    
    if( self.imageViewLoader ) {
        [self.imageViewLoader stop];
    }
    
    self.imageViewLoader = [ImageViewLoader loader];
    self.imageViewLoader.url = lists.userHeadUrl;
    self.imageViewLoader.view = self.userHeadImage;
    self.imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:lists.userHeadUrl];
    [self.imageViewLoader loadImage];
//    self.imageViewLoader.sdWebImageView = self.userHeadImage;
//    [self.imageViewLoader loadImageWithOptions:SDWebImageRefreshCached placeholderImage:[UIImage imageNamed:@""]];
    
    self.userNameLabel.text = lists.userNameStr;
    
    self.userIDLabel.text = [NSString stringWithFormat:@"ID:%@",lists.userIDStr];
    
    if ( lists.isMale ) {
        [self.sexImage setImage:[UIImage imageNamed:@"Search_sex_male"]];
    }else{
        [self.sexImage setImage:[UIImage imageNamed:@"Search_sex_female"]];
    }
    
//    [self.lvImage setImage:[UIImage imageNamed:lists.lvStr]];
    
    if ( lists.isFollow ) {
        
//        self.followBtn setImage:<#(nullable UIImage *)#> forState:<#(UIControlState)#>
    }else{
        
//        self.followBtn setImage:<#(nullable UIImage *)#> forState:<#(UIControlState)#>
    }
}

@end
