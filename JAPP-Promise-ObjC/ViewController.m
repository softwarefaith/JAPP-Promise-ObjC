//
//  ViewController.m
//  JAPP-Promise-ObjC
//
//  Created by 蔡杰Alan on 16/6/21.
//  Copyright © 2016年 Allan. All rights reserved.
//

#import "ViewController.h"

#import "JPromise.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    JPromise *promise =  [[JPromise alloc]init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        sleep(4);
        dispatch_async(dispatch_get_main_queue(), ^{
            [promise resolve:@(1)];
        });
    });
    
   [ promise then:^JPromise *(id object) {
        
        NSLog(@"--%@",object);
        return nil;
    } failed:^(NSError * error) {
        
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
