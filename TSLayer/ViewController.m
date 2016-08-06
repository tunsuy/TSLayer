//
//  ViewController.m
//  TSLayer
//
//  Created by tunsuy on 21/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import "ViewController.h"
#import "TSCTCoreTextData.h"
#import "TSCTFrameParser.h"
#import "TSCTFrameParserConfig.h"
#import "TSCTDisplayLayer.h"
#import "TSCTDisplayView.h"

@interface ViewController ()

@property (nonatomic, strong) TSCTDisplayLayer *displayLayer;
@property (nonatomic, strong) TSCTDisplayView *displayView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
 
    /** 直接绘制在layer上 */
//    _displayLayer = [TSCTDisplayLayer layer];
//    _displayLayer.frame = CGRectMake(20, 80, SCREEN_WIDTH - 40, SCREEN_HEIGHT - 80);
//    _displayLayer.backgroundColor = [UIColor yellowColor].CGColor;
//    
//    TSCTFrameParserConfig *config = [[TSCTFrameParserConfig alloc] init];
//    config.width = _displayLayer.bounds.size.width;
//    config.textColor = [UIColor redColor];
    
//    NSString *content =
//        @"合适的国家粮食局大概就是了大概就是的速度就分了就发了多少分开始放"
//         "三个老师说的估计是浪费啥地方噶是的噶速度高"
//         "威迫我屁股上；顾客时空公司；打开速度";
    
    /** 对整段文字进行设置 */
//    TSCTCoreTextData *data = [TSCTFrameParser parserContent:content config:config];
    
    /** 个性化部分文字 */
//    NSDictionary *attr = [TSCTFrameParser attributesWithConfig:config];
//    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:content attributes:attr];
//    [attributedContent addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, 10)];
//    TSCTCoreTextData *data = [TSCTFrameParser parserAttributedContent:attributedContent config:config];
    
    /** 读取文件属性化内容 */
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"AttributedContent" ofType:@"json"];
//    TSCTCoreTextData *data = [TSCTFrameParser parserAttributedContentFromFile:filePath config:config];
//    
//    _displayLayer.data = data;
//    CGRect frame = _displayLayer.frame;
//    frame.size.height = data.height;
//    _displayLayer.frame = frame;
//    
//    [self.view.layer addSublayer:_displayLayer];
    
    
    _displayView = [[TSCTDisplayView alloc] initWithFrame:CGRectMake(20, 80, SCREEN_WIDTH - 40, SCREEN_HEIGHT - 80)];
    _displayView.backgroundColor = [UIColor whiteColor];
    
    TSCTFrameParserConfig *config = [[TSCTFrameParserConfig alloc] init];
    config.width = _displayView.bounds.size.width;
    config.textColor = [UIColor redColor];
    config.numberOfLines = 5;
    
    /** 读取文件属性化内容 */
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"AttributedContent" ofType:@"json"];
    TSCTCoreTextData *data = [TSCTFrameParser parserAttributedContentFromFile:filePath config:config];
    
    _displayView.data = data;
    CGRect frame = _displayView.frame;
    frame.size.height = data.height;
    _displayView.frame = frame;
    
    [self.view addSubview:_displayView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
