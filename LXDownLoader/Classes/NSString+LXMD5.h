//
//  NSString+LXMD5.h
//  LXDownLoader
//
//  Created by wenglx on 2017/3/16.
//  Copyright © 2017年 wenglx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LXMD5)
/**
 *  创建MD5加密
 */
- (NSString *)lx_MD5Str;

/**
 *  获取文件MD5加密 - 需要服务器配合返回相同文件MD5加密作对比
 */
+ (NSString*)lx_getFileMD5WithPath:(NSString*)path;
@end
