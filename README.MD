## iOSDeviceMonitor

### Usage

#### Network

```objectiveC
+ (instancetype)sharedInstance;

- (void)startMonitorWithInblock:(WXNetworkBlock)inBlock outBlock:(WXNetworkBlock)outBlock;
- (void)stopMonitor;
```

block will return 1 time per seconds, unit is bytes/s.
transform units according to you.

#### FPS

```objectiveC
@property (nonatomic, copy) WXFPSMonitorBlock fpsBlock;

+ (instancetype)sharedInstance;

- (void)startMonitor;
- (void)stopMonitor;
```

#### CPU and Memory

```objectiveC
@property (nonatomic, copy)WXMemoryBlock memoryBlock;
@property (nonatomic, copy)WXCPUBlock cpuBlock;

+ (instancetype)sharedInstance;

- (void)startMonitor;
- (void)stopMonitor;
```

### carthage 

```
github "supergithuber/iOSDeviceMonitor" ~> 0.8.0
```

### Manual

* drag folder Monitor files to your project.

or

* drag framework NetworkCardMonitor.framework to your project