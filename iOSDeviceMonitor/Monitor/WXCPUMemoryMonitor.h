//
//  WXCPUMemoryMonitor.h
//  NetworkMonitor
//
//  Created by HFY on 2018/7/26.
//  Copyright © 2018年 wuxi. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^WXMemoryBlock)(float memory);  //MB
typedef void(^WXCPUBlock)(float cpu);  //percentage

@interface WXCPUMemoryMonitor : NSObject

@property (nonatomic, copy)WXMemoryBlock memoryBlock;
@property (nonatomic, copy)WXCPUBlock cpuBlock;

+ (instancetype)sharedInstance;

- (void)startMonitor;
- (void)stopMonitor;

@end
