# A New Beginning

A small NES-style romance visual novel prototype written in 6502 assembly.

## Requirements

- cc65 (`ca65` and `ld65`)
- GNU Make
- NES emulator such as Mesen, FCEUX, or Nestopia

## Build

```sh
make
```

The ROM is written to `build/a-new-beginning.nes`.

## Controls

- **A**: advance dialogue / confirm
- **B**: return to the title
- **Left/Right**: select a choice
- **Start**: advance / confirm

This prototype includes the opening, Maya and Sophia routes, a secret route, relationship counters, and four ending states. The bundled CHR area is intentionally a blank placeholder; replace the `CHARS` segment in `src/main.s` with an 8 KB font or tileset for visible text graphics.

All characters are adults. Romantic content is non-explicit.
