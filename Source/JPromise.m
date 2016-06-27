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



@end

@implementation JPromise

@synthesize result = _result;

@synthesize reason = _reason;

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
    
    return [self promise];
}

- (JPromise *)reject:(NSError *)reason{
    
    self.reason = reason;
    
    return [self promise];
}

- (void)transitionToState:(JPromiseState)state{
    
    _State = state;
    
}


@end