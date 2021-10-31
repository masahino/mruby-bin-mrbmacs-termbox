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
  assert_equal 'C-a', Mrbmacs.strfkey(Keytest.new(Termbox::EVENT_KEY, 0, Termbox::KEY_CTRL_A, 0))
  assert_equal 'a', Mrbmacs.strfkey(Keytest.new(Termbox::EVENT_KEY, 0, 0, 'a'))
  assert_equal 'M-a', Mrbmacs.strfkey(Keytest.new(Termbox::EVENT_KEY, Termbox::MOD_ALT, 0, 'a'))
end