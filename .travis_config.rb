class MRuby::Build
  # mruby 3.3+ splits core objects into libmruby_core.a, but gem binaries
  # in this project still expect both archives to be linked.
  def libraries
    [libmruby_static, libmruby_core_static]
  end
end

MRuby::Build.new do |conf|
  # Gets set by the VS command prompts.
  if ENV['VisualStudioVersion'] || ENV['VSINSTALLDIR']
    conf.toolchain :visualcpp
  else
    conf.toolchain :gcc
  end
  conf.enable_debug

  # conf.cc.defines << %w[MRB_USE_ALL_SYMBOLS]
  conf.cc.defines << %w[MRB_UTF8_STRING]

  conf.gembox 'default'
#  conf.gem "#{MRUBY_ROOT}/mrbgems/mruby-exit"
  conf.gem github: 'mattn/mruby-iconv' do |g|
    g.linker.libraries.delete 'iconv' if RUBY_PLATFORM.include?('linux')
    g.skip_test = true
  end

  conf.gem github: 'masahino/mruby-mrbmacs-lsp'
  conf.gem github: 'masahino/mruby-lsp-client' do |g|
    g.skip_test = true
  end
  conf.gem github: 'katzer/mruby-process' do |g|
    g.skip_test = true
  end
  conf.gem github: 'iij/mruby-regexp-pcre' do |g|
    g.skip_test = true
  end
  conf.gem github: 'ksss/mruby-file-stat' do |g|
    g.skip_test = true
  end

  # additional themes
  # conf.gem github: 'masahino/mruby-mrbmacs-themes-base16'
  # conf.gem github: 'masahino/mruby-mrbmacs-themes-tomorrow', branch: 'main'

  conf.gem "#{MRUBY_ROOT}/.." do |g|
#   g.linker.libraries << 'stdc++'
  end

  conf.enable_bintest
  conf.enable_test

  if ENV['DEBUG'] == 'true'
    conf.gem github: 'masahino/mruby-debug'
  end
end
