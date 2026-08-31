# 表示文言と多言語対応

ユーザーに表示する文言は`lib/l10n/app_ja.arb`を原本とし、PresentationのWidgetへ直書きしません。
件数、日時、エラー詳細など可変値を含む文言はARBのplaceholderを使います。

生成コードの`app_localizations*.dart`は直接編集せず、ARB変更後に次を実行します。

```bash
fvm flutter gen-l10n
```

言語を追加する場合は、同じメッセージIDを持つ`app_en.arb`などを`lib/l10n`へ追加します。
追加したLocaleは生成後に`AppLocalizations.supportedLocales`へ自動反映されます。
