//
//  SWAlertController.h
//  VPAN3Plus
//
//  Created by 邱成西 on 2017/8/7.
//  Copyright © 2017年 FDSTECH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWAlertController;

//alertAction配置链
typedef SWAlertController * _Nonnull (^SWAlertActionTitle)(NSString * _Nullable title, UIColor * _Nullable color);

//alert按钮执行回调
typedef void (^SWAlertActionBlock)(NSInteger buttonIndex, UIAlertAction * _Nullable action, SWAlertController * _Nullable alertSelf);


@interface SWAlertController : UIAlertController

@property (nullable, nonatomic, copy) void (^alertDidShown)();
@property (nullable, nonatomic, copy) void (^alertDidDismiss)();

//设置toast模式展示时间：如果alert未添加任何按钮，将会以toast样式展示，这里设置展示时间，默认1s
@property (nonatomic, assign) NSTimeInterval toastStyleDuration;

@property (nonatomic, assign) UIKeyboardType keyboardType;
@property (nullable, nonatomic, copy) NSString *placeholder;
@property (nonatomic, assign) BOOL secureTextEntry;

-(SWAlertActionTitle _Nullable )addActionMonitorTitle;
-(SWAlertActionTitle _Nullable )addActionDefaultTitle;
-(SWAlertActionTitle _Nullable )addActionCancelTitle;
-(SWAlertActionTitle _Nullable )addActionDestructiveTitle;

@end

/*
 1. showAlertWithTitle：
输出alertController
 
 2. showActionSheetWithTitle
输出ActionSheet
 
 3. showTextAlertWithTitle
输出带输入框的alertController
 
 //目前只支持一个带监听的输入框，多个可以调showAlertWithTitle，在加工链里面添加
 */

//alert构造块,配置对象
typedef void(^SWAlertAppearanceProcess)(SWAlertController * _Nullable alertMaker);
//text盼定条件
typedef BOOL (^SWFilter)(NSString * _Nullable value);

@interface UIViewController (SWAlertController)

@property (nonatomic, copy) SWFilter _Nullable textFilter;
@property (nonatomic, strong) UIAlertAction * _Nullable alertAction;

-(void)showAlertWithTitle:(nullable NSString *)title
                   message:(nullable NSString *)message
         appearanceProcess:(nullable SWAlertAppearanceProcess)appearanceProcess
              actionsBlock:(nullable SWAlertActionBlock)actionBlock;

-(void)showActionSheetWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)message
                   appearanceProcess:(nullable SWAlertAppearanceProcess)appearanceProcess
                        actionsBlock:(nullable SWAlertActionBlock)actionBlock;

-(void)showTextAlertWithTitle:(nullable NSString *)title
                      message:(nullable NSString *)message
            appearanceProcess:(nullable SWAlertAppearanceProcess)appearanceProcess
                    textRegex:(nullable SWFilter)textFilter
                 actionsBlock:(nullable SWAlertActionBlock)actionBlock;
@end
