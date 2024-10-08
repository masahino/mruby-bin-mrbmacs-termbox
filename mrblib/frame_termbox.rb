# Mrbmacs
module Mrbmacs
  # Frame class for termbox
  class Frame
    TERMBOX_KEYMAP = {
      Termbox::KEY_CTRL_A => 'C-a',
      Termbox::KEY_CTRL_B => 'C-b',
      Termbox::KEY_CTRL_C => 'C-c',
      Termbox::KEY_CTRL_D => 'C-d',
      Termbox::KEY_CTRL_E => 'C-e',
      Termbox::KEY_CTRL_F => 'C-f',
      Termbox::KEY_CTRL_G => 'C-g',
      # Termbox::KEY_CTRL_H => 'C-h',
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
      Termbox::KEY_SPACE => ' ',
      Termbox::KEY_TAB => 'Tab',
      Termbox::KEY_ENTER => 'Enter',
      Termbox::KEY_ESC => 'Escape',
      Termbox::KEY_CTRL_BACKSLASH => 'C-\\',
      Termbox::KEY_CTRL_SLASH => 'C-/',
      Termbox::KEY_CTRL_UNDERSCORE => 'C-_',
      Termbox::KEY_F1 => 'F1',
      Termbox::KEY_F2 => 'F2',
      Termbox::KEY_F3 => 'F3',
      Termbox::KEY_F4 => 'F4',
      Termbox::KEY_F5 => 'F5',
      Termbox::KEY_F6 => 'F6',
      Termbox::KEY_F7 => 'F7',
      Termbox::KEY_F8 => 'F8',
      Termbox::KEY_F9 => 'F9',
      Termbox::KEY_F10 => 'F10',
      Termbox::KEY_F11 => 'F11',
      Termbox::KEY_F12 => 'F12'
    }.freeze

    TERMBOX_KEYSYMS = {
      Termbox::KEY_INSERT => Scintilla::SCK_INSERT,
      Termbox::KEY_DELETE => Scintilla::SCK_DELETE,
      Termbox::KEY_HOME => Scintilla::SCK_HOME,
      Termbox::KEY_END => Scintilla::SCK_END,
      Termbox::KEY_ARROW_UP => Scintilla::SCK_UP,
      Termbox::KEY_ARROW_DOWN => Scintilla::SCK_DOWN,
      Termbox::KEY_ARROW_LEFT => Scintilla::SCK_LEFT,
      Termbox::KEY_ARROW_RIGHT => Scintilla::SCK_RIGHT,
      Termbox::KEY_BACKSPACE => Scintilla::SCK_BACK,
      Termbox::KEY_TAB => Scintilla::SCK_TAB,
      Termbox::KEY_ENTER => Scintilla::SCK_RETURN,
      Termbox::KEY_SPACE => 32,
      Termbox::KEY_BACKSPACE2 => Scintilla::SCK_BACK,
      Termbox::KEY_MOUSE_LEFT => 1,
      Termbox::KEY_MOUSE_MIDDLE => 2,
      Termbox::KEY_MOUSE_RIGHT => 3,
      Termbox::KEY_MOUSE_WHEEL_UP => 4,
      Termbox::KEY_MOUSE_WHEEL_DOWN => 5
    }.freeze

    def initialize(buffer)
      Termbox.init
      Termbox.select_output_mode(Termbox::OUTPUT_TRUECOLOR)
      Termbox.select_input_mode(Termbox::INPUT_ESC | Termbox::INPUT_MOUSE)
      Termbox.set_cursor(Termbox::HIDE_CURSOR, Termbox::HIDE_CURSOR)
      @width = Termbox.width
      @height = Termbox.height
      @sci_notifications = []
      @edit_win = EditWindowTermbox.new(self, buffer, 0, 0, Termbox.width, Termbox.height - 1)
      @view_win = @edit_win.sci
      @echo_win = new_echowin
      @edit_win_list = [@edit_win]
      @view_win.refresh
    end

    def new_editwin(buffer, left, top, width, height)
      EditWindowTermbox.new(self, buffer, left, top, width, height)
    end

    def send_mouse(event, win)
      tmp_win = get_edit_win_from_pos(event.y, event.x)
      return if tmp_win.nil?

      if tmp_win.sci != win && win != @echo_win
        switch_window(tmp_win)
        win = tmp_win.sci
      end
      mouse_event = determine_mouse_event(event)
      c = TERMBOX_KEYSYMS.fetch(event.key, 0)
      win.send_mouse(mouse_event, c, event.y, event.x, false, false, false)
    end

    def determine_mouse_event(event)
      return Scintilla::SCM_DRAG if event.mod == Termbox::MOD_MOTION
      return Scintilla::SCM_RELEASE if event.key == Termbox::KEY_MOUSE_RELEASE

      Scintilla::SCM_PRESS
    end

    def send_key(event, win = nil)
      win = @view_win if win.nil?
      case event.type
      when Termbox::EVENT_KEY
        ctrl = false
        c = event.ch.ord
        if strfkey(event)[0..1] == 'C-'
          ctrl = true
          c = strfkey(event)[2].ord
        end
        c = TERMBOX_KEYSYMS[event.key] if TERMBOX_KEYSYMS.key? event.key
        win.send_key(c, false, ctrl, false) if c != 0
      when Termbox::EVENT_MOUSE
        send_mouse(event, win)
      end
    end

    def waitkey(_win = nil)
      [nil, Termbox.poll_event]
    end

    def strfkey(event)
      return TERMBOX_KEYMAP[event.key] if TERMBOX_KEYMAP.key?(event.key)

      key_str = if event.mod == Termbox::MOD_ALT
                  'M-'
                else
                  ''
                end
      if event.key.zero? && event.ch == 0.chr
        key_str += 'C- '
      else
        key_str += event.ch
      end
      key_str
    end

    def modeline(app, win = @edit_win)
      mode_str = get_mode_str(app)
      if mode_str.length < win.width - 1
        mode_str += '-' * (win.width - mode_str.length)
      else
        mode_str = mode_str[0, win.width - 1]
      end
      win.mode_win.update(mode_str)
      win.refresh_modeline
    end

    def modeline_refresh(_app)
      @edit_win_list.map(&:refresh_modeline)
    end

    def exit
      Termbox.shutdown
    end

    def select_buffer(default_buffername, buffer_list)
      echo_text = "Switch to buffer: (default #{default_buffername}) "
      echo_gets(echo_text, '') do |input_text|
        list = buffer_list.select { |b| b[0, input_text.length] == input_text }
        [list.join(@echo_win.sci_autoc_get_separator.chr), input_text.length]
      end
    end

    def delete_other_window
      @edit_win_list.each do |w|
        if w != @edit_win
          w.sci.sci_add_refdocument(w.buffer.docpointer)
          w.delete
        end
      end
      @edit_win_list.delete_if { |w| w != @edit_win }
      @edit_win.x1 = 0
      @edit_win.x2 = Termbox.width - 1
      @edit_win.y1 = 0
      @edit_win.y2 = Termbox.height - 1 - 1
      @edit_win.compute_area
      @edit_win.refresh
    end

    def extend_width(new_width)
      @edit_win_list.each do |win|
        if win.x2 == @width - 1
          win.x2 = new_width - 1
          win.compute_area
        end
      end
    end

    def extend_height(new_height)
      @edit_win_list.each do |win|
        if win.y2 == @height - 1 - 1
          win.y2 = new_height - 1 - 1
          win.compute_area
        end
      end
    end

    def shorten_width(new_width)
      @edit_win_list.each do |win|
        if win.x1 < new_width - 1 && new_width - 1 < win.x2
          win.x2 = new_width - 1
          win.compute_area
        end
      end
    end

    def shorten_height(new_height)
      @edit_win_list.each do |win|
        if win.y1 < new_height - 1 - 1 && new_height - 1 - 1 < win.y2
          win.y2 = new_height - 1 - 1
          win.compute_area
        end
      end
    end

    def delete_too_small_window(new_width, new_height)
      @edit_win_list.each do |win|
        delete_window(win) if new_width - 1 < win.x1
        delete_window(win) if new_height - 1 - 1 < win.y1
      end
    end

    def resize_terminal(new_width, new_height)
      if @edit_win_list.size == 1
        @edit_win.x2 = new_width - 1
        @edit_win.y2 = new_height - 1 - 1
        @edit_win.compute_area
        @edit_win.refresh
      else
        delete_too_small_window(new_width, new_height) if new_width < @width || new_height < @height
        if new_width > @width
          extend_width(new_width)
        elsif new_width < @width
          shorten_width(new_width)
        end
        if new_height > @height
          extend_height(new_height)
        elsif new_height < @height
          shorten_height(new_height)
        end
      end
      @width = new_width
      @height = new_height
      refresh_all
    end
  end
end
