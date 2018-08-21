# NSProtocolMockNetWork
本例实现了基于NSURLProtocol对WKWebview，普通http请求，AFN3.0的mock
##NSURLProtocolproperty
苹果官方是这样描述的：
```objc
/**
NSURLProtocol is an abstract class which provides the
basic structure for performing protocol-specific loading of URL
data. Concrete subclasses handle the specifics associated with one
or more protocols or URL schemes.*/
```
##对它的基本使用可以参考苹果的官方[demo](https://developer.apple.com/library/ios/samplecode/CustomHTTPProtocol/CustomHTTPProtocol.zip)

##基本使用
*`必须实现的几个方法`
```
+ (BOOL)registerClass:(Class)protocolClass;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request;

+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest*)theRequest

- (void)startLoading

- (void)stopLoading

```

##如何拦截AFN3.0
```objc
我们监控网络是通过注册NSURLProtocol来进行网络监控的,
但是通过 sessionWithConfiguration:delegate:delegateQueue:
得到的session,他的configuration中已经有一个NSURLProtocol,
所以他不会走我们的protocol来,怎么解决这个问题呢?
其实很简单,我们将NSURLSessionConfiguration的属性protocolClasses的get方法hook掉,
通过返回我们自己的protocol,这样,
我们就能够监控到通过 sessionWithConfiguration:delegate:delegateQueue:
得到的session的网络请求
```
```
+ (void)exchangeNSURLSessionConfiguration{
Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
Method originalMethod = class_getInstanceMethod(cls, @selector(protocolClasses));
Method stubMethod = class_getInstanceMethod([self class], @selector(protocolClasses));
if (!originalMethod || !stubMethod) {
[NSException raise:NSInternalInconsistencyException format:@"Couldn't load NEURLSessionConfiguration."];
}
method_exchangeImplementations(originalMethod, stubMethod);
}

- (NSArray *)protocolClasses{
//此处不可以使用self，方法替换后self是URLSessionConfigration
return @[[CustomProtocol class]];
}
```

##如何拦截WKWebview的请求
*`WKWebView是基于webkit，网络请求有自己单独的进程，不走主线程的URL Loading Systerm`
*`我们通过私有API注册我们自己的protocol`
```
Class cls = [[[WKWebView new] valueForKey:@"browsingContextController"] class];
SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
if ([(id)cls respondsToSelector:sel]) {
[(id)cls performSelector:sel withObject:@"http"];
[(id)cls performSelector:sel withObject:@"https"];
[(id)cls performSelector:sel withObject:@"myapp"];
}
```

##实现效果
*在demo中我在WKwebview上加载了一张本地图片，
```objc
2018-08-21 16:46:44.038552+0800
NSURLProtocolLoadLocalImage[61581:11346857] myapp://image1.png
```
*使用AFN请求返回本地数据
```objc
2018-08-21 16:46:43.027131+0800 NSURLProtocolLoadLocalImage[61581:11346581] {
content = "";
flag = "";
messageId = appVersionUpdate;
reviewing = 1;
statusCode = 0;
title = "";
updateList =     (
);
updateTime = "";
url = "";
versionCode = "2.1";
versionName = "";
}
```



















