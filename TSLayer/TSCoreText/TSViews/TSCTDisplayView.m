//
//  TSCTDisplayView.m
//  TSLayer
//
//  Created by tunsuy on 25/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import "TSCTDisplayView.h"
#import "TSCTCoreTextData.h"
#import "TSCTUtils.h"

@implementation TSCTDisplayView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!self.data) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /** 切换坐标系 */
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.f, -1.f);
    
    CTFrameDraw(self.data.frameRef, context);
    
    for (NSDictionary *imageDict in self.data.imageArray) {
        UIImage *image = [UIImage imageNamed:imageDict[@"name"]];
        if (!image) {
            continue;
        }
        /** 这样绘制出来的是翻转的 */
//        CGContextDrawImage(context, [imageDict[@"positon"] CGRectValue], image.CGImage);

//        [image drawInRect:imageRealBounds];
        
        CGContextSaveGState(context);
        CGContextDrawImage(context, [imageDict[@"position"] CGRectValue], image.CGImage);
        CGContextRestoreGState(context);
        
    }
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        [self addGestureRecognizer:tapGesture];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)tapClick:(UITapGestureRecognizer *)tapGesture {
    CGPoint tapPoint = [tapGesture locationInView:self];
    
    for (NSDictionary *imageDict in self.data.imageArray) {
        /** image坐标转换 ： imageDict中保存的是CoreText坐标系坐标 */
        CGRect imageBounds = [imageDict[@"position"] CGRectValue];
        CGPoint imagePosition = imageBounds.origin;
        imagePosition.y = self.bounds.size.height - imageBounds.origin.y - imageBounds.size.height;
        CGRect imageRealBounds = CGRectMake(imagePosition.x, imagePosition.y, imageBounds.size.width, imageBounds.size.height);
        
        if (CGRectContainsPoint(imageRealBounds, tapPoint)) {
            NSLog(@"click the image");
            break;
        }
    }
    
    NSDictionary *linkDict = [TSCTUtils touchLinkInView:self atPoint:tapPoint data:self.data];
    if (!linkDict) {
        return;
    }
    NSLog(@"click the link : %@", linkDict[@"url"]);
}

@end
