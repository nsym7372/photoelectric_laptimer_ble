#include "BluetoothSerial.h"

const int sensorPin = 4; // センサー接続ピン
char elapsedTimeStr[10]; // データ送信用の固定バッファ

unsigned long startTime = 0; // タイマーの開始時刻
unsigned long elapsedTime;   // 経過時間

const unsigned long ignoreInterval = 3000; // センサー再検知を無視する時間（ミリ秒）
unsigned long lastDetectionTime = 0;       // 最後にセンサーを検知した時間
int previousSensorState = HIGH;            // センサーの前回状態

BluetoothSerial SerialBT;

void setup() {
    Serial.begin(115200); // デバッグ用シリアルモニタ
    pinMode(sensorPin, INPUT_PULLUP);

    // デバッグとBluetoothの初期化
    SerialBT.begin("BT_LapTimer"); // Bluetoothのデバイス名
    Serial.println("Bluetooth Initialized. Ready to pair!");
}

void loop() {
    int sensorState = digitalRead(sensorPin); // センサーの現在状態を取得

    // センサーが変化して LOW になった場合
    if (sensorState == LOW && previousSensorState == HIGH) {

        // センサー検知から一定時間が経過している場合のみ処理を実行
        if ((millis() - lastDetectionTime) > ignoreInterval) {
            elapsedTime = millis() - startTime; // 経過時間を計測
            snprintf(elapsedTimeStr, sizeof(elapsedTimeStr), "%lu", elapsedTime);

            // // デバッグ用ログ
            // Serial.println("Elapsed Time Detected: " + String(elapsedTimeStr));
            
            // Bluetooth送信
            SerialBT.println(elapsedTimeStr);

            // 次の計測のためにタイマーをリセット
            startTime = millis();
            lastDetectionTime = millis(); 
        }
    }

    // センサー状態を更新
    previousSensorState = sensorState;
}

