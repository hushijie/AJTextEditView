//
//  AJTextView.h
//  AJTextEditView
//
//  Created by JasonHu on 2017/7/3.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 文本编辑域
 */

#import <UIKit/UIKit.h>

@interface AJTextView : UITextView


#pragma mark -

/**
 AJTextView的初始化设置

 @param maxCount 可输入的最大字数限制（maxCount=0，表示不限制输入字数）
 @param isSupportBlank 是否支持输入空格
 @param isSupportNewLine 是否支持输入换行
 @param prepareText 预备文字（有些textView需要预先传递文案进去显示）
 @param textViewTextDidChangeBlock 文本域中编辑内容改变的block
 */
-(void)setMaxCount:(int)maxCount isSupportBlank:(BOOL)isSupportBlank isSupportNewLine:(BOOL)isSupportNewLine prepareText:(NSString *)prepareText textViewTextDidChangeBlock:(void(^)(NSString * textViewText))textViewTextDidChangeBlock;


#pragma mark -

/**
 默认文字
 */
@property (nonatomic, copy) NSString *placeholder;


@end
