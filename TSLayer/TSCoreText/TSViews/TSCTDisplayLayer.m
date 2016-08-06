//
//  TSCTDisplayLayer.m
//  TSLayer
//
//  Created by tunsuy on 23/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import "TSCTDisplayLayer.h"
#import "TSCTCoreTextData.h"
#import <UIKit/UIKit.h>

@implementation TSCTDisplayLayer

- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    
    if (!self.data) {
        return;
    }
    
    CTFrameDraw(self.data.frameRef, ctx);
    
    for (NSDictionary *imageDict in self.data.imageArray) {
        UIImage *image = [UIImage imageNamed:imageDict[@"name"]];
        if (!image) {
            continue;
        }
        CGContextDrawImage(ctx, [imageDict[@"position"] CGRectValue], image.CGImage);
    }
}

@end
