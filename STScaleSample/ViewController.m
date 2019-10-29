//
//  ViewController.m
//  STScaleLibrarySample
//
//  Created by muchunyu on 2019/10/27.
//  Copyright © 2019 swiftechie. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *txtDeviceType;
@property (weak, nonatomic) IBOutlet UILabel *txtDeviceAddress;
@property (weak, nonatomic) IBOutlet UILabel *txtDeviceState;
@property (weak, nonatomic) IBOutlet UITextField *txtHeight;
@property (weak, nonatomic) IBOutlet UITextField *txtAge;
@property (weak, nonatomic) IBOutlet UITextField *txtGender;
@property (weak, nonatomic) IBOutlet UILabel *txtWeight;
@property (weak, nonatomic) IBOutlet UILabel *txtImpedance;
@property (weak, nonatomic) IBOutlet UILabel *txtBodyfat;
@property (weak, nonatomic) IBOutlet UILabel *txtWater;
@property (weak, nonatomic) IBOutlet UILabel *txtMuscle;

@property (weak, nonatomic) STScaleLibrary *libScale;

@property (weak, nonatomic) NSString *name;
@property (weak, nonatomic) NSString *address;
@property (weak, nonatomic) NSString *uuid;
@property NSInteger state;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // frameworkを初期化
    _libScale = [STScaleLibrary getInstance];
    // コールバックを設定
    [_libScale setCallBackWithCallback:self];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _name = [ud valueForKey:@"name"];
    _address = [ud valueForKey:@"address"];
    _uuid = [ud valueForKey:@"uuid"];
    if (_name == nil) {
        _name = @"";
        _address = @"";
        _uuid = @"";
    }
    [self showDeviceInfo];
    if (_name != nil && _name.length > 0) {
        // nameが正しくない場合、1021が返す
        // adressとuuidが正しくない場合、framework異常終了の恐れがあるため、必ず正しい値を渡してください。
        // デバイスが接続できない場合、６０秒間で周りの体組成計をスキャンします。６０秒以内に体組成計が検知でき
        // ない場合、接続状態を2（未接続）に変わって、onStateChangedBeforeを呼び出します。
        // もっと待ちたい場合、onStateChangedBeforeで再度接続してください。
        [self->_libScale connectWithName:self->_name address:self->_address uuid:self->_uuid];
    }
}

- (IBAction)onScanClick:(id)sender {
    [self saveDeviceInfo:@"" addr:@"" uuid:@""];
    [self showDeviceInfo];
    // ６０秒間で周りの体組成計をスキャンします。６０秒以内に体組成計が検知できない場合、
    // 接続状態を2（未接続）に変わって、onStateChangedBeforeを呼び出します。
    // もっとスキャンしたい場合、onStateChangedBeforeで再度スキャンしてください。
    [_libScale startScan];
}

- (void)saveDeviceInfo:(NSString *)name addr:(NSString *)addr uuid:(NSString *)uuid {
    self->_address = addr;
    self->_uuid = uuid;
    self->_name = name;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:self->_name forKey:@"name"];
    [ud setValue:self->_address forKey:@"address"];
    [ud setValue:self->_uuid forKey:@"uuid"];
}

- (void)showDeviceInfo {
    self->_txtDeviceType.text = self->_name;
    self->_txtDeviceAddress.text = self->_address;
}

// 周りの体組成計が検知した場合のコールバック
- (void)onNewScaleWithDev:(BleDevice *)dev {
    //BleDeice {
    //   name,    // 体組成計の名前です、接続時が必要です。
    //   address, // 体組成計のアドレスです、接続時が必要です。
    //   uuid,    // iOS  Bluetoothのuuidです、接続時が必要です。
    //   rssi}    // 体組成計の信号の強さです。
    dispatch_async(dispatch_get_main_queue(), ^{
        [self saveDeviceInfo:dev.name addr:dev.address uuid:dev.uuid.UUIDString];
        
        [self showDeviceInfo];
        // start connect
        [self->_libScale connectWithName:self->_name address:self->_address uuid:self->_uuid];
    });
}

// 接続した体組成計の体重データが検知した場合のコールバック
- (void)onDataReceiveWithData:(ScaleData *)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        // ScaleData {
        //    weight,              // 体重、単位（g）
        //    impedance,           // 抵抗、体脂肪率計算ためが必要です。
        //    isLockData,          // 体重測定完了後のデータはtrue、その他はfalseになります。
        //    errorType,           // エラーコード　0:解析成功 1:抵抗値が不正 2:年齢不正、利用可能範囲（６〜９９） 3:体重不正、利用可能範囲（１０〜２００kg） 4:身長不正、利用可能範囲（９０〜２２０cm）
        //    htproteinPercentage, // 蛋白質,精度：0.1, 範囲2.0% ~ 30.0%
        //    htBodyAge,           // 身体年齢,6~99オ
        //    htIdealWeight,       // 理想体重
        //    htBMI,               // Body Mass Index BMI, 精度：0.1, 範囲10.0 ~ 90.0
        //    htBMR,               // Basal Metabolic Rate基礎代謝, 精度1, 範囲500 ~ 10000、単位cal
        //    htVFAL,              // Visceral fat area leverl内蔵脂肪レベル, 精度1, 範囲1 ~ 60
        //    htBone,              // 骨量(kg), 精度0.1, 範囲0.5 ~ 8.0
        //    htBodyfatPercentage, // 体脂肪率(%), 精度0.1, 範囲5.0% ~ 75.0%
        //    htWaterPercentage,   // 水分率(%), 精度0.1, 範囲35.0% ~ 75.0%
        //    htMuscle}            // 脱脂防組織量(kg), 精度0.1, 範囲10.0 ~ 120.0
        self->_txtWeight.text = [NSString stringWithFormat:@"%.1f", ((double)data.weight) / 1000];
        self->_txtImpedance.text = [NSString stringWithFormat:@"%ld", (long)data.impedance];
        self->_txtBodyfat.text = [NSString stringWithFormat:@"%.01ld", (long)data.htBodyfatPercentage];
        self->_txtWater.text = [NSString stringWithFormat:@"%.01ld", (long)data.htWaterPercentage];
        self->_txtMuscle.text = [NSString stringWithFormat:@"%.01ld", (long)data.htMuscle];
    });
}

// 体組成計の接続状態が変わる時のコールバック
- (void)onStateChangedBefore:(NSInteger)before after:(NSInteger)after {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 1:Bluetoothが使えない
        // 2:未接続
        // 3:スキャン中
        // 4:接続中
        // 5:接続済み
        self->_state = after;
        switch (self->_state) {
            case 1:
                self->_txtDeviceState.text = @"ble disabled.";
                break;
            case 2:
                self->_txtDeviceState.text = @"scale disconnected.";
                break;
            case 3:
                self->_txtDeviceState.text = @"scaning...";
                break;
            case 4:
                self->_txtDeviceState.text = @"scale connecting.";
                break;
            case 5:
                self->_txtDeviceState.text = @"scale connected.";
                break;
            default:
                self->_txtDeviceState.text = @"unknown.";
                break;
        }
    });
}
- (IBAction)onSetUserInfoClicked:(id)sender {
    // height:単位CM、可能範囲（９０〜２２０）、その以外の場合、４が返す
    // age:可能範囲（６〜９９）、その以外の場合、２が返す
    // gender:１は男性、０は女性、その以外の場合、５が返す
    [_libScale setUserInfoWithHeight:_txtHeight.text.intValue age:_txtAge.text.intValue gender:_txtGender.text.intValue];
    [self.view endEditing:YES];
}
- (IBAction)onConnectClick:(id)sender {
    if (_name != nil && _name.length > 0) {
        [_libScale connectWithName:_name address:_address uuid:_uuid];
    }
}
- (IBAction)onDisconnectClick:(id)sender {
    [_libScale disconnect];
}
- (IBAction)onKGClick:(id)sender {
    // 0と1以外の値はサポートしない、6が返します。
    // 体組成計の表示単位をlbに切り替えでも、アプリに返す体重の単位はgから変わりません。
    // 体組成計の表示をKGに変更する
    [_libScale setUnitWithUnit:0];
}
- (IBAction)onLBSClick:(id)sender {
    // 体組成計の表示をLBSに変更する
    [_libScale setUnitWithUnit:1];
}

@end
