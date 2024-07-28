//
//  KCODistributionViewController.m
//  PodsDistribution
//
//  Created by caiyue on 2024/7/19.
//

#import "KCODistributionViewController.h"
#import "NSDistributonTableRowView.h"
#import "KCOPodspecModel.h"
#import "KCOTableView.h"
#import "KCORepoChecker.h"
#import "KCOLocaiization.h"
#import "KCommonHeader.h"
#import "KCOToastController.h"
#import <Masonry/Masonry.h>

static const CGFloat kDistributonBtnHeight = 40.f;
static const CGFloat kDistributonBtnWidth = 100;
NSString *reuseIdentify = @"kDistributionIdentifier";

@interface KCODistributionViewController () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong) NSButton *distributonBtn;
@property (nonatomic, strong) NSButton *stopDistributon;

@property (nonatomic, strong) NSButton *developLocalPathBtn;
@property (nonatomic, strong) NSButton *addRepoBtn;
@property (nonatomic, strong) NSButton *commitCodeBtn;
@property (nonatomic, strong) KCOTableView *repoTableView;
@property (nonatomic, strong) NSMutableOrderedSet *podspecMap;
// check & update
@property (nonatomic, strong) KCORepoChecker *checker;
// stastics
@property (nonatomic, strong) NSDate *taskStartDate;
@end

@implementation KCODistributionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.distributonBtn];
    [self.view addSubview:self.stopDistributon];
    [self.view addSubview:self.developLocalPathBtn];
    [self.view addSubview:self.commitCodeBtn];
    [self.view addSubview:self.addRepoBtn];
    [self.view addSubview:self.repoTableView];
    
    [self.distributonBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(40);
        make.top.mas_equalTo(20);
        make.width.mas_equalTo(kDistributonBtnWidth);
        make.height.mas_equalTo(kDistributonBtnHeight);
    }];
    [self.stopDistributon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.distributonBtn.mas_trailing).offset(20);
        make.top.mas_equalTo(20);
        make.width.mas_equalTo(kDistributonBtnWidth);
        make.height.mas_equalTo(kDistributonBtnHeight);
    }];
    [self.addRepoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-40);
        make.top.equalTo(self.distributonBtn);
        make.width.mas_equalTo(kDistributonBtnWidth);
        make.height.mas_equalTo(kDistributonBtnHeight);
    }];
    [self.commitCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.addRepoBtn.mas_leading).offset(-20);
        make.top.equalTo(self.distributonBtn);
        make.width.mas_equalTo(kDistributonBtnWidth + 20);
        make.height.mas_equalTo(kDistributonBtnHeight);
    }];
    [self.developLocalPathBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.self.commitCodeBtn.mas_leading).offset(-20);
        make.top.equalTo(self.distributonBtn);
        make.width.mas_equalTo(kDistributonBtnWidth);
        make.height.mas_equalTo(kDistributonBtnHeight);
    }];
    [self.repoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(40);
        make.top.equalTo(self.distributonBtn.mas_bottom).offset(20);
        make.trailing.mas_equalTo(-40);
        make.height.mas_equalTo(kWindowHeight - 120);
    }];
    
    // init data
    self.podspecMap = [NSMutableOrderedSet orderedSetWithArray:[KCOLocaiization fetchLocalPods]];
    [self reloadData];
    if (self.podspecMap.count > 0) {
        [self.checker checkWithRepoList:self.podspecMap.array];
    }
}

# pragma mark - Event

- (void)didDistribution {
    [self showDistributionInputAlert:@"输入版本号" message:@"组件列表将统一发布" placeholder:@"1.2.3"];
}

- (void)didStopDistribution:(NSButton *)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTask *task = [[NSTask alloc] init];
        task.currentDirectoryURL = [NSURL fileURLWithPath:@"/"];
        [task setLaunchPath:@"/bin/bash"];
        NSArray *arguments = @[@"-c", @"for i in `ps aux | grep -E 'distribution.sh|gundam' | grep -v 'grep' | awk -F ' ' '{print $2}'`; do kill -9 $i; done"];
        NSDictionary *environment = NSProcessInfo.processInfo.environment;
        [task setEnvironment:environment];
        [task setArguments:arguments];
        [task launch];
        [task waitUntilExit];
        NSTaskTerminationReason exitStatus = [task terminationReason];
        if (exitStatus == NSTaskTerminationReasonExit) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self resetTask];
                [self reloadData];
                if (sender) {
                    [self alertContent:@"success" title:@"终止发布成功" ensureTitle:nil ensureBlock:nil];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (sender) {
                    [self alertContent:@"failed" title:@"终止发布失败" ensureTitle:nil ensureBlock:nil];
                }
            });
        }
    });
}

- (void)check:(NSButton *)button {
    // do something after event
}

- (void)didGeneratePodfilePath {
    NSString *podfileLocalPath = @"";
    for (KCOPodspecModel *model in self.podspecMap.array) {
        podfileLocalPath = [podfileLocalPath stringByAppendingFormat:@"\tpod \'%@\', :path => \'%@\'\n", [model.podName componentsSeparatedByString:@"."].firstObject, model.path];
    }
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:nil];
    [pasteboard setData:[podfileLocalPath dataUsingEncoding:NSUTF8StringEncoding] forType:NSPasteboardTypeString];
    [KCOToastController showToastMessage:@"Copyed" inView:self.view];
}

- (void)didCommitCode {
    for (KCOPodspecModel *model in self.podspecMap.array) {
        NSTask *task = [[NSTask alloc] init];
        task.currentDirectoryURL = [NSURL fileURLWithPath:model.path];
        [task setLaunchPath:@"/usr/local/bin/kdev"];
        NSArray *arguments = @[@"diff", @"-r", @"wangdongliang03", @"sunyonglong", @"-n"];
        NSDictionary *environment = NSProcessInfo.processInfo.environment;
        [task setEnvironment:environment];
        [task setArguments:arguments];
        [task launch];
    }
}

- (void)didAddRepo {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanCreateDirectories:YES];
    
    [openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        BOOL found = NO;
        if (result == NSModalResponseOK) {
            NSURL *selectedURL = [openPanel URL];
            NSString *path = selectedURL.path;
            // 当前目录是否存在podspec
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *currentDirectoryURL = [NSURL fileURLWithPath:path isDirectory:YES];
            NSError *error;
            NSArray *directoryContents = [fileManager contentsOfDirectoryAtURL:currentDirectoryURL
                                                    includingPropertiesForKeys:nil
                                                                       options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                         error:&error];
            if (error) {
                NSLog(@"Error checking directory contents: %@", error);
            } else {
                for (NSURL *fileURL in directoryContents) {
                    if ([[fileURL pathExtension] isEqualToString:@"podspec"]) {
                        found = YES;
                        // name
                        NSString *podspecName = fileURL.lastPathComponent;
                        NSString *podVersion = nil;
                        // version
                        NSError *error = nil;
                        // 读取文件内容
                        NSString *fileContents = [NSString stringWithContentsOfURL:fileURL
                                                                          encoding:NSUTF8StringEncoding
                                                                             error:&error];
                        if (fileContents) {
                            // Use regular expression to extract the version field
                            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\bversion\\s*=\\s*@?[\"']([^\"']+)[\"']"
                                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                                     error:nil];
                            NSTextCheckingResult *match = [regex firstMatchInString:fileContents
                                                                            options:0
                                                                              range:NSMakeRange(0, [fileContents length])];
                            if (match) {
                                NSRange versionRange = [match rangeAtIndex:1];
                                podVersion = [fileContents substringWithRange:versionRange];
                            }
                        }
                        
                        KCOPodspecModel *podspecModel = [[KCOPodspecModel alloc] initWithName:podspecName
                                                                                         path:selectedURL.path
                                                                                      version:podVersion];
                        if ([self.podspecMap.array containsObject:podspecModel]) {
                            [self alertContent:@"podspec has already existed"
                                         title:podspecName
                                   ensureTitle:nil
                                   ensureBlock:nil];
                        } else {
                            [self.podspecMap addObject:podspecModel];
                            [self reloadData];
                            // check
                            [self.checker checkWithRepoList:self.podspecMap.array];
                        }
                    }
                }
            }
            if (!found) {
                [self alertContent:@"no podspec found ~" title:@"NOT FOUND" ensureTitle:nil ensureBlock:nil];
            }
        } else if (result == NSModalResponseCancel) {
            // do noting
        }
    }];
}

# pragma mark - Distributon

- (void)showDistributionInputAlert:(NSString *)title message:(NSString *)message placeholder:(NSString *)placeholder {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert setIcon:[NSImage imageNamed:@"warn"]];
    
    NSView *contentView = [NSView new];
    contentView.frame = CGRectMake(0, 0, 150, 60);
    
    NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(15, 20, 120, 40)];
    [textField setPlaceholderString:placeholder];
    [textField setEditable:YES];
    [textField setSelectable:YES];
    [textField setFocusRingType:NSFocusRingTypeNone];
    [contentView addSubview:textField];
    
    NSButton *notSpeedupBtn = [NSButton radioButtonWithTitle:@"lint" target:self action:@selector(check:)];
    notSpeedupBtn.frame = CGRectMake(15, 0, 40, 20);
    [notSpeedupBtn setButtonType:NSButtonTypeToggle];
    notSpeedupBtn.state = NSControlStateValueOn; // default
    
    NSButton *speedupBtn = [NSButton radioButtonWithTitle:@"跳过lint" target:self action:@selector(check:)];
    speedupBtn.frame = CGRectMake(65, 0, 80, 20);
    [speedupBtn setButtonType:NSButtonTypeToggle];
    [contentView addSubview:speedupBtn];
    [contentView addSubview:notSpeedupBtn];
    
    [alert setAccessoryView:contentView];
    [alert addButtonWithTitle:@"Ensure"];
    NSInteger result = [alert runModal];
    if (result == NSAlertFirstButtonReturn) {
        // check
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d+\\.\\d+\\.\\d+$"
                                                                               options:0
                                                                                 error:&error];
        NSRange range = NSMakeRange(0, [textField.stringValue length]);
        // 检查整个字符串是否匹配模式
        BOOL valid = [regex firstMatchInString:textField.stringValue options:0 range:range] != nil;
        if (valid) {
            // to publish
            self.taskStartDate = [NSDate date];
            NSString *distributonText = @"";
            for (KCOPodspecModel *model in self.podspecMap.array) {
                distributonText  = [distributonText stringByAppendingString:[NSString stringWithFormat:@"%@:%@\n", model.podName, textField.stringValue]];
            }
            [self alertContent:distributonText title:@"确定发布？" ensureTitle:nil ensureBlock:^{
                if (speedupBtn.state == NSControlStateValueOn) {
                    [self startDistribtion:textField.stringValue];
                } else {
                    [self startCheckDistributon:textField.stringValue];
                }
            }];
        } else {
            [self alertContent:@"Formate error" title:@"Error" ensureTitle:nil ensureBlock:nil];
        }
    }
}

- (void)startCheckDistributon:(NSString *)targetVersion {
    for (KCOPodspecModel *model in self.podspecMap.array) {
        // update target version
        model.targetVersion = targetVersion;
        model.isExecuteScript = YES;
        void (^taskBlock)(KCOPodspecModel *) = ^(KCOPodspecModel *model) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSTask *task = [[NSTask alloc] init];
                task.currentDirectoryURL = [NSURL fileURLWithPath:model.path];
                [task setLaunchPath:@"/bin/bash"];
                NSString *shellPath = [model.path stringByAppendingPathComponent:@"distribution.sh"];
                NSArray *arguments = @[@"-l", shellPath, @"check"];
                NSDictionary *environment = NSProcessInfo.processInfo.environment;
                [task setEnvironment:environment];
                [task setArguments:arguments];
                [task launch];
                [task waitUntilExit];
                NSTaskTerminationReason exitStatus = [task terminationReason];
                if (exitStatus == NSTaskTerminationReasonExit) {
                    model.checkPassed = YES;
                    // 都成功了就开始进入发布流程
                    [self ensureCheckState:targetVersion];
                } else {
                    model.checkPassed = NO;
                    model.isExecuteScript = NO;
                    [self didStopDistribution:nil];
                    // show error alert
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self alertContent:@"编译失败" title:model.podName ensureTitle:nil ensureBlock:nil];
                    });
                }
            });
        };
        taskBlock(model);
    }
    [self reloadData];
}

- (void)startDistribtion:(NSString *)targetVersion {
    for (KCOPodspecModel *model in self.podspecMap.array) {
        // update target version
        model.targetVersion = targetVersion;
        model.isExecuteScript = YES;
        void (^taskBlock)(KCOPodspecModel *) = ^(KCOPodspecModel *model) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSTask *task = [[NSTask alloc] init];
                task.currentDirectoryURL = [NSURL fileURLWithPath:model.path];
                [task setLaunchPath:@"/bin/bash"];
                NSString *shellPath = [model.path stringByAppendingPathComponent:@"distribution.sh"];
                NSArray *arguments = @[@"-l", shellPath, targetVersion];
                NSDictionary *environment = NSProcessInfo.processInfo.environment;
                [task setEnvironment:environment];
                [task setArguments:arguments];
                [task launch];
                [task waitUntilExit];
                NSTaskTerminationReason exitStatus = [task terminationReason];
                if (exitStatus == NSTaskTerminationReasonExit) {
                    // update current version
                    model.version = targetVersion;
                    model.versionDate = [NSDate date];
                    model.isExecuteScript = NO;
                    [self ensureDistributonComplete:targetVersion];
                } else {
                    model.isExecuteScript = NO;
                    // show error alert
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self alertContent:@"发版失败" title:model.podName ensureTitle:nil ensureBlock:nil];
                    });
                }
            });
        };
        taskBlock(model);
    }
}

- (void)ensureCheckState:(NSString *)targetVersion  {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL notOk = NO;
        for (KCOPodspecModel *model in self.podspecMap.array) {
            if (!model.checkPassed) {
                notOk = YES;
                break;;
            }
        }
        if (!notOk) {
            [self startDistribtion:targetVersion];
        }
    });
}

- (void)ensureDistributonComplete:(NSString *)targetVersion {
    dispatch_async(dispatch_get_main_queue(), ^{
        // reload
        [self reloadData];
        // alert
        BOOL notOk = NO;
        for (KCOPodspecModel *model in self.podspecMap.array) {
            if (![model.version isEqualToString:targetVersion] || model.isExecuteScript ) {
                notOk = YES;
                break;;
            }
        }
        if (!notOk) {
            NSString *distributonText = @"";
            for (KCOPodspecModel *model in self.podspecMap.array) {
                distributonText  = [distributonText stringByAppendingString:[NSString stringWithFormat:@"%@:%@\n", model.podName, targetVersion]];
            }
            distributonText = [distributonText stringByAppendingFormat:@"发版耗时:%.0lf秒", [[NSDate date] timeIntervalSinceDate:self.taskStartDate]];
            [self alertContent:@"发版完成" title:distributonText ensureTitle:nil ensureBlock:nil];
        }
    });
}

- (void)removeItemWithConfirm:(KCOPodspecModel *)podspec {
    [self alertContent:@"Confirm delete this podspec?"
                 title:podspec.podName
           ensureTitle:@"Remove"
           ensureBlock:^{
        [self.podspecMap removeObject:podspec];
        [self reloadData];
    }];
}

- (void)openRepoDirectory:(KCOPodspecModel *)podspec {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:podspec.path]];
}

- (void)reloadData {
    [self.repoTableView reloadData];
    [KCOLocaiization saveToLocal:self.podspecMap.array];
}

# pragma mark - Utils

- (void)alertContent:(NSString *)alertContent
               title:(NSString *)title
         ensureTitle:(NSString *)ensureTitle
         ensureBlock:(dispatch_block_t)ensureBlock {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:title];
    [alert setInformativeText:alertContent];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert setIcon:[NSImage imageNamed:@"warn"]];
    
    // Add buttons to the alert
    [alert addButtonWithTitle:ensureTitle ? : @"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    
    // Display the alert as a modal dialog
    NSModalResponse response = [alert runModal];
    // Handle the user's response
    if (response == NSAlertFirstButtonReturn) {
        if (ensureBlock) ensureBlock();
    } else if (response == NSAlertSecondButtonReturn) {
    }
}

- (void)resetTask {
    for (KCOPodspecModel *model in self.podspecMap.array) {
        model.targetVersion = nil;
        model.isExecuteScript = NO;
    }
}

# pragma mark - Getter

- (NSButton *)distributonBtn {
    if (!_distributonBtn) {
        _distributonBtn =  [NSButton buttonWithTitle:@"发布" target:self action:@selector(didDistribution)];
    }
    return _distributonBtn;
}

- (NSButton *)stopDistributon {
    if (!_stopDistributon) {
        _stopDistributon =  [NSButton buttonWithTitle:@"终止发布" target:self action:@selector(didStopDistribution:)];
    }
    return _stopDistributon;
}

- (NSButton *)developLocalPathBtn {
    if (!_developLocalPathBtn) {
        _developLocalPathBtn =  [NSButton buttonWithTitle:@"Podfile Path" target:self action:@selector(didGeneratePodfilePath)];
    }
    return _developLocalPathBtn;
}

- (NSButton *)addRepoBtn {
    if (!_addRepoBtn) {
        _addRepoBtn =  [NSButton buttonWithTitle:@"添加Repo" target:self action:@selector(didAddRepo)];
    }
    return _addRepoBtn;
}

- (NSButton *)commitCodeBtn {
    if (!_commitCodeBtn) {
        _commitCodeBtn =  [NSButton buttonWithTitle:@"一键提交KDev" target:self action:@selector(didCommitCode)];
    }
    return _commitCodeBtn;
}

- (KCOTableView *)repoTableView {
    if (!_repoTableView) {
        _repoTableView = [[KCOTableView alloc] init];
        _repoTableView.style = NSTableViewStylePlain;
        _repoTableView.delegate = self;
        _repoTableView.dataSource = self;
        _repoTableView.wantsLayer = YES;
        _repoTableView.layer.borderWidth = 2;
        _repoTableView.layer.borderColor = [NSColor yellowColor].CGColor;
        _repoTableView.layer.masksToBounds = YES;
        _repoTableView.translatesAutoresizingMaskIntoConstraints = YES;
    }
    return _repoTableView;
}

- (NSMutableOrderedSet *)podspecMap {
    if (!_podspecMap) {
        _podspecMap = [NSMutableOrderedSet new];
    }
    return _podspecMap;
}

- (KCORepoChecker *)checker {
    if (!_checker) {
        _checker = [KCORepoChecker new];
        __weak typeof(self) weakSelf = self;
        _checker.repoStateChanged = ^{
            [weakSelf reloadData];
        };
    }
    return _checker;
}

# pragma mark - Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.podspecMap.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [self.podspecMap objectAtIndex:row];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return nil;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    NSDistributonTableRowView *view = [tableView makeViewWithIdentifier:reuseIdentify owner:self];
    if (!view) {
        view = [[NSDistributonTableRowView alloc] init];
        view.podspecModel = [self.podspecMap objectAtIndex:row];
        __weak typeof(self) weakSelf = self;
        view.longPressAction = ^(KCOPodspecModel * _Nonnull podspec) {
            [weakSelf removeItemWithConfirm:podspec];
        };
        view.doubleClickAction = ^(KCOPodspecModel * _Nonnull podspec) {
            [weakSelf openRepoDirectory:podspec];
        };
    }
    return view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return kRowHeight;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
}

@end
