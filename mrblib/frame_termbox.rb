module Mrbmacs
  def self.common_str(comp_list)
    max_len = comp_list.map { |i| i.length }.sort[0]
    (1..max_len).reverse_each do |i|
      if comp_list.map { |f| f[0..i] }.sort.uniq.size == 1
        return comp_list[0][0..i]
      end
    end
    nil
  end

  class Frame
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
      Termbox::KEY_BACKSPACE2 => Scintilla::SCK_BACK
    }
    def initialize(buffer)
      Termbox.init
      Termbox.select_output_mode(5)
      @sci_notifications = []
      @edit_win = EditWindowTermbox.new(self, buffer, 0, 0, Termbox.width, Termbox.height - 1)
      @view_win = @edit_win.sci
      @echo_win = new_echowin
      @edit_win_list = [@edit_win]
      @view_win.refresh
$stderr.puts "frame end"
    end

    def new_echowin
      echo_win = ScintillaTermbox.new
      echo_win.resize(Termbox.width, 1)
      echo_win.move(0, Termbox.height - 1)
      echo_win.sci_style_set_fore(Scintilla::STYLE_DEFAULT, 0xffffff)
      echo_win.sci_style_set_back(Scintilla::STYLE_DEFAULT, 0x000000)
      echo_win.sci_style_clear_all
      echo_win.sci_set_focus(false)
      echo_win.sci_autoc_set_choose_single(1)
      echo_win.sci_autoc_set_auto_hide(false)
      echo_win.sci_set_margin_typen(3, 4)
      echo_win.sci_set_caretstyle Scintilla::CARETSTYLE_BLOCK_AFTER | Scintilla::CARETSTYLE_OVERSTRIKE_BLOCK | Scintilla::CARETSTYLE_BLOCK
      echo_win.sci_set_wrap_mode(Scintilla::SC_WRAP_CHAR)
#      echo_win.sci_autoc_set_max_height(16)
      echo_win.refresh
      echo_win
    end

    def send_key(ev, win = nil)
      win = @view_win if win.nil?
      c = ev.ch.ord
      if TERMBOX_KEYSYMS.key? ev.key
        c = TERMBOX_KEYSYMS[ev.key]
      end
      win.send_key(c, false, false, false)
    end

    def modeline(app)
      mode_str = get_mode_str(app)
      if mode_str.length < @edit_win.width - 1
        mode_str += '-' * (@edit_win.width - mode_str.length - 1)
      else
        mode_str[@edit_win.width - 1] = ' '
      end
$stderr.puts mode_str
      (0..(mode_str.length - 1)).each do |x|
        Termbox.change_cell(@edit_win.x1 + x, @edit_win.y2,
                            Termbox.utf8_char_to_unicode(mode_str[x]), 0x000000, 0xffffff)
      end
    end

    def waitkey
      while ev = Termbox.poll_event
        if ev.type == Termbox::EVENT_KEY
          return ev
        end
      end
    end

    def echo_gets(prompt, text = '', &block)
      @view_win.sci_set_focus(false)
      @view_win.refresh
      @echo_win.sci_set_focus(true)
      @echo_win.sci_clear_all
      echo_set_prompt(prompt)
      prefix_text = text
      @echo_win.sci_add_text(prefix_text.bytesize, prefix_text)
      @echo_win.refresh
      input_text = nil
      last_input = nil
      while true
        ev = waitkey
        key_str = Mrbmacs.strfkey(ev)
        if key_str == 'C-g'
          @echo_win.sci_clear_all
          @echo_win.sci_add_text('Quit')
          input_text = nil
          break
        end
        case ev.key
        when Termbox::KEY_ENTER, Termbox::KEY_INSERT
          if @echo_win.sci_autoc_active == 0
            @echo_win.sci_autoc_cancel
            input_text = @echo_win.sci_get_line(0)
            break
          else
            send_key(ev, @echo_win)
          end
        when Termbox::KEY_TAB
          input_text = @echo_win.sci_get_line(0)
          if @echo_win.sci_autoc_active == 0
            if block != nil
              @echo_win.sci_autoc_cancel
              @view_win.refresh
              comp_list, len = block.call(input_text)
              @echo_win.sci_autoc_show(len, comp_list)
            end
          else
            @echo_win.sci_autoc_cancel
            @view_win.refresh
            comp_list, len = block.call(input_text)
            common_str = Mrbmacs.common_str(comp_list.split(@echo_win.sci_autoc_get_separator.chr))
            if common_str != nil
              @echo_win.sci_autoc_cancel
              @echo_win.sci_add_text(common_str[len..-1].bytesize, common_str[len..-1])
              @echo_win.refresh
              len = common_str.length
            end
            @echo_win.sci_autoc_show(len, comp_list)

          end
        else
          send_key(ev, @echo_win)
        end
        if @echo_win.sci_margin_get_text(0) == ''
          echo_set_prompt(prompt)
        end
        @echo_win.refresh
      end
      @echo_win.sci_clear_all
      @echo_win.sci_set_focus(false)
      @echo_win.refresh
      @view_win.sci_set_focus(true)
      @view_win.refresh
      input_text
    end

    def echo_set_prompt(prompt)
      @echo_win.sci_set_margin_widthn(3, @echo_win.sci_text_width(Scintilla::STYLE_DEFAULT, prompt))
      @echo_win.sci_margin_set_text(0, prompt)
      @echo_win.refresh
    end

    def echo_puts(text)
      @echo_win.sci_clear_all
      echo_set_prompt('[Message]')
      if text != nil
        @echo_win.sci_add_text(text.bytesize, text)
      end
      @echo_win.refresh
    end

    def exit
      Termbox.shutdown
    end

    def select_buffer(default_buffername, buffer_list)
      echo_text = "Switch to buffer: (default #{default_buffername}) "
      buffername = echo_gets(echo_text, '') do |input_text|
        list = buffer_list.select { |b| b[0, input_text.length] == input_text }
        [list.join(' '), input_text.length]
      end
      buffername
    end
  end
end
