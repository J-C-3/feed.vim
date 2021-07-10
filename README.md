# Fork of feed.vim for retrieving writing prompts from reddit

# feed.vim

## Require

- https://github.com/J-C-3/webapi-vim fork of https://github.com/mattn/webapi-vim.git
- open-browser.vim

## Configure

By default, `g:feedvim_urls` points to `https://reddit.com/r/WritingPrompts/new/.rss?sort=new`

Change this in your `init.vim` or `~/.vimrc`

```
let g:feedvim_urls = [ 'http:/foo.com/rss', 'http://bar.com/rss ]
```

## Command

```
:FeedVim
```
