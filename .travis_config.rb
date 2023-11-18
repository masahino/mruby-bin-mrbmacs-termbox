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
  end

  conf.gem github: 'masahino/mruby-mrbmacs-lsp'
  conf.gem github: 'masahino/mruby-mrbmacs-dap', branch: 'main'

  # additional themes
  # conf.gem github: 'masahino/mruby-mrbmacs-themes-base16', branch: 'main'
  # conf.gem github: 'masahino/mruby-mrbmacs-themes-tomorrow', branch: 'main'

  conf.gem "#{MRUBY_ROOT}/.."
#  conf.linker.libraries << 'stdc++'

  conf.enable_bintest
  conf.enable_test

  if ENV['DEBUG'] == 'true'
    conf.gem github: 'masahino/mruby-debug', branch: 'main'
  end
end
