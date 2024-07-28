//
//  KCORepoChecker.m
//  PodsDistribution
//
//  Created by caiyue on 2024/7/24.
//

#import "KCORepoChecker.h"
#import "KCOPodspecModel.h"

@interface KCORepoChecker ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation KCORepoChecker

- (void)checkWithRepoList:(NSArray<KCOPodspecModel *> *)repos {
    if (self.timer) [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:3 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSInteger shouldNotify = 0;
        for (KCOPodspecModel *model in repos) {
            shouldNotify += [self checkPodspecModelUpdate:model];
        }
        if (shouldNotify) {
            if (self.repoStateChanged) self.repoStateChanged();
        }
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (BOOL)checkPodspecModelUpdate:(KCOPodspecModel *)podspecMode {
    BOOL found = YES;
    BOOL shouldUpdate = NO;
    // name
    // NSString *podspecName = podspecMode.podName;
    NSString *podVersion = nil;
    // version
    NSError *error = nil;
    // 读取文件内容
    NSString *specFullPath = [podspecMode.path stringByAppendingPathComponent:podspecMode.podName];
    NSString *fileContents = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:specFullPath isDirectory:NO]
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    if (fileContents) {
        // Use regular expression to extract the version field
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\bversion\\s*=\\s*@?[\"']([^\"']+)[\"']"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:fileContents
                                                        options:0
                                                          range:NSMakeRange(0, [fileContents length])];
        if (match) {
            NSRange versionRange = [match rangeAtIndex:1];
            podVersion = [fileContents substringWithRange:versionRange];
            
            if ([podspecMode.version isEqualToString:podVersion]) {
                // do noting
            } else {
                // update version
                podspecMode.version = podVersion;
                shouldUpdate = YES;
            }
        }
    } else {
        shouldUpdate = YES;
        found = NO;
    }
    
    // 如果文件路径状态发生变化
    if (!podspecMode.invalid != found) {
        shouldUpdate = YES;
    }
    
    // update
    podspecMode.invalid = !found;
    return shouldUpdate;
}

@end
