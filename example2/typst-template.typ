#let report(
  title: none,
  date: none,
  content,
) = {
  set page(
    paper: "us-letter",
    margin: (top: 1in, bottom: 1in, x: 1in, y: 1in),
  )
  set text(
    lang: "en",
    region: "US",
    font: "Source Serif Pro",
    size: 11pt,
  )
  align(left)[
    #block(text(weight: 700, 1.75em, title))
  ]

  if date != none {
    align(left)[
      #text(size: 1.1em, date)
    ]
  }
  set heading(numbering: "1.1")
  show heading: it => {
    set text(font: "Karla", weight: 900)
    it
  }
  // Level 1 (= Title)
  show heading.where(level: 1): it => {
    set text(size: 18pt)
    set align(center)
    it
  }

  // Level 2 (== Subtitle)
  show heading.where(level: 2): set text(size: 14pt)

  // Level 3 (=== Section)
  show heading.where(level: 3): set text(size: 12pt)

  // Target figure captions specifically
  show figure.caption: set text(
    size: 0.85em, // 85% of normal text size
    style: "italic", // Make it italic
  )


  v(4em, weak: true)

  content
}
