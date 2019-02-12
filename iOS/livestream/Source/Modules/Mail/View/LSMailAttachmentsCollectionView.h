//
//  LSMailAttachmentsCollectionView.h
//  livestream
//
//  Created by test on 2018/12/26.
//  Copyright © 2018 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMailAttachmentModel.h"

@protocol LSMailAttachmentsCollectionViewDelegate <NSObject>

- (void)mailAttachmentsCollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface LSMailAttachmentsCollectionView : UICollectionView

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, weak)id <LSMailAttachmentsCollectionViewDelegate> collectionViewDelegate;
@end
