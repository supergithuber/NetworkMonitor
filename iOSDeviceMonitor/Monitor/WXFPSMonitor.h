//
//  WXFPSMonitor.h
//  NetworkMonitor
//
//  Created by HFY on 2018/7/26.
//  Copyright © 2018年 wuxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^WXFPSMonitorBlock)(float fps);

@interface WXFPSMonitor : NSObject

@property (nonatomic, copy) WXFPSMonitorBlock fpsBlock;

+ (instancetype)sharedInstance;

- (void)startMonitor;
- (void)stopMonitor;

@end
