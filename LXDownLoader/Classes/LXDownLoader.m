//
//  LXDownLoader.m
//  LXDownLoader
//
//  Created by wenglx on 2017/3/14.
//  Copyright © 2017年 wenglx. All rights reserved.
//

#import "LXDownLoader.h"
#import "LXFileManager.h"
#import "NSString+LXMD5.h"

#define kCachesPath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

@interface LXDownLoader () <NSURLSessionDataDelegate>
{
    /** 已下载的偏移量 */
    long long _fileSize;
    /** 下载总大小 */
    long long _totalSize;
}
/** 会话 */
@property (nonatomic, strong) NSURLSession *session;
/** 请求 */
@property (nonatomic, weak) NSURLSessionDataTask *task;
/** 下载流 */
@property (nonatomic, strong) NSOutputStream *stream;
/** 已经下载的资源路径 */
@property (nonatomic, copy) NSString *downLoadedFilePath;
/** 正下载的资源路径 */
@property (nonatomic, copy) NSString *downLoadingFilePath;
@end

@implementation LXDownLoader

/** 创建方法 */
+ (instancetype)lx_downLoader
{
    return [[self alloc] init];
}

/**
 *  根据URL下载资源
 */
- (void)lx_downLoadFileWithURL:(NSURL *)url
{
    if ([url isEqual:self.task.originalRequest.URL]) {
        if (self.task && self.status == LXDownLoadStatusSuspend) {
            return [self lx_resume];
        } else if (self.status == LXDownLoadStatusDowning) {
            return NSLog(@"资源正在下载中");
        }
    }
    self.downLoadedFilePath = [self.lx_getDownLoadedPath stringByAppendingPathComponent:url.lastPathComponent];
    self.downLoadingFilePath = [self.lx_getDownLoadingPath stringByAppendingPathComponent:url.lastPathComponent];
    if ([LXFileManager lx_fileExistsAtPath:_downLoadedFilePath]) {
        NSLog(@"下载资源已经存在");
        return;
    }
    if (![LXFileManager lx_fileExistsAtPath:_downLoadingFilePath]) {
        [self lx_downLoaderWithURL:url offset:_fileSize];
        return;
    }
    _fileSize = [LXFileManager lx_getFileSizeWithPath:_downLoadingFilePath];
    if (self.loadMessageBlock) {
        self.loadMessageBlock(_fileSize, _downLoadingFilePath);
    }
    [self lx_downLoaderWithURL:url offset:_fileSize];
}

- (void)lx_downLoadFileWithURL:(NSURL *)url messageBlock:(void (^)(long long totalSize, NSString *downLoadingFilePath))loadMessage progressChangeBlock:(void (^)(float progress))loadProgress successBlock:(void (^)(NSString *downLoadingFilePath))loadSuccess failureBlock:(void (^)(NSString *errorMsg))loadFailure
{
    self.loadMessageBlock = loadMessage;
    self.loadProgressChangeBlock = loadProgress;
    self.loadSuccessBlock = loadSuccess;
    self.loadFailureBlock = loadFailure;
    [self lx_downLoadFileWithURL:url];
}

/**
 *  根据URL和已下载的偏移量继续下载
 */
- (void)lx_downLoaderWithURL:(NSURL *)url offset:(long long)offset
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
}

/**
 *  开启
 */
- (void)lx_resume
{
    if (self.task && self.status == LXDownLoadStatusSuspend) {
        [self.task resume];
        self.status = LXDownLoadStatusDowning;
    }
}

/**
 *  暂停
 */
- (void)lx_suspend
{
    if (self.status == LXDownLoadStatusDowning) {
        [self.task suspend];
        self.status = LXDownLoadStatusSuspend;
    }
}

/**
 *  取消
 */
- (void)lx_cancel
{
    [self.session invalidateAndCancel];
    self.session = nil;
}

/**
 *  取消并清除缓存
 */
- (void)lx_downLoaderCancelAndClean
{
    [self lx_cancel];
    [LXFileManager lx_removeFileAtPath:_downLoadingFilePath];
    _fileSize = 0;
}

#pragma mark - NSURLSessionDataDelegate
/**
 *  开始接收响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    _totalSize = [[response.allHeaderFields[@"Content-Range"] componentsSeparatedByString:@"/"].lastObject longLongValue];
    if (_fileSize == _totalSize && _totalSize > 0) {
        NSLog(@"资源已经下载完成,验证资源完整性，移动文件资源");
        [LXFileManager lx_moveFileFromPath:_downLoadingFilePath toPath:_downLoadedFilePath];
        completionHandler(NSURLSessionResponseCancel);
        return ;
    } else if (_fileSize > _totalSize && _totalSize > 0) {
        [LXFileManager lx_removeFileAtPath:_downLoadingFilePath];
        completionHandler(NSURLSessionResponseCancel);
        [self lx_downLoadFileWithURL:response.URL];
        return ;
    }
    
    [self.stream open];
    self.status = LXDownLoadStatusDowning;
    completionHandler(NSURLSessionResponseAllow);
}

/**
 *  接收数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if (self.status == LXDownLoadStatusDowning) {
        _fileSize += data.length;
        [self.stream write:data.bytes maxLength:data.length];
        if (self.loadProgressChangeBlock) {
            self.loadProgressChangeBlock(1.0 * _fileSize / _totalSize);
        }
    } else if (self.status == LXDownLoadStatusSuspend) {
        [self.stream close];
    }
}

/**
 *  请求完成 != 下载完成
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self.stream close];
    self.stream = nil;
    if (!error && _fileSize == _totalSize && _totalSize > 0) {
        [LXFileManager lx_moveFileFromPath:_downLoadingFilePath toPath:_downLoadedFilePath];
        self.status = LXDownLoadStatusSuccess;
        if (self.loadSuccessBlock) {
            self.loadSuccessBlock(_downLoadedFilePath);
        }
    } else {
        self.status = LXDownLoadStatusFailure;
        if (self.loadFailureBlock) {
            self.loadFailureBlock([NSString stringWithFormat:@"请求失败 -- 错误信息:%@", error]);
        }
    }
}

#pragma mark - setter getter
- (void)setStatus:(LXDownLoadStatus)status
{
    _status = status;
    if (self.loadStatusChangeBlock) {
        self.loadStatusChangeBlock(status);
    }
}

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue new]];
    }
    return _session;
}

- (NSOutputStream *)stream
{
    if (!_stream) {
        _stream = [NSOutputStream outputStreamToFileAtPath:_downLoadingFilePath append:YES];
    }
    return _stream;
}

/**
 *  获取下载完成的路径
 */
- (NSString *)lx_getDownLoadedPath
{
    NSString *downLoadedPath = [kCachesPath stringByAppendingPathComponent:@"lx_downLoader/downLoaded"];
    BOOL result = [LXFileManager lx_createdDirectoryIfNotExistsWithPath:downLoadedPath];
    if (!result) {
        NSLog(@"下载完成的路径创建失败");
        return nil;
    }
    return downLoadedPath;
}

/**
 *  获取下载中的路径
 */
- (NSString *)lx_getDownLoadingPath
{
    NSString *downLoadingPath = [kCachesPath stringByAppendingPathComponent:@"lx_downLoader/downLoading"];
    BOOL result = [LXFileManager lx_createdDirectoryIfNotExistsWithPath:downLoadingPath];
    if (!result) {
        NSLog(@"下载中的路径创建失败");
        return nil;
    }
    return downLoadingPath;
}

- (void)dealloc
{
    [self lx_cancel];
}

@end
