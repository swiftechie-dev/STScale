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
    
    _libScale = [STScaleLibrary getInstance];
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
        [self->_libScale connectWithName:self->_name address:self->_address uuid:self->_uuid];
    }
}

- (IBAction)onScanClick:(id)sender {
    [self saveDeviceInfo:@"" addr:@"" uuid:@""];
    [self showDeviceInfo];
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

- (void)onNewScaleWithDev:(BleDevice *)dev {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self saveDeviceInfo:dev.name addr:dev.address uuid:dev.uuid.UUIDString];
        
        [self showDeviceInfo];
        // start connect
        [self->_libScale connectWithName:self->_name address:self->_address uuid:self->_uuid];
    });
}

- (void)onDataReceiveWithData:(ScaleData *)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_txtWeight.text = [NSString stringWithFormat:@"%.1f", ((double)data.weight) / 1000];
        self->_txtImpedance.text = [NSString stringWithFormat:@"%ld", (long)data.impedance];
        self->_txtBodyfat.text = [NSString stringWithFormat:@"%.01ld", (long)data.htBodyfatPercentage];
        self->_txtWater.text = [NSString stringWithFormat:@"%.01ld", (long)data.htWaterPercentage];
        self->_txtMuscle.text = [NSString stringWithFormat:@"%.01ld", (long)data.htMuscle];
    });
}

- (void)onStateChangedBefore:(NSInteger)before after:(NSInteger)after {
    dispatch_async(dispatch_get_main_queue(), ^{
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
    [_libScale setUnitWithUnit:0];
}
- (IBAction)onLBSClick:(id)sender {
    [_libScale setUnitWithUnit:1];
}

@end
