//
//  NSURLSession+JKCategory.m
//  JKNetwork
//
//  Created by Jekin on 2019/11/14.
//

#import "NSURLSession+JKCategory.h"
#import <objc/runtime.h>


void swizzing(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}
@implementation NSURLSession (JKCategory)
+ (void)load{
#if DEBUG
#else
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [NSURLSession class];
        swizzing(class, @selector(sessionWithConfiguration:), @selector(jk_sessionWithConfiguration:));
        
        swizzing(class, @selector(sessionWithConfiguration:delegate:delegateQueue:),
                 @selector(jk_sessionWithConfiguration:delegate:delegateQueue:));
    });
#endif
}

+ (NSURLSession *)jk_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration
                                     delegate:(nullable id<NSURLSessionDelegate>)delegate
                                delegateQueue:(nullable NSOperationQueue *)queue{
    if (!configuration){
        configuration = [[NSURLSessionConfiguration alloc] init];
    }
    configuration.connectionProxyDictionary = @{};
    return [self jk_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

+ (NSURLSession *)jk_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration{
    if (configuration){
        configuration.connectionProxyDictionary = @{};
    }
    return [self jk_sessionWithConfiguration:configuration];
}
@end
