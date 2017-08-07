//
//  ViewController.m
//  QYAlertController
//
//  Created by 邱成西 on 2017/8/7.
//  Copyright © 2017年 邱大侠. All rights reserved.
//

#import "ViewController.h"
#import "SWAlertController.h"

@interface ViewController ()

<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *table;

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.dataArray = @[@"普通的alert",@"alert-toast",@"输入框的alert",@"action",@"alert带多个输入框，未实现监听"];
    
    [self.table reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table代理

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"alert_cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    switch (indexPath.row) {
        case 0:
            
            
            [self showAlertWithTitle:self.dataArray[indexPath.row] message:nil appearanceProcess:^(SWAlertController * _Nullable alertMaker) {
                alertMaker.addActionDefaultTitle(@"确定",[UIColor blackColor]);
                alertMaker.addActionCancelTitle(@"取消",[UIColor redColor]);
                
            } actionsBlock:^(NSInteger buttonIndex, UIAlertAction * _Nullable action, SWAlertController * _Nullable alertSelf) {
                
                NSLog(@"buttonIndex = %ld",buttonIndex);
            }];
            
            
            break;
            
        case 1:
            
            [self showAlertWithTitle:self.dataArray[indexPath.row] message:nil appearanceProcess:^(SWAlertController * _Nullable alertMaker) {
                alertMaker.toastStyleDuration = 1.5;
                
                alertMaker.alertDidShown = ^{
                    NSLog(@"出现");
                };
                
                alertMaker.alertDidDismiss = ^{
                    NSLog(@"消失");
                };
                
            } actionsBlock:nil];
            
            break;
            
        case 2:
            
            [self showTextAlertWithTitle:self.dataArray[indexPath.row] message:nil appearanceProcess:^(SWAlertController * _Nullable alertMaker) {
                alertMaker.addActionCancelTitle(@"取消",[UIColor redColor]);
                alertMaker.addActionMonitorTitle(@"确认",[UIColor redColor]);
                alertMaker.keyboardType = UIKeyboardTypeNumberPad;
            } textRegex:^BOOL(NSString * _Nullable value) {
                return value.length >6;
            } actionsBlock:^(NSInteger buttonIndex, UIAlertAction * _Nullable action, SWAlertController * _Nullable alertSelf) {
                UITextField *textField = alertSelf.textFields.firstObject;
                NSLog(@"buttonIndex = %ld",buttonIndex);
                NSLog(@"text = %@",textField.text);
            }];
            
            break;
            
        case 3:
            
            [self showActionSheetWithTitle:self.dataArray[indexPath.row] message:nil appearanceProcess:^(SWAlertController * _Nullable alertMaker) {
                alertMaker.addActionDefaultTitle(@"确定",[UIColor blackColor]);
                alertMaker.addActionCancelTitle(@"取消",[UIColor redColor]);
            } actionsBlock:^(NSInteger buttonIndex, UIAlertAction * _Nullable action, SWAlertController * _Nullable alertSelf) {
                NSLog(@"buttonIndex = %ld",buttonIndex);
            }];
            
            break;
            
        case 4:
            
            [self showAlertWithTitle:self.dataArray[indexPath.row] message:nil appearanceProcess:^(SWAlertController * _Nullable alertMaker) {
                alertMaker.addActionDefaultTitle(@"确定",[UIColor blackColor]);
                alertMaker.addActionCancelTitle(@"取消",[UIColor redColor]);
                
                [alertMaker addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.placeholder = @"输入框1-请输入";
                }];
                [alertMaker addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.placeholder = @"输入框2-请输入";
                }];
                
            } actionsBlock:^(NSInteger buttonIndex, UIAlertAction * _Nullable action, SWAlertController * _Nullable alertSelf) {
                
                if (buttonIndex == 0) {
                    UITextField *textField = alertSelf.textFields.firstObject;
                    NSLog(@"text0 = %@",textField.text);
                }else {
                    UITextField *textField = alertSelf.textFields.lastObject;
                    NSLog(@"text1 = %@",textField.text);
                }
            }];

            
            break;
        default:
            break;
    }
}

@end
