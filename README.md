# mruby-bin-mrbmacs-termbox

mrbmacs-termbox is a lightweight text editor with an Emacs-like interface. It adopts the Scintilla framework for efficient code editing and enhanced syntax highlighting, augmented by the customizability of mruby scripting extensions.

![mrbmacs-termbox](https://user-images.githubusercontent.com/381912/141677899-5cb7041d-0b92-44ab-a727-fddee4565c70.png "mrbmacs-termbox")

## Requirements

+ [Scintilla](https://www.scintilla.org)
+ [Termbox-next](https://github.com/masahino/termbox_next)
+ mrbgems
  + [mattn/mruby-require](https://github.com/mattn/mruby-require)
  + [mattn/mruby-iconv](https://github.com/mattn/mruby-iconv/)
  + [mattn/mruby-onig-regexp](https://github.com/mattn/mruby-onig-regexp/)
  + [mruby-termbox](https://github.com/masahino/mruby-termbox)
  + [masahino/mruby-scintilla-base](https://github.com/masahino/mruby-scintilla-base/)
  + [masahino/mruby-scintilla-termbox](https://github.com/masahino/mruby-scintilla-termbox/)
  + [masahino/mruby-mrbmacs-base](https://github.com/masahino/mruby-mrbmacs-base/)
    + [mruby-tiny-opt-parser](https://github.com/katzer/mruby-tiny-opt-parser)
    + [mruby-dir](https://github.com/iij/mruby-dir/)
    + [mruby-env](https://github.com/iij/mruby-env/)
    + [mruby-logger](https://github.com/katzer/mruby-logger)
    + [mruby-process2](https://github.com/katzer/mruby-process/)
    + [mruby-singleton](https://github.com/ksss/mruby-singleton/)
  + [masahino/mruby-mrbmacs-themes-base16](https://github.com/masahino/mruby-mrbmacs-themes-base16/) (optional)
  + [masahino/mruby-mrbmacs-lsp](https://github.com/masahino/mruby-mrbmacs-lsp/) (optional)
    + [masahino/mruby-lsp-client](https://github.com/masahino/mruby-lsp-client/)
  + [masahino/mruby-mrbmacs-dap](https://github.com/masahino/mruby-mrbmacs-dap/) (optional)
    + [masahino/mruby-dap-client](https://github.com/masahino/mruby-dap-client/)

## Build

```
$ git clone https://github.com/masahino/mruby-bin-mrbmacs-termbox
$ cd mruby-bin-mrbmacs-termbox
$ ./build.sh
```
