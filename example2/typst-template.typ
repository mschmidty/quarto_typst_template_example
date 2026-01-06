#let report(
  title: none,
  date: none,
  authors: (),
  content,
) = {
  set page(
    paper: "us-letter",
    margin: (top: 1in, bottom: 1in, x: 1in, y: 1in),
  )
  set text(
    lang: "en",
    region: "US",
    font: "Inter",
    size: 11pt,
  )
  align(left)[
    #block(text(weight: 700, 1.75em, title))
    #if authors.len() > 0 {
      block(text(size: 1.2em)[
        // Join the list of authors with a comma
        #authors.join(", ", last: " & ")
      ])
      v(0.5em)
    }
  ]


  if date != none {
    align(left)[
      #text(size: 1.1em, date)
    ]
  }

  set heading(numbering: "1.1")
  show heading: it => {
    set text(
      font: "Inter",
      weight: 700,
      fill: rgb("#005e2f"),
    )
    it
  }
  // Level 1 (= Title)
  show heading.where(level: 1): it => {
    set align(center)
    set block(below: 1.5em)
    set text(
      size: 18pt,
      fill: rgb("#666666"),
    )
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

  show table: set text(
    size: 9pt,
  )
  // 1. THE WRAPPER (Handles Top & Bottom Lines)
  // This wraps every table in a box with heavy top/bottom borders.
  show table: it => block(
    stroke: (
      top: 1pt + black, // Heavy Top Line
      bottom: 1pt + black, // Heavy Bottom Line
    ),
    // We remove the block's internal padding so the lines touch the table
    inset: 0pt,
    it,
  )

  // 2. THE INTERNALS (Handles the Header Line)
  set table(
    inset: 6pt,
    align: horizon,
    stroke: (x, y) => (
      x: none, // No vertical lines
      // KEY FIX: Turn off ALL bottom lines to prevent the "double line" at the end
      bottom: none,
      // Draw separators at the TOP of cells instead
      top: if y == 0 {
        // Row 0 Top: Handled by wrapper (so none here)
        none
      } else if y == 1 {
        // Row 1 Top: This is the line UNDER the header
        1pt + black
      } else {
        // Row 2+ Top: These are the separators between data rows
        0.5pt + gray.lighten(50%)
      },
    ),
  )

  // 2. HEADER ROW SPECIFIC STYLING
  //    Target the first row (y: 0) to make it bold and distinct
  show table.cell.where(y: 0): set text(weight: "bold")


  v(4em, weak: true)

  content
}
