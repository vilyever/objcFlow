//
//  VDFlow.m
//  objcFlow
//
//  Created by Deng on 16/8/8.
//  Copyright © Deng. All rights reserved.
//

#import "VDFlow.h"

#import <objcBlock/objcBlock.h>
#import <objcWeakRef/objcWeakRef.h>
#import <objcHook/objcHook.h>

@interface VDFlow ()

- (void)__i__initVDFlow;
- (void)__i__addBranch:(VDFlow *)branch;
- (void)__i__removeBranch:(VDFlow *)branch;

@property (nonatomic, assign, readwrite) BOOL isMain;

@property (nonatomic, strong, readwrite) NSMutableArray<__kindof UIViewController<VDFlowDelegate> *> *delegates;
@property (nonatomic, strong, readwrite) NSMutableArray<__kindof VDFlow *> *branchArray;

@end


@implementation VDFlow

#pragma mark Constructor
+ (instancetype)mainFlow {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [ [ [self class] alloc] initWithMain:YES];
    } );
    
    return _sharedInstance;
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
    
    if (self.isMain) {
        for (VDFlow *branch in [self.branchArray copy]) {
            [branch mainFlowDidChange:self];
        }
    }
    
    if (self.parentFlow) {
        [self.parentFlow childFlowDidChange:self];
    }
}

- (void)triggerDelegate:(UIViewController<VDFlowDelegate> *)delegate {
    [self triggerDelegate:delegate cancelOnViewDisappeared:YES];
}

- (void)triggerDelegate:(UIViewController<VDFlowDelegate> *)delegate cancelOnViewDisappeared:(BOOL)cancelOnViewDisappeared {
    if (!cancelOnViewDisappeared
        || (cancelOnViewDisappeared
            && (delegate.isViewLoaded
                && delegate.view.window)))  {
                if ([delegate respondsToSelector:@selector(flowDidChange:)]) {
                    [delegate flowDidChange:self];
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

- (void)flowDidUnbindAllDelegates {
    
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
