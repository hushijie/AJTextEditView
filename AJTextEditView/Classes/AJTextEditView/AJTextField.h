//
//  AJTextField.h
//  AJTextEditView
//
//  Created by JasonHu on 2017/7/3.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 文本编辑框
 */

#import <UIKit/UIKit.h>

@interface AJTextField : UITextField


#pragma mark - 

/**
 AJTextField的初始化设置

 @param maxCount 可输入的最大字数限制（maxCount=0，表示不限制输入字数）
 @param isSupportBlank 是否支持输入空格
 @param prepareText 预备文字（有些textField需要预先传递文案进去显示）
 @param textFieldDidEndEditingBlock 文本框停止编辑的block
 @param textFieldEditingChangedBlock 文本框中编辑内容改变的block
 */
-(void)setMaxCount:(int)maxCount isSupportBlank:(BOOL)isSupportBlank prepareText:(NSString *)prepareText textFieldDidEndEditingBlock:(void(^)(NSString * text))textFieldDidEndEditingBlock textFieldEditingChangedBlock:(void(^)(AJTextField * textField,NSString * text))textFieldEditingChangedBlock;


@end
