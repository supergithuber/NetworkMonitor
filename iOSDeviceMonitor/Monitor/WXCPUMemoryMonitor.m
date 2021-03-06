//
//  WXCPUMemoryMonitor.m
//  NetworkMonitor
//
//  Created by HFY on 2018/7/26.
//  Copyright © 2018年 wuxi. All rights reserved.
//

#import "WXCPUMemoryMonitor.h"
#import <sys/sysctl.h>
#import <mach/mach.h>

@interface WXCPUMemoryMonitor()

@property (nonatomic, strong)NSTimer* timer;

@end

@implementation WXCPUMemoryMonitor

static WXCPUMemoryMonitor* instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)startMonitor{
    if (!self.timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getCPUAndMemory:) userInfo:nil repeats:YES];
        [_timer fire];
    }
}

- (void)stopMonitor{
    if (self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)getCPUAndMemory:(NSTimer *)timer{
    float cpuPercentage = [self cpu_usage];
    float memoryUsage = [self memory_usage];
    if (self.memoryBlock) {
        self.memoryBlock(memoryUsage);
    }
    if (self.cpuBlock) {
        self.cpuBlock(cpuPercentage);
    }
}

- (float)memory_usage {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    if (kernReturn != KERN_SUCCESS) { return NSNotFound; }
    return taskInfo.resident_size/1024.0/1024.0;
}

- (float)cpu_usage{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0;
    
    basic_info = (task_basic_info_t)tinfo;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    }
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}
@end
