//
//  CQRScanController.h
//  ScanDemo
//
//  Created by YOUKE on 2018/4/13.
//  Copyright © 2018年 YOUKE. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^ResultBlock)(NSString *result);

typedef NS_ENUM(NSInteger, CQRCodeScanerType) {
    CQRCodeScanerAllType = 0, //二维码和条形码全部扫描
    CZQCodeScanerQRType,    //只扫描二维码
    CZQCodeScanerBarCodeType //只扫描条形码
};

@interface CQRScanController : UIViewController


@property(assign , nonatomic)CQRCodeScanerType scanType;
@property(copy , nonatomic)NSString *titleStr;
@property(copy , nonatomic)NSString *tips;
@property(copy , nonatomic)ResultBlock resultBlock;
-(void)resultBlock:(ResultBlock)result;

@end
