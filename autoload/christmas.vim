" christmas.vim
" Author: skanehira
" License: MIT

let s:snows = ['＋', '十', '＊', '*']
let s:snows_len = len(s:snows)
let s:snow_colors = [
      \ 226,
      \ 255,
      \ 129,
      \ 13,
      \ 1,
      \ ]
let s:snow_colors_len = len(s:snow_colors)
let s:snow_timers = []
let s:snow_windows = []
let s:state = 'stopped'

let s:tree = [
      \ '    +-----------------+    ',
      \ '    | Merry Christmas |    ',
      \ '    +-----------------+    ',
      \ '            |  |           ',
      \ '           ﾟ｡：｡ﾟ          ',
      \ '         ・‥☆‥・        ',
      \ '           ｡ﾟ▲ﾟ｡          ',
      \ '            ▲▲           ',
      \ '           ▲▲☆          ',
      \ '          ▲☆彡▲         ',
      \ '         ☆彡▲▲☆        ',
      \ '        彡▲▲☆∴▲       ',
      \ '       ▲▲☆∴▲▲☆      ',
      \ '      ▲☆∴▲▲☆彡▲     ',
      \ '     ☆∴▲▲☆彡▲▲☆    ',
      \ '    ▲▲▲☆彡▲▲☆∴▲   ',
      \ '         ＿_|＿|_＿        ',
      \ '         | | || | |        ',
      \ '         ----------        ',
      \ ]

function! s:new_snow(timer) abort
  let r = rand(srand())
  let text = s:snows[r%s:snows_len]
  let col = s:tree_window_pos.range[rand(srand())%s:tree_window_pos.range_len]
  let winid = popup_create(text, {
        \ 'col': col,
        \ 'line': s:tree_window_pos.line,
        \ 'minwidth': 1,
        \ 'zindex': 200,
        \ })

  call win_execute(winid, 'syntax match Snow /[＋十＊*]/')

  let timer = timer_start(60, function("s:move_snow_down", [winid]), {
        \ 'repeat': -1,
        \ })
  call add(s:snow_timers, timer)
  call add(s:snow_windows, winid)
endfunction

function! s:move_snow_down(winid, timer) abort
  let opt = popup_getpos(a:winid)
  if opt.line is# s:tree_window_pos.bottom
    call timer_stop(a:timer)
    call remove(s:snow_timers, index(s:snow_timers, a:timer))
    call popup_close(a:winid)
    return
  endif

  let opt.line += 1
  call popup_move(a:winid, opt)
endfunction

function! s:show_tree() abort
  set ambiwidth=double

  let s:tree_window = popup_create(s:tree, {
        \ 'pos': 'center',
        \ })

  let s:tree_window_pos = popup_getpos(s:tree_window)
  let s:tree_window_pos['bottom'] = s:tree_window_pos.line + s:tree_window_pos.height - 1
  let s:tree_window_pos['left'] = s:tree_window_pos.col
  let s:tree_window_pos['right'] = s:tree_window_pos.left + s:tree_window_pos.width - 2
  let s:tree_window_pos['range'] = range(s:tree_window_pos.left, s:tree_window_pos.right)
  let s:tree_window_pos['range_len'] = len(s:tree_window_pos.range)

  call win_execute(s:tree_window, 'syntax match SnowGreen /▲/')
  call win_execute(s:tree_window, 'syntax match SnowDeco /彡/')
  call win_execute(s:tree_window, 'syntax match SnowDeco /彡/')
  call win_execute(s:tree_window, 'syntax match SnowTree /\%<5l.*/')
  call win_execute(s:tree_window, 'syntax match SnowTree /\%>16l.*/')

  let s:starlight_timer = timer_start(1000, function('s:starlight'), {'repeat': -1})
endfunction

function! s:starlight(timer) abort
  let star_color = s:snow_colors[rand(srand()) % s:snow_colors_len]
  exe 'hi SnowStar ctermfg=' .. star_color
  call win_execute(s:tree_window, 'syntax match SnowStar /[☆ﾟ‥：・｡∴]/')
endfunction

function! s:stoptimers() abort
  call timer_stop(s:top_timer)
  call timer_stop(s:starlight_timer)
  for t in s:snow_timers
    call timer_stop(t)
  endfor
endfunction

function! s:close_popupwindow() abort
  call popup_close(s:tree_window)
  for w in s:snow_windows
    call popup_close(w)
  endfor
endfunction

function! s:define_highlight() abort
  hi Snow ctermfg=255 cterm=bold
  hi SnowGreen ctermfg=2
  hi SnowDeco ctermfg=197
  hi SnowStar ctermfg=11
  hi SnowTree ctermfg=208
endfunction

function! christmas#end() abort
  set ambiwidth=single
  let s:state = 'stopped'
  hi clear Snow SnowGreen SnowDeco SnowStar SnowTree
  call s:stoptimers()
  call s:close_popupwindow()
endfunction

function! christmas#start() abort
  if s:state is# 'started'
    return
  endif
  let s:state = 'started'
  call s:define_highlight()
  call s:show_tree()

  let s:top_timer = timer_start(200, function('s:new_snow'), {'repeat': -1})
endfunction
