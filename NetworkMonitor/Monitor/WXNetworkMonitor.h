//
//  WXNetworkMonitor.h
//  NetworkMonitor
//
//  Created by Wuxi on 2018/7/7.
//  Copyright © 2018年 wuxi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXNetworkMonitor : NSObject

+ (instancetype)sharedInstance;

- (void)startMonitor;
- (void)stopMonitor;

@end
