//
//  TSCTUtils.m
//  TSLayer
//
//  Created by tunsuy on 25/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import "TSCTUtils.h"
#import "TSCTCoreTextData.h"
#import <UIKit/UIKit.h>

@implementation TSCTUtils

+ (NSDictionary *)touchLinkInView:(UIView *)view atPoint:(CGPoint)touchPoint data:(TSCTCoreTextData *)data {
    CTFrameRef frameRef = data.frameRef;
    CFArrayRef lineArrayRef = CTFrameGetLines(frameRef);
    CFIndex lineCount = CFArrayGetCount(lineArrayRef);
    
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), lineOrigins);
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    for (int i=0; i<lineCount; i++) {
        CTLineRef lineRef = CFArrayGetValueAtIndex(lineArrayRef, i);
        CGRect lineBounds = [self lineBoundsWithLineRef:lineRef lineOrigin:lineOrigins[i]];
        /** 将lineBounds转换为UIKit坐标系下的 */
        CGRect lineRealBounds = CGRectApplyAffineTransform(lineBounds, transform);
        
        if (CGRectContainsPoint(lineRealBounds, touchPoint)) {
            /** 将触摸点坐标转换为相对于当前行的坐标 */
            CGPoint touchPointRelateLine = CGPointMake(touchPoint.x - CGRectGetMinX(lineRealBounds), touchPoint.y - CGRectGetMinY(lineRealBounds));
            
            CFIndex index = CTLineGetStringIndexForPosition(lineRef, touchPointRelateLine);
            return [self linkDictAtLineStrIndex:index linkArray:data.linkArray];
        }
    }
    return nil;
}

/** 这里的坐标是在CoreText坐标系下的 */
+ (CGRect)lineBoundsWithLineRef:(CTLineRef)lineRef lineOrigin:(CGPoint)lineOrigin {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    
    /** descent为负。故是origin.y - descent */
    return CGRectMake(lineOrigin.x, lineOrigin.y - descent, width, height);
}

+ (NSDictionary *)linkDictAtLineStrIndex:(CFIndex)lineStrIndex linkArray:(NSArray *)linkArray {
    for (NSDictionary *linkDict in linkArray) {
        NSRange linkRange = [linkDict[@"range"] rangeValue];
        if (NSLocationInRange(lineStrIndex, linkRange)) {
            return linkDict;
        }
    }
    return nil;
}

@end
