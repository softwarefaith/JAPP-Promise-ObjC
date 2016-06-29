#iOS 之 Promise实现


##Promises/A的API规范

####1. 有限状态机
 Promise  有一个有限状态机，共有三种状态：pending（执行中）、fulfilled（执行成功）和rejected（执行失败）。<br/>

其中pending为初始状态，fulfilled和rejected为结束状态（结束状态表示promise的生命周期已结束）。<br/>

状态转换关系为：pending->fulfilled，pending->rejected。<br/>

####2.构造函数

 Promise({Function} factory/*({Function} resolve, {Function} reject)*/) ，构造函数存在一个Function类型的入参factory，作为唯一一个修改promise对象状态的地方，其中factory函数的入参resolve的作用是将promise对象的状态从pending转换为fulfilled，而reject的作用是将promise对象的状态从pending转换为rejected。<br/>

  入参 void resolve({Any} val)  ， 当val为非thenable对象和promise对象时则会将val作为执行成功事件处理函数的入参，若val为thenable对象时则会执行 thenable.then方法，若val为Promise对象时则会将该Promise对象添加到Promise对象单向链表中。<br/>

   入参 void reject({Any} reason) ，reason不管是哪种内容均直接作为执行失败事件处理函数的入参。<br/>

  ***Note***：关于抛异常的做法，同步模式为 throw new Error("I'm synchronous way!") ，而Promise规范的做法是 reject(new Error("I'm asynchronous way!")); 
  
  
####3.实例方法
Promise then([{Function} onFulfilled[, {Function} onRejected]]) ， 用于订阅Promise对象状态转换事件，入参onFulfilled为执行成功的事件处理函数，入参onRejected为执行失败的事件处理函数。两 者的返回值均作为Promise对象单向链表中下一个Promise对象的状态转换事件处理函数的入参。而then方法的返回值是一个新的Promise 对象并且已添加到Promise对象单向链表的末尾。<br/>

  Promise catch({Function} onRejected) ，相当于 then(null, onRejected) 。<br/>

####4.类方法
  Promise Promise.resolve({Any} obj) ，用于将非Promise类型的入参封装为Promise对象，若obj为非thenable对象则返回状态为fulfilled的Promise对象，对于非若入参为Promise对象则直接返回。<br/>

   Promise Promise.reject({Any} obj) ，用于将非Promise类型的入参封装为状态为rejected的Promise对象。<br/>

   Promise Promise.all({Array} array) ， 当array中所有Promise实例的状态均为fulfilled时，该方法返回的Promise对象的状态也转为fulfilled（执行成功事件处 理函数的入参为array数组中所有Promise实例执行成功事件处理函数的返回值），否则转换为rejected。<br/>

   Promise Promise.race({Array} array) ， 当array中所有Promise实例的状态出现fulfilled时，该方法返回的Promise对象的状态也转为fulfilled（执行成功事件处 理函数的入参为状态为fulfilled的Promise实例执行成功事件处理函数的返回值），否则转换为rejected。<br/>

#####5.thenable对象

    拥有 then方法 的对象均称为thenable对象，并且thenable对象将作为Promise对象被处理。


##参考文章

1.阿里<https://yq.aliyun.com/articles/31914>

2.美团<http://tech.meituan.com/promise-insight.html>

3.阮一峰<http://javascript.ruanyifeng.com/advanced/promise.html>

3.defer<http://www.ruanyifeng.com/blog/2011/08/a_detailed_explanation_of_jquery_deferred_object.html>