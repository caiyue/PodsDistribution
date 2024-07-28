//
//  KCOLocaiization.m
//  PodsDistribution
//
//  Created by caiyue on 2024/7/24.
//

#import "KCOLocaiization.h"
#import "KCOPodspecModel.h"

#define kPodsLocalizationKey @"kPodsLocalizationKey"

@implementation KCOLocaiization

+ (void)saveToLocal:(NSArray<KCOPodspecModel *> *)pods {
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:pods requiringSecureCoding:NO error:nil];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:archivedData forKey:kPodsLocalizationKey];
    [userDefault synchronize];
}

+ (NSArray<KCOPodspecModel *> *)fetchLocalPods {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSData *unarchivedData = [userDefault valueForKey:kPodsLocalizationKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:unarchivedData];
}

@end
