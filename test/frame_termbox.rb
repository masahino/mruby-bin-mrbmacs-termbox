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
  frame = Mrbmacs::Frame.new(Mrbmacs::Buffer.new)
  assert_equal 'C-a', frame.strfkey(Keytest.new(Termbox::EVENT_KEY, 0, Termbox::KEY_CTRL_A, 0))
  assert_equal 'a', frmae.strfkey(Keytest.new(Termbox::EVENT_KEY, 0, 0, 'a'))
  assert_equal 'M-a', frame.strfkey(Keytest.new(Termbox::EVENT_KEY, Termbox::MOD_ALT, 0, 'a'))
  frame.exit
end
