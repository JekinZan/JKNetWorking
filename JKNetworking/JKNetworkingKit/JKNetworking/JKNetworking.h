//
//  JKNetworking.h
//  JKNetworking
//
//  Created by zhangjie on 2018/4/16.
//  Copyright © 2018年 zhangjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
typedef void(^JKNetworkDidReceiveResponseCallback)(NSHTTPURLResponse *httpURLResponse);
typedef void(^JKNetworkProgressCallback)(NSProgress *progress);
typedef void(^JKNetworkCompletionHandler)(NSError *error,id responseObj);

@interface JKNetworking : NSObject
@property (nonatomic, strong,readonly) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong, readonly) NSURLRequest *request;
@property (nonatomic, strong, readonly) NSHTTPURLResponse *httpURLResponse;
/** time out,defalut is 15s, setup before resume */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
/** 设置请求头 [resume]前有效 */
@property (nonatomic, strong, readonly) NSMutableDictionary *headers;
/** should use cookie ,setup before resume,  defalut is YES */
@property (nonatomic, assign) BOOL shouldUseCookie;
/** set parameters(It's usually a dictionary) setup before resume */
@property (nonatomic, strong) id parameters;

/** receive callBack */
@property (nonatomic, copy) JKNetworkDidReceiveResponseCallback didReceiveResponseCallback;
/** upload callback progress */
@property (nonatomic, copy) JKNetworkProgressCallback uploadProgressCallback;
/** download progress */
@property (nonatomic, copy) JKNetworkProgressCallback downloadProgressCallback;
/** request completion */
@property (nonatomic, copy) JKNetworkCompletionHandler completionHandler;

#pragma mark METHOD
/**
 GET
 */
+ (instancetype)GETWithUrl:(NSString *)url
                parameters:(id)parameters
         completionHandler:(JKNetworkCompletionHandler)completionHandler;

/**
 POST
 */
+ (instancetype)POSTWithUrl:(NSString *)url
                 parameters:(id)parameters
          completionHandler:(JKNetworkCompletionHandler)completionHandler;

/**
 PUT
 */
+ (instancetype)PUTWithUrl:(NSString *)url
                parameters:(id)parameters
         completionHandler:(JKNetworkCompletionHandler)completionHandler;

/**
 DELETE
 */
+ (instancetype)DELETEWithUrl:(NSString *)url
                   parameters:(id)parameters
            completionHandler:(JKNetworkCompletionHandler)completionHandler;
/**
 custom for request
 OPTIONS,HEAD,GET,POST,PUT,DELETE,CONNECT
 */
- (instancetype)initWithMethod:(NSString *)method
                           url:(NSString *)url
                    parameters:(id)parameters
             completionHandler:(JKNetworkCompletionHandler)completionHandler;

//start
- (void)resume;
//cancel
- (void)cancel;
@end
@interface JKNetworkingDataTask : JKNetworking
@end
