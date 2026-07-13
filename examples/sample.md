# Markgraf sample note

Drop this note into a vault with the Markgraf plugin enabled and switch to
Reading view (or Live Preview) to see the fence below render as a live,
scrubbable animation.

```markgraf
seed 1

scene "a request arrives" {
  + browser: Browser
  + server: Server
  + browser -> server

  browser ~> server: GET /
}

scene "the server answers" {
  + db: Database
  + server -> db

  server ~> db: query
  server <~ db: rows
  browser <~ server: 200 OK
}
```
