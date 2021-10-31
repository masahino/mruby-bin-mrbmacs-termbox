module Mrbmacs
  TERMBOX_KEYMAP = {
    Termbox::KEY_CTRL_A => 'C-a',
    Termbox::KEY_CTRL_B => 'C-b',
    Termbox::KEY_CTRL_C => 'C-c',
    Termbox::KEY_CTRL_D => 'C-d',
    Termbox::KEY_CTRL_E => 'C-e',
    Termbox::KEY_CTRL_F => 'C-f',
    Termbox::KEY_CTRL_G => 'C-g',
    Termbox::KEY_CTRL_H => 'C-h',
    Termbox::KEY_CTRL_I => 'C-i',
    Termbox::KEY_CTRL_J => 'C-j',
    Termbox::KEY_CTRL_K => 'C-k',
    Termbox::KEY_CTRL_L => 'C-l',
    Termbox::KEY_CTRL_M => 'C-m',
    Termbox::KEY_CTRL_N => 'C-n',
    Termbox::KEY_CTRL_O => 'C-o',
    Termbox::KEY_CTRL_P => 'C-p',
    Termbox::KEY_CTRL_Q => 'C-q',
    Termbox::KEY_CTRL_R => 'C-r',
    Termbox::KEY_CTRL_S => 'C-s',
    Termbox::KEY_CTRL_T => 'C-t',
    Termbox::KEY_CTRL_U => 'C-u',
    Termbox::KEY_CTRL_V => 'C-v',
    Termbox::KEY_CTRL_W => 'C-w',
    Termbox::KEY_CTRL_X => 'C-x',
    Termbox::KEY_CTRL_Y => 'C-y',
    Termbox::KEY_CTRL_Z => 'C-z',
    Termbox::KEY_CTRL_F => 'C-f',
    Termbox::KEY_TAB => 'Tab',
    Termbox::KEY_ENTER => 'Enter',
    Termbox::KEY_ESC => 'Escape',
    Termbox::KEY_CTRL_BACKSLASH => 'C-\\',
    Termbox::KEY_CTRL_SLASH => 'C-/',
    Termbox::KEY_CTRL_UNDERSCORE => 'C-_'
  }
  def self.strfkey(ev)
    key_str = ''
    if TERMBOX_KEYMAP.key? ev.key
      key_str = TERMBOX_KEYMAP[ev.key]
    else
      if ev.mod == Termbox::MOD_ALT
        key_str = 'M-'
      end
      if ev.key == 0 && ev.ch == 0.chr
        key_str += 'C- '
      else
        key_str += ev.ch
      end
    end
    key_str
  end
end