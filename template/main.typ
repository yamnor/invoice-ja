#import "@local/invoice-ja:0.1.0": invoice_ja

#show: invoice_ja(
  // 複数種別を一度に出す例: ("見積書", "請求書", "納品書")
  "請求書",
  (
    name: "サンプル商事株式会社",
    honorific: "御中",
    address: "東京都千代田区サンプル 1-2-3",
  ),
  datetime(year: 2026, month: 4, day: 22),
  (
    (name: "Webサイト保守（4月分）", price: 30000, qty: 1),
    (name: "機能追加対応（5時間）", price: 7000, qty: 5),
    (name: "月次レポート作成", price: 12000, qty: 1),
  ),
  tax_rate: 0.1,
  issuer: (
    label: "発行元",
    company: "サンプルテック合同会社",
    name: "山田 太郎",
    postal_code: "100-0001",
    address: "東京都千代田区サンプル 4-5-6",
  ),
  bank: (
    bank_name: "サンプル銀行（銀行コード：0000）",
    branch_name: "本店営業部（支店コード：001）",
    account_type: "普通",
    account_number: "1234567",
    account_name: "サンプルテックドウ",
  ),
  remarks: [
    お支払期限は 2026年5月末日です。 \
    ご不明点がございましたら担当者までご連絡ください。
  ],
  document_number: "INV-20260422-001",
)
