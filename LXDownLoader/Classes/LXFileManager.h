//
//  LXFileManager.h
//  LXDownLoader
//
//  Created by wenglx on 2017/3/14.
//  Copyright © 2017年 wenglx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LXFileManager : NSObject
/**
 *  根据path创建路径
 */
+ (BOOL)lx_createdDirectoryIfNotExistsWithPath:(NSString *)path;

/**
 *  根据path判断下载文件是否存在
 */
+ (BOOL)lx_fileExistsAtPath:(NSString *)path;

/**
 *  根据path获得已经下载的文件大小
 */
+ (long long)lx_getFileSizeWithPath:(NSString *)path;

/**
 *  移除path路径的缓存资源
 */
+ (void)lx_removeFileAtPath:(NSString *)path;

/**
 *  移动缓存文件
 */
+ (void)lx_moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath;
@end
