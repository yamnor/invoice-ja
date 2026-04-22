// 日本語フォントの設定（必要に応じて環境に合わせて差し替えてください）
#let font-sans = (
  "Hiragino Sans",
)
// グレースケール（濃淡は luma(0)=黒 … luma(255)=白）
#let brand = luma(32)
#let brand-soft = luma(245)
#let line-soft = luma(175)

#let pad-3(n) = {
  let s = str(n)
  if n < 10 {
    "00" + s
  } else if n < 100 {
    "0" + s
  } else {
    s
  }
}

#let format-jpy(n) = {
  let sign = if n < 0 { "-" } else { "" }
  let abs-n = calc.abs(n)
  if abs-n < 1000 {
    sign + str(abs-n)
  } else {
    let head = int(calc.floor(abs-n / 1000))
    let tail = calc.rem(abs-n, 1000)
    sign + format-jpy(head) + "," + pad-3(tail)
  }
}

#let document-config(doc-type) = {
  if doc-type == "見積書" {
    (
      title: "見積書",
      intro: "下記の通りお見積り申し上げます。",
      amount-label: "お見積金額（税込）",
      date-label: "見積日",
      no-label: "見積番号",
      no-prefix: "EST-",
      show-tax: true,
      total-label: "見積合計",
      show-bank: false,
    )
  } else if doc-type == "納品書" {
    (
      title: "納品書",
      intro: "下記の通り納品いたしました。",
      amount-label: "納品合計（税込）",
      date-label: "納品日",
      no-label: "納品書番号",
      no-prefix: "DEL-",
      show-tax: false,
      total-label: "納品合計",
      show-bank: false,
    )
  } else {
    (
      title: "請求書",
      intro: "下記の通りご請求申し上げます。",
      amount-label: "ご請求金額（税込）",
      date-label: "発行日",
      no-label: "請求書番号",
      no-prefix: "INV-",
      show-tax: true,
      total-label: "合計",
      show-bank: true,
    )
  }
}

// テンプレート関数（`invoice-ja(...)` は減算と解釈されるため識別子は `invoice_ja`）
#let invoice_ja(
  doc_type,
  recipient,
  issue_date,
  items,
  tax_rate: 0.1,
  issuer: (
    label: "販売元",
    company: "サンプル株式会社",
    name: none,
    postal_code: none,
    address: none,
    // `custom` に content を渡すと、差出し欄はその内容だけを表示（自由レイアウト用）
    custom: none,
  ),
  bank: none,
  remarks: none,
  document_number: none,
) = {
  let cfg = document-config(doc_type)

  // ページ設定 (A4)
  set page(paper: "a4", margin: 2.5cm)
  set text(font: font-sans, size: 11pt)

  // タイトル
  align(center)[
    #text(26pt, weight: "bold", fill: brand)[#cfg.title]
  ]
  v(1.6em)

  // 小計・消費税・合計の自動計算ロジック
  let subtotal = items.fold(0, (sum, item) => sum + (item.price * item.qty))
  // 税額は四捨五入で算出（1円単位）
  let tax = int(calc.round(subtotal * tax_rate))
  let total = subtotal + tax
  let grand-total = if cfg.show-tax { total } else { subtotal }
  let doc-number = if document_number == none {
    cfg.no-prefix + issue_date.display("[year][month padding:zero][day padding:zero]")
  } else {
    document_number
  }

  // ヘッダー情報（宛先と差出人情報）
  grid(
    columns: (1.15fr, 0.85fr),
    column-gutter: 1.5cm,
    align: (left + top, right + top),
    [
      #text(14pt, weight: "bold")[
        #recipient.name
        #if recipient.honorific != none [#h(0.5em)#recipient.honorific]
      ]
      #if recipient.address != none [
        #v(0.25em)
        #text(size: 10pt, fill: luma(70))[#recipient.address]
      ]
      #v(1em)
      #text(fill: luma(70))[#cfg.intro]
      #v(0.9em)
      #rect(
        inset: 8pt,
        radius: 0pt,
        fill: brand-soft,
        stroke: 0.6pt + line-soft,
      )[
        #text(10pt, fill: luma(80))[#cfg.amount-label]
        #v(0.15em)
        #text(19pt, weight: "bold", fill: brand)[¥ #format-jpy(grand-total)]
      ]
    ],
    [
      #align(right)[#cfg.date-label: #issue_date.display("[year]年[month padding:zero]月[day padding:zero]日")]
      #align(right)[#cfg.no-label: #doc-number]
      #v(1em)
      #rect(
        inset: 9pt,
        radius: 0pt,
        stroke: 0.8pt + line-soft,
        fill: white,
      )[
        #if issuer.at("custom", default: none) != none [
          #set align(left)
          #issuer.custom
        ] else [
          #align(left)[#text(size: 9.5pt, fill: brand)[#issuer.label]]
          #v(0.25em)
          #align(left)[#text(size: 10.5pt, weight: "semibold")[#issuer.company]]
          #if issuer.at("name", default: none) != none [#align(left)[#text(size: 10.5pt)[#issuer.name]]]
          #if issuer.at("postal_code", default: none) != none [
            #v(0.25em)
            #align(left)[#text(size: 10pt, fill: luma(70))[〒#issuer.postal_code]]
          ]
          #if issuer.at("address", default: none) != none [
            #align(left)[#text(size: 10pt, fill: luma(70))[#issuer.address]]
          ]
        ]
      ]
    ]
  )

  v(2em)

  // 明細テーブルの生成
  table(
    columns: (1fr, auto, auto, auto),
    inset: 6pt,
    stroke: 0.7pt + line-soft,
    fill: (x, y) => if y == 0 { luma(0) } else { none },
    align: (x, y) => if y == 0 {
      center
    } else if x == 0 {
      left
    } else {
      right
    },

    // ヘッダー行（黒背景・白字・中央揃え）
    [#text(weight: "semibold", fill: white)[品目]],
    [#text(weight: "semibold", fill: white)[単価]],
    [#text(weight: "semibold", fill: white)[数量]],
    [#text(weight: "semibold", fill: white)[金額]],

    // 明細データ行を展開
    ..items.map(item => (
      item.name,
      [¥ #format-jpy(item.price)],
      str(item.qty),
      [¥ #format-jpy(item.price * item.qty)]
    )).flatten(),

    // 合計行
    ..if cfg.show-tax {
      (
        table.cell(colspan: 2)[], [小計], [¥ #format-jpy(subtotal)],
        table.cell(colspan: 2)[], [消費税], [¥ #format-jpy(tax)],
        table.cell(colspan: 2)[], [#cfg.total-label], [*¥ #format-jpy(total)*],
      )
    } else {
      (
        table.cell(colspan: 2)[], [#cfg.total-label], [*¥ #format-jpy(subtotal)*],
      )
    }
  )

  if remarks != none [
    #v(1.2em)
    #rect(
      width: 100%,
      inset: 10pt,
      radius: 0pt,
      fill: white,
      stroke: 0.7pt + line-soft,
    )[
      #text(size: 10pt, weight: "semibold", fill: brand)[備考]
      #v(0.35em)
      #text(size: 10pt)[#remarks]
    ]
  ]

  if cfg.show-bank and bank != none [
    #v(1.2em)
    #rect(
      inset: 10pt,
      radius: 0pt,
      fill: brand-soft,
      stroke: 0.7pt + line-soft,
    )[
      #text(size: 10pt, weight: "semibold", fill: brand)[振込先]
      #v(0.35em)
      #text(size: 10.5pt)[#bank.bank_name]
      #linebreak()
      #text(size: 10.5pt)[#bank.branch_name]
      #v(0.25em)
      #text(size: 10.5pt)[#(bank.account_type + " " + bank.account_number)]
      #v(0.25em)
      #text(size: 10.5pt, weight: "semibold")[#bank.account_name]
    ]
  ]
}