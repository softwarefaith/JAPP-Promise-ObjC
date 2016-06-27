//
//  JPromise.h
//  JAPP-Promise-ObjC
//
//  Created by 蔡杰Alan on 16/6/21.
//  Copyright © 2016年 Allan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @brief 有限状态机
           pending为初始状态
           fulfilled和rejected为结束状态（结束状态表示promise的生命周期已结束）
 
      状态转换关系为：pending->fulfilled，pending->rejected。
 */
typedef NS_ENUM(NSInteger,JPromiseState) {
    /**
     *  执行中
     */
    JPromiseStatePending,
    /**
     *  执行成功
     */
    JPromiseStateResolved,
    /**
     *  执行失败
     */
    JPromiseStateRejected
};



@interface JPromise : NSObject {
    /**
     *  @brief 状态
     */
    
    JPromiseState _State;
}

@property (nonatomic,readonly,strong) id result;

@property (nonatomic,readonly,strong) NSError *reason;

+ (JPromise *)resolved:(id)result;
+ (JPromise *)rejected:(NSError *)reason;


@end


@interface JDeferred : JPromise

+ (JDeferred *)deferred;

- (JPromise *)promise;
- (JPromise *)resolve:(id)result;
- (JPromise *)reject:(NSError *)reason;

@end
