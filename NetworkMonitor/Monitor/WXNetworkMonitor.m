//
//  WXNetworkMonitor.m
//  NetworkMonitor
//
//  Created by Wuxi on 2018/7/7.
//  Copyright © 2018年 wuxi. All rights reserved.
//

#import "WXNetworkMonitor.h"
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>


@interface WXNetworkMonitor(){
    uint32_t _inBytes;
    uint32_t _outBytes;
    uint32_t _allBytes;
    
    uint32_t _inWifiBytes;
    uint32_t _outWifiBytes;
    uint32_t _allWifiBytes;
    
    uint32_t _inWanBytes;
    uint32_t _outWanBytes;
    uint32_t _allWanBytes;
}

@property (nonatomic, strong)NSTimer *timer;

@end

@implementation WXNetworkMonitor

static WXNetworkMonitor* singleton = nil;

- (void)dealloc{
    if (self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
}
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

+ (instancetype)allocWithZone:(struct _NSZone*)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [super allocWithZone:zone];
    });
    return singleton;
}

- (instancetype)init{
    if (self = [super init]){
        _inBytes = _outBytes = _allBytes = _inWifiBytes = _outWifiBytes = _allWifiBytes = _inWanBytes = _outWanBytes = _allWanBytes = 0;
    }
    return self;
}

- (void)startMonitor {
    
}

- (void)stopMonitor {
    
}

@end
