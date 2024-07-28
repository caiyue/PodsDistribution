//
//  KCOLocaiization.h
//  PodsDistribution
//
//  Created by caiyue on 2024/7/24.
//

#import <Foundation/Foundation.h>

@class KCOPodspecModel;
NS_ASSUME_NONNULL_BEGIN

@interface KCOLocaiization : NSObject

+ (void)saveToLocal:(NSArray <KCOPodspecModel *> *)pods;
+ (NSArray<KCOPodspecModel *> *)fetchLocalPods;

@end

NS_ASSUME_NONNULL_END
