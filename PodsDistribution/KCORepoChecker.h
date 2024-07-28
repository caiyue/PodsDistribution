//
//  KCORepoChecker.h
//  PodsDistribution
//
//  Created by caiyue on 2024/7/24.
//

#import <Foundation/Foundation.h>

@class KCOPodspecModel;
NS_ASSUME_NONNULL_BEGIN

@interface KCORepoChecker : NSObject

@property (nonatomic) void (^repoStateChanged)(void);

- (void)checkWithRepoList:(NSArray <KCOPodspecModel *> *)repos;

@end

NS_ASSUME_NONNULL_END
