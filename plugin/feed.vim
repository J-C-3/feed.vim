" requirements: webapi-vim, open-browser.vim

let s:links = {'0':'hoge'}
let g:feedvim_urls = [ 'http://reddit.com/r/WritingPrompts/new/.rss?sort=new' ]

function! FeedvimOpenLink()
  let s:url = s:links[ line('.') ]
  execute "OpenBrowser" s:url
endfunction

" buffer operation
augroup MyGroup
  autocmd!
  autocmd FileType feed.vim.buffer nnoremap <buffer> o :call FeedvimOpenLink()<CR>
  autocmd FileType feed.vim.buffer setlocal noswapfile
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
  " change buffer
  let bufnum = bufnr('feed.vim.buffer')
  if bufnum == -1
    50vsplit 'feed.vim.buffer'
  else
    50vsplit bufnum.'buffer'
  endif

  " set buffer parameter
  setl filetype=feed.vim.buffer
  setl buftype=nofile
  setl noshowcmd noshowmode
  nnoremap <buffer> q :call ExitWritingPrompt()<CR>
  file 'feed.vim.buffer'

  " output
  for url in g:feedvim_urls
    " " title
    call s:write("Choose your writing prompt...")
    " call s:write("#  ".s:get_title(url))
    call s:write("")

    " item
    for item in webapi#feed#parseURL(url)
      call s:write("* ".item.title.' - '.item.link)
      " call s:write("* ".item.title)
      let s:links[ ''.line('$').'' ] = item.link
      call s:write("")
    endfor
  endfor
endfunction

function! CreateWritingPrompt()
  " change buffer
  call FeedvimOpenBuffer()
  Limelight
  let g:wpbuff = bufnr('feed.vim.buffer')
  nnoremap <buffer><silent> q :call ExitWritingPrompt()<CR>
endfunction

function! ExitWritingPrompt()
    if bufexists(g:wpbuff)
      execute "bdelete " . g:wpbuff
      Limelight!
    endif
  let g:wpbuff = -1
endfunction

command! Feedvim call FeedvimOpenBuffer()
command! WritingPrompt call CreateWritingPrompt()
command! WritingPromptExit call ExitWritingPrompt()
