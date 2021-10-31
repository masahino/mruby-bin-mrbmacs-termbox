module Mrbmacs
  class EditWindowTermbox < EditWindow
    def initialize(frame, buffer, left, top, width, height)
      $stderr.puts "EditWindowTermbox"
      @frame = frame
      @sci = Scintilla::ScintillaTermbox.new do |scn|
        code = scn['code']
        @frame.sci_notifications.delete_if { |n| n['code'] == code }
        @frame.sci_notifications.push(scn)
      end
      @buffer = buffer
      @x1 = left
      @y1 = top
      @x2 = left + width - 1
      @y2 = top + height - 1
      @width = width
      @height = height
      @sci.resize(@width, @height - 1)
      #      @sci.move_window(@y1, @x1)
      @sci.sci_set_codepage(Scintilla::SC_CP_UTF8)
      @sci.sci_set_mod_event_mask(Scintilla::SC_MOD_INSERTTEXT | Scintilla::SC_MOD_DELETETEXT)
      @sci.sci_set_caretstyle Scintilla::CARETSTYLE_BLOCK_AFTER | Scintilla::CARETSTYLE_OVERSTRIKE_BLOCK | Scintilla::CARETSTYLE_BLOCK
      init_margin_termbox

      @sci.sci_set_focus(true)
      set_buffer(buffer)
      @sci.refresh
      #      @mode_win = create_mode_win
    end

    def init_margin_termbox
      set_margin
      @sci.sci_set_margin_maskn(0, ~Scintilla::SC_MASK_FOLDERS)
      @sci.sci_set_margin_widthn(1, 1)
      @sci.sci_set_margin_typen(1, 0)
    end
    def set_theme(theme)
      set_theme_base(theme)
      @sci.sci_set_fold_margin_colour(true, theme.background_color)
      @sci.sci_set_fold_margin_hicolour(true, theme.foreground_color)
      for n in 25..31
        @sci.sci_marker_set_fore(n, theme.foreground_color)
        @sci.sci_marker_set_back(n, theme.background_color)
      end
    end
  end
end