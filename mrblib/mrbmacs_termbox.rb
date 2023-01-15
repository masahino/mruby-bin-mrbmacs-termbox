module Mrbmacs
  # Application class for Termbox
  class ApplicationTermbox < ApplicationTerminal
    def add_buffer_to_frame(buffer) end

    def doscan(prefix = '')
      loop do
        ev = nil
        if prefix == ''
          ev = Termbox.peek_event(1)
        else
          ev = Termbox.poll_event
        end
        return if ev.nil?

        if ev.type == Termbox::EVENT_RESIZE
          @frame.resize_terminal(ev.w, ev.h)
          @current_buffer = @frame.edit_win.buffer
          return
        end

        key_str = @frame.strfkey(ev)
        add_recent_key(key_str)
        key_str = prefix + key_str
        key_str.gsub!(/^Escape /, 'M-')
        command = key_scan(key_str)
        if command != nil
          return @frame.view_win.send_message(command, nil, nil) if command.is_a?(Integer)
          return doscan("#{key_str} ") if command == 'prefix'

          extend(command)
        else
          @frame.send_key(ev)
          if @current_buffer.name != @frame.edit_win.buffer.name
            @current_buffer = @frame.edit_win.buffer
          end
        end
        prefix = ''
      end
    end

    def editloop
      add_io_read_event($stdin) { doscan }
      @frame.view_win.refresh
      loop do
        # notification event
        while @frame.sci_notifications.length > 0
          e = @frame.sci_notifications.shift
          @logger.debug "sci notification [#{e['code']}]"
          call_sci_event(e)
        end
        @frame.view_win.refresh
        # set cursor pos for IME
        # current_pos = @frame.view_win.sci_get_current_pos
        # x = @frame.view_win.sci_point_x_from_position(0, current_pos)
        # y = @frame.view_win.sci_point_y_from_position(0, current_pos)
        # @frame.view_win.setpos(y, x)

        # IO event
        readable, _writable = IO.select(@readings)
        readable.each do |ri|
          next if @io_handler[ri].nil?

          begin
            @io_handler[ri].call(self, ri)
          rescue => e
            @logger.error e.to_s
            @logger.error e.backtrace
            @frame.echo_puts(e.to_s)
          end
        end

        @frame.view_win.refresh
        @frame.modeline(self)
      end
    end
  end
end
