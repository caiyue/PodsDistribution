//
//  KCOPodspecModel.m
//  PodsDistribution
//
//  Created by caiyue on 2024/7/24.
//

#import "KCOPodspecModel.h"

@implementation KCOPodspecModel

- (instancetype)initWithName:(NSString *)podName path:(NSString *)path version:(NSString *)version {
    if (self = [super init]) {
        _podName = podName;
        _path = path;
        _version = version;
        _versionDate = [NSDate date];
    }
    return self;
}

- (BOOL)isEqual:(KCOPodspecModel *)object {
    if ([self.podName isEqualToString:object.podName]) {
        return YES;
    }
    return NO;
}

- (BOOL)isEqualTo:(KCOPodspecModel *)object {
    if ([self.podName isEqualToString:object.podName]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return  [[NSString stringWithFormat:@"%@-%@-%@", self.podName, self.path, self.version] hash];
}

# pragma mark - Coding

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if(self = [super init]) {
        self.podName = [coder decodeObjectForKey:@"podName"];
        self.path = [coder decodeObjectForKey:@"path"];
//        self.targetVersion = [coder decodeObjectForKey:@"targetVersion"];
        self.version = [coder decodeObjectForKey:@"version"];
        self.versionDate = [coder decodeObjectForKey:@"versionDate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.podName forKey:@"podName"];
    [coder encodeObject:self.path forKey:@"path"];
//    [coder encodeObject:self.targetVersion forKey:@"targetVersion"];
    [coder encodeObject:self.version forKey:@"version"];
    [coder encodeObject:self.versionDate forKey:@"versionDate"];
}

@end
