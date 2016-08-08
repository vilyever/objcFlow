//
//  VDFlow.h
//  objcFlow
//
//  Created by Deng on 16/8/8.
//  Copyright © Deng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class VDFlow;

@protocol VDFlowDelegate <NSObject>
@optional
- (void)flowDidChange:(VDFlow *)flow;
@end

/**
 *  专注于处理业务流程，包括UI状态，界面跳转，动作执行，防重复快速点击等
 *  与ViewController绑定后，在UI状态变更时通知ViewController
 *  ViewController中对BUTTON点击等事件的处理通过调用此子类封装的方法进行操作
 *  例：点击table列表的第一项，- (BOOL)trySelectItem:(Model *)model;
 *  依据table的index取得相应的model后调用封装的方法，此处BOOL返回值表示操作是否成功
 *  比如第一次点击第一项后将跳转详细界面展示，点击后记录此项为selectedItem，返回YES，若此时在跳转操作未完成时，又点击了其它项，因为selectedItem不为nil，则不进行操作返回NO
 *  在跳转详细界面时，通过回调或aop等方法，在详细界面dealloc时将selectedItem设为nil
 */
@interface VDFlow : NSObject

#pragma mark Constructor
/**
 *  通用主业务流程
 *  每次调用的返回值都是同一Flow
 *  通常用于大部分业务
 */
+ (instancetype)mainFlow;

/**
 *  新建分支业务流程
 *  每次调用时都返回新的Flow
 *  通常用于多开临时状态变化
 *  例：显示文件信息时，界面中有相关文件可点操作，若此时点击后跳转到一个新的ViewController显示另一文件信息，则无法通过更改mainFlow来实现，否则返回时将导致每个显示文件信息的ViewController都显示相同的文件
 */
+ (instancetype)newBranchFlow;

/**
 *  只继承不调用
 */
- (instancetype)initWithMain:(BOOL)isMain;

#pragma mark Public Method
- (void)bindDelegate:(UIViewController<VDFlowDelegate> *)delegate;
- (void)unbindDelegate:(UIViewController<VDFlowDelegate> *)delegate;

- (void)triggerAllDelegates;
- (void)triggerDelegate:(UIViewController<VDFlowDelegate> *)delegate;
- (void)triggerDelegate:(UIViewController<VDFlowDelegate> *)delegate cancelOnViewDisappeared:(BOOL)cancelOnViewDisappeared;
- (void)triggerDelegateAfterViewWillAppear:(UIViewController<VDFlowDelegate> *)delegate;
- (void)triggerDelegateAfterViewDidAppear:(UIViewController<VDFlowDelegate> *)delegate;


#pragma mark Properties
@property (nonatomic, assign, readonly) BOOL isMain;
@property (nonatomic, weak) VDFlow *parentFlow;
@property (nonatomic, strong, readonly) NSMutableArray<__kindof VDFlow *> *childFlowArray;

@property (nonatomic, strong, readonly) NSMutableArray<__kindof UIViewController<VDFlowDelegate> *> *delegates;
@property (nonatomic, strong, readonly) NSMutableArray<__kindof VDFlow *> *branchArray;

#pragma mark Protected Method
- (void)mainFlowDidChange:(VDFlow *)mainFlow;
- (void)childFlowDidChange:(VDFlow *)childFlow;
- (void)parentFlowDidChange:(VDFlow *)parentFlow;
- (void)flowDidUnbindAllDelegates;

#pragma mark Private Method


@end
