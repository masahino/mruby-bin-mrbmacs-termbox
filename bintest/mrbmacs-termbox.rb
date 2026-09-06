require 'open3'
require 'fileutils'
require 'timeout'
require 'pty'
require 'io/console'

$script_dir = "#{File.dirname(__FILE__)}/scripts/"
$capture_file = "#{File.dirname(__FILE__)}/.capture"

# mrbmacs-termbox opens /dev/tty and reads the terminal size during startup
# (tb_init), so it needs a real, sized terminal. A plain pipe (Open3) makes
# tb_init fail; an unsized CI PTY makes it come up 0x0. Run it under a PTY with
# an explicit winsize instead.
def termbox_run(args, timeout: 20)
  output = +''
  status = nil
  PTY.spawn("#{cmd('mrbmacs-termbox')} #{args}") do |r, w, pid|
    w.winsize = [40, 120] rescue nil
    begin
      Timeout.timeout(timeout) { loop { output << r.readpartial(4096) } }
    rescue Errno::EIO, EOFError
      # child exited and closed the pty - expected
    rescue Timeout::Error
      Process.kill('KILL', pid) rescue nil
    end
    _pid, status = Process.wait2(pid) rescue [nil, nil]
  end
  [output, status]
end

# Assert the run exited cleanly; on failure show the signal/status and the
# tail of the merged PTY output so CI logs are actionable.
def assert_run_ok(status, output)
  ok = status.is_a?(Process::Status) && status.exitstatus == 0
  assert_true ok,
              "mrbmacs-termbox did not exit cleanly: #{status.inspect}\n" \
              "--- last output ---\n#{output.to_s[-1000..] || output}"
end

# Run a -l script that reports lines through ENV['MRBMACS_BINTEST_OUT'].
# The PTY merges stdout/stderr with termbox's escape output, so scripts write
# their assertions to a file instead.
def termbox_capture(script)
  File.delete($capture_file) if File.exist?($capture_file)
  ENV['MRBMACS_BINTEST_OUT'] = $capture_file
  output, status = termbox_run("-q -l #{$script_dir}#{script}")
  assert_run_ok(status, output)
  File.exist?($capture_file) ? File.read($capture_file).split("\n") : []
end

assert('report the generated frontend version') do
  version_file = File.join(
    ENV.fetch('BUILD_DIR'), 'mrbgems', GEMNAME, 'version.txt'
  )
  expected_version = File.read(version_file).strip
  stdout, stderr, status = Open3.capture3(
    "#{cmd('mrbmacs-termbox')} --version"
  )

  assert_equal 0, status.to_i
  assert_equal '', stderr
  assert_equal expected_version, stdout.strip
end

assert('init buffer') do
  lines = termbox_capture('init_buffer')
  assert_equal '*scratch*', lines[0]
end

assert('split window') do
  lines = termbox_capture('split_window')
  assert_equal [], lines
end

assert('split window 2') do
  lines = termbox_capture('split_window2')
  assert_equal '*scratch*', lines[0]
  assert_equal '*scratch*', lines[1]
end

def run_edit_test(test_name, input_file = 'test.input')
  edit_file = "#{File.dirname(__FILE__)}/#{test_name}.input"
  output_file = "#{$script_dir}#{test_name}.output"
  FileUtils.cp "#{File.dirname(__FILE__)}/#{input_file}", edit_file
  output, status = termbox_run("-q -l #{$script_dir}#{test_name} #{edit_file}")
  assert_run_ok(status, output)
  assert_equal File.read(output_file), File.read(edit_file)
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
