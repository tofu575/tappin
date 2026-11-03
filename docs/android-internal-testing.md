# Google Play 内部テスト配信

## 現在の構成

- applicationId / namespace: `com.tofu575.glarea`。Play Console登録名との一致は所有者が確認する。
- versionName: `pubspec.yaml` の `0.1.0`。versionCodeのみビルド引数で上書きする。
- Flutter: `.flutter-version` とFVM設定の3.44.9に固定。Java 17、AGP 8.11.1、Kotlin 2.2.20、Gradle 8.14。
- compile / min / target SDKは使用するFlutter SDKの既定値。flavorはなく、DB用packageではbuild_runnerを使用する。
- CI（`android-check.yml`）は秘密情報なしで未署名のrelease AABを生成し、バージョン・ソースSHA・SHA-256を添えて7日間保存する。
- CD（`android-internal-test.yml`）は対象コミットの利用可能なCI成果物を再利用し、アップロード鍵で署名する。成果物がない・期限切れ・配信済みの番号しかない場合だけ、同じソースからビルドする。

## 初回設定（所有者の作業）

1. Google Play開発者アカウントを作成し、本人確認・登録要件を完了する。対象アプリを作成する。既存アプリがある場合、パッケージ名が `com.tofu575.glarea` であることを確認し、アプリIDや既存の鍵を変更しない。違う場合は配信を止め、実装側のIDを含めて方針を確認する。
2. Play App Signingを設定する。Playが保持する「アプリ署名鍵」とCIで使う「アップロード鍵」は別。既存アップロード鍵があれば再利用する。なければローカルの安全な場所で生成する（値をチャット・コミット・Actionsログに貼らない）。

   ```sh
   keytool -genkeypair -v -keystore upload.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
   keytool -export -rfc -keystore upload.jks -alias upload -file upload_certificate.pem
   ```

   公開証明書をPlay Consoleの要求に従って登録する。秘密鍵・パスワードは安全にバックアップする。既存公開アプリの鍵を勝手に作り直さない。`.jks` / `.keystore` はGitに含めない。
3. アプリ情報、コンテンツレーティング、対象ユーザー、データセーフティ、必要なプライバシーポリシー、アクセス情報、配信地域等をConsoleのダッシュボードに従って設定する。審査や必要条件はアカウント・アプリ状態で異なる。初回リリースはConsoleから手動アップロード・公開が必要なことがあるため、初回からAPI配信できるとは限らない。
4. 内部テストトラックを作成し、メール一覧またはGoogleグループでテスターを登録する。初回の署名済みAABをアップロードして内部テストとして公開する。Consoleが示す未完了タスクを解消する。
5. Google CloudプロジェクトでGoogle Play Android Developer API（Android Publisher API）を有効化し、サービスアカウントを作成する。Play Consoleの「ユーザーと権限」でそのメールアドレスを招待し、**対象アプリだけ**にアクセスを限定する。「アプリ情報の表示（読み取り専用）」および「テストトラックへのアプリのリリース」（Consoleの表記に従う）を付与する。本番リリース・管理者権限は不要。ConsoleにAPIアクセス設定が表示される場合はその案内も完了する。Cloud IAMのOwner/Editor付与だけではPlay権限にならない。
6. サービスアカウントのJSON鍵を作り、下記Secretsへ登録する。長期鍵の漏えいリスクがあるためアプリ権限を限定し、定期ローテーション・不要鍵の削除を行う。将来はGitHub OIDC / Workload Identity Federation + サービスアカウント偽装で鍵を廃止できるが、Cloud側の信頼条件と認証ステップの追加が必要なため今回はJSON方式。
7. GitHub Settings → Environmentsで `play-internal` を作成し、Secretsと配信用Variablesを登録する。`BASE_VERSION_CODE` はCIも参照するため **repository variable** に置き、environment側に同名の値を重複させない。Required reviewersによる配信承認は維持する。`workflow_run` の実行refはデフォルトブランチになるため、environmentのbranch制限を使用する場合はそのrefも許可する。配信元がmainの成功したpush CIであることはCDのjob条件で検証する。このPRは配信を実行しない。

## GitHub Secrets

`play-internal` environment（またはrepository Secrets）に登録する。値そのものは文書へ書かない。

| 名前 | 内容 |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | アップロード用キーストアのBase64、改行なし（Linux: `base64 -w 0 upload.jks`、macOS: `base64 < upload.jks \| tr -d '\n'`） |
| `ANDROID_KEY_ALIAS` | アップロード鍵のalias |
| `ANDROID_KEY_PASSWORD` | 鍵のパスワード |
| `ANDROID_STORE_PASSWORD` | キーストアのパスワード |
| `PLAY_SERVICE_ACCOUNT_JSON` | サービスアカウントJSON全体（Base64ではない） |

秘密ファイルはrunnerの一時ディレクトリに権限600で復元し、`always()`で削除する。Artifactには保存しない。自前runnerの場合、強制終了時の削除は保証されないので一時runnerを使用する。

## GitHub VariablesとversionCode

| 名前 | 保存場所・内容 |
| --- | --- |
| `BASE_VERSION_CODE` | **Repository variable**。CIとCDで共有する非負の初期オフセット。environmentに同名の上書きを置かない |
| `PLAY_PACKAGE_NAME` | `play-internal` environment。Consoleで確認済みの `com.tofu575.glarea` |
| `PLAY_MAX_VERSION_CODE` | `play-internal` environment。全トラック・過去のアップロードを含む使用済み最大値。未使用なら0 |

CIはビルド前に `BASE_VERSION_CODE + CIのrun_number * 100 + run_attempt` をversionCodeとして確定する。
例: BASE=10000、CI run=12、attempt=1 → 11201。CIを再実行すると11202。
CDは成果物内の番号をそのまま使用し、CD自身のrun_numberで上書きしない。

CDはPlayの全トラックに現在見えている最大番号と `PLAY_MAX_VERSION_CODE` の大きい方を確認する。
その番号以下のCI成果物は使用しない。成果物がない場合は
`max(BASE_VERSION_CODE, 確認済み最大値) + 1` で再ビルドする。
CD独自のrun_numberでは番号を飛ばさないため、手動配信の回数が増えても以後のCI成果物を不必要に古い番号にしない。
手動実行で `version_code` を指定した場合は、その番号の成果物を探し、なければその番号でビルドする。
指定番号が使用済み最大値以下なら、ビルド前に失敗する。

attemptは1〜99、versionCodeの上限は2,100,000,000。100回目以降は新しいrunを起こす。
APIだけでは過去に消費した全コードを列挙できないため、`PLAY_MAX_VERSION_CODE` も更新する。
外部アップロードと同時実行しない。古いコミットの再配信やCI workflowの番号がリセットされた場合は、
新しいCI成果物が既存番号を超えるようBASEを増やす。古い成果物を使って番号を逆転させることはない。

## CI成果物の検索・検証・署名

- CIはすべてのブランチへのpushと手動実行で、その実コミットの検証・releaseビルドを行う。
  PRイベントはマージ検証用コミットのテストだけを行い、Java / Gradle / AAB生成・保存は省略する。
  ブランチpush側で作るAABを手動CDに再利用するため、同じ更新でreleaseビルドを二重に行わない。
- 成果物名は `glarea-aab-<versionName>-<versionCode>-<commit SHA>`。
  中身は未署名の `app-release.aab` と `release.json` の2ファイルだけ。
- `release.json` にはversionName、versionCode、package、ソースSHA、Flutter版、BASE、CI run ID / number / attempt、AABのSHA-256を含む。
- CDの自動実行は **mainのpush CI成功後**。発火元CI runから取得するため、CI完了前にCDが別ビルドを始めることはない。対象SHAがすでにmainの最新でなくなっている古い自動配信は、ビルド・署名・アップロードをスキップする。
- 手動CDは選択したブランチのコミットと完全に一致する成功CIを新しい順に検索する。
  他コミットやforkの成果物、PRイベントの成果物は配信に使用しない。
  PRのマージ用SHAとブランチ先端SHAは異なるため、配信用成果物はブランチpush後のCIで作る。
  このworkflow変更をまだ含まない既存ブランチでは、Actions → Android checks → Run workflowで
  対象ブランチを選択してCIを成功させれば、同じコミットの手動CDで再利用できる。
- GitHubのarchive digest、AABのSHA-256、メタデータ、CI runの出所を照合してから使用する。
  APIの権限エラー・通信エラー・不正な成果物は再ビルドで隠さず停止する。
- 利用可能な成果物がない場合だけFlutterをインストールし、依存を取得して未署名AABをビルドする。テストはCIで実行し、CDではPython / Flutterテストを再実行しない。
  キャッシュ命中時はFlutter / pub get / Gradle buildをすべて省略する。
- 成果物を除外した理由（PRイベント、SHA / versionName不一致、期限切れ、使用済みversionCode、
  指定番号との不一致、削除済みarchive）を選択ステップに表示する。API失敗や整合性不一致は停止する。
- 選んだ未署名AABをCDで `jarsigner` により署名・検証してから内部テストへアップロードする。
  パスワードはコマンド引数に直接埋め込まず環境変数経由で渡す。秘密鍵・認証情報は成果物に含めない。
- CDのGitHub権限は `contents: read` と、他runの成果物を取得する `actions: read`。

## ビルドキャッシュ

- CIとCDの再ビルド経路でFlutter Actionの `cache: true` を指定し、SDKとpubの取得済みパッケージを保存・復元する。
  SDKのバージョンとrootの `pubspec.lock` に応じたAction既定のキャッシュキーを使う。
- `gradle/actions/setup-gradle` の `basic` providerでGradle User Homeを保存・復元する。
  Gradle Wrapper、依存、変換済みライブラリ、タスク出力を再利用する。タスク出力キャッシュはCI/CDのBundleビルドstepだけに設定する `GRADLE_OPTS: -Dorg.gradle.caching=true` で有効にする。
  プロジェクト共通の `android/gradle.properties` では有効化せず、ローカルの既定動作を維持する。
- PRのテストでもFlutter / pubキャッシュを使用する。Gradleキャッシュはブランチpush・手動CIのビルドとCDの再ビルドで使用する。
- `flutter pub get --enforce-lockfile` は各checkoutで1回行い、ローカルのpackage設定を生成しつつlockfileとの一致を検証する。
  CIのテストには `--no-pub` を指定する。CDではテストを実行しない。releaseビルドには指定せず、Flutterによるrelease用プラグイン登録コードの再生成を行わせる。
  Flutter 3.44.9ではビルドの `--no-pub` がこの再生成も省略し、dev dependencyの `integration_test` が登録コードに残ってJavaコンパイルに失敗する。pubの再確認は取得済みキャッシュを利用する。
- CDでAAB成果物が見つかった場合は、FlutterとGradle両方のキャッシュ復元も省略し、署名・アップロードへ進む。
- PRの更新では古い実行をキャンセルする。各ブランチの実行中のpushジョブとCDの配信はキャンセルしない。
- 初回はキャッシュ作成が必要。実際の短縮時間は、同じブランチの後続実行でSDK復元・Gradle復元・Bundleビルドの所要時間を比較する。
  Flutterの全タスクがキャッシュ可能とは限らないため、releaseビルド全体の省略はAAB成果物の再利用で行う。

## 配信・端末での更新

- 実装は`enhance/mvp`向けPRでレビューする。**enhance/mvpへのマージでは配信されない**。
- 初期設定・実配信の承認後、`main`へマージするとCIが成果物を作り、その成功後にCDが配信する。手動はActions → Android internal test → Run workflowで配信するブランチを選ぶ。必要なら `version_code` を指定する。`enhance/mvp` も手動配信できるが、pushだけでは配信されない。
- Actionsの設定検証・テスト・Build・Uploadの各ステップを確認する。Upload失敗はジョブ失敗となる。Play配信は第三者Actionを使用せず、Google公式google-authとPlay Developer APIを直接利用する。Python依存はバージョンと配布物SHA256に固定する。internalトラックのみ、GitHub権限はcontents:readとactions:read。
- Play Console → テスト → 内部テストでversionCodeと公開状態を確認する。
- 登録したGoogleアカウントでConsoleのオプトインURLを開き、テストへ参加してPlayストアからインストールする。ストア反映・自動更新は即時を保証しない。更新が来なければ、そのアカウントでPlayストアのアプリページを開いて「更新」する。

ローカルで署名する場合はGit管理外にJava properties形式の `storeFile`（絶対パス）、`storePassword`、`keyAlias`、`keyPassword` を用意し、`ANDROID_KEY_PROPERTIES=/絶対パス/key.properties flutter build appbundle --release --build-number=<未使用整数>` を実行する。特殊文字はJava propertiesのエスケープ規則に従う。環境変数がなければreleaseは未署名で、Playにはアップロードできない。debug開発には秘密情報不要。

## トラブルシュート

| 症状 | 確認 |
| --- | --- |
| AABが存在するのに再ビルドされる | CDの選択ログの除外理由を確認。旧PR成果物はマージ検証用SHAなので対象外。対象ブランチのpushまたは手動CIを成功させ、SHA・未使用versionCode・保持期限を照合する |
| versionCode重複・最大値以下 | 全トラックとApp bundle explorerを確認しVariablesを更新、新しいrunで再配信 |
| 署名不一致 | Play App Signing画面のアップロード証明書と使用鍵を比較。アプリ署名鍵と混同しない |
| 401/403 | JSON鍵の有効性、Publisher API有効化、Playへの招待と対象アプリのテストリリース権限 |
| 初回公開・draftに関するエラー | Consoleで初回手動リリース、必須アプリ情報・ポリシー設定を完了 |
| AAB検証エラー | UploadログとConsoleのSDK・対象API・権限・ページサイズ等の要件を確認。必要なSDK/プラグイン更新は別途検証 |
| 設定検証失敗 | 必須Secrets/Variables、Base64改行除去、最大値・パッケージ・JSON形式を確認。秘密値をログに出さない |
| テスターに表示されない | アカウント、オプトイン、公開状態、反映待ち、端末の対応条件を確認 |

## 初回配信チェックリスト

- [ ] パッケージ名・既存鍵・全履歴の最大versionCodeを所有者が確認
- [ ] Play App Signingと必要な初回手動リリースを完了
- [ ] アプリ情報・ポリシー・対象APIなどConsoleの要件を完了
- [ ] サービスアカウントのアプリ単位権限・Secrets/Variables設定
- [ ] テスター登録・参加URL確認
- [ ] 実配信の承認後、mainで実行しActionsとConsoleを確認
- [ ] テスター端末でPlay経由のインストール・更新確認

将来の本番公開は同じapplicationId・Play App Signingを維持し、検証済みリリースを本番へ昇格する。このワークフローは本番へ配信しない。開発版と本番版を同じ端末で共存させる場合は別applicationIdのflavorとPlay上の別アプリが必要（今回は追加しない）。

## パッケージ名の変更とActionの安全性確認

Android applicationId / namespaceとiOS bundle IDは `com.tofu575.glarea`、Dartパッケージ名は `glarea`。起動時は `StoneApp` と本番のStone・Wish・写真用Interactorを使用する。配信更新でも同じアプリIDと署名設定を維持する。iOSの署名・Provisioning Profileもこのbundle IDに対応した設定が必要。

checkout・setup-java・upload-artifactはGitHub公式、Flutter SDK設定はsubosito/flutter-action、Gradleキャッシュはgradle/actions/setup-gradleを使用し、すべてSHA固定。Flutter Actionの既定キーとGradle Actionのbasic providerでキャッシュを保存・復元する。Play配信に検討したr0adkll/upload-google-playは、v1.1.3とv1.1.5の依存監査で既知脆弱性が検出されたため採用しない。依存監査の検出は、この用途での悪用可能性を断定するものではない。SHA固定は上流タグ差替えへの対策であり、無欠陥の保証ではない。

SecretsはGitHub Environmentから受け取る。リポジトリには秘密値を保存せず、アップロード鍵はCDのAAB署名、サービスアカウントは配信前の番号確認とPlayアップロードにのみ使用する。GitHubのcheckout資格情報は作業ツリーに永続化しない。`play-internal`の承認と対象アプリへの最小権限を併用する。

依存監査（2026-10-27 JST）: `pip-audit -r scripts/play-requirements.txt` で固定したPython依存11件に既知脆弱性の検出なし。監査時点のデータベースによる結果であり、将来・未発見の問題は保証しない。依存更新時はハッシュを再生成し、監査・テスト後にPRで更新する。
