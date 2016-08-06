//
//  TSCTDisplayLayer.h
//  TSLayer
//
//  Created by tunsuy on 23/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class TSCTCoreTextData;

@interface TSCTDisplayLayer : CATextLayer

@property (nonatomic, strong) TSCTCoreTextData *data;

@end
