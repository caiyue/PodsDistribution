//
//  AppDelegate.m
//  PodsDistribution
//
//  Created by caiyue on 2024/7/19.
//

#import "AppDelegate.h"
#import "KCODistributionViewController.h"
#import "KCommonHeader.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, kWindowWidth, kWindowHeight)
                                                   styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    [window center];
    [window setTitle:@"Pods发版助手"];
    
    KCODistributionViewController *viewController = [[KCODistributionViewController alloc] init];
    viewController.view.frame = CGRectMake(0, 0, kWindowWidth, kWindowHeight);
    [window setContentViewController:viewController];
    [window makeKeyAndOrderFront:nil];
    
    [viewController.view layoutSubtreeIfNeeded];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
