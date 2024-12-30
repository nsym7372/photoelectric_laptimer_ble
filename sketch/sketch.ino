#include "WiFi.h"
// #include <ESP8266WiFi.h>
#include <WebSocketsServer.h>
#include "config.h"

const int sensorPin = 4;
char elapsedTimeStr[10]; // データ送信用の固定バッファ

WebSocketsServer webSocket(81);                  
unsigned long startTime;
unsigned long elapsedTime;

const unsigned long ignoreInterval = 3000; // センサー再検知を無視する時間（ミリ秒）
unsigned long lastDetectionTime = 0;

void setup() {
  Serial.begin(115200);
  pinMode(sensorPin, INPUT_PULLUP);

  initNetWork();
  webSocket.begin();
  Serial.println("WebSocket server started");

  startTime = millis();
}

void loop() {
  webSocket.loop();
  int sensorState = digitalRead(sensorPin);
  static int previousSensorState = HIGH;
  if (sensorState == LOW && previousSensorState == HIGH) {

    // センサー検知から一定時間が経過している場合のみ処理を実行
    if ((millis() - lastDetectionTime) > ignoreInterval) {
      elapsedTime = millis() - startTime;
      snprintf(elapsedTimeStr, sizeof(elapsedTimeStr), "%lu", elapsedTime);
      webSocket.broadcastTXT(elapsedTimeStr);

      // 次の計測のためにタイマーをリセット
      startTime = millis();
      lastDetectionTime = millis(); 
    }
  }
  // センサー状態を更新
  previousSensorState = sensorState;
}

void initNetWork(){

  IPAddress local_IP(192, 168, 179, 9);
  IPAddress gateway(192, 168, 179, 1);
  IPAddress subnet(255, 255, 255, 0);

  if (!WiFi.config(local_IP, gateway, subnet)) {
    Serial.println("Failed to configure static IP");
  }

  // const char* ssid = "<ssid>";
  // const char* password = "<password>";

  WiFi.begin(CONF_SSID, CONF_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
}

