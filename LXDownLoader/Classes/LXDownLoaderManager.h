//
//  LXDownLoaderManager.h
//  LXDownLoader
//
//  Created by wenglx on 2017/3/16.
//  Copyright © 2017年 wenglx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LXDownLoader.h"

typedef BOOL(^LXDownLoaderManagerFileMD5Blcok)(NSString *fileMD5);

@interface LXDownLoaderManager : NSObject

/** 文件MD5加密 */
@property (nonatomic, copy) LXDownLoaderManagerFileMD5Blcok loadFileMD5Block;

/**
 *  创建单例方法
 */
+ (instancetype)manager;

/**
 *  根据多个URL下载多个资源
 */
- (void)lx_downLoadFileWithURL:(NSURL *)url messageBlock:(void(^)(long long totalSize, NSString *downLoadingFilePath))loadMessage progressChangeBlock:(void(^)(float progress))loadProgress statusChanedBlock:(void(^)(LXDownLoadStatus status))loadStatus successBlock:(void(^)(NSString *downLoadedFilePath))loadSuccess failureBlock:(void(^)(NSString *errorMsg))loadFailure;

/**
 *  开启
 */
- (void)lx_resumeWith:(NSURL *)url;

/**
 *  开启全部
 */
- (void)lx_resumeAll;

/**
 *  暂停
 */
- (void)lx_suspendWith:(NSURL *)url;

/**
 *  暂停全部
 */
- (void)lx_suspendAll;

/**
 *  取消
 */
- (void)lx_cancelWith:(NSURL *)url;

/**
 *  取消全部
 */
- (void)lx_cancelAll;

/**
 *  取消并清除缓存
 */
- (void)lx_downLoaderCancelAndCleanWith:(NSURL *)url;

/**
 *  取消并清除缓存全部
 */
- (void)lx_downLoaderCancelAndCleanAll;
@end
