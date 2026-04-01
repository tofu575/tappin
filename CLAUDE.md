# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 技術選定

- 状態管理: flutter_riverpod（他に変えない）
- DB: sqflite（Firebase 等に移行しない）

## アーキテクチャ概要

- クリーンアーキテクチャ。依存の向きは domain ← gateway ← presentation
- domain 層は Flutter/外部パッケージに依存してはいけない

## テスト方針
- 外部サービス（位置情報・DB・ウィジェット）は必ずインターフェース越しに注入してモック可能に
する
- pumpAndSettle はタイムアウトするため、非同期処理を含む場合は pump を使う

## 命名規則

- data, info, file など、情報を持たない単語は使用を禁止する
- 関数は動詞はじまり
- クラスは基本的に名詞、もしくは〜者(er)といった命名

## コーディング規約

- 依存のimportは、相対パスではなく絶対パスで指定すること
  - どこのファイルを指しているか、わかりにくくなるため
- スカラー型（double, String など）を引数・戻り値に使わない
  - 理由: 意味のない型になるため。例えば `double latitude` より `Latitude` の方が
    バリデーションも持てて意図が明確になる
  - 例外: UI の表示文字列など、変換の必要がない末端の値
- 固定文字列は原則、ファイル冒頭でconstで定義すること
  - 秘匿情報や、接続先URIなどは環境変数から読み取ること
- NULL や Emptyなど、続行してエラーになりうるものは必ず事前チェックと適切なハンドリングをすること
  - `!`で読み飛ばすことは絶対にしてはいけない

### 禁止事項

- ProviderScope 外での HomeWidget.* 直接呼び出し（テストが壊れるため）
- ネイティブ 側でビジネスロジック実装（Flutter 側で完結させる）
- 相対パス import
