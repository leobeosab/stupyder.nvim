rockspec_format = '3.0'
package = 'stupyder.nvim'
version = 'scm-1'

test_dependencies = {
  'lua >= 5.1',
  'nlua',
  'busted'
}

source = {
  url = 'git://github.com/leobeosab/' .. package,
}

build = {
  type = 'builtin',
}
