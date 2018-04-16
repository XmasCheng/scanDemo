//
//  ViewController.m
//  ScanDemo
//
//  Created by YOUKE on 2018/4/12.
//  Copyright © 2018年 YOUKE. All rights reserved.
//

#import "ViewController.h"
#import "CQRScanController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *scan = [UIButton buttonWithType:UIButtonTypeSystem];
    scan.frame = CGRectMake(100, 300, 100, 30);

    [scan setTitle:@"点击开始扫描" forState:UIControlStateNormal];
    [scan addTarget:self action:@selector(scanAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scan];
}

-(void)scanAction{
    CQRScanController *qrScanVC = [[CQRScanController alloc] init];
    [self presentViewController:qrScanVC animated:YES completion:nil];
    [qrScanVC resultBlock:^(NSString *result) {
        NSLog(@"result++\%@",result);
    }];
}

@end
