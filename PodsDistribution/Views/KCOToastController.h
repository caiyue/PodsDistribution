//
//  KCOToastController.h
//  PodsDistribution
//
//  Created by caiyue on 2024/7/27.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface KCOToastController : NSWindowController

+ (void)showToastMessage:(NSString *)message inView:(NSView *)view;

@end

NS_ASSUME_NONNULL_END
