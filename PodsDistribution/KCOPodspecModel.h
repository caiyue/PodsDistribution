//
//  KCOPodspecModel.h
//  PodsDistribution
//
//  Created by caiyue on 2024/7/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KCOPodspecModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString *podName;
@property (nonatomic, copy) NSString *path;

@property (nonatomic, copy, nullable) NSString *targetVersion;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, strong) NSDate *versionDate;
@property (nonatomic, assign) BOOL invalid; // path是否失效
@property (nonatomic, assign) BOOL checkPassed;
@property (nonatomic, assign) BOOL isExecuteScript;

- (instancetype)initWithName:(NSString *)podName path:(NSString *)path version:(NSString *)version;

@end

NS_ASSUME_NONNULL_END
