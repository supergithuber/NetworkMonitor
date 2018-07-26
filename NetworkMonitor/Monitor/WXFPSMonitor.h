//
//  WXFPSMonitor.h
//  NetworkMonitor
//
//  Created by HFY on 2018/7/26.
//  Copyright © 2018年 wuxi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WXFPSMonitorBlock)(float fps);

@interface WXFPSMonitor : NSObject

+ (instancetype)sharedInstance;

- (void)startMonitor:(WXFPSMonitorBlock)block;
- (void)stopMonitor;

@end
