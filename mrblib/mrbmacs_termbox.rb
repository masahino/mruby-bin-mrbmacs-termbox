module Mrbmacs
  class ApplicationTermbox < Application
    def add_buffer_to_frame(buffer) end

    def doscan(prefix = '')
      ev = @frame.waitkey
      key_str = prefix + Mrbmacs.strfkey(ev)
      key_str.gsub!(/^Escape /, 'M-')
$stderr.puts key_str
      command = key_scan(key_str)
$stderr.puts command
      if command != nil
        if command.is_a?(Integer)
          return @frame.view_win.send_message(command, nil, nil)
        end
        if command == 'prefix'
          return doscan(key_str + ' ')
        else
          return extend(command)
        end
      end
      @frame.send_key(ev)
    end

    def editloop
      add_io_read_event(STDIN) { |app, io| doscan }
      @frame.view_win.refresh
      loop do
        # notification event
        while @frame.sci_notifications.length > 0
          e = @frame.sci_notifications.shift
          if $DEBUG
            $stderr.puts e['code']
          end
          call_sci_event(e)
        end
        @frame.view_win.refresh
        # set cursor pos for IME
        current_pos = @frame.view_win.sci_get_current_pos
        x = @frame.view_win.sci_point_x_from_position(0, current_pos)
        y = @frame.view_win.sci_point_y_from_position(0, current_pos)
#        @frame.view_win.setpos(y, x)

        # IO event
        readable, _writable = IO.select(@readings)
        readable.each do |ri|
          if @io_handler[ri] != nil
            begin
              @io_handler[ri].call(self, ri)
            rescue => e
              @logger.error e.to_s
              @logger.error e.backtrace
              @frame.echo_puts(e.to_s)
            end
          end
        end

        @frame.view_win.refresh
        @frame.modeline(self)
      end
    end

    def editloop_old
      @frame.view_win.refresh
      loop do
        doscan('')
        @frame.modeline(self)
        @frame.view_win.refresh
      end
    end
  end
end
