# Visual Asset差し替えガイド

画鋲は`assets/images/pin.png`、移動キャラクターは種類ごとのPNGを使います。
案内用Iconは現在のPlaceholderを維持します。
画面Widgetは素材パスを持たず、`TapPinVisualAssets`を通して描画します。

| 用途 | 推奨ファイル | 形式 | 主な利用箇所 |
| --- | --- | --- | --- |
| ブランド画鋲 | `pin.png` | PNG（透過） | Home、オンボーディング、記録中表示 |
| 紙テクスチャ | `paper_texture.png` | 小さく継ぎ目のないPNG | 共通`PaperBackground` |
| 車 | `movement_car.png` | PNG（透過） | Quick Mode |
| バス | `movement_bus.png` | PNG（透過） | Quick Mode |
| 自転車 | `movement_bicycle.png` | PNG（透過） | Quick Mode |
| 徒歩 | `movement_walking.png` | PNG（透過） | Quick Mode |

素材追加時は`pubspec.yaml`へAssetディレクトリを登録し、
`lib/presentation/assets/tap_pin_visual_assets.dart`の返却Widgetだけを変更してください。
紙素材は`lib/presentation/widgets/paper_background.dart`だけで重ね、各Pageへ個別に読み込みを追加しません。
