
// This is the core project function
#let project(
  title: "",
  authors: (),
  date: none,
  abstract: none,
  cols: 1,
  body-font: ("Inter"),
  header-font: ("Space Grotesk"),
  font-size: 11pt,
  body
) = {
  set document(author: authors, title: title)
  set text(font: body-font, size: font-size)
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

  set heading(numbering: "1.1")
  show heading: it => {
    // Define font sizes and styles based on heading level
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

  // Title Row
  align(center)[
    #block(text(font: header-font, weight: 700, 2em, title))
    #v(1em, weak: true)
    #if date != none {
      text(date)
    }
  ]

  // Authors
  pad(
    top: 0.5em,
    bottom: 0.5em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center, strong(author))),
    ),
  )

  // Abstract
  if abstract != none {
    pad(
      x: 2em,
      top: 1em,
      bottom: 1.5em,
      align(center)[
        #heading(
          outlined: false,
          numbering: none,
          text(0.85em, smallcaps[Abstract]),
        )
        // Use a block for abstract content to allow parbreaks if needed, though usually abstract is short.
        #block(width: 100%, text(0.95em, emph(abstract)))
      ],
    )
  }

  set par(justify: true)
  
  if cols > 1 {
    columns(cols, gutter: 4%, body)
  } else {
    body
  }
}

// Apply the template
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
$if(cols)$
  cols: $cols$,
$else$
  cols: 1,
$endif$
$if(body-font)$
  body-font: ("$body-font$"),
$endif$
$if(header-font)$
  header-font: ("$header-font$"),
$endif$
  doc,
)

$body$
