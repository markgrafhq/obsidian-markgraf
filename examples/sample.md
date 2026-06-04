# Markgraf sample note

Drop this note into a vault with the Markgraf plugin enabled and switch to
Reading view (or Live Preview) to see the fence below render as a live,
scrubbable animation.

```markgraf
seed 1

frame "a request arrives" {
  +node browser "Browser"
  +node server "Server"
  +edge browser server

  browser -> server "GET /"
}

frame "the server answers" {
  +node db "Database"
  +edge server db

  server -> db "query"
  server <- db "rows"
  browser <- server "200 OK"
}
```
