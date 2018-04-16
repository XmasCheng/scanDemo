//
//  CQRScanController.m
//  ScanDemo
//
//  Created by YOUKE on 2018/4/13.
//  Copyright © 2018年 YOUKE. All rights reserved.
//

#import "CQRScanController.h"
#import <AVFoundation/AVFoundation.h>

#define statusHeight [[UIApplication sharedApplication] statusBarFrame].size.height
@interface CQRScanController ()<AVCaptureMetadataOutputObjectsDelegate>

@property(strong , nonatomic)AVCaptureSession *session;
@property(assign , nonatomic)CGFloat width;
@property(assign , nonatomic)CGFloat height;
@property(strong , nonatomic)UILabel *tipLabel;
@property(strong , nonatomic)UIImageView *lineImageView;
@property(strong , nonatomic)UILabel *titleLabel;
@property(assign , nonatomic)BOOL isReading;
@property(strong , nonatomic)NSTimer *timer;
@property(strong , nonatomic)UIButton *lightBtn;
@end

@implementation CQRScanController

-(id)init{
    if(self = [super init]){
        self.scanType = CQRCodeScanerAllType;
    }
    return self;
}

-(void)dealloc{
    _session = nil;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSString *codeStr = @"";
    switch (_scanType) {
        case CQRCodeScanerAllType:codeStr = @"二维码/条码";break;
        case CZQCodeScanerQRType:codeStr = @"二维码";break;
        case CZQCodeScanerBarCodeType:codeStr = @"条形码";break;
        default:break;
    }
    if(self.titleStr && self.titleStr.length > 0){
        self.titleLabel.text = self.titleStr;
    }else{
        self.titleLabel.text = codeStr;
    }
    
    if(self.tips && self.tips.length > 0){
        self.tipLabel.text = self.tips;
    }else{
        self.tipLabel.text = [NSString stringWithFormat:@"将%@放入框内，自动扫描",codeStr];
    }
    
    [self startScan];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.scanType == 0){
        NSLog(@"0");
    }else if (self.scanType == 1){
        NSLog(@"1");
    }else if (self.scanType == 2){
        NSLog(@"2");
    }
    [self _creatScanView];
    [self setPermission];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
}

//创建扫描视图
-(void)_creatScanView{
    self.view.backgroundColor = [UIColor blackColor];
    CGRect rc = [[UIScreen mainScreen] bounds];
    _width = rc.size.width *0.1;
    _height = (rc.size.height - (rc.size.width - _width * 2)) / 2 ;
    CGFloat alpha = 0.5;
    
    //最上部view
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rc.size.width, _height)];
    upView.backgroundColor = [UIColor blackColor];
    upView.alpha = alpha;
    [self.view addSubview:upView];
    
    //左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, _height, _width, rc.size.height - _height *2)];
    leftView.backgroundColor = [UIColor blackColor];
    leftView.alpha = alpha;
    [self.view addSubview:leftView];
    
    //中间扫描区域View
    UIImageView *scanAreaView = [[UIImageView alloc] initWithFrame:CGRectMake(_width, _height, rc.size.width - 2 *_width, rc.size.height - 2 *_height)];
    scanAreaView.image = [UIImage imageNamed:@"scanBorder"];
    scanAreaView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scanAreaView];
    
    //右侧区域View
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(rc.size.width - _width, _height, _width, rc.size.height - _height *2)];
    rightView.backgroundColor = [UIColor blackColor];
    rightView.alpha = alpha;
    [self.view addSubview:rightView];
    
    //底部区域View
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, rc.size.height - _height, rc.size.width, _height)];
    downView.backgroundColor = [UIColor blackColor];
    downView.alpha = alpha;
    [self.view addSubview:downView];
    
    //用已说明的label
    self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_width, rc.size.height - _height, rc.size.width - 2 * _width, 40)];
    self.tipLabel.backgroundColor = [UIColor clearColor];
    self.tipLabel.textColor = [UIColor whiteColor];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.tipLabel];
    
    //打开手机电筒
    self.lightBtn = [[UIButton alloc] initWithFrame:CGRectMake((rc.size.width - 30)/2, CGRectGetMaxY(self.tipLabel.frame)+ 30, 30, 30)];
    [self.lightBtn setImage:[UIImage imageNamed:@"light_off"] forState:UIControlStateNormal];
    [self.lightBtn setImage:[UIImage imageNamed:@"light_on"] forState:UIControlStateSelected];
    [self.lightBtn addTarget:self action:@selector(lightAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.lightBtn];
    
    //轻触照亮
    UILabel *lightLabel = [[UILabel alloc] initWithFrame:CGRectMake((rc.size.width - 80)/2, CGRectGetMaxY(self.lightBtn.frame) + 10, 80, 25)];
    lightLabel.text = @"轻触照亮";
    lightLabel.font = [UIFont systemFontOfSize:14];
    lightLabel.textAlignment = NSTextAlignmentCenter;
    lightLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:lightLabel];
    
    
    //画中间的基准线
    self.lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_width, _height, rc.size.width - 2 *_width, 5)];
    self.lineImageView.image = [UIImage imageNamed:@"baseLine"];
    [self.view addSubview:self.lineImageView];
    
    //标题
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, statusHeight, rc.size.width - 2 * 50, 44)];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
    //返回
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, statusHeight, 44, 44)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    
    
}

//设置权限
-(void)setPermission{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(granted){
                [self loadScanView];
                [self startScan];
            }else{
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请在iPhone的“设置-隐私-相机”选项中，允许APP访问你的相机" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *seting = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleCancel handler:nil];
                
                [alertVC addAction:seting];
                [alertVC addAction:cancel];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
            
        });
    }];
}

-(void)loadScanView{
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput *inPut = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput *outPut = [[AVCaptureMetadataOutput alloc] init];
    //设置代理 在主线程刷新
    [outPut setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //初始化链接对象
    self.session = [[AVCaptureSession alloc] init];
    //高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    [self.session addInput:inPut];
    [self.session addOutput:outPut];
    
    //设置扫描支持的格式
    switch (self.scanType) {
        case CQRCodeScanerAllType:
        outPut.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                       AVMetadataObjectTypeEAN13Code,
                                       AVMetadataObjectTypeEAN8Code,
                                       AVMetadataObjectTypeUPCECode,
                                       AVMetadataObjectTypeCode39Code,
                                       AVMetadataObjectTypeCode39Mod43Code,
                                       AVMetadataObjectTypeCode39Code,
                                       AVMetadataObjectTypeCode128Code,
                                       AVMetadataObjectTypePDF417Code];
        break;
        case CZQCodeScanerQRType:
        outPut.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        break;
        case CZQCodeScanerBarCodeType:
        outPut.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                       AVMetadataObjectTypeEAN8Code,
                                       AVMetadataObjectTypeUPCECode,
                                       AVMetadataObjectTypeCode39Code,
                                       AVMetadataObjectTypeCode39Mod43Code,
                                       AVMetadataObjectTypeCode39Code,
                                       AVMetadataObjectTypeCode128Code,
                                       AVMetadataObjectTypePDF417Code];
        break;
        default:
        break;
    }
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if(!_isReading){
        return;
    }
    
    if(metadataObjects.count > 0){
        _isReading = NO;
        AVMetadataMachineReadableCodeObject * metdataObject = metadataObjects[0];
        NSString *result = metdataObject.stringValue;
        if(self.resultBlock){
            self.resultBlock(result);
        }
        [self backAction];
    }
}

-(void)startScan{
    if(self.session){
        _isReading = YES;
        [self.session startRunning];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(baseLineMoveDownAndUp) userInfo:nil repeats:YES];
    }
    
}
-(void)stopScan{
    if([self.timer isValid]){
        [self.timer invalidate];
        self.timer = nil;
    }
    [self.session stopRunning];
}

-(void)backAction{
    UINavigationController *nav = self.navigationController;
    if(nav){
        if(nav.viewControllers.count == 1.2){
            [nav dismissViewControllerAnimated:YES completion:nil];
        }else{
            [nav popViewControllerAnimated:YES];
        }
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//基准线开始上下移动
-(void)baseLineMoveDownAndUp{
    
    
    CGFloat Y = self.lineImageView.frame.origin.y;
    if(_height + self.lineImageView.frame.size.width - 5 == Y){
        [UIView beginAnimations:@"asa" context:nil];
        [UIView setAnimationDuration:1.2];
        CGRect frame = self.lineImageView.frame;
        frame.origin.y = _height;
        self.lineImageView.frame = frame;
        [UIView commitAnimations];
    }else if (_height == Y){
        [UIView beginAnimations:@"asa" context:nil];
        [UIView setAnimationDuration:1.2];
        CGRect frame = self.lineImageView.frame;
        frame.origin.y = _height + self.lineImageView.frame.size.width - 5;
        self.lineImageView.frame = frame;
        [UIView commitAnimations];
    }
}

-(void)resultBlock:(ResultBlock)result{
    self.resultBlock = result;
}


-(void)lightAction:(UIButton *)button{
    button.selected = !button.selected;
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if(captureDeviceClass != nil){
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if([device hasTorch] && [device hasFlash]){
            [device lockForConfiguration:nil];
            if(button.selected == YES){
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
            }else{
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopScan];
}

@end
