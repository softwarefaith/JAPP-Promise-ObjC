//
//  JPromise.m
//  JAPP-Promise-ObjC
//
//  Created by 蔡杰Alan on 16/6/21.
//  Copyright © 2016年 Allan. All rights reserved.
//

#import "JPromise.h"


@interface JPromise ()

@property (nonatomic,readwrite,strong) id result;

@property (nonatomic,readwrite,strong) NSError *reason;

@property (nonatomic,copy) rejected_block   reject;

@property (nonatomic,copy) resolved_block   resolve;

@property (nonatomic,copy) finally_block   finally;

@property (nonatomic, strong) JPromise *returnedPromise;


@property (nonatomic, strong) JPromise *strongSelf;

@end

@implementation JPromise
    


@synthesize result = _result;
@synthesize reason = _reason;

@dynamic isRejected,isResolved;

#pragma mark --Init


-(instancetype)init{
    
    if (self = [super init]) {
        _state = JPromiseStatePending;
        _synLock = [[NSObject alloc] init];
        _result = nil;
    }
    return self;
    
}



#pragma mark --rewrite

-(BOOL)isResolved{
    
    return _state == JPromiseStateResolved;
}

-(BOOL)isRejected{
    
    return _state == JPromiseStateRejected;
}



#pragma mark --Public

-(JPromise *)then:(resolved_block)thenBlock{
    
    return [self then:thenBlock failed:nil];
}


-(JPromise *)then:(resolved_block)thenBlock failed:(rejected_block)rejectedBlock{
    
    
    self.strongSelf = self;
    self.resolve = [thenBlock copy];
    self.reject = [rejectedBlock copy];
    
    JPromise *temp = [[JPromise alloc] init];
    self.returnedPromise = temp;
    return temp;
}


-(void)finally:(finally_block)finallyBlock{
    
    self.finally = [finallyBlock copy];
}


#pragma mark --Public
-(void)resolve:(id)object{
     @synchronized (_synLock) {
    self.result = object;
    if (self.resolve) {
        [self populateReturnPromiseWithPromise:self.resolve(object)];
    }
     }
}

- (void)reject:(NSError *)reson;
 {
      @synchronized (_synLock) {
            self.reason = reson;
            if (self.reject)
                self.reject(reson);
            [self.returnedPromise reject:reson];
            [self completeFinally];
    }
}

- (void)completeFinally {
    if (self.finally) {
        self.finally();
    } else if (self.returnedPromise.finally) {
        self.returnedPromise.finally();
    }
    self.strongSelf = nil;
}

- (void)populateReturnPromiseWithPromise:(JPromise *)promise {
    promise.resolve = self.returnedPromise.resolve;
    promise.reject = self.returnedPromise.reject;
    promise.strongSelf = promise;
}

@end








