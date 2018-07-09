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

static NSString *const WXNetworkInBlockKey = @"wx.inblockKey";
static NSString *const WXNetworkOutBlockKey = @"wx.outblockKey";

@interface WXNetworkMonitor(){
    uint32_t _inBytes;
    uint32_t _outBytes;
    uint32_t _allBytes;
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
        _inBytes = _outBytes = _allBytes = 0;
    }
    return self;
}

- (void)startMonitorWithInblock:(WXNetworkBlock)inBlock outBlock:(WXNetworkBlock)outBlock {
    if (!_timer){
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[inBlock copy] forKey:WXNetworkInBlockKey];
        [dict setObject:[outBlock copy] forKey:WXNetworkOutBlockKey];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getNetworkSpeed:) userInfo:dict repeats:YES];
        [_timer fire];
    }
}

- (void)getNetworkSpeed:(NSTimer *)timer{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1) {  //获取网络接口信息
        return;
    }
    uint32_t inBytes = 0;
    uint32_t outBytes = 0;
    uint32_t allBytes = 0;
    
    WXNetworkBlock inBlock = [[timer userInfo]objectForKey:WXNetworkInBlockKey];
    WXNetworkBlock outBlock = [[timer userInfo]objectForKey:WXNetworkOutBlockKey];
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        if (ifa->ifa_data == 0)
            continue;
        //network
        if (strncmp(ifa->ifa_name, "lo", 2)){
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            inBytes += if_data->ifi_ibytes;
            outBytes += if_data->ifi_obytes;
            allBytes = inBytes + outBytes;
        }
    }
    freeifaddrs(ifa_list);
    if (_inBytes != 0) {
        if (inBlock){
            inBlock(inBytes - _inBytes);
        }
    }
    
    _inBytes = inBytes;
    if (_outBytes != 0) {
        if (outBlock){
            outBlock(outBytes - _outBytes);
        }
    }
    _outBytes = outBytes;
}

- (void)stopMonitor {
    if ([self.timer isValid]){
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
