MRuby::Gem::Specification.new('mruby-bin-mrbmacs-termbox') do |spec|
  spec.license = 'MIT'
  spec.author  = 'masahino'
  spec.version = '0.9.0'
  spec.add_dependency 'mruby-mrbmacs-base', github: 'masahino/mruby-mrbmacs-base'
  spec.add_dependency 'mruby-iconv'
  spec.add_dependency 'mruby-termbox', github: 'masahino/mruby-termbox'
  spec.add_dependency 'mruby-scintilla-termbox', github: 'masahino/mruby-scintilla-termbox', branch: 'main'
  spec.add_test_dependency 'mruby-require'
  spec.bins = %w[mrbmacs-termbox]
end
