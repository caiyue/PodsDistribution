//
//  KCOTableView.m
//  PodsDistribution
//
//  Created by caiyue on 2024/7/24.
//

#import "KCOTableView.h"

@implementation KCOTableView

- (instancetype)init {
    if (self = [super init]) {
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
}

@end
