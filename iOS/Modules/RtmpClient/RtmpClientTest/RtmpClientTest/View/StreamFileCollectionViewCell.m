//
//  StreamFileCollectionViewCell.m
//  RtmpClientTest
//
//  Created by Max on 2020/10/12.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "StreamFileCollectionViewCell.h"

@interface StreamFileCollectionViewCell ()
@end

@implementation StreamFileCollectionViewCell
+ (NSString *)cellIdentifier {
    return NSStringFromClass([StreamFileCollectionViewCell class]);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    [self reset];
}

- (void)reset {
//    const NSArray *ColorArray = @[[UIColor redColor], [UIColor blueColor], [UIColor greenColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor magentaColor]];
//    int index = arc4random() % ColorArray.count;
//    self.backgroundColor = ColorArray[index];
    self.fileImageView.image = nil;
    self.fileNameLabel.text = @"";
}

@end
