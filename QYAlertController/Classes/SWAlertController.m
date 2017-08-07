//
//  SWAlertController.m
//  VPAN3Plus
//
//  Created by 邱成西 on 2017/8/7.
//  Copyright © 2017年 FDSTECH. All rights reserved.
//

#import "SWAlertController.h"
#import <objc/runtime.h>

//toast默认展示时间
static NSTimeInterval const SWAlertShowDurationDefault = 1.0f;

#define LazyLoadMethod(variable)    \
- (NSMutableArray *)variable \
{   \
if (!_##variable)  \
{   \
_##variable = [NSMutableArray array];  \
}   \
return _##variable;    \
}


#pragma mark - 
#pragma mark - 配置action对象

@interface SWAlertActionModel : NSObject

@property (nonatomic, copy) NSString * title;
@property (nonatomic, assign) UIAlertActionStyle style;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) BOOL isMonitor;

@end

@implementation SWAlertActionModel

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"";
        self.style = UIAlertActionStyleDefault;
        self.color = [UIColor orangeColor];
        self.isMonitor = NO;
    }
    return self;
}
@end

// AlertActions配置
typedef void (^SWAlertActionsConfig)(SWAlertActionBlock actionBlock);

@interface SWAlertController ()<UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray <SWAlertActionModel *>*alertActionArray;

@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, strong) UIAlertAction *alertAction;

-(SWAlertActionsConfig)alertActionsConfig;
@end

@implementation SWAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.keyboardType = UIKeyboardTypeDefault;
    self.secureTextEntry = NO;
    self.placeholder = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.alertDidDismiss) {
        self.alertDidDismiss();
    }
}

- (instancetype)initAlertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle {
    if (!(title.length > 0) && (message.length > 0) && (preferredStyle == UIAlertControllerStyleAlert)) {
        title = @"";
    }
    self = [[self class] alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    if (!self) return nil;
    
    self.toastStyleDuration = SWAlertShowDurationDefault;
    
    return self;
}


#pragma mark -
#pragma mark - 配置action对象,该block返回值不是本类属性，只是局部变量，不会造成循环引用

-(SWAlertActionTitle _Nullable )addActionMonitorTitle {
    return ^(NSString *title, UIColor *color) {
        SWAlertActionModel *actionModel = [[SWAlertActionModel alloc] init];
        actionModel.title = title;
        actionModel.style = UIAlertActionStyleDefault;
        actionModel.color = color;
        actionModel.isMonitor = YES;
        [self.alertActionArray addObject:actionModel];
        return self;
    };
}

- (SWAlertActionTitle)addActionDefaultTitle {
    return ^(NSString *title, UIColor *color) {
        SWAlertActionModel *actionModel = [[SWAlertActionModel alloc] init];
        actionModel.title = title;
        actionModel.style = UIAlertActionStyleDefault;
        actionModel.color = color;
        [self.alertActionArray addObject:actionModel];
        return self;
    };
}

-(SWAlertActionTitle _Nullable )addActionCancelTitle {
    return ^(NSString *title, UIColor *color) {
        SWAlertActionModel *actionModel = [[SWAlertActionModel alloc] init];
        actionModel.title = title;
        actionModel.style = UIAlertActionStyleCancel;
        actionModel.color = color;
        [self.alertActionArray addObject:actionModel];
        return self;
    };
}

-(SWAlertActionTitle _Nullable )addActionDestructiveTitle {
    return ^(NSString *title, UIColor *color) {
        SWAlertActionModel *actionModel = [[SWAlertActionModel alloc] init];
        actionModel.title = title;
        actionModel.style = UIAlertActionStyleDestructive;
        actionModel.color = color;
        [self.alertActionArray addObject:actionModel];
        return self;
    };
}

//action配置
-(SWAlertActionsConfig)alertActionsConfig {
    return ^(SWAlertActionBlock actionBlock) {
        if (self.alertActionArray.count > 0) {
            //创建action
            __weak typeof(self)weakSelf = self;
            [self.alertActionArray enumerateObjectsUsingBlock:^(SWAlertActionModel *actionModel, NSUInteger idx, BOOL * _Nonnull stop) {
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:actionModel.title style:actionModel.style handler:^(UIAlertAction * _Nonnull action) {
                    __strong typeof(weakSelf)strongSelf = weakSelf;
                    if (actionBlock) {
                        actionBlock(idx, action, strongSelf);
                    }
                }];
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
                    [alertAction setValue:actionModel.color forKey:@"_titleTextColor"];
                }
                
                if (actionModel.isMonitor) {
                    alertAction.enabled = !actionModel.isMonitor;
                    
                    self.alertAction = alertAction;
                }
                
                [self addAction:alertAction];
            }];
        }else {
            NSTimeInterval duration = self.toastStyleDuration > 0 ? self.toastStyleDuration : SWAlertShowDurationDefault;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:NULL];
            });
        }
    };
}



LazyLoadMethod(alertActionArray);

@end

NSString const *filterKey = @"filterKey";
NSString const *actionKey = @"actionKey";

@implementation UIViewController (SWAlertController)

-(void)showAlertWithPreferredStyle:(UIAlertControllerStyle)preferredStyle
                             title:(NSString *)title
                           message:(NSString *)message
                 appearanceProcess:(SWAlertAppearanceProcess)appearanceProcess
                      actionsBlock:(SWAlertActionBlock)actionBlock {
    if (appearanceProcess) {
        SWAlertController *alertMaker = [[SWAlertController alloc] initAlertControllerWithTitle:title message:message preferredStyle:preferredStyle];
        //防止nil
        if (!alertMaker) {
            return ;
        }
        //加工链
        appearanceProcess(alertMaker);
        //配置响应
        alertMaker.alertActionsConfig(actionBlock);
        
        if (alertMaker.alertDidShown) {
            [self presentViewController:alertMaker animated:YES completion:^{
                alertMaker.alertDidShown();
            }];
        }else {
            [self presentViewController:alertMaker animated:YES completion:NULL];
        }
    }
}

-(void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         appearanceProcess:(SWAlertAppearanceProcess)appearanceProcess
              actionsBlock:(SWAlertActionBlock)actionBlock {
    [self showAlertWithPreferredStyle:UIAlertControllerStyleAlert title:title message:message appearanceProcess:appearanceProcess actionsBlock:actionBlock];
}

-(void)showActionSheetWithTitle:(NSString *)title
                             message:(NSString *)message
                   appearanceProcess:(SWAlertAppearanceProcess)appearanceProcess
                        actionsBlock:(SWAlertActionBlock)actionBlock {
    [self showAlertWithPreferredStyle:UIAlertControllerStyleActionSheet title:title message:message appearanceProcess:appearanceProcess actionsBlock:actionBlock];
}

-(void)showTextAlertWithTitle:(nullable NSString *)title
                      message:(nullable NSString *)message
            appearanceProcess:(nullable SWAlertAppearanceProcess)appearanceProcess
                    textRegex:(nullable SWFilter)textFilter
                 actionsBlock:(nullable SWAlertActionBlock)actionBlock {
    if (appearanceProcess) {
        SWAlertController *alertMaker = [[SWAlertController alloc] initAlertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        //防止nil
        if (!alertMaker) {
            return ;
        }
        
        //加工链
        appearanceProcess(alertMaker);

        __block SWAlertController *alert  = alertMaker;
        [alertMaker addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = alert.placeholder;
            textField.keyboardType = alert.keyboardType;
            textField.secureTextEntry = alert.secureTextEntry;

            [textField addTarget:self action:@selector(watchTextFieldMethod:) forControlEvents:UIControlEventEditingChanged];
        }];
        
        //配置响应
        alertMaker.alertActionsConfig(actionBlock);
        
        self.alertAction = alertMaker.alertAction;
        
        self.textFilter = textFilter;
        
        if (alertMaker.alertDidShown) {
            [self presentViewController:alertMaker animated:YES completion:^{
                alertMaker.alertDidShown();
            }];
        }else {
            [self presentViewController:alertMaker animated:YES completion:NULL];
        }
    }
}

//监听输入的UITextField
-(void)watchTextFieldMethod:(UITextField *)textField {
    if (self.textFilter(textField.text)) {
        self.alertAction.enabled = YES;
    }
}

#pragma mark - getter/setter

-(SWFilter)textFilter {
    return objc_getAssociatedObject(self, &filterKey);
}

-(void)setTextFilter:(SWFilter)textFilter {
    objc_setAssociatedObject(self, &filterKey, textFilter, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(UIAlertAction *)alertAction {
    return objc_getAssociatedObject(self, &actionKey);
}

-(void)setAlertAction:(UIAlertAction *)alertAction {
    objc_setAssociatedObject(self, &actionKey, alertAction, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

