//
//  CustomProtocol.m
//  NSURLProtocolLoadLocalImage
//
//  Created by jorgon on 20/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "CustomProtocol.h"
#import <objc/runtime.h>
#import <WebKit/WebKit.h>

@implementation CustomProtocol

static NSString * requestkey = @"requestkey";
+ (void)start{
    [self exchangeNSURLSessionConfiguration];
    [NSURLProtocol registerClass:[self class]];
    Class cls = [[[WKWebView new] valueForKey:@"browsingContextController"] class];
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    if ([(id)cls respondsToSelector:sel]) {
        [(id)cls performSelector:sel withObject:@"http"];
        [(id)cls performSelector:sel withObject:@"https"];
        [(id)cls performSelector:sel withObject:@"myapp"];
    }
}

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
+ (BOOL)canInitWithRequest:(NSURLRequest*)theRequest
{
    BOOL shouldAccept = NO;
    if ([theRequest.URL.scheme caseInsensitiveCompare:@"myapp"] == NSOrderedSame) {
        shouldAccept = YES;
    } else {
        NSURL * url = theRequest.URL;
        NSString * fileName = [url.lastPathComponent stringByAppendingString:@"Response"];
        NSString * filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
        shouldAccept = filePath!= nil;
        
    }
    if ([self propertyForKey:requestkey inRequest:theRequest]) {
        shouldAccept = NO;
    }
    return shouldAccept;
}


+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest*)theRequest
{
    return theRequest;
}

- (void)startLoading
{
    NSLog(@"%@", self.request.URL);
    NSString * shceme = self.request.URL.scheme;
    NSData * data = nil;
    NSURLResponse *response = nil;
    if ([shceme isEqualToString:@"myapp"]) {
        response = [[NSURLResponse alloc] initWithURL:[self.request URL]
                                                            MIMEType:@"image/png"
                                               expectedContentLength:-1
                                                    textEncodingName:nil];
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"image1" ofType:@"png"];
        data = [NSData dataWithContentsOfFile:imagePath];
    } else {
        NSString * fileName = [self.request.URL.lastPathComponent stringByAppendingString:@"Response"];
        NSString * filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@".json"];
        response = [[NSURLResponse alloc] initWithURL:[self.request URL]
                                                            MIMEType:@"application/json"
                                               expectedContentLength:-1
                                                    textEncodingName:nil];
        data = [NSData dataWithContentsOfFile:filePath];
    }
    
    [self.class setProperty:@YES forKey:requestkey inRequest:self.request.mutableCopy];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self client] URLProtocol:self didLoadData:data];
    [[self client] URLProtocolDidFinishLoading:self];
}

/*!
 @method stopLoading
 @abstract Stops protocol-specific loading of a request.
 @discussion When this method is called, the protocol implementation
 should end the work of loading a request. This could be in response
 to a cancel operation, so protocol implementations must be able to
 handle this call while a load is in progress.
 当调用此方法时，协议实现应该结束加载请求的工作。
 这可能是对取消操作的响应，因此协议实现必须能够在加载过程中处理此调用
 */

- (void)stopLoading
{
    NSLog(@"request cancel");
}

@end
