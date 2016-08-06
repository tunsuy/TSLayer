//
//  TSCTCoreTextData.h
//  TSLayer
//
//  Created by tunsuy on 23/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCTCoreTextData : NSObject

@property (nonatomic, assign) CTFrameRef frameRef;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) NSArray *imageArray; //存储内容中的图像
@property (nonatomic, strong) NSArray *linkArray; //存储内容中的链接

@end
