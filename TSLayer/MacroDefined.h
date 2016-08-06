//
//  MacroDefined.h
//  TSLayer
//
//  Created by tunsuy on 22/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#ifndef MacroDefined_h
#define MacroDefined_h

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define SCREEN_NATIVE_SCALE ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]?[UIScreen mainScreen].nativeScale:SCREEN_SCALE)
#define SCREEN_SCALE ([UIScreen mainScreen].scale)

#ifdef DEBUG
#define debugLog(...) NSLog(__VA_ARGS__)
#define debugMethod() NSLog(@"%s", __func__)
#else
#define debugLog(...)
#define debugMethod()
#endif

#define RGB(A, B, C)    [UIColor colorWithRed:A/255.0 green:B/255.0 blue:C/255.0 alpha:1.0]


#endif /* MacroDefined_h */
