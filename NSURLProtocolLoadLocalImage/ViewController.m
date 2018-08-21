//
//  ViewController.m
//  NSURLProtocolLoadLocalImage
//
//  Created by jorgon on 20/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "ViewController.h"
#import "CustomProtocol.h"
#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(20, 20, 300, 520) configuration:[WKWebViewConfiguration new]];
    [self.view addSubview:self.webView];
    NSString * localHtmlFilePath = [[NSBundle mainBundle] pathForResource:@"file" ofType:@"html"];
    
    NSString * localHtmlFileURL = [NSString stringWithFormat:@"file://%@", localHtmlFilePath];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:localHtmlFileURL]]];
    
     [self network];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self network];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self network];
}

- (void)network{
//    NSURLSession * session = [NSURLSession sharedSession];
//    NSURLSessionTask * task = [session dataTaskWithURL:[NSURL URLWithString:@"https://mob-tech.meme2c.com/ums/app/appVersionUpdate"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSLog(@"%@",response);
//    }];
//    [task resume];
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
     [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = AFJSONRequestSerializer.serializer;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", @"application/xml", @"text/xml", @"*/*", nil];
    [manager POST:@"https://mob-tech.meme2c.com/ums/app/appVersionUpdate"
       parameters:@{} progress:^(NSProgress * _Nonnull uploadProgress) {

                              } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  NSLog(@"sucess--------------");

                                  NSLog(@"%@",responseObject);
                              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  NSLog(@"%@",error);
                              }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
