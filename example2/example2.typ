// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}

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
    font: "Inter",
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


  v(4em, weak: true)

  content
}
#import "@preview/fontawesome:0.5.0": *

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
)

#show: body => report(
  title: [This is another typst test not made with AI],
  date: [2025-12-27],
  body,
)

= Introduction
<introduction>
This is an example document created using Quarto and a custom Typst template. The template defines the layout, fonts, and styling. We are currently using a two-column layout as defined in the YAML header (`cols: 2`).

== Text Formatting
<text-formatting>
I would also like to test out a biobliography so here are some random referneces @colemanNORTHERNGOSHAWKSAccIPITERGENTILlASTRICkAPILLUSWISTPHECIALREFERENCETOCROCKERBEDFOR1D990ANDKENNEDY19971998, @squiresAnthropogenicallyProtectedNaturally2024

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
#box(image("example2_files/figure-typst/fig-sine-1.svg"))
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
#box(image("example2_files/figure-typst/fig-hist-1.svg"))
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

#bibliography("references.bib")

