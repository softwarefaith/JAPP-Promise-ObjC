//
//  JPromise.h
//  JAPP-Promise-ObjC
//
//  Created by 蔡杰Alan on 16/6/21.
//  Copyright © 2016年 Allan. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  @brief Block 定义
 */

typedef void (^bound_block)    (void);
typedef id   (^transform_block)(id);

typedef void (^resolved_block)(id);
typedef void (^rejected_block)(NSError *);
typedef void (^always_block)(id,NSError*);

typedef void (^finally_block)(id,NSError*);



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
     *  @brief 执行队列
     */
    dispatch_queue_t _queue;
    /**
     *  @brief 状态锁
     */
    
    NSObject *_stateLock;
    
    NSMutableArray *_callbackBindings;
    NSMutableArray<resolved_block> *_resolved_blocks;
    NSMutableArray<rejected_block> *_rejected_blocks;
    NSMutableArray<always_block>   *_alwaysBlocks;
    
    NSUInteger thenCount; //统计then个数
}

@property (nonatomic,readonly,strong) id result;

@property (nonatomic,readonly,strong) NSError *reason;

//当前的状态
@property (nonatomic,readonly,assign) BOOL isResolved;
@property (nonatomic,readonly,assign) BOOL isRejected;


@property (nonatomic,copy) finally_block   finally;

/**
 *  @brief 封装Promise对象
 */
+ (JPromise *)resolved:(id)result;
+ (JPromise *)rejected:(NSError *)reason;

/**
 *  @brief 执行的队列
 */
- (JPromise *)on:(dispatch_queue_t)queue;
- (JPromise *)onMainQueue;

/**
 *  @brief 链式函数
 */
- (JPromise *)then:(resolved_block)thenBlock;
- (JPromise *)then:(resolved_block)thenBlock failed:(rejected_block)rejectedBlock;
- (JPromise *)then:(resolved_block)thenBlock failed:(rejected_block)rejectedBlock always:(always_block)alwaysBlock;



@end


@interface JDeferred : JPromise

+ (JDeferred *)deferred;

- (JPromise *)promise;
- (JPromise *)resolve:(id)result;
- (JPromise *)reject:(NSError *)reason;

@end
