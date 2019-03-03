//
//  LXFileManager.m
//  LXDownLoader
//
//  Created by wenglx on 2017/3/14.
//  Copyright © 2017年 wenglx. All rights reserved.
//

#import "LXFileManager.h"

@implementation LXFileManager
/**
 *  根据path创建路径
 */
+ (BOOL)lx_createdDirectoryIfNotExistsWithPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        NSError *error;
        BOOL result = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!result || error) {
            NSLog(@"文件路径创建失败");
            return NO;
        }
    }
    return YES;
}

/**
 *  根据path判断下载文件是否存在
 */
+ (BOOL)lx_fileExistsAtPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager fileExistsAtPath:path];
}

/**
 *  根据path获得已经下载的文件大小
 */
+ (long long)lx_getFileSizeWithPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        NSLog(@"下载路径不存在");
        return 0;
    }
    NSDictionary *fileInfoDict = [manager attributesOfItemAtPath:path error:nil];
    return [fileInfoDict[NSFileSize] longLongValue];
}

/**
 *  移除缓存资源
 */
+ (void)lx_removeFileAtPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        NSLog(@"缓存资源不存在");
        return;
    }
    [manager removeItemAtPath:path error:nil];
}

/**
 *  移动缓存文件
 */
+ (void)lx_moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:fromPath]) {
        NSLog(@"缓存资源不存在");
        return;
    }
    [manager moveItemAtPath:fromPath toPath:toPath error:nil];
}
@end
