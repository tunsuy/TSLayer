//
//  TSCTFrameParser.m
//  TSLayer
//
//  Created by tunsuy on 23/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import "TSCTFrameParser.h"
#import "TSCTFrameParserConfig.h"
#import "TSCTCoreTextData.h"
#import "NSString+TSEmoji.h"

@implementation TSCTFrameParser

#pragma mark - Public Method
+ (TSCTCoreTextData *)parserContent:(NSString *)content config:(TSCTFrameParserConfig *)config {
    NSDictionary *attributes = [self attributesWithConfig:config];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    
    return [self parserAttributedContent:attributedString config:config];
}

+ (TSCTCoreTextData *)parserAttributedContent:(NSAttributedString *)attributedContent config:(TSCTFrameParserConfig *)config {
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedContent);
    
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, config.width, textHeight));
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), pathRef, NULL);
    
    if (config.numberOfLines > 0) {
        NSAttributedString *attributedString = [self lineCutAttributeString:[attributedContent mutableCopy] lineWidth:config.width numberOfLines:config.numberOfLines frameRef:frameRef];
        textHeight = [self textHeightForAttributedString:attributedString numberOfLines:config.numberOfLines lineWidth:config.width frameRef:frameRef];
        
        framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
        pathRef = CGPathCreateMutable();
        CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, config.width, textHeight));
        frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), pathRef, NULL);
    }
    
    TSCTCoreTextData *coreTextData = [[TSCTCoreTextData alloc] init];
    coreTextData.frameRef = frameRef;
    coreTextData.height = textHeight;
    
    CFRelease(framesetterRef);
    CFRelease(pathRef);
    CFRelease(frameRef);
    
    return coreTextData;
}

+ (TSCTCoreTextData *)parserAttributedContentFromFile:(NSString *)filePath config:(TSCTFrameParserConfig *)config {
    if (!filePath || ![filePath isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    /** 使用强引用的方式传入方法中 */
    NSMutableArray *imageArray = [NSMutableArray array];
    NSMutableArray *linkArray = [NSMutableArray array];
    NSAttributedString *attributedContent = [self attributedContentFromFile:filePath config:config imageArray:imageArray linkArray:linkArray];
    TSCTCoreTextData *data = [self parserAttributedContent:attributedContent config:config];
    /** 将图像数据传入coreTextData对象属性中 */
    data.imageArray = [imageArray copy];
    data.linkArray = [linkArray copy];
    
    return data;
}

+ (NSDictionary *)attributesWithConfig:(TSCTFrameParserConfig *)config {
    CGFloat fontSize = config.fontSize;
    CTFontRef fontRef = CTFontCreateWithName(NULL, fontSize, NULL);
    
    CGFloat lineSpace = config.lineSpace;
    const CFIndex kNumberOfSettings = 3;
    CTParagraphStyleSetting settings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpace},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpace},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpace}
    };
    CTParagraphStyleRef paragraphRef = CTParagraphStyleCreate(settings, kNumberOfSettings);
    
    UIColor *textColor = config.textColor;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    /** 使用ct类型的属性会导致前端覆盖重定义的时候不生效，故使用下一种方式 */
    //    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    //    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    //    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)paragraphRef;
    
    dict[NSForegroundColorAttributeName] = textColor;
    dict[NSFontAttributeName] = (__bridge id)fontRef;
    dict[NSParagraphStyleAttributeName] = (__bridge id)paragraphRef;
    
    CFRelease(paragraphRef);
    CFRelease(fontRef);
    
    return dict;
}

#pragma mark - Private Method
/** imageArray存储内容中的图像数据 */
+ (NSAttributedString *)attributedContentFromFile:(NSString *)filePath
                                           config:(TSCTFrameParserConfig *)config
                                       imageArray:(NSMutableArray *)imageArray
                                        linkArray:(NSMutableArray *)linkArray {
    if (!filePath || ![filePath isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] init];
    
    if (data) {
        NSArray *attributedContentArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (![attributedContentArray isKindOfClass:[NSArray class]]) {
            return nil;
        }
        for (NSDictionary *dict in attributedContentArray) {
            NSAttributedString *subAttributedContent;
            if ([dict[@"type"] isEqualToString:@"txt"]) {
                subAttributedContent = [self attributedContentFromDict:dict config:config];
                [attributedContent appendAttributedString:subAttributedContent];
            }
            else if ([dict[@"type"] isEqualToString:@"img"]) {
                /** 使用字典类型存储存储图像信息 */
                NSMutableDictionary *imageDict = [NSMutableDictionary dictionary];
                imageDict[@"name"] = dict[@"name"];
                [imageArray addObject:imageDict];
                
                subAttributedContent = [self attributedImageContentFromDict:dict config:config];
                [attributedContent appendAttributedString:subAttributedContent];
            }
            else if ([dict[@"type"] isEqualToString:@"link"]) {
                NSUInteger linkStartPosition = attributedContent.length;
                subAttributedContent = [self attributedContentFromDict:dict config:config];
                [attributedContent appendAttributedString:subAttributedContent];
                NSUInteger linkLength = attributedContent.length - linkStartPosition;
                NSRange linkRange = NSMakeRange(linkStartPosition, linkLength);
                
                /** 使用字典类型存储存储链接信息 */
                NSMutableDictionary *linkDict = [NSMutableDictionary dictionary];
                linkDict[@"content"] = dict[@"content"];
                linkDict[@"url"] = dict[@"url"];
                linkDict[@"range"] = [NSValue valueWithRange:linkRange];
                [linkArray addObject:linkDict];
            }
            
        }
        return attributedContent;
    }
    return nil;
}

+ (NSAttributedString *)attributedContentFromDict:(NSDictionary *)dict config:(TSCTFrameParserConfig *)config {
    NSAssert([dict isKindOfClass:[NSDictionary class]], @"参数类型错误");
    NSMutableDictionary *attributed = [[self attributesWithConfig:config] mutableCopy];
    
    UIColor *textColor = [self colorWithDictForColorKey:dict[@"color"]];
    if (textColor) {
        attributed[NSForegroundColorAttributeName] = textColor;
    }
    
    if ([dict[@"size"] floatValue] > 0) {
        CTFontRef fontRef = CTFontCreateWithName(NULL, [dict[@"size"] floatValue], NULL);
        attributed[NSFontAttributeName] = (__bridge id)fontRef;
        CFRelease(fontRef);
    }
    
    return [[NSAttributedString alloc] initWithString:dict[@"content"] attributes:attributed];
}

+ (UIColor *)colorWithDictForColorKey:(NSString *)colorKey {
    if ([colorKey isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    }
    else if ([colorKey isEqualToString:@"red"]) {
        return [UIColor redColor];
    }
    else if ([colorKey isEqualToString:@"black"]) {
        return [UIColor blackColor];
    }
    else {
        return nil;
    }
}

#pragma mark - CTRunDelegateCallbacks
static CGFloat ascentCallback(void *ref) {
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref) {
    return 0;
}

static CGFloat widthCallback(void *ref) {
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"width"] floatValue];
}

+ (NSAttributedString *)attributedImageContentFromDict:(NSDictionary *)dict config:(TSCTFrameParserConfig *)config {
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    
    CTRunDelegateRef runDelegateRef = CTRunDelegateCreate(&callbacks, (__bridge void *)dict);
    unichar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSDictionary *attributes = [self attributesWithConfig:config];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, runDelegateRef);
    CFRelease(runDelegateRef);
    
    return space;
}

#pragma mark - 字符串截断处理
+ (NSAttributedString *)lineCutAttributeString:(NSMutableAttributedString *)attributeString lineWidth:(CGFloat)lineWidth numberOfLines:(NSUInteger)numberOfLines frameRef:(CTFrameRef)frameRef {
    if (!frameRef) {
        return nil;
    }
    CFRetain(frameRef);
    
    //获得显示行数的高度
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CFIndex count = CFArrayGetCount(lines);
    
    if (count == 0) {
        CFRelease(frameRef);
        return 0;
    }
    
    NSInteger linenum = count;
    if (numberOfLines > 0) {
        //判断numberOfLines和默认计算出来的行数的最小值，作为可以显示的行数
        linenum = MIN(numberOfLines, count);
    }
        
    //截到最后一行
    CTLineRef lineRef = CFArrayGetValueAtIndex(lines, linenum - 1);
    CFRange lastLineRange = CTLineGetStringRange(lineRef);
    NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length;
    NSMutableAttributedString *cutAttributedString = [[attributeString attributedSubstringFromRange:NSMakeRange(0, truncationAttributePosition)] mutableCopy];
    NSLog(@"cutAttributedString----cut before:%@",cutAttributedString.string);
    NSMutableAttributedString *lastLineAttributeString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
    NSString *kEllipsesCharacter = @"\u2026";//省略号
    NSMutableAttributedString *kEllipsesCharacterAttr = [[NSMutableAttributedString alloc] initWithString:kEllipsesCharacter attributes:@{NSForegroundColorAttributeName: [UIColor redColor]}];
    [lastLineAttributeString appendAttributedString:kEllipsesCharacterAttr];
        
    //对最后一行做处理
    lastLineAttributeString = [self cutLastLineAttributeString:lastLineAttributeString lineWidth:lineWidth];
    //替换最后一行
    cutAttributedString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(0, lastLineRange.location)] mutableCopy];
    [cutAttributedString appendAttributedString:lastLineAttributeString];
    attributeString = cutAttributedString;
    
//    CFRelease(lineRef);
    CFRelease(frameRef);
    
    //最后对textRect微调
//    return [self textRectForAttributedString:[attributeString mutableCopy] numberOfLines:numberOfLines lineWidth:lineWidth frameRef:frameRef];
    
    return attributeString;
}

+ (NSMutableAttributedString *)cutLastLineAttributeString:(NSMutableAttributedString *)attributeString lineWidth:(CGFloat)lineWidth
{
    CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)attributeString);
    CGFloat lastLineWidth = (CGFloat)CTLineGetTypographicBounds(truncationToken, nil, nil,nil);
    CFRelease(truncationToken);
    if (lastLineWidth>lineWidth) {
        NSLog(@"不够宽");
        //Emoji表情占两个字符，因此需要判断
        NSString *lastString = [[attributeString attributedSubstringFromRange:NSMakeRange(attributeString.length - 3, 2)] string];
        //减去省略号前一个符号；
        BOOL isEmoji = [NSString ts_stringContainsEmoji:lastString];
        [attributeString deleteCharactersInRange:NSMakeRange(attributeString.length - (isEmoji?3:2), isEmoji?2:1)];
        //递归处理，直到够宽为止
        return [self cutLastLineAttributeString:attributeString lineWidth:lineWidth];
    }
    else {
        NSLog(@"够宽");
        return attributeString;
    }
}

+ (CGFloat)textHeightForAttributedString:(NSAttributedString *)attributedString numberOfLines:(NSInteger)numberOfLines lineWidth:(CGFloat)lineWidth frameRef:(CTFrameRef)frameRef {
    if (!frameRef) {
        return 0.0f;
    }
    CFRetain(frameRef);
    
    //获得显示行数的高度
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CFIndex count = CFArrayGetCount(lines);
    
    if (count == 0) {
        CFRelease(frameRef);
        return 0.0f;
    }
    
    //根据numberOfLines显示的行数判断，如果等于0，就默认suggestSize
    NSInteger linenum = count;
    if (numberOfLines > 0) {
        //判断numberOfLines和默认计算出来的行数的最小值，作为可以显示的行数
        linenum = MIN(numberOfLines, count);
    }
    
    CTLineRef lineRef = CFArrayGetValueAtIndex(lines, linenum-1);
    CFRange lastLineRange = CTLineGetStringRange(lineRef);
    NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length;
    NSMutableAttributedString *maxAttributedString = [[attributedString attributedSubstringFromRange:NSMakeRange(0, truncationAttributePosition)] mutableCopy];
    
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)maxAttributedString);
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, maxAttributedString.length), NULL, CGSizeMake(lineWidth, MAXFLOAT), NULL);
    
//    CGMutablePathRef pathRef = CGPathCreateMutable();
//    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, lineWidth, suggestSize.height));
//    CTFrameRef realFrameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), pathRef, NULL);
//    CFRetain(realFrameRef);
//    frameRef = realFrameRef;
    
    CFRelease(framesetterRef);
    CFRelease(lineRef);
    CFRelease(frameRef);
//    CFRelease(pathRef);

    return suggestSize.height;
}

@end
