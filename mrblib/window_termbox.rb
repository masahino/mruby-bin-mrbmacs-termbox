module Mrbmacs
  class EditWindowTermbox < EditWindow
    def initialize(frame, buffer, left, top, width, height)
      super(frame, buffer, left, top, width, height)
      @sci = Scintilla::ScintillaTermbox.new do |scn|
        code = scn['code']
        @frame.sci_notifications.delete_if { |n| n['code'] == code }
        @frame.sci_notifications.push(scn)
      end

      compute_area
      init_sci_default
      init_margin_termbox
      set_buffer(buffer)

      @sci.sci_set_focus(true)
      @sci.refresh
    end

    def init_margin_termbox
      set_margin
      @sci.sci_set_margin_maskn(0, ~Scintilla::SC_MASK_FOLDERS)
      @sci.sci_set_margin_widthn(1, 2)
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

    def compute_area
      @width = @x2 - @x1 + 1
      @height = @y2 - @y1 + 1
      @sci.move(@x1, @y1)
      @sci.resize(@width, @height - 1)
    end
  end
end
