# iOS TestFlight配信

## 配信の流れ

`.github/workflows/ios-testflight.yml` は、Android配信と同じく **mainへのpushに対する
Android checksの成功後** に起動する。成功したコミットをmacOS 26 / Xcodeでビルドし、
Apple Distribution証明書で署名したIPAをApp Store Connectへアップロードする。
mainが先へ進んだ古い自動配信はスキップする。
Actions → **iOS TestFlight** → **Run workflow** から、ブランチを選んだ手動配信もできる。
手動配信ではチェック完了を待たないため、検証済みコミットを選ぶ。

FlutterはAndroidと同じ `.flutter-version`、依存は `pubspec.lock` を使用する。
workflowファイルは既定ブランチ（現在 `enhance/mvp`）にも必要。
既定ブランチへのpushだけでは自動配信されず、現在のAndroidと同様に自動配信元はmain。

## 初回設定

1. Apple Developer Programへ登録し、契約の同意など未完了項目を済ませる。
2. Certificates, Identifiers & Profilesに、明示的なBundle ID **`com.tofu575.glarea`** を登録する。
   App Store Connectにも同じBundle IDのiOSアプリを作成する。既存アプリがある場合はIDと署名資産を確認する。
3. 秘密鍵付きの **Apple Distribution** 証明書を用意し、Macのキーチェーンアクセスから
   パスワード付き `.p12` として書き出す。開発用証明書では配信できない。
4. 同じチーム・Bundle ID・証明書で、App Store Connect配信用のprovisioning profile
   （`.mobileprovision`）を作成・ダウンロードする。Development / Ad Hoc / Enterprise用は使用しない。
5. App Store Connect → ユーザとアクセス → 統合 → App Store Connect APIで、
   チームAPIキーを作成する。ビルドのアップロードに必要な **Developer** 権限を付与し、
   Key ID・Issuer ID・秘密鍵 `.p8` を保存する。この構成はチームAPIキーを使用する。
6. GitHub Settings → Environmentsに **`testflight`** を作成し、以下を登録する。
   既存の承認・ブランチ制限があればそれに従う。`workflow_run` は既定ブランチのrefで動くため、
   自動配信ではそのrefも許可する。Appleの鍵をチャットやGitへ貼り付けない。

### Environment Secrets

| 名前 | 内容 |
| --- | --- |
| `IOS_DISTRIBUTION_CERTIFICATE_BASE64` | 秘密鍵付き `.p12` のBase64 |
| `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` | `.p12` の書き出しパスワード（空文字不可） |
| `IOS_PROVISIONING_PROFILE_BASE64` | 配信用 `.mobileprovision` のBase64 |
| `APP_STORE_CONNECT_KEY_ID` | APIキーのKey ID |
| `APP_STORE_CONNECT_ISSUER_ID` | APIキーのIssuer ID |
| `APP_STORE_CONNECT_PRIVATE_KEY` | `.p8` の内容全体。Base64ではなく、BEGIN/END行と改行を含む |

MacでのBase64変換例（出力はSecretsへ直接登録する）:

```sh
base64 < distribution.p12 | tr -d '\n' | pbcopy
base64 < distribution.mobileprovision | tr -d '\n' | pbcopy
```

### Environment Variables

| 名前 | 内容 |
| --- | --- |
| `APPLE_TEAM_ID` | Apple Developerの10文字のTeam ID |
| `TESTFLIGHT_BUILD_OFFSET` | 必須の非負整数。初回は `0`。既存アップロードがある場合は下記の番号が既存最大値を超える値 |

## ビルド番号

versionNameは `pubspec.yaml` のバージョンを使用する。iOSのCFBundleVersionだけを
`(TESTFLIGHT_BUILD_OFFSET + このworkflowのrun_number).run_attempt.0` で上書きする。
例えばOFFSET=100、run=12、attempt=1なら `112.1.0`、再実行すると `112.2.0`。
AndroidのversionCodeとは独立している。

Appleの制約に合わせ、第1成分は1〜9999、第2成分は1〜99に制限する。
既存ビルド・別経路のアップロード・workflowの作り直しがある場合は、App Store Connectの
使用済み最大番号を確認し、番号が逆転しないようOFFSETを調整する。別経路と同時に配信しない。
このworkflow同士は同じconcurrency groupで直列化する。

## テスターへの配布と確認

1. 初回はActionsから手動実行し、署名・ビルド・アップロードの成功を確認する。
2. App Store ConnectのTestFlightタブでAppleのビルド処理完了を待つ。
   アップロード成功は、処理完了やテスターへの配布完了を意味しない。
3. 暗号化の輸出コンプライアンスなど、表示される未完了事項に回答する。
   回答内容はアプリの利用技術に基づいて判断し、CIでは決め打ちしない。
4. **内部テストグループ**を作り、対象アプリにアクセスできるApp Store Connectユーザーを招待する。
   グループで **自動配布** を有効にすると、以後の処理済みビルドも自動的に配布される。
   招待されたユーザーはiPhone / iPadのTestFlightアプリからインストールする。
5. App Store Connectユーザー以外へ配る場合は **外部テストグループ** を使用する。
   初回などにBeta App Reviewが必要で、このworkflowだけでは外部審査の申請・承認は完了しない。

証明書、profile、APIキーはrunnerの一時領域に権限を制限して復元する。
署名鍵は専用の一時キーチェーンに読み込み、終了時は失敗時も含めて削除する。
秘密情報はArtifactへ保存しない。GitHub-hostedの一時runnerを使用する。
証明書・profileの期限切れやAPIキーの失効時は、該当Secretsを更新して再実行する。

Linuxの開発環境では実際のXcodeビルドとAppleへのアップロードは実行できない。
所有者による初回設定後、macOSのActionsで実配信を確認する。
