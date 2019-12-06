# NetworkMonitor

## 简介
NetworkMonitor主要用于监控应用的网络请求，获取网络请求相关的性能参数，方便开发、测试、产品等人员对应用进行分析。监控的指标主要有：成功率、状态码、流量、网络响应时间、HTTP与HTTPS的 DNS 解析、TCP握手、SSL握手（HTTPS）等。
NetworkMonitor的优点主要有：
* 收集数据全面。主要监控参数如上所述，基本涵盖了网络监控需求。
* 监控范围广。基本涵盖了应用层的网络请求，但是UIWebView/WKWebView除外，这个是后续开发方向。
* 接入使用方便。采用无埋点的数据收集方式，用户不需要手动埋点，接入只需要几行代码，即可收集基本数据。
* 可扩展性强。除了基本参数之外，用户还可以自定义扩展参数。
* 简洁轻量。SDK包大小不到0.5M，运行内存小，不挤占主应用资源。
* 数据准确度较高。SDK尽可能地使用了系统提供的数据，对于自己计算得到的数据，都经过了校准调优。

## 原理及设计
见 [iOS端网络监控思路及实现](https://www.jianshu.com/p/3bdb027a63c7)

## 集成使用

### 导入SDK
将NetworkMonitor.framework导入到工程中，并在工程配置中General—>Embedded Binaries中添加该framework。

### SDK使用
1、初始化配置
网络监控配置项都封装在NMConfig类中，通过执行以下代码初始化配置。
```
NMConfig *config = [[NMConfig alloc] init];
config.enableNetworkMonitor = YES;
config.enableLog = YES;
…
[[NMManager sharedNMManager] initConfig:config];
```
配置项说明：
-  enableNetworkMonitor：监控总开关，默认为NO。如果配置为NO，NetworkMonitor中任何代码都不会运行。
-  enableLog：日志开关，默认为YES。
- enableInterferenceMode：是否开启干扰模式，默认为NO;非干扰模式下，记录结束时间由SDK决定;干扰模式下，记录结束由用户手动触发。
- urlWhiteList：排除在监控之外的url列表。
- cmdWhiteList：排除在监控之外的cmd(即接口方法)列表。

2、开始/结束监控
完成初始化配置之后，调用NMManager中的开始/停止方法，就可以启动/关闭监控了。
开始监控：
```
[[NMManager sharedNMManager] start];
```
停止监控：
```
[[NMManager sharedNMManager] stop];
```

注：start/stop方法是动态开关。执行start之后，NetworkMonitor中所有hook逻辑就执行了。但stop并不是对hook的逆操作，执行stop只是阻止了NetworkMonitor内部进行数据的收集和处理。

至此，简单的几步，就可以完成基础默认数据的收集了。

3、监控数据的输出
上面已经完成基础数据的收集了，NetworkMonitor内部是不带数据上传的，那么怎么获取到收集的数据呢？有两种方式：
* 默认方式
收集到的数据会默认存储在NetworkMonitor内部的数据库。可以通过NetworkMonitor的方法将数据取出。
对数据操作的方法主要有下面几个：
```
NSArray *data = [[NMManager sharedNMManager] getAllData];
```
获取所有数据。
```
[[NMManager sharedNMManager] removeAllData];
```
删除所有数据。
* 设置数据输出block
```
[NMManager sharedNMManager].outputBlock = ^(NSString *traceId, NSDictionary *data){
}
```
如果设置了outputBlock，默认方式将会失效。而且所有收集到的数据将会一条一条地通过outputBlock回调输出出来，每收集到一条数据回调一次。

4、数据收集模式
数据收集模式有两种，分别是默认模式和干预模式。通过前面介绍的配置项enableInterferenceMode进行设置。这两种模式的主要区别在于，一条网络请求数据收集结束的时间。
在默认模式下，一条请求数据收集完成，SDK内部会自动结束该次数据的收集。而在干预模式下，需要开发者手动调用以下方法完成数据收集：
```
[[NMManager sharedNMManager] finishColection:traceId];
```

5、扩展参数设置
以上介绍的主要是默认的数据收集。但是，这些数据一般是很难满足业务需要。那么怎样将想要的其他数据放在这些基础数据一起进行收集呢？这就要用到扩展参数的设置。
扩展参数设置又分为网络请求之前参数设置和网络请求之后参数设置。
* 网络请求之前参数设置
有些参数需要在网络请求发起之前进行设置，例如网络请求接口名(cmd)、设备信息等。NetworkMonitor提供了两种设置网络请求之前参数的方法。
一种是引入头文件“NSURL+NM.h”，然后把参数绑定在NSURL实例的extendedParameter属性上，如下所示：
```
[NSURL *url = [NSURL URLWithString:@"xxx"];
url.extendedParameter = @{@"cmd":@"xxx"};
```
另一种情况是，NSURL实例被封装了，外面看不到，例如AFNetworking。这种情况一般可以拿到网络请求头的字典，直接用SDK提供的宏定义HEAD_KEY_MAKE（）将key封装一下作为请求头中的key，再把value设置进求头中就可以了。例如：
```
NSString * key = @"xxx";
AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
[manager.requestSerializer setValue: @"xxx" forHTTPHeaderField:HEAD_KEY_MAKE(key)];
```
* 网络请求之后参数设置
需要网络请求之后进行设置的参数，一般是网络请求结果或者依赖于网络请求结果的数据，例如：下载文件的md5等。需要注意的是，这种情况一般需要开发者手动结束SDK的数据收集，即配合干预模式使用。
此时可以调用SDK的setExtendedParameter:方法进行设置。如下所示，需要传入traceId参数，可以从响应头中拿到。
```
NSString *traceId = mrq.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
[[NMManager sharedNMManager] setExtendedParameter:@{@"xxx": @"xxx"} traceId:traceId];
```
然后需要手动调用finishColection:traceId，以结束数据收集。
```
[[NMManager sharedNMManager] finishColection:traceId];
```

6、名词解释
traceId：一次网络请求数据记录的唯一标志。

干预模式：开发者能够手动干预SDK数据收集的模式。

白名单：网络请求url或者同一url下面的不同服务端接口，如果加在了白名单中，那么对该url或者url下面服务端接口的网络请求数据不会被SDK收集。

SDK定义的一些特定Key：
```
NMDATA_KEY_CMD; //接口描述
NMDATA_KEY_ERRORTYPE; //错误类型
NMDATA_KEY_RESPONSEDATA; //返回包（状态为失败时记录）
NMDATA_KEY_ORIGINALMD5; //原始md5信息
NMDATA_KEY_DOWNLOADMD5; //下载成功文件的md5信息
NMDATA_KEY_ORIGINALSIZE; //原始文件大小
NMDATA_KEY_DOWNLOADSIZE; //下载成功文件的文件大小
NMDATA_KEY_REALDOWNLOADSIZE; //实际下载大小（md5不一致时记录）
```
注：在引入NetworkMonitor.framework之后，这些key是可以直接使用的。在拿到这些key对应的value之后，可以直接设置到扩展参数中。

7、SDK中参数含义对照表

| 参数key | 参数含义 |
| ------ | ------ |
| ti | 单次请求的唯一id |
| apn | 当前接入点名称(wifi、cmwap、ctwap、uniwap、cmnet、uninet、ctnet、g3net、g3wap、unknown) |
| ns(networktype) | 网络类型 |
| cmd | 接口描述 |
| ourl(originalUrl) | 原始url |
| rurl(redirectUrl) | 重定向url |
| oip(originalIp) | 原始ip |
| rip(redirectIp) | 重定向ip |
| reqs(requestSize) | 请求包大小 |
| state | 接口请求结果：success、failure、cancel |
| sc(statusCode) | 状态码 |
| etp(errorType) | 错误类型：1网络错误 2http错误 3业务错误 |
| ec(errorCode) | 错误码 |
| ed(errorDetail) | 错误描述 |
| ress(responseSize) | 返回包大小 |
| cty(contentType) | mimeType |
| ddata(responseData) | 返回包(状态为失败时记录) |
| sreq(startRequest) | 请求开始时间 |
| dnst(dnsTime) | 域名解析的时间 |
| sslt(sslTime) | SSL的时间，仅针对https，当http时此项为空 |
| cnnt(connTime) | 与服务器建立tcp链接需要的时间 |
| sdt(sendTime) | 从客户端发送HTTP请求到服务器所耗费的时间 |
| wtt(waitTime) | 响应报文首字节到达时间 |
| rcvt(receiveTime) | 客户端从开始接收数据到接收完所有数据的时间 |
| eres(endResponse) | 响应结束时间 |
| ttt(totalTime) | 请求总耗时 |
| omd5(originalMd5) | 原始md5信息 |
| dmd5(downloadMd5) | 下载成功文件的md5信息 |
| osize(originalSize) | 原始文件大小，单位：字节 |
| dsize(downloadSize) | 下载成功文件的文件大小，单位：字节 |
| rdsize(realDownloadSize) | 实际下载大小(md5不一致时记录)，单位：字节 |
