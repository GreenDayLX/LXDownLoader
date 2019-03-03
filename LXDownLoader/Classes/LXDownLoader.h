//
//  LXDownLoader.h
//  LXDownLoader
//
//  Created by wenglx on 2017/3/14.
//  Copyright © 2017年 wenglx. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LXDownLoadStatus) {
    LXDownLoadStatusSuspend, // 暂停
    LXDownLoadStatusDowning, // 下载中
    LXDownLoadStatusSuccess, // 成功
    LXDownLoadStatusFailure  // 失败
};

typedef void(^LXDownLoadStatusChangeBlock)(LXDownLoadStatus status);
typedef void(^LXDownLoadMessageBlock)(long long totalSize, NSString *downLoadingPath);
typedef void(^LXDownLoadProgressChangeBlock)(float progress);
typedef void(^LXDownLoadSuccessBlock)(NSString *downLoadedFilePath);
typedef void(^LXDownLoadFailureBlock)(NSString *errorMsg);
typedef BOOL(^LXDownLoaderManagerFileMD5Blcok)(NSString *fileMD5);

@interface LXDownLoader : NSObject

/** 创建方法 */
+ (instancetype)lx_downLoader;

/** 下载状态 */
@property (nonatomic, assign, readonly) LXDownLoadStatus status;

/** 状态回调 */
@property (nonatomic, copy) LXDownLoadStatusChangeBlock loadStatusChangeBlock;
@property (nonatomic, copy) LXDownLoadMessageBlock loadMessageBlock;
@property (nonatomic, copy) LXDownLoadProgressChangeBlock loadProgressChangeBlock;
@property (nonatomic, copy) LXDownLoadSuccessBlock loadSuccessBlock;
@property (nonatomic, copy) LXDownLoadFailureBlock loadFailureBlock;
@property (nonatomic, copy) LXDownLoaderManagerFileMD5Blcok loadFileMD5Block;

/**
 *  根据一个URL下载一个资源
 */
- (void)lx_downLoadFileWithURL:(NSURL *)url;

- (void)lx_downLoadFileWithURL:(NSURL *)url messageBlock:(void(^)(long long totalSize, NSString *downLoadingFilePath))loadMessage progressChangeBlock:(void(^)(float progress))loadProgress successBlock:(void(^)(NSString *downLoadedFilePath))loadSuccess failureBlock:(void(^)(NSString *errorMsg))loadFailure;

/**
 *  开启
 */
- (void)lx_resume;

/**
 *  暂停
 */
- (void)lx_suspend;

/**
 *  取消
 */
- (void)lx_cancel;

/**
 *  取消并清除缓存
 */
- (void)lx_downLoaderCancelAndClean;
@end
