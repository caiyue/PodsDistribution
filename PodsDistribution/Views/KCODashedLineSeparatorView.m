//
//  KCODashedLineSeparatorView.m
//  PodsDistribution
//
//  Created by caiyue on 2024/7/24.
//

#import "KCODashedLineSeparatorView.h"

@implementation KCODashedLineSeparatorView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    CGContextRef cgContext = [context graphicsPort];
    
    // 设置线条颜色和虚线样式
    [[NSColor grayColor] setStroke];
    CGFloat dashPattern[] = {5, 5};
    CGContextSetLineDash(cgContext, 0, dashPattern, sizeof(dashPattern)/sizeof(CGFloat));
    
    // 计算虚线的起始和结束点
    NSPoint startPoint = NSMakePoint(0, self.bounds.size.height - 1);
    NSPoint endPoint = NSMakePoint(self.bounds.size.width, self.bounds.size.height - 1);
    
    // 绘制虚线
    CGContextMoveToPoint(cgContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(cgContext, endPoint.x, endPoint.y);
    CGContextStrokePath(cgContext);
}

@end
