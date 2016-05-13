//
//  STPPromise.m
//  Stripe
//
//  Created by Jack Flintermann on 4/20/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPPromise.h"

@interface STPPromise<T>()

@property(atomic)T value;
@property(atomic)NSError *error;
@property(atomic)NSArray<STPPromiseValueBlock> *successCallbacks;
@property(atomic)NSArray<STPPromiseErrorBlock> *errorCallbacks;

@end

@implementation STPPromise

+ (instancetype)promiseWithError:(NSError *)error {
    STPPromise *promise = [STPPromise new];
    [promise fail:error];
    return promise;
}

+ (instancetype)promiseWithValue:(id)value {
    STPPromise *promise = [STPPromise new];
    [promise succeed:value];
    return promise;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _successCallbacks = @[];
        _errorCallbacks = @[];
    }
    return self;
}

- (BOOL)completed {
    return (self.error != nil || self.value != nil);
}

- (void)succeed:(id)value {
    if (self.completed) {
        return;
    }
    self.value = value;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (STPPromiseValueBlock valueBlock in self.successCallbacks) {
            valueBlock(value);
        }
    });
}

- (void)fail:(NSError *)error {
    if (self.completed) {
        return;
    }
    self.error = error;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (STPPromiseErrorBlock errorBlock in self.errorCallbacks) {
            errorBlock(error);
        }
    });
}

- (instancetype)onSuccess:(STPPromiseValueBlock)callback {
    if (self.value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(self.value);
        });
    } else {
        self.successCallbacks = [self.successCallbacks arrayByAddingObject:callback];
    }
    return self;
}

- (instancetype)onFailure:(STPPromiseErrorBlock)callback {
    if (self.error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(self.error);
        });
    } else {
        self.errorCallbacks = [self.errorCallbacks arrayByAddingObject:callback];
    }
    return self;
}

- (instancetype)onCompletion:(STPPromiseCompletionBlock)callback {
    return [[self onSuccess:^(id  _Nonnull value) {
        callback(value, nil);
    }] onFailure:^(NSError * _Nonnull error) {
        callback(nil, error);
    }];
}

- (STPPromise *)flatMap:(STPPromiseFlatMapBlock)callback {
    STPPromise<id>* wrapper = [STPPromise<id> new];
    [[self onSuccess:^(id value) {
        STPPromise *internal = callback(value);
        [[internal onSuccess:^(id internalValue) {
            [wrapper succeed:internalValue];
        }] onFailure:^(NSError *internalError) {
            [wrapper fail:internalError];
        }];
    }] onFailure:^(NSError *error) {
        [wrapper fail:error];
    }];
    return wrapper;
}

- (STPVoidPromise *)asVoid {
    STPVoidPromise *voidPromise = [STPVoidPromise new];
    [[self onSuccess:^(__unused id value) {
        [voidPromise succeed];
    }] onFailure:^(NSError * _Nonnull error) {
        [voidPromise fail:error];
    }];
    return voidPromise;
}

@end

@implementation STPVoidPromise

- (void)succeed {
    [self succeed:[NSNull null]];
}

- (instancetype)voidOnSuccess:(STPVoidBlock)callback {
    return [super onSuccess:^(__unused id value) {
        if (callback) {
            callback();
        }
    }];
}

- (STPPromise<id> *)voidFlatMap:(STPVoidPromiseFlatMapBlock)block {
    return [super flatMap:^STPPromise *(__unused id value) {
        return block();
    }];
}

- (STPVoidPromise *)asVoid {
    return self;
}

@end
