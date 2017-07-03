//
//  AJTextField.m
//  AJTextEditView
//
//  Created by JasonHu on 2017/7/3.
//  Copyright © 2017年 AJ. All rights reserved.
//

#define AJTextField_FontSize 15
#define AJTextField_TextColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.80]
#define AJTextField_placeholderLabel_TextColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.16]
#define AJTextField_TintColor [UIColor colorWithRed:255.0/255.0 green:104.0/255.0 blue:120.0/255.0 alpha:1]

#import "AJTextField.h"

@interface AJTextField ()<UITextFieldDelegate>

/**
 允许输入的最大字数
 */
@property (nonatomic ,assign)int maxCount;

/**
 是否支持空格：YES-支持、NO-不支持（默认支持）
 */
@property (nonatomic ,assign)BOOL isSupportBlank;


/**
 停止编辑后的回调（返回编辑的文本）
 */
@property (nonatomic ,copy)void(^textFieldDidEndEditingBlock)(NSString * text);


/**
 是否需要添加监听textField编辑变化的方法:YES-添加、NO-不添加 （如果设置了maxCount，会自动设置该属性为YES）
 */
@property (nonatomic ,assign)BOOL isNeedAddTargetTextFieldEditingChanged;

/**
 监听textField编辑变化后的回调
 */
@property (nonatomic ,copy)void(^textFieldEditingChangedBlock)(AJTextField * textField,NSString * text);


/**
 预备文字（有些textField需要预先传递文案进去显示）
 */
@property (nonatomic, copy) NSString * prepareText;

@end

@implementation AJTextField

#pragma mark -

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

-(void)setUp
{
    /*
     字体、颜色等样式的初始化操作
     */
    self.font=[UIFont systemFontOfSize:AJTextField_FontSize];
    self.textColor=AJTextField_TextColor;
    [self setValue:AJTextField_placeholderLabel_TextColor forKeyPath:@"_placeholderLabel.textColor"];
    [self setValue:[UIFont systemFontOfSize:AJTextField_FontSize] forKeyPath:@"_placeholderLabel.font"];
    
    //设置光标颜色
    self.tintColor=AJTextField_TintColor;
}


#pragma mark - setter

-(void)setMaxCount:(int)maxCount isSupportBlank:(BOOL)isSupportBlank prepareText:(NSString *)prepareText textFieldDidEndEditingBlock:(void(^)(NSString * text))textFieldDidEndEditingBlock textFieldEditingChangedBlock:(void(^)(AJTextField * textField,NSString * text))textFieldEditingChangedBlock;
{
    //不限制字数
    if (maxCount==0) {
        _maxCount=INT_MAX;
    }
    //限制字数
    else{
        _maxCount=maxCount;
    }
    
    self.isNeedAddTargetTextFieldEditingChanged=YES;//设置文本变化的监听
    self.delegate=self;//将自己设置为 UITextFieldDelegate 代理
    
    _isSupportBlank=isSupportBlank;
    
    _textFieldDidEndEditingBlock=textFieldDidEndEditingBlock;
    _textFieldEditingChangedBlock=textFieldEditingChangedBlock;

    //设置预设置文字
    self.prepareText=prepareText;
}

-(void)setIsNeedAddTargetTextFieldEditingChanged:(BOOL)isNeedAddTargetTextFieldEditingChanged
{
    _isNeedAddTargetTextFieldEditingChanged=isNeedAddTargetTextFieldEditingChanged;
    
    //需要添加textField变化的监听
    if (_isNeedAddTargetTextFieldEditingChanged) {
        
        [self addTarget:self action:@selector(textFieldEditingChanged) forControlEvents:UIControlEventEditingChanged];

    }
}

-(void)setPrepareText:(NSString *)prepareText
{
    _prepareText=prepareText;
    
    if (_prepareText.length>0) {
        self.text=_prepareText; //设置预备文字
        [self textFieldEditingChanged];   //调文字改变触发的事件
    }
    
}


#pragma mark - UITextFieldDelegate


/**
 在点击return键的时 调用的方法
 */
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


/**
 编辑框文字变化的时候 - 是否返回键盘输入内容的回调方法
 */
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /*
     不返回内容的可能情形：
     1.不能超过最大字数限制
     2.不能输入空格
     */
    
    NSString * nextstring=[NSString stringWithFormat:@"%@%@",textField.text,string];
    
    //不能超过最大字数
    if (nextstring.length>self.maxCount) {
        return NO;
    }
    
    //如果不支持空格、却输入了空格
    if (!self.isSupportBlank && [string isEqualToString:@" "]) {
        return NO;
    }
    
    return YES;
    
}


/**
 结束编辑的时候（收起键盘的时候）- 返回编辑的内容
 */
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if (self.textFieldDidEndEditingBlock) {
        self.textFieldDidEndEditingBlock(self.text);
    }
}




#pragma mark - textField编辑变化的监听方法


-(void)textFieldEditingChanged
{
    /*
     裁剪多余字数
     */
    
    //超出了最大字数限制，裁剪掉
    if (self.text.length>self.maxCount) {
        
        int kMaxLength = self.maxCount;
        NSString *toBeString = self.text;
        NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
        
        // 简体中文输入，包括简体拼音，健体五笔，简体手写
        if ([lang isEqualToString:@"zh-Hans"]) {
            UITextRange *selectedRange = [self markedTextRange];
            //获取高亮部分
            UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (!position) {
                if (toBeString.length > kMaxLength) {
                    
                    int lenth = self.maxCount;
                    
                    toBeString = [self disable_emoji:toBeString];
                    
                    if (lenth>toBeString.length) {
                        
                        lenth = (int)toBeString.length;
                    }
                    
                    self.text = [toBeString substringToIndex:lenth];
                    
                }
            }
            // 有高亮选择的字符串，则暂不对文字进行统计和限制
            else{
                
            }
        }
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        else{
            if (toBeString.length > kMaxLength) {
                
                int lenth = self.maxCount;
                
                toBeString = [self disable_emoji:toBeString];
                
                if (lenth>toBeString.length) {
                    
                    lenth = (int)toBeString.length;
                }
                
                self.text = [toBeString substringToIndex:lenth];
            }
        }
        
    }
    
    
    //走编辑变化的回调
    if (self.textFieldEditingChangedBlock) {
        self.textFieldEditingChangedBlock(self,self.text);
    }
}


/**
 消除emoji
 */
- (NSString *)disable_emoji:(NSString *)text
{
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text options:0 range:NSMakeRange([text length]-2, 2) withTemplate:@""];
    return modifiedString;
    
}

@end
