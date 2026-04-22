# typst-template-invoice

Typst で日本語の **請求書 / 見積書 / 納品書** を作成できるテンプレートです。  
1つの関数 `invoice(...)` にデータを渡すだけで、PDF を出力できます。

## できること

- 1つのテンプレートで書類種別を切り替え（`請求書` / `見積書` / `納品書`）
- 明細から小計・消費税・合計を自動計算
- 発行元・宛先・振込先・備考をパラメータで差し替え
- サンプルファイルですぐに動作確認

## ファイル構成

- `invoice-ja.typ` - テンプレート本体（`invoice` 関数を定義）
- `example-invoice-ja.typ` - サンプルデータを渡して表示する実行例

## 必要環境

- [Typst](https://typst.app/) 0.11 以上
- 日本語フォント（デフォルト設定: `Hiragino Sans`）

## クイックスタート

### 1) サンプルをそのまま PDF 化

```bash
typst compile example-invoice-ja.typ
```

`example-invoice-ja.pdf` が生成されます。

### 2) 自分用の入力ファイルを作る

```bash
cp example-invoice-ja.typ my-invoice.typ
```

`my-invoice.typ` を編集し、次の項目を差し替えてください。

- `doc_type` - 書類種別（`"請求書"` / `"見積書"` / `"納品書"`）
- `recipient` - 宛先情報
- `issue_date` - 発行日
- `items` - 明細（品目・単価・数量）
- `issuer` - 発行元情報
- `bank` - 振込先情報（請求書で利用）
- `remarks` - 備考（任意）
- `document_number` - 書類番号（任意）

### 3) 編集したファイルを PDF 化

```bash
typst compile my-invoice.typ
```

## 使い方（最小例）

```typst
#import "invoice-ja.typ": invoice

#show: invoice(
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

## `invoice` 関数のシグネチャ

```typst
#show: invoice(
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

- `doc_type`: `"請求書"` / `"見積書"` / `"納品書"`
- `recipient`: `(name, honorific, address)`
- `issue_date`: `datetime(...)`
- `items`: `((name, price, qty), ...)`
- `tax_rate`: 消費税率（例: `0.1`）
- `issuer`: `(label, company, name, postal_code, address)`
- `bank`: `(bank_name, branch_name, account_type, account_number, account_name)` または `none`
- `remarks`: 備考。`none` で非表示
- `document_number`: 文字列。`none` の場合は日付ベースで自動採番

## 書類種別ごとの違い

- `請求書`: 消費税と振込先を表示
- `見積書`: 消費税を表示、振込先は非表示
- `納品書`: 消費税と振込先を非表示

## フォントに関する注意

- 環境によっては利用可能フォントが異なります
- 表示が崩れる場合は `invoice-ja.typ` 冒頭の `font-sans` 設定を変更してください

## よくある調整ポイント

- タイトルや色味を変更したい: `invoice-ja.typ` の `brand` / `brand-soft` を編集
- 余白を変更したい: `set page(...)` の `margin` を編集
- 文字サイズを変更したい: `set text(...)` の `size` を編集
- 備考欄や振込先の見た目を変えたい: `rect(...)` の `inset` / `radius` / `stroke` を編集
