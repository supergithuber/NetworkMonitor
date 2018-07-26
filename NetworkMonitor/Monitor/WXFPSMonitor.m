//
//  WXFPSMonitor.m
//  NetworkMonitor
//
//  Created by HFY on 2018/7/26.
//  Copyright © 2018年 wuxi. All rights reserved.
//

#import "WXFPSMonitor.h"

@interface WXFPSMonitor()

@property (nonatomic, strong)CADisplayLink *displayLink;

@property (nonatomic, assign)NSTimeInterval lastTimestamp;
@property (nonatomic, assign)NSUInteger displayTimes;

@end

@implementation WXFPSMonitor

static WXFPSMonitor *shared = nil;

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

+ (instancetype)allocWithZone:(struct _NSZone*)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [super allocWithZone:zone];
    });
    return shared;
}

- (void)startMonitor{
    if (self.displayLink == nil){
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTicks:)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink = displayLink;
    }
}

- (void)stopMonitor{
    if (self.displayLink){
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

- (void)displayLinkTicks:(CADisplayLink *)displayLink{
    if (_lastTimestamp == 0){
        _lastTimestamp = displayLink.timestamp;
        return;
    }
    _displayTimes++;
    NSTimeInterval timeInterval = displayLink.timestamp - _lastTimestamp;
    if (timeInterval < 1){
        return;
    }
    _lastTimestamp = displayLink.timestamp;
    float fps = _displayTimes / timeInterval;
    if (self.fpsBlock){
        self.fpsBlock(fps);
    }
    _displayTimes = 0;
    
}
@end
