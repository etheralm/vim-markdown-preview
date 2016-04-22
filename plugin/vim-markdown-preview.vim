"============================================================
"                    Vim Markdown Preview
"   git@github.com:JamshedVesuna/vim-markdown-preview.git
"============================================================

let g:vmp_script_path = resolve(expand('<sfile>:p:h'))

if !exists("g:vim_markdown_preview_browser")
  let g:vim_markdown_preview_browser = 'Google Chrome'
endif

if !exists("g:vim_markdown_preview_temp_file")
  let g:vim_markdown_preview_temp_file = 0
endif

if !exists("g:vim_markdown_preview_toggle")
  let g:vim_markdown_preview_toggle = 0
endif

if !exists("g:vim_markdown_preview_github")
  let g:vim_markdown_preview_github = 0
endif

if !exists("g:vim_markdown_preview_use_xdg_open")
    let g:vim_markdown_preview_use_xdg_open = 0
endif

if !exists("g:vim_markdown_preview_hotkey")
    let g:vim_markdown_preview_hotkey='<C-p>'
endif


let g:vmp_osname = 'Unidentified'

if has('win32')
  let g:vmp_osname = 'win32'
  let g:tmp_file = '%TEMP%\vim-markdown-preview.html'
endif
if has('unix')
  let g:vmp_osname = 'unix'
  let g:tmp_file = '/tmp/vim-markdown-preview.html'
endif
if has('mac')
  let g:vmp_osname = 'mac'
  let g:vmp_search_script = g:vmp_script_path . '/applescript/search-for-vmp.scpt'
  let g:vmp_activate_script = g:vmp_script_path . '/applescript/activate-vmp.scpt'
  let g:tmp_file = '/tmp/vim-markdown-preview.html'
endif



function! Vim_Markdown_Preview()
  let b:curr_file = expand('%:p')

  if g:vim_markdown_preview_github == 1
    call system('grip "' . b:curr_file . '" --export "' . g:tmp_file . '" --title vim-markdown-preview.html')
  else
    call system('markdown "' . b:curr_file . '" > "' . g:tmp_file . '"')
  endif

  if g:vmp_osname == 'unix'
    let chrome_wid = system("xdotool search --name 'vim-markdown-preview.html - " . g:vim_markdown_preview_browser . "'")
    if !chrome_wid
      if g:vim_markdown_preview_use_xdg_open == 1
        call system('xdg-open "' . g:tmp_file . '" &> /dev/null &')
      else
        call system('see "' . g:tmp_file . '" &> /dev/null &')
      endif
    else
      let curr_wid = system('xdotool getwindowfocus')
      call system('xdotool windowmap ' . chrome_wid)
      call system('xdotool windowactivate ' . chrome_wid)
      call system("xdotool key 'ctrl+r'")
      call system('xdotool windowactivate ' . curr_wid)
    endif
  endif

  if g:vmp_osname == 'mac'
    if g:vim_markdown_preview_browser == "Google Chrome"
      let b:vmp_preview_in_browser = system('osascript ' . g:vmp_search_script)
      if b:vmp_preview_in_browser == 1
        call system('open -g "' . g:tmp_file . '"')
      else
        call system('osascript ' . g:vmp_activate_script)
      endif
    else
      call system('open -g "' . g:tmp_file . '"')
    endif
  endif

  if g:vmp_osname == 'win32'
      call system('"' . g:tmp_file . '"')
  endif

  if g:vim_markdown_preview_temp_file == 1
    sleep 200m
    call system('rm "' . g:tmp_file . '"')
  endif
endfunction


"Renders html locally and displays images
function! Vim_Markdown_Preview_Local()
  let b:curr_file = expand('%:p')

  if g:vim_markdown_preview_github == 1
    call system('grip "' . b:curr_file . '" --export vim-markdown-preview.html --title vim-markdown-preview.html')
  else
    call system('markdown "' . b:curr_file . '" > vim-markdown-preview.html')
  endif

  if g:vmp_osname == 'unix'
    let chrome_wid = system("xdotool search --name vim-markdown-preview.html - " . g:vim_markdown_preview_browser . "'")
    if !chrome_wid
      if g:vim_markdown_preview_use_xdg_open == 1
        call system('xdg-open vim-markdown-preview.html &> /dev/null &')
      else
        call system('see vim-markdown-preview.html &> /dev/null &')
      endif
    else
      let curr_wid = system('xdotool getwindowfocus')
      call system('xdotool windowmap ' . chrome_wid)
      call system('xdotool windowactivate ' . chrome_wid)
      call system("xdotool key 'ctrl+r'")
      call system('xdotool windowactivate ' . curr_wid)
    endif
  endif

  if g:vmp_osname == 'mac'
    if g:vim_markdown_preview_browser == "Google Chrome"
      let b:vmp_preview_in_browser = system('osascript ' . g:vmp_search_script)
      if b:vmp_preview_in_browser == 1
        call system('open -g vim-markdown-preview.html')
      else
        call system('osascript ' . g:vmp_activate_script)
      endif
    else
      call system('open -g vim-markdown-preview.html')
    endif
  endif

  if g:vmp_osname == 'win32'
      call system('vim-markdown-preview.html')
  end-if
 
  if g:vim_markdown_preview_temp_file == 1
    sleep 200m
    call system('rm vim-markdown-preview.html')
  endif
endfunction

if g:vim_markdown_preview_toggle == 0
  "Maps vim_markdown_preview_hotkey to Vim_Markdown_Preview()
  :exec 'autocmd Filetype markdown,md map <buffer> ' . g:vim_markdown_preview_hotkey . ' :call Vim_Markdown_Preview()<CR>'
elseif g:vim_markdown_preview_toggle == 1
  "Display images - Maps vim_markdown_preview_hotkey to Vim_Markdown_Preview_Local() - saves the html file locally
  "and displays images in path
  :exec 'autocmd Filetype markdown,md map <buffer> ' . g:vim_markdown_preview_hotkey . ' :call Vim_Markdown_Preview_Local()<CR>'
elseif g:vim_markdown_preview_toggle == 2
  "Display images - Automatically call Vim_Markdown_Preview_Local() on buffer write
  autocmd BufWritePost *.markdown,*.md :call Vim_Markdown_Preview_Local()
elseif g:vim_markdown_preview_toggle == 3
  "Automatically call Vim_Markdown_Preview() on buffer write
  autocmd BufWritePost *.markdown,*.md :call Vim_Markdown_Preview()
endif
