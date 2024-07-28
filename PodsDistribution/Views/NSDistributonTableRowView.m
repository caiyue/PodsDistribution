//
//  NSDistributonTableRowView.m
//  PodsDistribution
//
//  Created by caiyue on 2024/7/23.
//

#import "NSDistributonTableRowView.h"
#import "KCODashedLineSeparatorView.h"
#import "KCommonHeader.h"
#import "KCOTextField.h"
#import "KCOPodspecModel.h"
#import <Masonry/Masonry.h>

static NSDateFormatter *dateFormatter;
@interface NSDistributonTableRowView ()

@property (nonatomic, strong) KCOTextField *nameTextField;
@property (nonatomic, strong) KCOTextField *pathTextField;
@property (nonatomic, strong) KCOTextField *targetVersionTextField;
@property (nonatomic, strong) NSProgressIndicator *indicator;
@property (nonatomic, strong) KCOTextField *versionTextField;
@property (nonatomic, strong) KCOTextField *updateTimeTextField;
@property (nonatomic, strong) KCODashedLineSeparatorView *sepratorView;

@end

@implementation NSDistributonTableRowView


- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.nameTextField];
        [self addSubview:self.pathTextField];
        [self addSubview:self.targetVersionTextField];
        [self addSubview:self.indicator];
        [self addSubview:self.versionTextField];
        [self addSubview:self.updateTimeTextField];
        [self addSubview:self.sepratorView];
        
        [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(20);
            make.height.mas_equalTo(20);
            make.centerY.equalTo(self);
        }];
        [self.pathTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(230);
            make.centerY.mas_equalTo(self);
        }];
        [self.versionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(-20);
            make.centerY.equalTo(self);
        }];
        [self.updateTimeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.versionTextField);
            make.top.equalTo(self.versionTextField.mas_bottom).offset(5);
        }];
        [self.targetVersionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.versionTextField.mas_leading).offset(-100);
            make.centerY.equalTo(self);
        }];
        [self.indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.targetVersionTextField.mas_trailing);
            make.width.height.mas_equalTo(15);
            make.centerY.equalTo(self.targetVersionTextField);
        }];
        [self.sepratorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(kWindowWidth);
            make.height.mas_equalTo(1);
        }];
        NSPressGestureRecognizer *longPress = [[NSPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.minimumPressDuration = 0.5;
        [self addGestureRecognizer:longPress];
        
        NSClickGestureRecognizer *doubleClickGes = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
        doubleClickGes.numberOfClicksRequired = 2;
        [self addGestureRecognizer:doubleClickGes];
    }
    return self;
}

- (void)setPodspecModel:(KCOPodspecModel *)podspecModel {
    _podspecModel = podspecModel;
    self.nameTextField.stringValue = podspecModel.podName;
    self.versionTextField.stringValue = podspecModel.version;
    
    if (podspecModel.invalid) {
        self.pathTextField.stringValue = [podspecModel.path stringByAppendingString:@" [NOT EXIST]"];
        self.pathTextField.textColor = [NSColor redColor];
    } else {
        self.pathTextField.stringValue = podspecModel.path;
        self.pathTextField.textColor = [NSColor blueColor];
    }
    
    // 是否在打包
    self.targetVersionTextField.hidden = !podspecModel.isExecuteScript;
    self.targetVersionTextField.stringValue = [NSString stringWithFormat:@"-> %@",podspecModel.targetVersion];
    self.indicator.hidden = !podspecModel.isExecuteScript;
    if (!self.indicator.hidden) {
        [self.indicator startAnimation:nil];
    } else {
        [self.indicator stopAnimation:nil];
    }
    
    // time
    if (podspecModel.versionDate) {
        self.updateTimeTextField.stringValue = [self.class dateStringFromDate:podspecModel.versionDate];
    }
}

- (void)longPress:(NSPressGestureRecognizer *)ges {
    if (ges.state == NSGestureRecognizerStateBegan) {
        if (self.longPressAction) self.longPressAction(self.podspecModel);
    }
}

- (void)doubleClick:(NSPressGestureRecognizer *)ges {
    if (ges.state == NSGestureRecognizerStateEnded) {
        self.doubleClickAction(self.podspecModel);
    }
}

+ (NSString *)dateStringFromDate:(NSDate *)date {
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd HH:mm:ss"];
    }
    return [dateFormatter stringFromDate:date];
}

# pragma mark - Getter

- (KCOTextField *)nameTextField {
    if (!_nameTextField) {
        _nameTextField = [[KCOTextField alloc] init];
        _nameTextField.editable = NO; // 设置标签不可编辑
        _nameTextField.bezeled = NO;  //设置标签无边框
        _nameTextField.drawsBackground = NO; // 设置标签不绘制背景
        _nameTextField.alignment =  NSTextAlignmentJustified; // 设置文本居中对齐
        _nameTextField.font = [NSFont systemFontOfSize:14]; // 设置文本字体大小
        _nameTextField.textColor = NSColor.blueColor; // 设置文本颜色
        _nameTextField.maximumNumberOfLines = 2;
        
    }
    return _nameTextField;
}

- (KCOTextField *)pathTextField {
    if (!_pathTextField) {
        _pathTextField = [[KCOTextField alloc] init];
        _pathTextField.editable = NO; // 设置标签不可编辑
        _pathTextField.bezeled = NO; // 设置标签无边框
        _pathTextField.drawsBackground = NO; // 设置标签不绘制背景
        _pathTextField.alignment =  NSTextAlignmentLeft; // 设置文本居中对齐
        _pathTextField.font = [NSFont systemFontOfSize:14]; // 设置文本字体大小
        _pathTextField.textColor = NSColor.blueColor; // 设置文本颜色
        _pathTextField.maximumNumberOfLines = 2;
    }
    return _pathTextField;
}

- (KCOTextField *)targetVersionTextField {
    if (!_targetVersionTextField) {
        _targetVersionTextField = [[KCOTextField alloc] init];
        _targetVersionTextField.editable = NO; // 设置标签不可编辑
        _targetVersionTextField.bezeled = NO; // 设置标签无边框
        _targetVersionTextField.drawsBackground = NO; // 设置标签不绘制背景
        _targetVersionTextField.alignment =  NSTextAlignmentCenter; // 设置文本居中对齐
        _targetVersionTextField.font = [NSFont systemFontOfSize:14]; // 设置文本字体大小
        _targetVersionTextField.textColor = NSColor.lightGrayColor; // 设置文本颜色
    }
    return _targetVersionTextField;
}

- (KCOTextField *)versionTextField {
    if (!_versionTextField) {
        _versionTextField = [[KCOTextField alloc] init];
        _versionTextField.editable = NO; // 设置标签不可编辑
        _versionTextField.bezeled = NO; // 设置标签无边框
        _versionTextField.drawsBackground = NO; // 设置标签不绘制背景
        _versionTextField.alignment =  NSTextAlignmentCenter; // 设置文本居中对齐
        _versionTextField.font = [NSFont systemFontOfSize:14]; // 设置文本字体大小
        _versionTextField.textColor = NSColor.blueColor; // 设置文本颜色
    }
    return _versionTextField;
}

- (NSProgressIndicator *)indicator {
    if (!_indicator) {
        _indicator = [[NSProgressIndicator alloc] init];
        _indicator.style = NSProgressIndicatorStyleSpinning;
    }
    return _indicator;
}

- (KCOTextField *)updateTimeTextField {
    if (!_updateTimeTextField) {
        _updateTimeTextField = [[KCOTextField alloc] init];
        _updateTimeTextField.editable = NO; // 设置标签不可编辑
        _updateTimeTextField.bezeled = NO; // 设置标签无边框
        _updateTimeTextField.drawsBackground = NO; // 设置标签不绘制背景
        _updateTimeTextField.alignment =  NSTextAlignmentCenter; // 设置文本居中对齐
        _updateTimeTextField.font = [NSFont systemFontOfSize:14]; // 设置文本字体大小
        _updateTimeTextField.textColor = NSColor.blueColor; // 设置文本颜色
    }
    return _updateTimeTextField;
}

- (KCODashedLineSeparatorView *)sepratorView {
    if (!_sepratorView) {
        _sepratorView = [[KCODashedLineSeparatorView alloc] init];
    }
    return _sepratorView;
}

@end
