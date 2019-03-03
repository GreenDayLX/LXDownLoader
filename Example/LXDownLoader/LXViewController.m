//
//  LXViewController.m
//  LXDownLoader
//
//  Created by GreenDayLX on 03/03/2019.
//  Copyright (c) 2019 GreenDayLX. All rights reserved.
//

#import "LXViewController.h"
#import "LXDownLoaderManager.h"

@interface LXViewController ()
/** 下载器 */
@property (nonatomic, strong) LXDownLoader *downLoader;

@end

@implementation LXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)resume {
    [[LXDownLoaderManager manager] lx_downLoadFileWithURL:[NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"] messageBlock:^(long long totalSize, NSString *downLoadingFilePath) {
        NSLog(@"文件总大小：%lld -- 路径：%@",totalSize, downLoadingFilePath);
    } progressChangeBlock:^(float progress) {
        NSLog(@"下载中 - %f",progress);
    } statusChanedBlock:^(LXDownLoadStatus status) {
        NSLog(@"状态 - %zd",status);
    } successBlock:^(NSString *downLoadedFilePath) {
        NSLog(@"下载完成 - %@",downLoadedFilePath);
    } failureBlock:^(NSString *errorMsg) {
        NSLog(@"下载失败 - %@",errorMsg);
    }];
}

- (IBAction)cancel {
    [self.downLoader lx_cancel];
    [[LXDownLoaderManager manager] lx_cancelWith:[NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"]];
}

- (IBAction)suspend {
    [self.downLoader lx_suspend];
    [[LXDownLoaderManager manager] lx_suspendWith:[NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"]];
}

- (IBAction)cancelAndRemoveFile {
    [self.downLoader lx_downLoaderCancelAndClean];
    [[LXDownLoaderManager manager] lx_downLoaderCancelAndCleanWith:[NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"]];
}

#pragma mark - 懒加载
- (LXDownLoader *)downLoader
{
    if (!_downLoader) {
        _downLoader = [[LXDownLoader alloc] init];
    }
    return _downLoader;
}

@end
