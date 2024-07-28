//
//  KCOToastController.m
//  PodsDistribution
//
//  Created by caiyue on 2024/7/27.
//

#import "KCOToastController.h"
#import <Masonry/Masonry.h>

@implementation KCOToastController

+ (void)showToastMessage:(NSString *)message inView:(NSView *)view {
    NSTextField *label = [[NSTextField alloc] init];
    label.editable = NO;
    label.stringValue = message;
    label.bezeled = NO;
    label.drawsBackground = NO;
    label.font = [NSFont systemFontOfSize:14];
    label.alignment = NSTextAlignmentCenter;
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(view);
        make.width.height.mas_equalTo(100);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [label removeFromSuperview];
    });
}
@end
