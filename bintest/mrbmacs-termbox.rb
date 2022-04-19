require 'open3'
require 'fileutils'
require 'timeout'

assert('init buffer') do
  skip '/dev/tty is not found' unless File.exist?('/dev/tty')
  _stdout, stderr, status =
    Open3.capture3("#{cmd('mrbmacs-termbox')} -l #{File.dirname(__FILE__)}/scripts/init_buffer")
  assert_equal 0, status.to_i
  lines = stderr.split("\n")
  assert_equal '*scratch*', lines[0]
end

assert('split window') do
  skip '/dev/tty is not found' unless File.exist?('/dev/tty')
  _stdout, stderr, status =
    Open3.capture3("#{cmd('mrbmacs-termbox')} -q -l #{File.dirname(__FILE__)}/scripts/split_window")
  assert_equal 0, status.to_i
  assert_equal 0, stderr.length
end

assert('split window') do
  skip '/dev/tty is not found' unless File.exist?('/dev/tty')
  _stdout, stderr, status =
    Open3.capture3("#{cmd('mrbmacs-termbox')} -q -l #{File.dirname(__FILE__)}/scripts/split_window2")
  assert_equal 0, status.to_i
  lines = stderr.split("\n")
  assert_equal '*scratch*', lines[0]
  assert_equal '*scratch*', lines[1]
end

def run_edit_test(test_name, input_file = 'test.input')
  skip '/dev/tty is not found' unless File.exist?('/dev/tty')

  edit_file = File.dirname(__FILE__) + "/#{test_name}.input"
  output_file = "#{File.dirname(__FILE__)}/scripts/#{test_name}.output"
  FileUtils.cp "#{File.dirname(__FILE__)}/#{input_file}", edit_file
  Timeout.timeout(10) do
    _stdout, _stderr, _status =
      Open3.capture3("#{cmd('mrbmacs-termbox')} -q -l #{File.dirname(__FILE__)}/scripts/#{test_name} #{edit_file}")
  end
  expected_text = File.open(output_file, 'r').read
  actual_text = File.open(edit_file, 'r').read
  #  assert_true FileUtils.cmp(edit_file, output_file)
  assert_equal expected_text, actual_text
  File.delete edit_file
end

assert('beginning-of-buffer') do
  run_edit_test('beginning-of-buffer')
end

assert('beginning-of-line') do
  run_edit_test('beginning-of-line')
end

assert('clear-rectangle') do
  run_edit_test('clear-rectangle')
end

assert('copy-region') do
  run_edit_test('copy-region')
end

assert('cut-region') do
  run_edit_test('cut-region')
end

assert('delete-rectangle') do
  run_edit_test('delete-rectangle')
end

assert('end-of-buffer') do
  run_edit_test('end-of-buffer')
end

assert('end-of-line') do
  run_edit_test('end-of-line')
end

assert('find-file') do
  run_edit_test('find-file')
end

assert('insert-file') do
  run_edit_test('insert-file')
end

assert('kill-buffer') do
  run_edit_test('kill-buffer')
end

assert('kill-line') do
  run_edit_test('kill-line')
end

assert('newline') do
  run_edit_test('newline')
end

assert('set-mark') do
  run_edit_test('set-mark')
end

assert('switch-to-buffer') do
  run_edit_test('switch-to-buffer')
end

assert('yank') do
  run_edit_test('yank')
end

assert('comment-line') do
  run_edit_test('comment-line', 'test2.input')
end

##########
assert('isearch-backward') do
end

assert('isearch-forward') do
end
