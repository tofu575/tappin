# claude-example

## 動かし方

- エミュレータ起動
  - fvm flutter emulators --launch Pixel_5_API_33
- 実行
  - fvm flutter run
- test
  - fvm flutter test

## UIレビュー用スクリーンショット

Pixel 5 API 33を代表端末として、Androidエミュレータを起動する。

```bash
fvm flutter emulators --launch Pixel_5_API_33
```

起動後、表示されたdevice IDを指定して次のコマンドを実行する。

```bash
fvm flutter drive \
  --driver=test_driver/ui_review_test_driver.dart \
  --target=integration_test/ui_review_test.dart \
  -d <device-id>
```

オンボーディング、未確認0件/ありのHome、未確認/確認済みの履歴、記録詳細、
Quick Mode案内、Quick Mode、記録成功後のPNGが`screenshots/ui_review/`へ生成される。
テストデータにはMock Gatewayの固定値を使うため、
位置情報、住所検索、端末内DB、ネットワークには依存しない。

同じコマンドはiOS Simulatorでも実行できる。`takeScreenshot()`はAndroidとiOSに対応するが、
ホストへPNGを保存するため`flutter test`ではなく上記のextended driverを使用する。

## アーキテクチャ

クリーンアーキテクチャを採用。依存の向きは `presentation → domain ← gateway` で、`gateway` と `presentation` はどちらも `domain` に依存するが、互いには依存しない。

Presentationは構築済みの`Interactor`だけを`interactorProvider`から取得する。Interactorはアプリケーションの操作順序を担当し、永続化、位置情報、ハプティクス、外部アプリ起動などの外部機能は注入されたGateway interfaceを通じて利用する。

```text
Presentation → interactorProvider → Interactor → Gateway interface ← Gateway実装
```

```
lib/
├── domain/                     # ビジネスロジック層（外部への依存なし）
│   ├── models/                 # 値オブジェクト・エンティティ
│   ├── repositories/           # 永続化Gatewayのインターフェース定義
│   ├── services/               # 端末・外部機能のGatewayインターフェース定義
│   └── interactor/             # アプリケーションの操作単位
│
├── gateway/                    # インフラ層（domainインターフェースの実装）
│                               # gateway配下は責務分離のため、概念上近くても分けること
│
└── presentation/               # UI層
    ├── pages/                  # 画面（HomePage, HistoryPage, PinDetailPage）
    ├── providers/              # 状態管理（Riverpod providers / Notifier）
    └── widgets/                # 再利用可能なUIコンポーネント
```

依存注入は `main.dart` でアプリ起動時に1度だけ行い、構築済みInteractorを`interactorProvider.overrideWithValue()`で渡す。
