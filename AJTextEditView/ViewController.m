//
//  ViewController.m
//  AJTextEditView
//
//  Created by JasonHu on 2017/7/3.
//  Copyright © 2017年 AJ. All rights reserved.
//

#import "ViewController.h"
#import "AJTextField.h"
#import "AJTextView.h"

@interface ViewController ()

@property (nonatomic ,weak)AJTextField * textfield;

@property (nonatomic ,weak)AJTextView * textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self textfield];
    
    [self textView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 懒加载

-(AJTextField *)textfield
{
    if (!_textfield) {
        
        AJTextField * textfield=[[AJTextField alloc]initWithFrame:CGRectMake(10, 100, [UIScreen mainScreen].bounds.size.width-10*2, 40)];
        textfield.layer.borderColor=[UIColor blackColor].CGColor;
        textfield.layer.borderWidth=0.5f;
        
        textfield.placeholder=@"请输入内容";
        [textfield setMaxCount:20 isSupportBlank:YES prepareText:nil textFieldDidEndEditingBlock:^(NSString *text) {
            
            NSLog(@"---textFieldDidEndEditing");
            
        } textFieldEditingChangedBlock:^(AJTextField *textField, NSString *text) {
            
            NSLog(@"---textFieldEditingChanged");
            
        }];
        
        [self.view addSubview:textfield];
        _textfield=textfield;
        
    }
    return _textfield;
}

-(AJTextView *)textView
{
    if (!_textView) {
        
        AJTextView * textView=[[AJTextView alloc]initWithFrame:CGRectMake(10, 200, [UIScreen mainScreen].bounds.size.width-10*2, 100)];
        textView.layer.borderColor=[UIColor blackColor].CGColor;
        textView.layer.borderWidth=0.5f;
        
    textView.placeholder=@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
        
        [textView setMaxCount:20 isSupportBlank:NO isSupportNewLine:NO prepareText:@"hushijie" textViewTextDidChangeBlock:^(NSString *textViewText) {
            
        }];
        
        [self.view addSubview:textView];
        _textView=textView;
        
    }
    return _textView;
}

@end
