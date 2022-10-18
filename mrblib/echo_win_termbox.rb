module Mrbmacs
  # Frame class for Termbox
  class Frame
    def new_echowin
      echo_win = ScintillaTermbox.new
      echo_win.sci_set_vscrollbar(false)
      echo_win.resize(Termbox.width, 1)
      echo_win.move(0, Termbox.height - 1)
      echo_win.sci_style_set_fore(Scintilla::STYLE_DEFAULT, 0xffffff)
      echo_win.sci_style_set_back(Scintilla::STYLE_DEFAULT, 0x000000)
      echo_style_base(echo_win)
      echo_win.refresh
      echo_win
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

      loop do
        _ret, ev = waitkey
        key_str = strfkey(ev)
        if key_str == 'C-g'
          @echo_win.sci_clear_all
          @echo_win.sci_add_text('Quit')
          input_text = nil
          break
        end
        case ev.key
        when Termbox::KEY_ENTER, Termbox::KEY_INSERT
          if !@echo_win.sci_autoc_active
            @echo_win.sci_autoc_cancel
            input_text = @echo_win.sci_get_line(0)
            break
          else
            send_key(ev, @echo_win)
          end
        when Termbox::KEY_TAB
          input_text = @echo_win.sci_get_line(0)
          if !@echo_win.sci_autoc_active
            unless block.nil?
              @echo_win.sci_autoc_cancel
              refresh_all
              comp_list, len = block.call(input_text)
              @echo_win.sci_autoc_show(len, comp_list)
            end
          else
            @echo_win.sci_autoc_cancel
            refresh_all
            comp_list, len = block.call(input_text)
            common_str = Mrbmacs.common_str(comp_list.split(@echo_win.sci_autoc_get_separator.chr))
            unless common_str.nil?
              @echo_win.sci_autoc_cancel
              @echo_win.sci_add_text(common_str[len..].bytesize, common_str[len..])
              @echo_win.refresh
              len = common_str.length
            end
            @echo_win.sci_autoc_show(len, comp_list)
          end
        else
          send_key(ev, @echo_win)
        end
        echo_set_prompt(prompt) if @echo_win.sci_margin_get_text(0) == ''
        @echo_win.refresh
      end
      @echo_win.sci_clear_all
      @echo_win.sci_set_focus(false)
      @echo_win.refresh
      @view_win.sci_set_focus(true)
      refresh_all
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
      @echo_win.sci_add_text(text.bytesize, text) unless text.nil?
      @echo_win.refresh
    end

    def y_or_n(prompt)
      @echo_win.sci_clear_all
      echo_set_prompt(prompt)
      _ret, ev = waitkey
      key_str = strfkey(ev)
      echo_set_prompt('')
      case key_str
      when 'Y', 'y'
        true
      when 'C-g'
        false
      else
        false
      end
    end
  end
end
