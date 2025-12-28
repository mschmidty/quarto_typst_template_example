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
  title: [Robust Typst Template Example],
  authors: (
                  "Michael Schmidt",
            ),
      date: [2024-05-21],
        abstract: [This document demonstrates a custom Quarto Typst format. It includes various elements such as formatted text, mathematics, code execution via R, and figures. The goal is to provide a comprehensive starting point for further customization.

],
        
  // Pass the document content as the final argument 'content'
  doc, 
)

= Introduction
<introduction>
This is an example document created using Quarto and a custom Typst template. The template defines the layout, fonts, and styling. We are currently using a two-column layout as defined in the YAML header (`cols: 2`).

== Text Formatting
<text-formatting>
Typst supports #emph[italics];, #strong[bold text];, and #strong[#emph[bold italics];];. You can also use `monospaced text` for code snippets.

Here is a block quote:

#quote(block: true)[
"The best way to predict the future is to create it." \
--- Peter Drucker
]

#block[
#callout(
body: 
[
Test text of a note.

]
, 
title: 
[
Warning
]
, 
background_color: 
rgb("#fcefdc")
, 
icon_color: 
rgb("#EB9113")
, 
icon: 
fa-exclamation-triangle()
, 
body_background_color: 
white
)
]
== Mathematics
<mathematics>
Quarto and Typst handle mathematics beautifully using standard LaTeX syntax.

Here is an inline equation: $E = m c^2$.

And here is a display equation:

$ frac(partial rho, partial t) + nabla dot.op (rho upright(bold(u))) = 0 $

We can also align equations:

$ f (x) & = x^2 + 2 x + 1\
 & = (x + 1)^2 $

= Computational Content (R)
<computational-content-r>
Since we are in a Quarto environment with R available, we can execute code and embed the results directly.

== Data Visualization
<data-visualization>
Below is a plot generated using R's base graphics system. It plots a simple sine wave.

```r
x <- seq(0, 2 * pi, length.out = 100)
y <- sin(x)

plot(
  x,
  y,
  type = "l",
  col = "blue",
  lwd = 2,
  main = "Sine Wave",
  xlab = "x",
  ylab = "sin(x)"
)
grid()
```

#figure([
#box(image("example_files/figure-typst/fig-sine-1.svg"))
], caption: figure.caption(
position: bottom, 
[
A simple sine wave generated in R.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-sine>


We can also use `ggplot2` if installed, but base R is safer for a generic template. Here is a histogram of random normal data:

#figure([
#box(image("example_files/figure-typst/fig-hist-1.svg"))
], caption: figure.caption(
position: bottom, 
[
Histogram of 1000 random normal values.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-hist>


See #ref(<fig-sine>, supplement: [Figure]) and #ref(<fig-hist>, supplement: [Figure]) for examples of generated figures.

= Tables
<tables>
Tables can be created using Markdown syntax or generated by code.

#figure([
#table(
  columns: 3,
  align: (left,center,left,),
  table.header([Feature], [Support], [Notes],),
  table.hline(),
  [Tables], [Yes], [Markdown tables work well],
  [Figures], [Yes], [Auto-captioning is supported],
  [Math], [Yes], [LaTeX syntax],
)
], caption: figure.caption(
position: top, 
[
Comparison of features
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-features>


We can also generate tables from R data frames:

#figure([
#table(
  columns: 5,
  align: (right,right,right,right,left,),
  table.header([Sepal.Length], [Sepal.Width], [Petal.Length], [Petal.Width], [Species],),
  table.hline(),
  [5.1], [3.5], [1.4], [0.2], [setosa],
  [4.9], [3.0], [1.4], [0.2], [setosa],
  [4.7], [3.2], [1.3], [0.2], [setosa],
  [4.6], [3.1], [1.5], [0.2], [setosa],
  [5.0], [3.6], [1.4], [0.2], [setosa],
)
], caption: figure.caption(
position: top, 
[
First 5 rows of the Iris dataset.
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-iris>


= Lorem Ipsum
<lorem-ipsum>
To demonstrate the text layout further, here is some dummy text.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Curabitur pretium tincidunt lacus. Nulla gravida orci a odio. Nullam varius, turpis et commodo pharetra, est eros bibendum elit, nec luctus magna felis sollicitudin mauris. Integer in mauris eu nibh euismod gravida. Duis ac tellus et risus vulputate vehicula. Donec lobortis risus a elit. Etiam tempor. Ut ullamcorper, ligula eu tempor congue, eros est euismod turpis, id tincidunt sapien risus a quam. Maecenas fermentum consequat mi. Donec fermentum. Pellentesque malesuada nulla a mi.

= Conclusion
<conclusion>
= Heading 1
<heading-1>
== Heading 2
<heading-2>
=== Heading 3
<heading-3>
==== Heading 4
<heading-4>
===== Heading 5
<heading-5>
====== Heading 6
<heading-6>
This template provides a solid foundation. You can modify:

+ `typst-template.typ` to change the visual styling (fonts, colors, margins) and metadata handling.
+ The YAML header in your `.qmd` file to toggle options like `cols`.

Happy writing!
