// ----------------------------------------------------------------------
// MINIMAL DEBUG TEMPLATE
// ----------------------------------------------------------------------

// Keep your definitions at the top
#let fa-info() = [ℹ]
#let callout(..args) = block(fill: gray.lighten(50%), inset: 1em, args.pos().last())

#let project(
  title: "",
  authors: (),
  date: none,
  abstract: none,
  body-font: "Inter",
  header-font: "Space Grotesk",
  content // The content variable
) = {
  
  // Just set the basic font so we can read it
  set text(font: body-font, size: 11pt)
  
  // -------------------------------------------------------------
  // DEBUG SECTION
  // -------------------------------------------------------------
  [DEBUG MODE: START OF CONTENT]
  parbreak()
  
  // Force the content to render directly
  content

  parbreak()
  [DEBUG MODE: END OF CONTENT]
}

// ----------------------------------------------------------------------
// QUARTO SHOW RULE (Keep this exactly as is)
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
  doc, 
)
