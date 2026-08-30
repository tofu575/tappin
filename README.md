# claude-example

## 動かし方

- エミュレータ起動
  - fvm flutter emulators --launch Pixel_5_API_33
- 実行
  - fvm flutter run
- test
  - fvm flutter test

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
    ├── pages/                  # 画面（HomePage, PinListPage）
    ├── providers/              # 状態管理（Riverpod providers / Notifier）
    └── widgets/                # 再利用可能なUIコンポーネント
```

依存注入は `main.dart` でアプリ起動時に1度だけ行い、構築済みInteractorを`interactorProvider.overrideWithValue()`で渡す。
