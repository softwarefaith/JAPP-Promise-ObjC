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

@property (nonatomic,strong) NSMutableArray<resolved_block> *resolved_blocks;

@property (nonatomic,strong) NSMutableArray<rejected_block> *rejected_blocks;

@property (nonatomic,strong) NSMutableArray<always_block>  *alwaysBlocks;

@end

@implementation JPromise{
    
   
}

@synthesize result = _result;
@synthesize reason = _reason;

@dynamic isRejected,isResolved;

#pragma mark --Init
- (id)initWithQueue:(dispatch_queue_t)queue
{
    if (self = [super init]) {
        
        _state = JPromiseStatePending;
        
        if (queue) {
            _queue = queue;
        }
        _stateLock = [[NSObject alloc] init];
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


-(NSMutableArray<resolved_block> *)resolved_blocks{
    
    if (_resolved_blocks == nil) {
        
        _resolved_blocks = [[NSMutableArray alloc] init];
    }
    
    return _resolved_blocks;
}

-(NSMutableArray<rejected_block> *)rejected_blocks{
    
    if (_resolved_blocks == nil) {
        _rejected_blocks = [[NSMutableArray alloc] init];
    }
    return _rejected_blocks;
}

-(NSMutableArray<always_block> *)finallyBlocks{
    
    if (_alwaysBlocks == nil) {
        _alwaysBlocks = [[NSMutableArray alloc] init];
    }
    return _alwaysBlocks;
    
}

#pragma mark --Public

-(JPromise *)then:(resolved_block)thenBlock{
  return [self then:thenBlock failed:nil always:nil];
}

-(JPromise *)then:(resolved_block)thenBlock failed:(rejected_block)rejectedBlock{
   return [self then:thenBlock failed:rejectedBlock always:nil];
}



-(JPromise *)then:(resolved_block)thenBlock failed:(rejected_block)rejectedBlock always:(always_block)alwaysBlock{
    
    if(_state == JPromiseStatePending){
        
        if (thenBlock == nil) {
            return self;
        }
        
        if (thenBlock) {
            
            thenCount++;
            
            [self.resolved_blocks addObject:thenBlock];
            
            __block JPromise *this = self;
            [this bindOrCallBlock:^{
                
                if ([this isResolved]) {
                    thenBlock(this.result);
                }
                
            }];
        }
        
        if (rejectedBlock){
            [self.rejected_blocks addObject:rejectedBlock];
            
            __block JPromise *this = self;
            [this bindOrCallBlock:^{
                
                if ([this isRejected]) {
                    thenBlock(this.reason);
                }
                
            }];

            
        }
        
        if (alwaysBlock){
            [self.alwaysBlocks addObject:alwaysBlock];
            
            __block JPromise *this = self;
            [this bindOrCallBlock:^{
                
                alwaysBlock(this.result,this.reason);
                
            }];

        }
        
    }else{
        
        if (_state == JPromiseStateResolved) {
            
            if (thenBlock) {
                thenBlock(self.result);
            }
        }else if(_state == JPromiseStateRejected){
            
            if (rejectedBlock) {
                rejectedBlock(self.reason);
            }
        }
        
        if (alwaysBlock) {
             alwaysBlock(self.result,self.reason);
        }
    }
    return self;
}



#pragma mark --private
- (void)executeBlock:(bound_block)block{
    if (_queue) {
        dispatch_async(_queue, block);
    } else {
        block();
    }
}

- (BOOL)bindOrCallBlock:(bound_block)block
{
    BOOL blockWasBound = NO;
    
    @synchronized (_stateLock) {
        if (_state == JPromiseStatePending) {
            [_callbackBindings addObject:[block copy]];
            
            blockWasBound = YES;
        }
    }
    
    if (!blockWasBound) {
        [self executeBlock:block];
    }
    
    return blockWasBound;
}

@end


#pragma mark -- JDefered Implementation

//@interface JDeferred ()
//
//@property (nonatomic,readwrite,strong) id result;
//
//
//@end





@implementation JDeferred

+ (JDeferred *)deferred{
    
    return [[JDeferred alloc] init];
}

-(JPromise *)promise{
    return self;
}

-(JPromise *)resolve:(id)result{
    
    self.result = result;
    
    [self transitionToState:JPromiseStateResolved];
    
    
    return [self promise];
}

- (JPromise *)reject:(NSError *)reason{
    
    self.reason = reason;
    
    [self transitionToState:JPromiseStateRejected];
    
    return [self promise];
}



- (void)transitionToState:(JPromiseState)state
{
    NSArray *blocksToExecute = nil;
    BOOL shouldComplete = NO;
    
    @synchronized (_stateLock) {
        if (_state == JPromiseStatePending) {
            _state = state;
            
            shouldComplete = YES;
            
            blocksToExecute = _callbackBindings;
            
            _callbackBindings = nil;
        }
    }
    if (shouldComplete) {
        for (bound_block block in blocksToExecute) {
            [self executeBlock:block];
        }
    }
}


@end