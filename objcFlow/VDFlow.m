//
//  VDFlow.m
//  objcFlow
//
//  Created by Deng on 16/8/8.
//  Copyright © Deng. All rights reserved.
//

#import "VDFlow.h"

#import <objcObject/objcObject.h>
#import <objcBlock/objcBlock.h>
#import <objcWeakRef/objcWeakRef.h>
#import <objcHook/objcHook.h>

@interface VDFlow ()

- (void)__i__initVDFlow;
- (void)__i__addBranch:(VDFlow *)branch;
- (void)__i__removeBranch:(VDFlow *)branch;

@property (nonatomic, assign, readwrite) BOOL isMain;

@property (nonatomic, strong, readwrite) NSMutableArray<__kindof VDFlow *> *childFlowArray;

@property (nonatomic, strong, readwrite) NSMutableArray<__kindof UIViewController<VDFlowDelegate> *> *delegates;
@property (nonatomic, strong, readwrite) NSMutableArray<__kindof VDFlow *> *branchArray;

@end


@implementation VDFlow

#pragma mark Constructor
+ (instancetype)mainFlow {
    return [self vd_sharedInstance:^id{
        return [[self alloc] initWithMain:YES];
    }];
}

+ (instancetype)newBranchFlow {
    return [[self alloc] initWithMain:NO];
}

- (instancetype)initWithMain:(BOOL)isMain {
    self = [super init];
    
    _isMain = isMain;
    
    [self __i__initVDFlow];
    
    return self;
}

#pragma mark Public Method
- (void)bindDelegate:(UIViewController<VDFlowDelegate> *)delegate {
    id weakRef = [VDWeakRef refWithObject:delegate];
    if (![self.delegates containsObject:weakRef]) {
        [self.delegates addObject:weakRef];
    }
    if (!self.isMain) {
        [[[self class] mainFlow] __i__addBranch:self];
    }
    
    VDWeakifySelf;
    __weak __typeof(&*delegate)vd_weak_delegate = delegate;
    [delegate vd_hookSelector:VDHookDeallocSelector beforeBlock:^(VDHookElement *element, VDHookInvocationInfo *info) {
        VDStrongifySelf;
        __strong __typeof(&*vd_weak_delegate)delegate = vd_weak_delegate;
        [self unbindDelegate:delegate];
    }];
}

- (void)unbindDelegate:(UIViewController<VDFlowDelegate> *)delegate {
    [self.delegates removeObject:delegate];
    
    NSMutableArray *releasedDeleages = [NSMutableArray new];
    for (VDWeakRef *delegate in self.delegates) {
        if (!delegate.weakObject) {
            [releasedDeleages addObject:delegate];
        }
    }
    [self.delegates removeObjectsInArray:releasedDeleages];
    
    
    if (self.delegates.count == 0) {
        [self flowDidUnbindAllDelegates];
        if (!self.isMain) {
            [[[self class] mainFlow] __i__removeBranch:self];
        }
    }
}

- (void)triggerAllDelegates {
    for (id delegate in [self.delegates copy]) {
        [self triggerDelegate:delegate];
    }
    
    for (VDFlow *child in [self.childFlowArray copy]) {
        [child parentFlowDidChange:self];
        [self childFlowDidTriggered:child];
    }
    
    if (self.parentFlow) {
        [self.parentFlow childFlowDidChange:self];
        [self parentFlowDidTriggered:self.parentFlow];
    }
    
    if (self.isMain) {
        for (VDFlow *branch in [self.branchArray copy]) {
            [branch mainFlowDidChange:self];
            [self branchFlowDidTriggered:branch];
        }
    }
   
}

- (void)triggerDelegate:(UIViewController<VDFlowDelegate> *)delegate {
    [self triggerDelegate:delegate cancelOnViewDisappeared:YES];
}

- (void)triggerDelegate:(UIViewController<VDFlowDelegate> *)delegate cancelOnViewDisappeared:(BOOL)cancelOnViewDisappeared {
    if (![delegate isKindOfClass:[UIViewController class]]
        || !cancelOnViewDisappeared
        || (cancelOnViewDisappeared
            && (delegate.isViewLoaded
                && delegate.view.window)))  {
        if ([delegate respondsToSelector:@selector(flowDidChange:)]) {
            [delegate flowDidChange:self];
            [self delegateDidTriggered:delegate];
        }
    }
}

- (void)triggerDelegateAfterViewWillAppear:(UIViewController<VDFlowDelegate> *)delegate {
    VDWeakifySelf;
    __weak __typeof(&*delegate)vd_weak_delegate = delegate;
    [delegate vd_hookSelector:@selector(viewWillAppear:) afterBlock:^(VDHookElement *element, VDHookInvocationInfo *info) {
        VDStrongifySelf;
        __strong __typeof(&*vd_weak_delegate)delegate = vd_weak_delegate;
        [self triggerDelegate:delegate cancelOnViewDisappeared:NO];
    }];
}

- (void)triggerDelegateAfterViewDidAppear:(UIViewController<VDFlowDelegate> *)delegate {
    VDWeakifySelf;
    __weak __typeof(&*delegate)vd_weak_delegate = delegate;
    [delegate vd_hookSelector:@selector(viewDidAppear:) afterBlock:^(VDHookElement *element, VDHookInvocationInfo *info) {
        VDStrongifySelf;
        __strong __typeof(&*vd_weak_delegate)delegate = vd_weak_delegate;
        [self triggerDelegate:delegate cancelOnViewDisappeared:NO];
    }];
}


#pragma mark Properties
- (NSMutableArray<__kindof VDFlow *> *)childFlowArray {
    if (!_childFlowArray) {
        _childFlowArray = [NSMutableArray new];
    }
    
    return _childFlowArray;
}

- (NSMutableArray<__kindof UIViewController<VDFlowDelegate> *> *)delegates {
    if (!_delegates) {
        _delegates = [NSMutableArray new];
    }
    
    return _delegates;
}

- (NSMutableArray<__kindof VDFlow *> *)branchArray {
    if (!_branchArray) {
        _branchArray = [NSMutableArray new];
    }
    
    return _branchArray;
}

- (void)setParentFlow:(VDFlow *)parentFlow {
    if (_parentFlow != parentFlow) {
        if (_parentFlow) {
            [_parentFlow.childFlowArray removeObject:self];
        }
        
        _parentFlow = parentFlow;
        [_parentFlow.childFlowArray addObject:self];
    }
    
}

#pragma mark Overrides
- (instancetype)init {
    self = [super init];
    
    // Initialization code
    [self __i__initVDFlow];

    return self;
}

- (void)dealloc {
    
}


#pragma mark Delegates


#pragma mark Protected Method
- (void)mainFlowDidChange:(VDFlow *)mainFlow {
    
}

- (void)childFlowDidChange:(VDFlow *)childFlow {
    
}

- (void)parentFlowDidChange:(VDFlow *)parentFlow {
    
}

- (void)flowDidUnbindAllDelegates {
    
}

- (void)delegateDidTriggered:(UIViewController<VDFlowDelegate> *)delegate {
    
}

- (void)branchFlowDidTriggered:(VDFlow *)branchFlow {
    
}

- (void)childFlowDidTriggered:(VDFlow *)childFlow {
    
}

- (void)parentFlowDidTriggered:(VDFlow *)parentFlow {
    
}

#pragma mark Private Method
- (void)__i__initVDFlow {
    
}

- (void)__i__addBranch:(VDFlow *)branch {
    if (!self.isMain) {
        return;
    }
    
    if (![self.branchArray containsObject:branch]) {
        [self.branchArray addObject:branch];
    }
}

- (void)__i__removeBranch:(VDFlow *)branch {
    if (!self.isMain) {
        return;
    }
    
    [self.branchArray removeObject:branch];
}

@end
