# STScale

## 概要
STScaleは士為テック株式会社のBluetooth体組成計Healthy Scaleを接続するためにライブラリーです。
Objective-CとSwifが両方サポートしますが、今回はObjective-Cのサンプリだけ提供します。
iOSだけがサポートしていますが、今後Android版を出す予定です。

## 利用方法

### Frameworkの追加
STScaleSample/STScaleSamle/Libs/STScale.frameworkは最新版のライブラリーです。
frameworkファイルをTARGETS→[SELF TARGET]->General->Frameworks,Libraries,And Embedded Contentに追加すると、使えます。

### Headerファイルのインポート
```objective-c
#import <STScale/STScale-Swift.h>
```

### framework callbackの実装

```objective-c
@interface ViewController : UIViewController<STScaleCallback>
@property (weak, nonatomic) STScaleLibrary *libScale;
@end

@implementation ViewController

// 初期化
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // frameworkを初期化
    _libScale = [STScaleLibrary getInstance];
    // コールバックを設定
    [_libScale setCallBackWithCallback:self];
}

// 周りの体組成計が検知した場合のコールバック
- (void)onNewScaleWithDev:(BleDevice *)dev {
	//BleDeice {
	//   name,    // 体組成計の名前です、接続時が必要です。
	//   address, // 体組成計のアドレスです、接続時が必要です。
	//   uuid,    // iOS  Bluetoothのuuidです、接続時が必要です。
	//   rssi}    // 体組成計の信号の強さです。
    dispatch_async(dispatch_get_main_queue(), ^{
        // TODO 見つかったデバイスをUIに表示する
    });
}

// 接続した体組成計の体重データが検知した場合のコールバック
- (void)onDataReceiveWithData:(ScaleData *)data {
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
    dispatch_async(dispatch_get_main_queue(), ^{
        // TODO 検知された体重情報をUIに表示する
    });
}

// 体組成計の接続状態が変わる時のコールバック
- (void)onStateChangedBefore:(NSInteger)before after:(NSInteger)after {
	// 1:Bluetoothが使えない
	// 2:未接続
	// 3:スキャン中
	// 4:接続中
	// 5:接続済み
    dispatch_async(dispatch_get_main_queue(), ^{
    	// 接続状態をUIに表示する
    });
}

@end
```

### 周りの体組成計をスキャンする
検知された体組成計の情報はonNewScaleWithDevを読んで通知します。
```objective-c
// ６０秒間で周りの体組成計をスキャンします。６０秒以内に体組成計が検知できない場合、
// 接続状態を2（未接続）に変わって、onStateChangedBeforeを呼び出します。
// もっとスキャンしたい場合、onStateChangedBeforeで再度スキャンしてください。
[_libScale startScan];
```

### 接続
```objective-c
// nameが正しくない場合、1021が返す
// adressとuuidが正しくない場合、framework異常終了の恐れがあるため、必ず正しい値を渡してください。
// デバイスが接続できない場合、６０秒間で周りの体組成計をスキャンします。６０秒以内に体組成計が検知でき
// ない場合、接続状態を2（未接続）に変わって、onStateChangedBeforeを呼び出します。
// もっと待ちたい場合、onStateChangedBeforeで再度接続してください。
[_libScale connectWithName:_name address:_address uuid:_uuid];
```

### ユーザー情報の設定
```objective-c
// height:単位CM、可能範囲（９０〜２２０）、その以外の場合、４が返す
// age:可能範囲（６〜９９）、その以外の場合、２が返す
// gender:１は男性、０は女性、その以外の場合、５が返す
[_libScale setUserInfoWithHeight:_txtHeight.text.intValue age:_txtAge.text.intValue gender:_txtGender.text.intValue];
```

### 体組成計表示単位の変更
```objective-c
// 0と1以外の値はサポートしない、6が返します。
// 体組成計の表示単位をlbに切り替えでも、アプリに返す体重の単位はgから変わりません。
// 体組成計の表示をKGに変更する
[_libScale setUnitWithUnit:0];
// 体組成計の表示をLBSに変更する
[_libScale setUnitWithUnit:1];
```

### 接続状態の取得
```objective-c
// 1:Bluetoothが使えない
// 2:未接続
// 3:スキャン中
// 4:接続中
// 5:接続済み
[_libScale getState];
```

### 切断
```objective-c
[_libScale disconnect];
```

## サンプルアプリの説明
サンプルアプリを起動すると、「Scan」ボタンで周りの体組成計をスキャンします。
体組成計を検知したら、画面に表示して、直接接続します。
体組成計から体重データが貰える時、体重データを解析し、onDataReceiveWithData
を呼び出します。<br>
「Set User Info」でユーザー情報を設定できます。<br>
「Conn」で表示された体組成計を接続します。<br>
「Disconn」で表示された体組成計を切断します。<br>
「kg」で接続された体組成計の単位をkgに切り替わります。<br>
「lbs」で接続された体組成計の単位をlbに切り替わります。<br>












