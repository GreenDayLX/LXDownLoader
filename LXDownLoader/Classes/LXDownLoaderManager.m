//
//  LXDownLoaderManager.m
//  LXDownLoader
//
//  Created by wenglx on 2017/3/16.
//  Copyright © 2017年 wenglx. All rights reserved.
//

#import "LXDownLoaderManager.h"
#import "NSString+LXMD5.h"

@interface LXDownLoaderManager () <NSCopying, NSMutableCopying>
/** 存储URL对应的下载器 */
@property (nonatomic, strong) NSMutableDictionary *downLoaderInfo;
@end

@implementation LXDownLoaderManager

static LXDownLoaderManager *_shareInstance;

/**
 *  创建单例方法
 */
+ (instancetype)manager
{
    if (!_shareInstance) {
        _shareInstance = [[self alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _shareInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return _shareInstance;
}

/**
 *  根据多个URL下载多个资源
 */
- (void)lx_downLoadFileWithURL:(NSURL *)url messageBlock:(void(^)(long long totalSize, NSString *downLoadingFilePath))loadMessage progressChangeBlock:(void(^)(float progress))loadProgress statusChanedBlock:(void(^)(LXDownLoadStatus status))loadStatus successBlock:(void(^)(NSString *downLoadedFilePath))loadSuccess failureBlock:(void(^)(NSString *errorMsg))loadFailure
{
    NSString *urlStr = [url.absoluteString lx_MD5Str];
    LXDownLoader *downLoader = self.downLoaderInfo[urlStr];
    if (downLoader == nil) {
        downLoader = [LXDownLoader lx_downLoader];
        self.downLoaderInfo[urlStr] = downLoader;
    }
    [downLoader setLoadStatusChangeBlock:^(LXDownLoadStatus status){
        if (loadStatus) {
            loadStatus(status);
        }
    }];
    __weak typeof(self) weakSelf = self;
    [downLoader lx_downLoadFileWithURL:url messageBlock:loadMessage progressChangeBlock:loadProgress successBlock:^(NSString *downLoadedFilePath) {
        [weakSelf.downLoaderInfo removeObjectForKey:urlStr];
        if (loadSuccess) {
            loadSuccess(downLoadedFilePath);
        }
    } failureBlock:loadFailure];
}

/**
 *  开启
 */
- (void)lx_resumeWith:(NSURL *)url
{
    NSString *urlStr = [url.absoluteString lx_MD5Str];
    LXDownLoader *downLoader = self.downLoaderInfo[urlStr];
    [downLoader lx_resume];
}

/**
 *  开启全部
 */
- (void)lx_resumeAll
{
    [self.downLoaderInfo.allValues performSelector:@selector(lx_resume) withObject:nil];
}

/**
 *  暂停
 */
- (void)lx_suspendWith:(NSURL *)url
{
    NSString *urlStr = [url.absoluteString lx_MD5Str];
    LXDownLoader *downLoader = self.downLoaderInfo[urlStr];
    [downLoader lx_suspend];
}

/**
 *  暂停全部
 */
- (void)lx_suspendAll
{
    [self.downLoaderInfo.allValues performSelector:@selector(lx_suspend) withObject:nil];
}

/**
 *  取消
 */
- (void)lx_cancelWith:(NSURL *)url
{
    NSString *urlStr = [url.absoluteString lx_MD5Str];
    LXDownLoader *downLoader = self.downLoaderInfo[urlStr];
    [downLoader lx_cancel];
}

/**
 *  取消全部
 */
- (void)lx_cancelAll
{
    [self.downLoaderInfo.allValues performSelector:@selector(lx_cancel) withObject:nil];
}

/**
 *  取消并清除缓存
 */
- (void)lx_downLoaderCancelAndCleanWith:(NSURL *)url
{
    NSString *urlStr = [url.absoluteString lx_MD5Str];
    LXDownLoader *downLoader = self.downLoaderInfo[urlStr];
    [downLoader lx_downLoaderCancelAndClean];
}

/**
 *  取消并清除缓存全部
 */
- (void)lx_downLoaderCancelAndCleanAll
{
    [self.downLoaderInfo.allValues performSelector:@selector(lx_downLoaderCancelAndClean) withObject:nil];
}

#pragma mark - 懒加载
- (NSMutableDictionary *)downLoaderInfo
{
    if (!_downLoaderInfo) {
        _downLoaderInfo = [NSMutableDictionary dictionary];
    }
    return _downLoaderInfo;
}









@end
