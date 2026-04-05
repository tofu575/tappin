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

```
lib/
├── domain/                     # ビジネスロジック層（外部への依存なし）
│   ├── models/                 # 値オブジェクト・エンティティ
│   ├── repositories/           # リポジトリインターフェース定義
│   ├── services/               # 外部サービスのインターフェース定義（LocationService など）
│   └── usecases/               # ユースケース（PinUseCase）
│
├── gateway/                    # インフラ層（domainインターフェースの実装）
│                               # gateway配下は責務分離のため、概念上近くても分けること
│
└── presentation/               # UI層
    ├── pages/                  # 画面（HomePage, PinListPage）
    ├── providers/              # 状態管理（Riverpod providers / Notifier）
    └── widgets/                # 再利用可能なUIコンポーネント
```

依存注入は `main.dart` でアプリ起動時に1度だけ行い、`ProviderScope.overrides` 経由で渡す。
