#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

const int sensorPin = 4; // センサー接続ピン
char elapsedTimeStr[10]; // データ送信用の固定バッファ

unsigned long startTime = 0; // タイマーの開始時刻
unsigned long elapsedTime;   // 経過時間

const unsigned long ignoreInterval = 3000; // センサー再検知を無視する時間（ミリ秒）
unsigned long lastDetectionTime = 0;       // 最後にセンサーを検知した時間
int previousSensorState = HIGH;            // センサーの前回状態

BLECharacteristic *pCharacteristic;

// コールバッククラス
class BLEServerCallbacksWrapper : public BLEServerCallbacks {
private:
    BLEAdvertising *pAdvertising;

public:
    BLEServerCallbacksWrapper(BLEAdvertising *advertising) : pAdvertising(advertising) {}

    void onConnect(BLEServer *pServer) override {
        Serial.println("Client connected");
    }

    void onDisconnect(BLEServer *pServer) override {
        Serial.println("Client disconnected. Restarting advertising...");
        pAdvertising->start(); // 切断時にアドバタイズを再開
    }
};

void setup() {
    Serial.begin(115200); // デバッグ用シリアルモニタ
    pinMode(sensorPin, INPUT_PULLUP);

    // BLEデバイスの初期化
    BLEDevice::init("BLE_LapTimer"); // BLEデバイス名
    BLEServer *pServer = BLEDevice::createServer();

    // サービスとキャラクタリスティックの作成
    BLEService *pService = pServer->createService("12345678-1234-5678-1234-56789abcdef0"); // サービスUUID
    pCharacteristic = pService->createCharacteristic(
        "abcdef01-1234-5678-1234-56789abcdef0", // キャラクタリスティックUUID
        BLECharacteristic::PROPERTY_NOTIFY      // 通知プロパティを指定
    );

    // クライアントが通知を受け取れるようにする
    pCharacteristic->addDescriptor(new BLE2902());
    pService->start();

    // アドバタイズを開始
    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->start();

    // コールバックを設定
    pServer->setCallbacks(new BLEServerCallbacksWrapper(pAdvertising));
    Serial.println("BLE Initialized. Ready to pair!");
}

void loop() {
    int sensorState = digitalRead(sensorPin); // センサーの現在状態を取得

    // センサーが変化して LOW になった場合
    if (sensorState == LOW && previousSensorState == HIGH) {

        // センサー検知から一定時間が経過している場合のみ処理を実行
        if ((millis() - lastDetectionTime) > ignoreInterval) {
            elapsedTime = millis() - startTime; // 経過時間を計測
            snprintf(elapsedTimeStr, sizeof(elapsedTimeStr), "%lu", elapsedTime);

            // BLEで通知
            pCharacteristic->setValue(elapsedTimeStr);
            pCharacteristic->notify();
            Serial.println("Sent: " + String(elapsedTimeStr)); // デバッグログ

            // 次の計測のためにタイマーをリセット
            startTime = millis();
            lastDetectionTime = millis();
        }
    }

    // センサー状態を更新
    previousSensorState = sensorState;
}
