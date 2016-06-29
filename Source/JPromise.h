//
//  JPromise.h
//  JAPP-Promise-ObjC
//
//  Created by 蔡杰Alan on 16/6/21.
//  Copyright © 2016年 Allan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JPromise;
/**
 *  @brief Block 定义
 */


typedef JPromise * (^resolved_block)(id object);
typedef void (^rejected_block)(NSError * error);
typedef void (^finally_block)();



/**
 *  @brief 有限状态机
           pending为初始状态
           fulfilled和rejected为结束状态（结束状态表示promise的生命周期已结束）
 
      状态转换关系为：pending->fulfilled，pending->rejected。
 
 - resolve 解决，进入到下一个流程
 - reject 拒绝，跳转到捕获异常流程
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
    
    JPromiseState _state;
    
    /**
     *  @brief 状态锁
     */
    
    NSObject *_synLock;
}

//当前的状态
@property (nonatomic,readonly,assign) BOOL isResolved;
@property (nonatomic,readonly,assign) BOOL isRejected;


/**
 *  @brief 链式函数
 */

- (JPromise *)then:(resolved_block)thenBlock ;

- (JPromise *)then:(resolved_block)thenBlock failed:(rejected_block)rejectedBlock;

- (void)finally:(finally_block)finallyBlock;

/**
 *  @brief 调用
 */
- (void)resolve:(id)object;
- (void)reject:(NSError *)reson;


@end



