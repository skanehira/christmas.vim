" christmas
" Author: skanehira
" License: MIT

if exists('loaded_christmas')
  finish
endif
let g:loaded_christmas = 1

command! ChristmasStart call christmas#start()
command! ChristmasEnd call christmas#end()
