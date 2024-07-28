//
//  NSDistributonTableRowView.h
//  PodsDistribution
//
//  Created by caiyue on 2024/7/23.
//

#import <Cocoa/Cocoa.h>

@class KCOPodspecModel;
NS_ASSUME_NONNULL_BEGIN

@interface NSDistributonTableRowView : NSTableRowView

@property (nonatomic, strong) KCOPodspecModel *podspecModel;
@property (nonatomic, copy) void (^longPressAction)(KCOPodspecModel *podspec);
@property (nonatomic, copy) void (^doubleClickAction)(KCOPodspecModel *podspec);

@end

NS_ASSUME_NONNULL_END
