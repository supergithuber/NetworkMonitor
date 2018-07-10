//
//  WXNetworkMonitor.h
//  NetworkMonitor
//
//  Created by Wuxi on 2018/7/7.
//  Copyright © 2018年 wuxi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WXNetworkBlock)(uint32_t allBytes, uint32_t wifiBytes, uint32_t wwanBytes);   //回调的单位是bytes/s，自己按位运算得到自己想要的单位

@interface WXNetworkMonitor : NSObject

@property (nonatomic, assign)NSTimeInterval timeInterval;

+ (instancetype)sharedInstance;

- (void)startMonitorWithInblock:(WXNetworkBlock)inBlock outBlock:(WXNetworkBlock)outBlock;
- (void)stopMonitor;

@end
