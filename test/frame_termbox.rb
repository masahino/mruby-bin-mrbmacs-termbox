class Keytest
  attr_accessor :type, :mod, :key, :ch
  def initialize(type, mod, key, ch)
    @type = type
    @mod = mod
    @key = key
    @ch = ch
  end
end

assert('strfkey') do
  # strfkey only reads the event and the TERMBOX_KEYMAP constant, so test it on
  # a bare instance. Mrbmacs::Frame.new would call Termbox.init (opens /dev/tty),
  # which is neither needed here nor available on a headless CI runner.
  frame = Mrbmacs::Frame.allocate
  assert_equal 'C-a', frame.strfkey(Keytest.new(Termbox::EVENT_KEY, 0, Termbox::KEY_CTRL_A, 0))
  assert_equal 'a', frame.strfkey(Keytest.new(Termbox::EVENT_KEY, 0, 0, 'a'))
  assert_equal 'M-a', frame.strfkey(Keytest.new(Termbox::EVENT_KEY, Termbox::MOD_ALT, 0, 'a'))
end
