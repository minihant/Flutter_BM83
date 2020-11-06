# Add BM83 require flow @ 2020-11-06
## bluetooth BLE scan inhancemant by HANT


# bluetooth_ble

BLE 蓝牙

支持安卓, 支持iOS, 后续可能根据flutter sdk的进度支持macOS(这部分基本可以照搬ios的代码), 其他端并没有精力去维护

## 说明

本项目基本为自用, 不打算添加更多的内容, 也不打算传pub

如果有人需要使用, 请使用git依赖

有错误可以在issue提出, 不承诺修复, 也欢迎讨论

## 用于连接 BLE 蓝牙设备

1. 扫描 BLE 外设
2. 连接外设
3. 探测服务
4. 探测服务的特征码
5. 监听特征码的通知 / 发送消息

异步步骤:

1. 连接中断时断开连接

## 当前进度

- [x] dart
- [x] ios
- [x] android
