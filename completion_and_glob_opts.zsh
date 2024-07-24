# -------------------------------
# Configure completions and globs
# -------------------------------

setopt \
  always_to_end \
  complete_in_word \
  extended_glob \
  glob_dots \
  glob_star_short \
  no_case_glob

zstyle ':completion:*:*:*:*:*' menu select
bindkey '^I' menu-expand-or-complete

# if (( $+commands[dircolors] ))  eval "$(dircolors -b)"
# export LS_COLORS="$(vivid generate snazzy)"
export LS_COLORS='tw=0:or=0;38;2;0;0;0;48;2;255;92;87:bd=0;38;2;154;237;254;48;2;51;51;51:di=0;38;2;87;199;255:so=0;38;2;0;0;0;48;2;255;106;193:st=0:do=0;38;2;0;0;0;48;2;255;106;193:no=0:sg=0:cd=0;38;2;255;106;193;48;2;51;51;51:mi=0;38;2;0;0;0;48;2;255;92;87:fi=0:pi=0;38;2;0;0;0;48;2;87;199;255:ow=0:ca=0:mh=0:rs=0:ex=1;38;2;255;92;87:ln=0;38;2;255;106;193:su=0:*~=0;38;2;102;102;102:*.h=0;38;2;90;247;142:*.t=0;38;2;90;247;142:*.p=0;38;2;90;247;142:*.o=0;38;2;102;102;102:*.m=0;38;2;90;247;142:*.d=0;38;2;90;247;142:*.r=0;38;2;90;247;142:*.c=0;38;2;90;247;142:*.z=4;38;2;154;237;254:*.a=1;38;2;255;92;87:*.el=0;38;2;90;247;142:*.ko=1;38;2;255;92;87:*.hh=0;38;2;90;247;142:*.ml=0;38;2;90;247;142:*.ts=0;38;2;90;247;142:*.rs=0;38;2;90;247;142:*.bz=4;38;2;154;237;254:*.mn=0;38;2;90;247;142:*.kt=0;38;2;90;247;142:*.fs=0;38;2;90;247;142:*css=0;38;2;90;247;142:*.nb=0;38;2;90;247;142:*.di=0;38;2;90;247;142:*.pm=0;38;2;90;247;142:*.pl=0;38;2;90;247;142:*.ex=0;38;2;90;247;142:*.jl=0;38;2;90;247;142:*.pp=0;38;2;90;247;142:*.lo=0;38;2;102;102;102:*.md=0;38;2;243;249;157:*.td=0;38;2;90;247;142:*.as=0;38;2;90;247;142:*.sh=0;38;2;90;247;142:*.py=0;38;2;90;247;142:*.gv=0;38;2;90;247;142:*.7z=4;38;2;154;237;254:*.cs=0;38;2;90;247;142:*.bc=0;38;2;102;102;102:*.rm=0;38;2;255;180;223:*.ui=0;38;2;243;249;157:*.go=0;38;2;90;247;142:*.xz=4;38;2;154;237;254:*.la=0;38;2;102;102;102:*.wv=0;38;2;255;180;223:*.js=0;38;2;90;247;142:*.hs=0;38;2;90;247;142:*.vb=0;38;2;90;247;142:*.gz=4;38;2;154;237;254:*.cr=0;38;2;90;247;142:*.so=1;38;2;255;92;87:*.hi=0;38;2;102;102;102:*.cc=0;38;2;90;247;142:*.cp=0;38;2;90;247;142:*.ll=0;38;2;90;247;142:*.rb=0;38;2;90;247;142:*.ps=0;38;2;255;92;87:*.m4v=0;38;2;255;180;223:*.kts=0;38;2;90;247;142:*.nix=0;38;2;243;249;157:*.mir=0;38;2;90;247;142:*.inl=0;38;2;90;247;142:*.cpp=0;38;2;90;247;142:*.ico=0;38;2;255;180;223:*.iso=4;38;2;154;237;254:*.xmp=0;38;2;243;249;157:*.img=4;38;2;154;237;254:*.yml=0;38;2;243;249;157:*.pyc=0;38;2;102;102;102:*.sty=0;38;2;102;102;102:*.pyo=0;38;2;102;102;102:*.tex=0;38;2;90;247;142:*.pps=0;38;2;255;92;87:*.mid=0;38;2;255;180;223:*.sbt=0;38;2;90;247;142:*.arj=4;38;2;154;237;254:*.xls=0;38;2;255;92;87:*.ppm=0;38;2;255;180;223:*.toc=0;38;2;102;102;102:*.swf=0;38;2;255;180;223:*.bin=4;38;2;154;237;254:*.pod=0;38;2;90;247;142:*.tgz=4;38;2;154;237;254:*.odp=0;38;2;255;92;87:*.com=1;38;2;255;92;87:*.pyd=0;38;2;102;102;102:*.wmv=0;38;2;255;180;223:*.hxx=0;38;2;90;247;142:*.tif=0;38;2;255;180;223:*.dot=0;38;2;90;247;142:*.pbm=0;38;2;255;180;223:*.apk=4;38;2;154;237;254:*.ind=0;38;2;102;102;102:*.pkg=4;38;2;154;237;254:*.mp3=0;38;2;255;180;223:*.erl=0;38;2;90;247;142:*.fsx=0;38;2;90;247;142:*.tcl=0;38;2;90;247;142:*.txt=0;38;2;243;249;157:*.blg=0;38;2;102;102;102:*.tsx=0;38;2;90;247;142:*.kex=0;38;2;255;92;87:*.h++=0;38;2;90;247;142:*.ogg=0;38;2;255;180;223:*.cfg=0;38;2;243;249;157:*.png=0;38;2;255;180;223:*.ipp=0;38;2;90;247;142:*.ilg=0;38;2;102;102;102:*.gif=0;38;2;255;180;223:*.bmp=0;38;2;255;180;223:*.asa=0;38;2;90;247;142:*.bz2=4;38;2;154;237;254:*hgrc=0;38;2;165;255;195:*.dpr=0;38;2;90;247;142:*.mov=0;38;2;255;180;223:*.clj=0;38;2;90;247;142:*.dmg=4;38;2;154;237;254:*.eps=0;38;2;255;180;223:*.tbz=4;38;2;154;237;254:*.pid=0;38;2;102;102;102:*.xcf=0;38;2;255;180;223:*.c++=0;38;2;90;247;142:*.flv=0;38;2;255;180;223:*.gvy=0;38;2;90;247;142:*.dox=0;38;2;165;255;195:*.aif=0;38;2;255;180;223:*.bcf=0;38;2;102;102;102:*.pro=0;38;2;165;255;195:*.wav=0;38;2;255;180;223:*.def=0;38;2;90;247;142:*.vim=0;38;2;90;247;142:*.awk=0;38;2;90;247;142:*.fsi=0;38;2;90;247;142:*.csv=0;38;2;243;249;157:*.fon=0;38;2;255;180;223:*.cxx=0;38;2;90;247;142:*.log=0;38;2;102;102;102:*.rst=0;38;2;243;249;157:*.mpg=0;38;2;255;180;223:*.swp=0;38;2;102;102;102:*.otf=0;38;2;255;180;223:*.rtf=0;38;2;255;92;87:*.bat=1;38;2;255;92;87:*.ppt=0;38;2;255;92;87:*.avi=0;38;2;255;180;223:*.inc=0;38;2;90;247;142:*.exs=0;38;2;90;247;142:*.epp=0;38;2;90;247;142:*.tar=4;38;2;154;237;254:*.bsh=0;38;2;90;247;142:*.lua=0;38;2;90;247;142:*.odt=0;38;2;255;92;87:*.aux=0;38;2;102;102;102:*.bib=0;38;2;243;249;157:*.jar=4;38;2;154;237;254:*.vcd=4;38;2;154;237;254:*.cgi=0;38;2;90;247;142:*.out=0;38;2;102;102;102:*.m4a=0;38;2;255;180;223:*.sxw=0;38;2;255;92;87:*.mkv=0;38;2;255;180;223:*.bag=4;38;2;154;237;254:*.xlr=0;38;2;255;92;87:*.ps1=0;38;2;90;247;142:*.mli=0;38;2;90;247;142:*.pdf=0;38;2;255;92;87:*.zsh=0;38;2;90;247;142:*.jpg=0;38;2;255;180;223:*.fls=0;38;2;102;102;102:*.vob=0;38;2;255;180;223:*.htc=0;38;2;90;247;142:*.fnt=0;38;2;255;180;223:*.elm=0;38;2;90;247;142:*.ltx=0;38;2;90;247;142:*.ods=0;38;2;255;92;87:*.bst=0;38;2;243;249;157:*.mp4=0;38;2;255;180;223:*.doc=0;38;2;255;92;87:*.zst=4;38;2;154;237;254:*.sxi=0;38;2;255;92;87:*.dll=1;38;2;255;92;87:*.git=0;38;2;102;102;102:*.bak=0;38;2;102;102;102:*.svg=0;38;2;255;180;223:*.zip=4;38;2;154;237;254:*.php=0;38;2;90;247;142:*.exe=1;38;2;255;92;87:*.pas=0;38;2;90;247;142:*.bbl=0;38;2;102;102;102:*.htm=0;38;2;243;249;157:*.csx=0;38;2;90;247;142:*.tml=0;38;2;243;249;157:*.deb=4;38;2;154;237;254:*.hpp=0;38;2;90;247;142:*TODO=1:*.xml=0;38;2;243;249;157:*.ini=0;38;2;243;249;157:*.idx=0;38;2;102;102;102:*.wma=0;38;2;255;180;223:*.psd=0;38;2;255;180;223:*.ics=0;38;2;255;92;87:*.rar=4;38;2;154;237;254:*.sql=0;38;2;90;247;142:*.tmp=0;38;2;102;102;102:*.rpm=4;38;2;154;237;254:*.pgm=0;38;2;255;180;223:*.ttf=0;38;2;255;180;223:*.xlsx=0;38;2;255;92;87:*.psm1=0;38;2;90;247;142:*.fish=0;38;2;90;247;142:*.diff=0;38;2;90;247;142:*.flac=0;38;2;255;180;223:*.yaml=0;38;2;243;249;157:*.bash=0;38;2;90;247;142:*.purs=0;38;2;90;247;142:*.less=0;38;2;90;247;142:*.hgrc=0;38;2;165;255;195:*.orig=0;38;2;102;102;102:*.dart=0;38;2;90;247;142:*.mpeg=0;38;2;255;180;223:*.lisp=0;38;2;90;247;142:*.tiff=0;38;2;255;180;223:*.opus=0;38;2;255;180;223:*.tbz2=4;38;2;154;237;254:*.make=0;38;2;165;255;195:*.h264=0;38;2;255;180;223:*.epub=0;38;2;255;92;87:*.toml=0;38;2;243;249;157:*.jpeg=0;38;2;255;180;223:*.html=0;38;2;243;249;157:*.java=0;38;2;90;247;142:*.webm=0;38;2;255;180;223:*.conf=0;38;2;243;249;157:*.lock=0;38;2;102;102;102:*.json=0;38;2;243;249;157:*.docx=0;38;2;255;92;87:*.rlib=0;38;2;102;102;102:*.psd1=0;38;2;90;247;142:*.pptx=0;38;2;255;92;87:*.toast=4;38;2;154;237;254:*.swift=0;38;2;90;247;142:*.xhtml=0;38;2;243;249;157:*.mdown=0;38;2;243;249;157:*.cabal=0;38;2;90;247;142:*.patch=0;38;2;90;247;142:*README=0;38;2;40;42;54;48;2;243;249;157:*shadow=0;38;2;243;249;157:*passwd=0;38;2;243;249;157:*.dyn_o=0;38;2;102;102;102:*.class=0;38;2;102;102;102:*.scala=0;38;2;90;247;142:*.cmake=0;38;2;165;255;195:*.cache=0;38;2;102;102;102:*.ipynb=0;38;2;90;247;142:*.shtml=0;38;2;243;249;157:*INSTALL=0;38;2;40;42;54;48;2;243;249;157:*.matlab=0;38;2;90;247;142:*.config=0;38;2;243;249;157:*LICENSE=0;38;2;153;153;153:*.ignore=0;38;2;165;255;195:*.gradle=0;38;2;90;247;142:*COPYING=0;38;2;153;153;153:*.dyn_hi=0;38;2;102;102;102:*TODO.md=1:*.flake8=0;38;2;165;255;195:*.groovy=0;38;2;90;247;142:*.gemspec=0;38;2;165;255;195:*Doxyfile=0;38;2;165;255;195:*Makefile=0;38;2;165;255;195:*TODO.txt=1:*.desktop=0;38;2;243;249;157:*setup.py=0;38;2;165;255;195:*.cmake.in=0;38;2;165;255;195:*.rgignore=0;38;2;165;255;195:*.markdown=0;38;2;243;249;157:*COPYRIGHT=0;38;2;153;153;153:*.DS_Store=0;38;2;102;102;102:*configure=0;38;2;165;255;195:*.fdignore=0;38;2;165;255;195:*README.md=0;38;2;40;42;54;48;2;243;249;157:*.kdevelop=0;38;2;165;255;195:*Dockerfile=0;38;2;243;249;157:*.scons_opt=0;38;2;102;102;102:*.gitignore=0;38;2;165;255;195:*SConstruct=0;38;2;165;255;195:*.gitconfig=0;38;2;165;255;195:*SConscript=0;38;2;165;255;195:*README.txt=0;38;2;40;42;54;48;2;243;249;157:*.localized=0;38;2;102;102;102:*CODEOWNERS=0;38;2;165;255;195:*INSTALL.md=0;38;2;40;42;54;48;2;243;249;157:*.travis.yml=0;38;2;90;247;142:*Makefile.am=0;38;2;165;255;195:*.synctex.gz=0;38;2;102;102;102:*.gitmodules=0;38;2;165;255;195:*INSTALL.txt=0;38;2;40;42;54;48;2;243;249;157:*MANIFEST.in=0;38;2;165;255;195:*LICENSE-MIT=0;38;2;153;153;153:*Makefile.in=0;38;2;102;102;102:*.applescript=0;38;2;90;247;142:*CONTRIBUTORS=0;38;2;40;42;54;48;2;243;249;157:*.fdb_latexmk=0;38;2;102;102;102:*configure.ac=0;38;2;165;255;195:*appveyor.yml=0;38;2;90;247;142:*.clang-format=0;38;2;165;255;195:*CMakeCache.txt=0;38;2;102;102;102:*.gitattributes=0;38;2;165;255;195:*LICENSE-APACHE=0;38;2;153;153;153:*CMakeLists.txt=0;38;2;165;255;195:*CONTRIBUTORS.md=0;38;2;40;42;54;48;2;243;249;157:*requirements.txt=0;38;2;165;255;195:*CONTRIBUTORS.txt=0;38;2;40;42;54;48;2;243;249;157:*.sconsign.dblite=0;38;2;102;102;102:*package-lock.json=0;38;2;102;102;102:*.CFUserTextEncoding=0;38;2;102;102;102'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' '+l:|=* r:|=*'
zstyle ':completion:*' accept-exact-dirs 'yes'

zstyle ':completion:*' group-name ''
zstyle ':completion:*' format '%F{yellow}%B-- %d --%b%f'

zstyle ':completion::complete:*' cache-path ${XDG_CACHE_HOME:-~/.cache}/zsh
zstyle ':completion::complete:*' use-cache 1

# -- Complete file path --
# Key: ctrl+/
# Superseded in broot.zsh
zstyle ':completion:complete-files:*' completer _files
zle -C complete-files menu-complete _generic
bindkey '^_' complete-files  # ctrl+/

# -- Previous item in completion menu --
# Key: shift+tab
bindkey '^[[Z' reverse-menu-complete  # shift+tab
