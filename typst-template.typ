// ----------------------------------------------------------------------
// 1. GLOBAL DEFINITIONS (Must be at the top)
// ----------------------------------------------------------------------

// Dummy definitions for FontAwesome icons so Quarto doesn't crash
#let fa-info() = [ℹ]
#let fa-exclamation-triangle() = [⚠️]
#let fa-stop-circle() = [🛑]
#let fa-lightbulb() = [💡]
#let fa-quote-right() = [❞]

// The Callout function (Global Scope)
#let callout(body:none, title: "Note", background_color: rgb("#e6f2ff"), icon_color: rgb("#007bff"), icon: none,..args) = {
  block(
    fill: background_color,
    width: 100%,
    inset: 1em,
    radius: 0.5em,
    stroke: icon_color + 0.5pt,
    {
      if icon != none {
        grid(
          columns: (2em, 1fr),
          align: (center + horizon, left),
          text(fill: icon_color, size: 1.2em, icon),
          {
            strong(title)
            v(0.2em)
            body
          }
        )
      } else {
        strong(title)
        v(0.2em)
        body
      }
    }
  )
}

// ----------------------------------------------------------------------
// 2. PROJECT FUNCTION
// ----------------------------------------------------------------------

#let project(
  title: "",
  authors: (),
  date: none,
  abstract: none,
  body-font: ("Inter"),
  header-font: ("Space Grotesk"),
  font-size: 11pt,
  content // <--- Named 'content' to avoid Quarto conflicts, NO default value
) = {
  
  // -- A. Document Settings --
  set document(author: authors, title: title)
  set text(font: body-font, size: font-size)
  set par(justify: true)

  set page(
    paper: "us-letter",
    margin: (left: 1in, right: 1in, top: 1in, bottom: 1in),
    numbering: "1",
    header: context {
      if counter(page).at(here()).first() > 1 {
        align(right, text(0.8em, fill: gray, font: header-font)[#title])
      }
    },
  )

  // -- B. Heading Styles --
  set heading(numbering: "1.1")
  show heading: it => {
    let (size, weight, style) = if it.level == 1 {
      (1.5em, 700, "normal")
    } else if it.level == 2 {
      (1.3em, 700, "normal")
    } else if it.level == 3 {
      (1.1em, 700, "normal")
    } else if it.level == 4 {
      (1em, 700, "normal")
    } else if it.level == 5 {
      (1em, 700, "italic")
    } else {
      (1em, 400, "italic")
    }

    pad(
      top: 0.5em,
      bottom: 0.3em,
      text(font: header-font, size: size, weight: weight, style: style, it)
    )
  }

  // -- C. Code Block Style --
  show raw.where(block: true): it => block(
    fill: rgb("#f5f5f5"),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
    it
  )

  // -- D. Caption Style --
  show figure.caption: it => context {
    set align(left)
    set text(size: 0.85em, style: "italic")
    strong(it.supplement)
    if it.numbering != none {
      strong([ ])
      strong(it.counter.display(it.numbering))
    }
    [: ]
    it.body
  }

  // --------------------------------------------------------------------
  // E. LAYOUT & CONTENT FLOW (The part you asked about)
  // --------------------------------------------------------------------

  // 1. Draw the Title
  align(left)[
    #block(text(font: header-font, weight: 700, 2em, title))
    #v(1em, weak: true)
    #if date != none {
      text(date)
    }
  ]

  // 2. Draw the Authors
  pad(
    top: 0.5em,
    bottom: 0.5em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(left, strong(author))),
    ),
  )

  // 3. Draw the Abstract (if present)
  if abstract != none {
    pad(
      top: 1em,
      bottom: 1.5em,
      align(left)[
        #heading(
          outlined: false,
          numbering: none,
          text(0.85em, smallcaps[Abstract]),
        )
        #block(width: 100%, text(0.95em, emph(abstract)))
      ],
    )
  }

  // 4. Add a separator space
  v(2em, weak: true)

  // 5. Draw the Body Content
  // This sits here alone to ensure it is returned as the final content block
  content
}

// ----------------------------------------------------------------------
// 3. QUARTO SHOW RULE (Must match the function above)
// ----------------------------------------------------------------------

#show: doc => project(
  title: [$title$],
  authors: (
    $if(by-author)$
      $for(by-author)$
        "$it.name.literal$",
      $endfor$
    $endif$
  ),
  $if(date)$
    date: [$date$],
  $endif$
  $if(abstract)$
    abstract: [$abstract$],
  $endif$
  $if(body-font)$
    body-font: ("$body-font$"),
  $endif$
  $if(header-font)$
    header-font: ("$header-font$"),
  $endif$
  
  // Pass the document content as the final argument 'content'
  doc, 
)

$body$
