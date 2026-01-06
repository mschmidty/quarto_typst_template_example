#show: body => report(
  title: [$title$],
  date: [$date$],
  authors: ($for(author)$[$author$], $endfor$),
  body,
)
