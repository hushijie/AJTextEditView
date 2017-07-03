//
//  AJTextView.m
//  AJTextEditView
//
//  Created by JasonHu on 2017/7/3.
//  Copyright © 2017年 AJ. All rights reserved.
//

#define AJTextView_FontSize 15
#define AJTextView_TextColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.80]
#define AJTextView_placeholderLabel_TextColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.16]
#define AJTextView_TintColor [UIColor colorWithRed:255.0/255.0 green:104.0/255.0 blue:120.0/255.0 alpha:1]

#import "AJTextView.h"

@interface AJTextView ()<UITextViewDelegate>

/**
 允许输入的最大字数（如果 maxCount=0 ，表示不限制输入字数）
 */
@property (nonatomic ,assign)int maxCount;

/**
 是否支持换行：YES-支持、NO-不支持
 */
@property (nonatomic ,assign)BOOL isSupportNewLine;

/**
 是否支持空格：YES-支持、NO-不支持
 */
@property (nonatomic ,assign)BOOL isSupportBlank;


/**
 是否需要设置text改变之后的监听:YES-需要、NO—不需要
 */
@property (nonatomic ,assign)BOOL isNeedTextViewTextDidChangeNotificationStatus;

/**
 定义一个block的属性,当字数改变的时候会调用此block
 */
@property(nonatomic,copy) void(^textViewTextDidChangeBlock)(NSString * textViewText);


/**
 默认文字的label
 */
@property (nonatomic, weak) UILabel * placeholderLabel;


/**
 预备文字（有些textView需要预先传递文案进去显示）
 */
@property (nonatomic, copy) NSString * prepareText;

@end

@implementation AJTextView

#pragma mark -

- (id)initWithFrame:(CGRect)frame
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

- (void)setUp
{
    /*
     字体、颜色等样式的初始化设置
     */
    self.font = [UIFont systemFontOfSize:AJTextView_FontSize];
    self.textColor = AJTextView_TextColor;
    
    //设置光标颜色
    self.tintColor=AJTextView_TintColor;
    
    //展示提示文字的label
    UILabel *placeholderLabel = [[UILabel alloc] init];
    placeholderLabel.backgroundColor = [UIColor whiteColor];
    placeholderLabel.textColor = AJTextView_placeholderLabel_TextColor;
    placeholderLabel.font = self.font;
    placeholderLabel.numberOfLines = 0;
    placeholderLabel.hidden = YES;
    [self insertSubview:placeholderLabel atIndex:0];
    self.placeholderLabel = placeholderLabel;
}

- (void)dealloc
{
    if (self.isNeedTextViewTextDidChangeNotificationStatus) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}



#pragma mark - 是否禁止复制粘贴

/*
 禁止复制粘贴菜单栏的方法
 */
//-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
//
//    //不能弹出复制粘贴菜单栏
//    return NO;
//}




#pragma mark - setter


-(void)setMaxCount:(int)maxCount isSupportBlank:(BOOL)isSupportBlank isSupportNewLine:(BOOL)isSupportNewLine prepareText:(NSString *)prepareText textViewTextDidChangeBlock:(void(^)(NSString * textViewText))textViewTextDidChangeBlock;
{
    //不限制输入字数
    if (maxCount==0) {
        _maxCount=INT_MAX;
    }
    //显示输入字数
    else{
        _maxCount=maxCount;
    }
    
    //遵循textView的代理，禁止回车/限制输入字数
    self.delegate=self;
    //设置字数变化的监听（因为shouldChangeTextInRange代理方法在iOS10以下版本，不能监听到联想文字输入的变化！需要另外设置textDidChange方法）
    self.isNeedTextViewTextDidChangeNotificationStatus=YES;
    
    
    _isSupportBlank=isSupportBlank;
    _isSupportNewLine=isSupportNewLine;
    
    _textViewTextDidChangeBlock=textViewTextDidChangeBlock;
    
    //设置预备文字
    self.prepareText=prepareText;
}


- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = [placeholder copy];
    
    self.placeholderLabel.text = placeholder;
    if (placeholder.length) {
        
        self.placeholderLabel.hidden = NO;
        
        // 计算frame
        CGFloat placeholderX = 4;
        CGFloat placeholderY = 8;
        CGFloat maxW = self.frame.size.width - 2 * placeholderX;
        
        CGRect textRect = [placeholder boundingRectWithSize:CGSizeMake(maxW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.placeholderLabel.font} context:nil];
        CGFloat needHeight = textRect.size.height;
        
        CGFloat maxH=self.frame.size.height-placeholderY*2;
        CGFloat height=needHeight>maxH?maxH:needHeight;
        
        CGSize placeholderSize = CGSizeMake(maxW, height);
        self.placeholderLabel.frame = CGRectMake(placeholderX, placeholderY, placeholderSize.width, placeholderSize.height);
        
    }
    else {
        self.placeholderLabel.hidden = YES;
    }
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    self.placeholderLabel.font = font;
    self.placeholder = self.placeholder;
}

-(void)setPrepareText:(NSString *)prepareText
{
    _prepareText=prepareText;
    
    if (_prepareText.length>0) {
        self.text=_prepareText; //设置预备文字
        [self textDidChange];   //调文字改变触发的事件
    }
    
}

-(void)setIsNeedTextViewTextDidChangeNotificationStatus:(BOOL)isNeedTextViewTextDidChangeNotificationStatus
{
    _isNeedTextViewTextDidChangeNotificationStatus=isNeedTextViewTextDidChangeNotificationStatus;
    
    if (_isNeedTextViewTextDidChangeNotificationStatus) {
        //监听textView文字改变的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
    }
}


#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    /*
     不返回内容的可能情形：
     1.不能超过最大字数限制
     2.不能输入回车
     3.不能输入空格
     */
    
    NSString * string=[NSString stringWithFormat:@"%@%@",textView.text,text];
    
    //不能超过最大字数
    if (string.length>self.maxCount) {
        return NO;
    }
    
    //如果不支持换行、却输入了换行
    if (!self.isSupportNewLine && [text isEqualToString:@"\n"]) {
        return NO;
    }
    
    //如果不支持空格、却输入了空格
    if (!self.isSupportBlank && [text isEqualToString:@" "]) {
        return NO;
    }
    
    return YES;
    
}



#pragma mark - 字数变化的监听方法

- (void)textDidChange
{
    self.placeholderLabel.hidden = (self.text.length != 0);
    
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
    
    
    /*
     走文字变化的回调（方便文字变化监听功能的拓展）
     */
    if (self.textViewTextDidChangeBlock) {
        self.textViewTextDidChangeBlock(self.text);
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
