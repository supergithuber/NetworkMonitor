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
    uint32_t _wifiInBytes;
    uint32_t _wifiOutBytes;
    uint32_t _wifiAllBytes;
    uint32_t _wwanInBytes;
    uint32_t _wwanOutBytes;
    uint32_t _wwanAllBytes;
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
        _inBytes = _outBytes = _allBytes = _wifiInBytes = _wifiOutBytes = _wifiAllBytes = _wwanInBytes = _wwanOutBytes = _wwanAllBytes = 0;
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
    uint32_t wifiInBytes = 0;
    uint32_t wifiOutBytes = 0;
    uint32_t wifiAllBytes = 0;
    uint32_t wwanInBytes = 0;
    uint32_t wwanOutBytes = 0;
    uint32_t wwanAllBytes = 0;
    
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
        //wifi
        if (!strcmp(ifa->ifa_name, "en0")) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            wifiInBytes += if_data->ifi_ibytes;
            wifiOutBytes += if_data->ifi_obytes;
            wifiAllBytes = wifiInBytes + wifiOutBytes;
        }
        //3G or gprs
        if (!strcmp(ifa->ifa_name, "pdp_ip0")) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            wwanInBytes += if_data->ifi_ibytes;
            wwanOutBytes += if_data->ifi_obytes;
            wwanAllBytes = wwanInBytes + wwanOutBytes;
        }
    }
    freeifaddrs(ifa_list);
    if (_inBytes != 0) {
        if (inBlock){
            inBlock(inBytes - _inBytes, wifiInBytes - _wifiInBytes, wwanInBytes - _wwanInBytes);
        }
    }
    _inBytes = inBytes;
    _wifiInBytes = wifiInBytes;
    _wwanInBytes = wwanInBytes;
    if (_outBytes != 0) {
        if (outBlock){
            outBlock(outBytes - _outBytes, wifiOutBytes - _wifiOutBytes, wwanOutBytes - _wwanOutBytes);
        }
    }
    _outBytes = outBytes;
    _wifiOutBytes = wwanOutBytes;
    _wwanOutBytes = wwanOutBytes;
}

- (void)stopMonitor {
    if ([self.timer isValid]){
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
