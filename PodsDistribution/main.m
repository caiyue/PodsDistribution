//
//  main.m
//  PodsDistribution
//
//  Created by caiyue on 2024/7/19.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        NSApplication *application = [NSApplication sharedApplication];
        application.delegate = AppDelegate.new;
        [application run];
        
        [application activateIgnoringOtherApps:YES];

    }

    return NSApplicationMain(argc, argv);
}
