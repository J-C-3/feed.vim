" requirements: webapi-vim, open-browser.vim

let s:links = {'0':'hoge'}
" http://reddit.com/r/[subreddit].[rss/json]?limit=[limit]&after=[after]`
let g:numPosts = 25
let g:feedvim_urls = ['https://www.reddit.com/r/WritingPrompts/new/.rss?limit='.g:numPosts]

function! FeedvimOpenLink()
  let s:url = s:links[ line('.') ]
  execute "OpenBrowser" s:url
endfunction

" buffer operation
augroup MyGroup
  autocmd!
  autocmd FileType writingPrompt.buffer nnoremap <buffer> o :call FeedvimOpenLink()<CR>
  autocmd FileType writingPrompt.buffer setlocal noswapfile
augroup END

function! s:get_title(url)
  let dom = webapi#xml#parseURL(a:url)
  let i=0
  let title='no title'

  while i < 25
    if dom['name'] == 'title'
      let title = dom['child'][0]
      break
    endif
    " let dom = dom['child'][1]
    let i += 1
  endwhile

  return title
endfunction

function! s:write(s) abort
  call append(line("$"), a:s)
endfunction

function! FeedvimOpenBuffer()
  let g:mainBuffer = bufnr('%')
  let b = bufnr('writingPrompt.buffer', )
  if b == -1
    let b = nvim_create_buf(0,1)
    call nvim_buf_set_name(b,'writingPrompt.buffer')
  endif
  if exists('*nvim_open_win')
    let width = 50
    let height = 25
    let config = {'relative':'editor',
          \ 'col':(nvim_win_get_width(0)/4)-(width/2),
          \ 'row':(nvim_win_get_height(0)/2)-(height/2),
          \ 'width':width,
          \ 'height':height}
    " change buffer
    let w = nvim_open_win(b, 1, config)
    call setwinvar(w, '&winhl', 'Normal:Floating')
    call setwinvar(w, '&cursorline', '1')
    call setwinvar(w, '&number', 0)
  endif

  " set buffer parameter
  setl filetype=writingPrompt.buffer
  setl buftype=nofile
  setl noshowcmd noshowmode modifiable

  " file 'writingPrompt.buffer'
  " output
  let g:titles={}
  let i = 1
  for url in g:feedvim_urls
    " call setbufline(b, i, url)
    " let g:titles[''.i.''] = url
    " let s:links[''.i.''] = url
    " let i+=1
    " item
    for item in webapi#feed#parseURL(url)
      let title = substitute(item.title, "&quot;", "\"", "g")
      let g:titles[''.i.''] = title.' | '.item.link
      let shortText = item.title[0:width-4].'...'
      call setbufline(b, i, shortText)
      let s:links[''.i.''] = item.link
      let i += 1
    endfor
  endfor

  setl nomodifiable
  redraw

  let g:wpWin = win_getid()
  augroup writingPrompts
    autocmd CursorMoved <buffer> call s:displayText(g:titles[''.line('.').''])
    autocmd WinLeave,ExitPre,QuitPre <buffer> call ExitWritingPrompt()
    nnoremap <buffer><silent><CR> :execute appendbufline(g:mainBuffer,'.',g:titles[line('.')])<CR>
                \:q<CR>
  augroup end
endfunction

function! s:displayText(title) abort
  let width = 50
  let height = (strlen(a:title)*4/width)+1
  let bufName = 'titleBuff'
  let b = bufnr(bufName)
  if b == -1
      let b = nvim_create_buf(0,1)
      call nvim_buf_set_name(b,bufName)
  endif
  if exists('g:titleWin')
    call nvim_win_close(g:titleWin, 1)
  endif
  let parentWin = nvim_win_get_position(g:wpWin)
  let config = {'relative':'editor',
        \ 'width': width,
        \ 'height':height,
        \ 'row': parentWin[0]- (height/4) - 3,
        \ 'col': parentWin[1] + nvim_win_get_width(g:wpWin)}
  " change buffer
  let g:titleWin = nvim_open_win(b, 0, config)
  call setwinvar(g:titleWin, '&winhl', 'Normal:Floating')
  call setwinvar(g:titleWin, '&buftype', 'nofile')
  call setbufvar(b, '&filetype', 'writingPrompt.buffer')
  call setbufvar(b, 'nonmodifiable', 1)
  let title = split(a:title, ' | ')
  call setbufline(b, 1, title[0])
  call setbufline(b, 2, '')
  call setbufline(b, 3, title[1])
  redraw
endfunction

function! CreateWritingPrompt()
  " change buffer
  call FeedvimOpenBuffer()
  nnoremap <buffer><silent> q :q<CR>
endfunction

function! ExitWritingPrompt()
  if exists('g:titleWin')
    if nvim_win_is_valid(g:titleWin)
      call nvim_win_close(g:titleWin, 1)
    endif
    unlet g:titleWin
  endif
  if exists('g:wpWin') == 1
    if nvim_win_is_valid(g:wpWin)
      call nvim_win_close(g:wpWin, 1)
    endif
    unlet g:wpWin
  endif
  if exists('g:titles') ==1
    unlet g:titles
  endif
endfunction

command! Feedvim call FeedvimOpenBuffer()
command! WritingPrompt call CreateWritingPrompt()
command! WritingPromptExit call ExitWritingPrompt()
