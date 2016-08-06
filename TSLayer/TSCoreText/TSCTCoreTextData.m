//
//  TSCTCoreTextData.m
//  TSLayer
//
//  Created by tunsuy on 23/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import "TSCTCoreTextData.h"

@implementation TSCTCoreTextData

- (void)setFrameRef:(CTFrameRef)frameRef {
    if (_frameRef != frameRef) {
        if (_frameRef) {
            CFRelease(_frameRef);
        }
        CFRetain(frameRef);
        _frameRef = frameRef;
    }
}

- (void)setImageArray:(NSArray *)imageArray {
    _imageArray = imageArray;
    [self fillImagePosition];
}

- (void)fillImagePosition {
    if ([_imageArray count] == 0) {
        return;
    }
    NSArray *lines = (NSArray *)CTFrameGetLines(self.frameRef);
    NSUInteger lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, 0), lineOrigins);
    
    int imageIndex = 0;
    NSMutableDictionary *imageData = self.imageArray[0];
    
    for (int i=0; i<lineCount; i++) {
        if (!imageData) {
            break;
        }
        
        CTLineRef lineRef = (__bridge CTLineRef)lines[i];
        NSArray *runObjArray = (NSArray *)CTLineGetGlyphRuns(lineRef);
        
        for (id runObj in runObjArray) {
            CTRunRef runRef = (__bridge CTRunRef)runObj;
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(runRef);
            CTRunDelegateRef runDelegateRef = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (!runDelegateRef) {
                continue;
            }
            
            NSDictionary *metaDict = CTRunDelegateGetRefCon(runDelegateRef);
            if (![metaDict isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            runBounds.size.width = CTRunGetTypographicBounds(runRef, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            
            CGFloat offsetX = CTLineGetOffsetForStringIndex(lineRef, CTRunGetStringRange(runRef).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + offsetX;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;
            
            CGPathRef pathRef = CTFrameGetPath(self.frameRef);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            
            /** 保存图像的现实位置 */
            imageData[@"position"] = [NSValue valueWithBytes:&delegateBounds objCType:@encode(CGRect)];
 
            if (++imageIndex == [self.imageArray count]) {
                imageData = nil;
                break;
            }
            else {
                imageData = self.imageArray[imageIndex];
            }
        }
    }
}

- (void)dealloc {
    if (_frameRef) {
        CFRelease(_frameRef);
        _frameRef = nil;
    }
}

@end
