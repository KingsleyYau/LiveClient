//
//  LSMailAttachmentView.m
//  livestream
//
//  Created by Albert on 2020/8/10.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSMailAttachmentView.h"
#import "LSImageViewLoader.h"

#define photoDistance (10)
#define BaseImageViewTag (100)
#define ImageViewStartY (70)

@interface LSMailAttachmentView()
{
    
}

/** 开始位置 */
@property (nonatomic, assign) CGFloat totalHeight;

@end

@implementation LSMailAttachmentView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        self.imageArray = [NSMutableArray array];
        self.totalHeight = ImageViewStartY;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 16.f)];
        [titleLabel setText:@"Mail Attachments"];
        [titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:14]];
        [titleLabel setTextColor: [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0]];
        [self addSubview:titleLabel];
        [titleLabel mas_updateConstraints:^(MASConstraintMaker *make){
            make.left.right.equalTo(self);
            make.top.equalTo(self).offset(20);
        }];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 36.f, frame.size.width, frame.size.height-36.f)];
        [bgView setBackgroundColor: [UIColor colorWithRed:248/255.0 green:241/255.0 blue:233/255.0 alpha:1/1.0]];
        bgView.layer.masksToBounds = YES;
        bgView.layer.borderColor = Color(220, 197, 171, 1).CGColor;
        bgView.layer.borderWidth = 1.f;
        [self addSubview:bgView];
        
        [bgView mas_updateConstraints:^(MASConstraintMaker *make){
            make.left.right.equalTo(self);
            make.top.equalTo(titleLabel.mas_bottom);
            make.bottom.equalTo(self);
        }];
        
        UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(10, 52, 6, 6)];
        pointView.layer.masksToBounds = YES;
        pointView.layer.cornerRadius = 3.f;
        [pointView setBackgroundColor:[UIColor colorWithRed:41/255.0 green:122/255.0 blue:243/255.0 alpha:1/1.0]];
        [self addSubview:pointView];
        [pointView mas_updateConstraints:^(MASConstraintMaker *make){
            //make.left.equalTo(bgView).offset(20);
        }];
        
        UILabel *tLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 52, frame.size.width, 17.f)];
        [tLabel1 setTextAlignment:NSTextAlignmentLeft];
        [tLabel1 setBackgroundColor:[UIColor clearColor]];
        
        NSString *str = @"Photo(Free)";
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:str];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:41/255.0 green:122/255.0 blue:243/255.0 alpha:1/1.0] range:NSMakeRange(0, 5)];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1/1.0] range:NSMakeRange(5, str.length-5)];
        [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialMT" size:16] range:NSMakeRange(0, str.length)];
        [tLabel1 setAttributedText:attString];
        
        [self addSubview:tLabel1];
        [tLabel1 mas_updateConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(bgView).offset(10);
            make.right.equalTo(bgView);
            make.left.equalTo(bgView).offset(20);
        }];
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    //self.imageViewLoader = [ImageViewLoader loader];
    self.imageArray = [NSMutableArray array];
    self.totalHeight = ImageViewStartY;
}

-(UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);

    if(CGSizeEqualToSize(imageSize, size) ==NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) *0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) *0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)reloadAttactments:(NSArray*)array {
    //[self removeAllSubviews];
    for (id subview in [self subviews]) {
        if ([subview tag] >= 88) {
            [subview removeFromSuperview];
        }
    }
    CGFloat leftMargin = 10.f;
    CGFloat margin = ImageViewStartY;
    CGFloat viewWidth = self.frame.size.width-20.f;
    CGFloat itemHeight = viewWidth;
    for (int i = 0; i < array.count; i++) {
        // PointY
        CGFloat picY = margin + (itemHeight + margin) * i;
        NSString *url = array[i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftMargin, picY, viewWidth, itemHeight)];
        imageView.userInteractionEnabled = YES;
        [self addSubview:imageView];
        
        // 加载图片
        __weak typeof(self) weakSelf = self;
                
        [[LSImageViewLoader loader] loadImageWithImageView:imageView options:0 imageUrl:url placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"] finishHandler:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    // 获取下载完成的view
                    NSLog(@"imageView:%f,%f,%f,%f",imageView.frame.origin.x,imageView.frame.origin.y,imageView.frame.size.width,imageView.frame.size.height);
                    CGRect viewFrame = imageView.frame;
                    UIImage *resultImage = [self imageCompressForWidth:image targetWidth:viewWidth];
                    
                    CGFloat resultHeight = resultImage.size.height / (resultImage.size.width / viewWidth);
                    viewFrame.size = CGSizeMake(viewWidth, resultHeight);
                    if (self.totalHeight == ImageViewStartY) {
                        // 记得当前是第一张图的位置
                        viewFrame.origin.y = ImageViewStartY;
                        self.totalHeight = ImageViewStartY;
                    }else {
                        // 更新下一位置的y点
                        viewFrame.origin.y = self.totalHeight + photoDistance + ImageViewStartY;
                        self.totalHeight += imageView.image.size.height + photoDistance + ImageViewStartY;
                    }
                    imageView.frame = viewFrame;
                    imageView.image = resultImage;

                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(mailVideoKeyViewUpdateHeight:)]) {
                        [weakSelf.delegate mailVideoKeyViewUpdateHeight:imageView];
                    }
                }
            });
        }];
    }
}
@end
