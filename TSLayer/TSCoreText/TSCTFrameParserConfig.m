//
//  TSCTFrameParserConfig.m
//  TSLayer
//
//  Created by tunsuy on 23/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import "TSCTFrameParserConfig.h"

@implementation TSCTFrameParserConfig

- (instancetype)init {
    if (self = [super init]) {
        /** 默认属性值 */
        self.width = 200.f;
        self.fontSize = 30.f;
        self.lineSpace = 8.f;
        self.textColor = RGB(108, 108, 108);
        self.numberOfLines = 0; 
    }
    return self;
}

@end
