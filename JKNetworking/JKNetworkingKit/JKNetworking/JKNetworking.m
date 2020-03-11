//
//  JKNetworking.m
//  JKNetworking
//
//  Created by zhangjie on 2018/4/16.
//  Copyright © 2018年 zhangjie. All rights reserved.
//

#import "JKNetworking.h"

#import <objc/runtime.h>

static NSString *const sessionDescription = @"jknetworking_session";
#pragma mark - JKNetworkingCategory
@interface JKNetworking (Exit)
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *httpURLResponse;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error;
@end

#pragma mark - JKNetworkingDataTask Entity
@interface JKNetworkingDataTask ()
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;
@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic, assign) unsigned long long totalBytesRead;
- (NSURLSessionResponseDisposition)URLSession:(NSURLSession *)session
                                     dataTask:(NSURLSessionDataTask *)dataTask
                           didReceiveResponse:(NSURLResponse *)response;
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data;
@end
@implementation JKNetworkingDataTask
- (void)resume {
    [super resume];
    __weak typeof(self) weakSelf = self;
    self.sessionDataTask = [self.sessionManager dataTaskWithRequest:self.request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (self) {
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                self.httpURLResponse = (NSHTTPURLResponse *)response;
            }
            if (self.completionHandler) {
                self.completionHandler(error, responseObject);
            }
        }
    }];
    
    [self.sessionManager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
        __strong typeof(weakSelf) self = weakSelf;
        return [self URLSession:session dataTask:dataTask didReceiveResponse:response];
    }];
    
    [self.sessionManager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
        __strong typeof(weakSelf) self = weakSelf;
        [self URLSession:session dataTask:dataTask didReceiveData:data];
    }];
    
    [self.sessionDataTask resume];
}

- (void)cancel {
    [super cancel];
    [self.sessionDataTask cancel];
}
#pragma mark privateMethod
- (NSURLSessionResponseDisposition)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response {
    self.httpURLResponse = (NSHTTPURLResponse *)response;
    if (self.didReceiveResponseCallback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.didReceiveResponseCallback(self.httpURLResponse);
        });
    }
    self.progress = [NSProgress progressWithTotalUnitCount:0];
    self.progress.completedUnitCount = self.httpURLResponse.expectedContentLength;
    return NSURLSessionResponseAllow;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    self.totalBytesRead += (long long)data.length;
    self.progress.totalUnitCount = self.totalBytesRead;
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (wself.downloadProgressCallback) {
            wself.downloadProgressCallback(wself.progress);
        }
    });
}
@end

#pragma mark - JKNetworking Entity
@interface JKNetworking ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableDictionary *headers;
@end
@implementation JKNetworking {
    os_block_t _resumeCancel;
    BOOL _isResumed;
    BOOL _isCancelled;
}
#pragma mark - initialize
- (instancetype)init {
    if (self = [super init]) {
        self.sessionManager = [AFHTTPSessionManager manager];
        self.sessionManager.securityPolicy.allowInvalidCertificates = YES;
        self.sessionManager.securityPolicy.validatesDomainName = NO;
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];
        self.sessionManager.session.sessionDescription = sessionDescription;
        _timeoutInterval = 15.0f;
        _shouldUseCookie = YES;
    }
    return self;
}

#pragma mark - publicMethod
- (instancetype)initWithMethod:(NSString *)method
                           url:(NSString *)url
                    parameters:(id)parameters
             completionHandler:(JKNetworkCompletionHandler)completionHandler {
    if (self = [self init]) {
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:method URLString:url parameters:nil error:&error];
        if (error || request == nil) {
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:method];
            request = [[self.sessionManager.requestSerializer requestBySerializingRequest:request withParameters:nil error:nil] mutableCopy];
        }
        
        self.request = [request copy];
        self.parameters = parameters;
        self.completionHandler = completionHandler;
    }
    return self;
}
+ (instancetype)GETWithUrl:(NSString *)url parameters:(id)parameters completionHandler:(JKNetworkCompletionHandler)completionHandler {
    JKNetworking *networking = [[self alloc] initWithMethod:@"GET" url:url parameters:parameters completionHandler:completionHandler];
    return networking;
}

+ (instancetype)POSTWithUrl:(NSString *)url parameters:(id)parameters completionHandler:(JKNetworkCompletionHandler)completionHandler {
    JKNetworking *networking = [[self alloc] initWithMethod:@"POST" url:url parameters:parameters completionHandler:completionHandler];
    return networking;
}

+ (instancetype)PUTWithUrl:(NSString *)url
                parameters:(id)parameters
         completionHandler:(JKNetworkCompletionHandler)completionHandler {
    JKNetworking *networking = [[self alloc] initWithMethod:@"PUT" url:url parameters:parameters completionHandler:completionHandler];
    return networking;
}

+ (instancetype)DELETEWithUrl:(NSString *)url
                   parameters:(id)parameters
            completionHandler:(JKNetworkCompletionHandler)completionHandler {
    JKNetworking *networking = [[self alloc] initWithMethod:@"DELETE" url:url parameters:parameters completionHandler:completionHandler];
    return networking;
}
- (void)resume {
    if (_isResumed)[self cancel];
    _isResumed = YES;
    _isCancelled = NO;
    NSMutableURLRequest *req = [self.request mutableCopy];
    req.timeoutInterval = self.timeoutInterval;
    req.HTTPShouldHandleCookies = self.shouldUseCookie;
    for (NSString *key in self.headers.allKeys) {
        [req setValue:self.headers[key] forHTTPHeaderField:key];
    }
    self.request = [self.sessionManager.requestSerializer requestBySerializingRequest:req withParameters:self.parameters error:nil];
    
    __strong __block JKNetworking *strongSelf = self;
    _resumeCancel = ^{
        strongSelf = nil;
    };
    [self.sessionManager setTaskDidCompleteBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSError * _Nullable error) {
        [strongSelf.sessionManager.session finishTasksAndInvalidate];
        [strongSelf URLSession:session task:task didCompleteWithError:error];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            strongSelf = nil;
        });
    }];
    
    if ([self isMemberOfClass:[JKNetworking class]]) {
        [[self.sessionManager dataTaskWithRequest:self.request completionHandler:nil] resume];
    }
}
- (void)cancel {
    if (!_isCancelled)return;
    _resumeCancel ? _resumeCancel() : nil;
    [self.sessionManager.operationQueue cancelAllOperations];
    [self.sessionManager.session invalidateAndCancel];
    _isCancelled = YES;
    _isResumed = NO;
}
#pragma mark - privateMethod
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if ([self isMemberOfClass:[JKNetworking class]]) {
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            self.httpURLResponse = (NSHTTPURLResponse *)task.response;
        }
        if (self.completionHandler) {
            self.completionHandler(error, nil);
        }
    }
}
#pragma mark - lazyload
- (void)setHttpURLResponse:(NSHTTPURLResponse *)httpURLResponse {
    _httpURLResponse = httpURLResponse;
}
- (void)setRequest:(NSURLRequest *)request {
    _request = request;
}

- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", @"application/javascript", nil];
        _sessionManager.session.sessionDescription = sessionDescription;
    }
    return _sessionManager;
}
- (NSMutableDictionary *)headers {
    if (!_headers) {
        _headers = [NSMutableDictionary dictionary];
    }
    return _headers;
}
@end
