//
//  TSCTFrameParser.h
//  TSLayer
//
//  Created by tunsuy on 23/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSCTFrameParserConfig;
@class TSCTCoreTextData;

@interface TSCTFrameParser : NSObject

+ (TSCTCoreTextData *)parserContent:(NSString *)content config:(TSCTFrameParserConfig *)config;
+ (TSCTCoreTextData *)parserAttributedContent:(NSAttributedString *)attributedContent config:(TSCTFrameParserConfig *)config;
+ (TSCTCoreTextData *)parserAttributedContentFromFile:(NSString *)filePath config:(TSCTFrameParserConfig *)config;

+ (NSDictionary *)attributesWithConfig:(TSCTFrameParserConfig *)config;

@end
