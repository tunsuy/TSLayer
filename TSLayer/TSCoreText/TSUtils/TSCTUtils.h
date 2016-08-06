//
//  TSCTUtils.h
//  TSLayer
//
//  Created by tunsuy on 25/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TSCTCoreTextData;

@interface TSCTUtils : NSObject

+ (NSDictionary *)touchLinkInView:(UIView *)view atPoint:(CGPoint)touchPoint data:(TSCTCoreTextData *)data;

@end
