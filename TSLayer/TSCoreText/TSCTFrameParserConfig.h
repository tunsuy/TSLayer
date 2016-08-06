//
//  TSCTFrameParserConfig.h
//  TSLayer
//
//  Created by tunsuy on 23/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TSCTFrameParserConfig : NSObject

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) NSUInteger numberOfLines; //显示的行数，默认为0，不限制

@end
