# invoice-ja

A Typst template for generating Japanese estimates, invoices, and delivery notes. Multiple document types can be combined into a single PDF.

Typst で日本語の **見積書 / 請求書 / 納品書** を作成できるテンプレートです。  

![Sample Invoice](https://i.gyazo.com/15846bba67782a8a01f225dc5adca7e8.png)

## できること

- 1つのテンプレートで書類種別を切り替え（`見積書` / `請求書` / `納品書`）
- `doc_type` に配列を渡すと、複数種別を **1つのPDF** に連続出力
- 明細から小計・消費税・合計を自動計算
- 発行元・宛先・振込先・備考をパラメータで差し替え

## 必要環境

- [Typst](https://typst.app/) 0.11 以上
- 日本語フォント（デフォルト設定: `Hiragino Sans`）

## ローカルパッケージとしてインストールして使う

Typst は、パッケージを **データディレクトリ** 下の  
`{data-dir}/typst/packages/{namespace}/{name}/{version}/` に置くと import できる仕組みです（[Typst Packages の README（Local packages）](https://github.com/typst/packages/blob/main/README.md)）。

`{data-dir}` の目安は次のとおりです。

| OS | 既定の `{data-dir}`（例） |
| --- | --- |
| Linux | `$XDG_DATA_HOME` があればそこ、なければ `~/.local/share` |
| macOS | `~/Library/Application Support` |
| Windows | `%APPDATA%`（例: `C:\Users\<ユーザー名>\AppData\Roaming`） |

実際のパスは環境によって異なるので、端末で `typst info` を実行し、**Package path** を確認してください。

このリポジトリの **ルート一式**（`typst.toml`・`lib.typ`・`invoice-ja.typ`・`template/` など）を、次のディレクトリにコピーします。

`{data-dir}/typst/packages/local/invoice-ja/{version}/`

`version` は `typst.toml` の `[package].version`（現状 `0.1.0`）と **必ず一致** させてください。`local` 名前空間に置くと `#import "@local/invoice-ja:0.1.0"` で読み込め、`template/main.typ` と同じ import 文のまま `typst init` やコンパイルが通ります（データディレクトリ側のパッケージはキャッシュより優先されます）。

以下の `0.1.0` は、インストールしたバージョンに合わせて読み替えてください。

### Linux（Bash の例）

次の `rsync` は **このリポジトリをクローンしたディレクトリのルート**で実行してください。

```bash
VERSION=0.1.0
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages/local/invoice-ja/$VERSION"
mkdir -p "$DEST"
rsync -a --exclude '.git' ./ "$DEST/"
```

### macOS（Bash / zsh の例）

リポジトリのルートで実行してください。

```bash
VERSION=0.1.0
DEST="$HOME/Library/Application Support/typst/packages/local/invoice-ja/$VERSION"
mkdir -p "$DEST"
rsync -a --exclude '.git' ./ "$DEST/"
```

### Windows（PowerShell の例）

リポジトリのルートで実行してください。

```powershell
$Version = "0.1.0"
$Dest = Join-Path $env:APPDATA "typst\packages\local\invoice-ja\$Version"
New-Item -ItemType Directory -Force -Path $Dest | Out-Null
Copy-Item -Path (Get-Item .).FullName\* -Destination $Dest -Recurse -Force
# .git をコピーしたくない場合は、エクスプローラーで除外するか robocopy 等を利用してください。
```

### インストール後の手順（`typst init`）

1. 上記のいずれかでパッケージを配置する。
2. 作業用の **空のディレクトリ** で次を実行する。

```bash
typst init "@local/invoice-ja:0.1.0"
```

3. `invoice-ja` サブディレクトリに移動する。

```bash
cd invoice-ja
```

4. `main.typ` の `#show: invoice_ja(...)` の引数を、自分の内容に合わせて書き換える。

- `doc_type` - 書類種別。1枚なら `"見積書"` などの文字列。複数なら `("見積書", "請求書", "納品書")` のように配列
- `recipient` - 宛先情報
- `issue_date` - 発行日
- `items` - 明細（品目・単価・数量）
- `issuer` - 発行元情報
- `bank` - 振込先情報（請求書で利用）
- `remarks` - 備考（任意）
- `document_number` - 書類番号（任意）。複数種別のときは `none`（種別ごと自動）か、種別の数と同じ長さの配列

5. PDF にする。

```bash
typst compile main.typ
```

`main.pdf` が生成されます。編集しながらプレビューする場合は `typst watch main.typ` も使えます。

`typst init` を使わず既存の `.typ` から使う場合は、先頭で `#import "@local/invoice-ja:0.1.0": invoice_ja` と書きます（バージョンはインストールしたものに合わせる）。関数名はパッケージ名に合わせて `invoice_ja` です（Typst では `invoice-ja(...)` が減算と解釈されるため、ハイフンではなくアンダースコアにしています）。

## 使い方

`local` 名前空間にインストール済みの場合の例です。

```typst
#import "@local/invoice-ja:0.1.0": invoice_ja

#show: invoice_ja(
  "請求書",
  (
    name: "株式会社サンプル",
    honorific: "御中",
    address: "東京都千代田区1-2-3",
  ),
  datetime(year: 2026, month: 4, day: 22),
  (
    (name: "開発費", price: 100000, qty: 1),
  ),
)
```

## 複数種別を1つのPDFに出力する

`doc_type` に文字列の配列を渡すと、同じ宛先・明細・発行元などの内容で **種類だけ変えた複数枚** を、ページ区切り付きで1本にまとめられます。

`document_number` は、複数種別のとき **`none`** にすると種別ごとに接頭辞＋日付で自動採番します。手で振る場合は、種別の枚数と同じ要素数の配列を渡してください。

## `invoice_ja` 関数のシグネチャ

```typst
#show: invoice_ja(
  doc_type,
  recipient,
  issue_date,
  items,
  tax_rate: 0.1,
  issuer: (...),
  bank: none,
  remarks: none,
  document_number: none,
)
```

- `doc_type`: 1枚なら `"見積書"` / `"請求書"` / `"納品書"` のいずれか。複数枚ならその文字列の配列
- `recipient`: `(name, honorific, address)`。`address` は `none` で省略可。
- `issue_date`: `datetime(...)`
- `items`: `((name, price, qty), ...)`
- `tax_rate`: 消費税率（例: `0.1`）
- `issuer`: 差出し欄。`(label, company, name, postal_code, address, custom)` 形式の辞書。
  - `name` / `postal_code` / `address` は `none` のときその行を出さない（住所を書かない請求書にも対応）。
  - `address` は複数行にしたい場合、`content` で渡す（`[#linebreak()]` や `\\` で改行）。
  - `custom` を **辞書に含め、かつ `none` でない content** にすると、差出しボックス内はその内容だけを表示する（登録番号・電話・独自ブロックなど、固定フィールドでは足りないとき用）。
- `bank`: `(bank_name, branch_name, account_type, account_number, account_name)` または `none`
- `remarks`: 備考。`none` で非表示
- `document_number`: 1枚のみのときは文字列。`none` の場合は日付ベースで自動採番。複数種別のときは `none` か、種別の枚数と同じ長さの配列（要素は文字列または `none`）

## 書類種別ごとの違い

- `見積書`: 消費税を表示、振込先は非表示
- `請求書`: 消費税と振込先を表示
- `納品書`: 消費税と振込先を非表示

## フォントに関する注意

- 環境によっては利用可能フォントが異なります
- 表示が崩れる場合は `invoice-ja.typ` 冒頭の `font-sans` 設定を変更してください

## よくある調整ポイント

- タイトルや濃淡を変更したい: `invoice-ja.typ` の `brand` / `brand-soft` / `line-soft`（いずれも `luma(...)`）を編集
- 余白を変更したい: `set page(...)` の `margin` を編集
- 文字サイズを変更したい: `set text(...)` の `size` を編集
- 備考欄や振込先の見た目を変えたい: `rect(...)` の `inset` / `radius` / `stroke` を編集

## ライセンス

[LICENSE](LICENSE) を参照してください（MIT）。
