#!/usr/bin/env zsh

# ---------------- 预处理 --------------- #

# https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
# 标准化 $0
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
# 将参数保存在同一变量中
typeset -gA Plugins
Plugins[ZSH_LS]="${0:h}"

# ---------------- 主函数 --------------- #

# 卸载清理别名
function __uninstall_zsh_ls__() {
  # https://wiki.zshell.dev/community/zsh_plugin_standard#standard-recommended-options
  # 获取干净的执行环境
  builtin emulate -L zsh ${=${options[xtrace]:#off}:+-o xtrace}
  builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

  if [[ $(alias oriLs) ]]; then
    unalias oriLs
  fi
  if [[ $(alias oriTree) ]]; then
    unalias oriTree
  fi

  if [[ $(alias ls) ]]; then
    unalias ls
  fi

  if [[ $(alias ll) ]]; then
    unalias ll
  fi
  if [[ $(alias llt) ]]; then
    unalias llt
  fi
  if [[ $(alias lls) ]]; then
    unalias lls
  fi

  if [[ $(alias la) ]]; then
    unalias la
  fi
  if [[ $(alias lat) ]]; then
    unalias lat
  fi
  if [[ $(alias las) ]]; then
    unalias las
  fi

  if [[ $(alias lt) ]]; then
    unalias lt
  fi
  if [[ $(alias tree) ]]; then
    unalias tree
  fi
}

# 安装别名
function __install_zsh_ls__() {
  # https://wiki.zshell.dev/community/zsh_plugin_standard#standard-recommended-options
  # 获取干净的执行环境
  builtin emulate -L zsh ${=${options[xtrace]:#off}:+-o xtrace}
  builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

  # 重命名 ls
  alias oriLs="$(which ls)"
  # 重命名 tree
  alias oriTree="$(which tree)"

  # 确定执行程序
  typeset -ag ZSH_LS_PROG

  if [[ ! -z "$ZSH_LS_PREFER_LSD" ]]; then
    ZSH_LS_PROG='lsd'
  elif [[ ! -z "$ZSH_LS_PREFER_EZA" ]]; then
    ZSH_LS_PROG='eza'
  elif [[ ! -z "$ZSH_LS_PREFER_EXA" ]]; then
    ZSH_LS_PROG='exa'
  elif [[ ! -z "$ZSH_LS_PREFER_LS" ]]; then
    ZSH_LS_PROG='ls'

  elif (( $+commands[lsd] )); then
    ZSH_LS_PROG='lsd'
  elif (( $+commands[eza] )); then
    ZSH_LS_PROG='eza'
  elif (( $+commands[exa] )); then
    ZSH_LS_PROG='exa'
  else
    ZSH_LS_PROG='ls'
  fi


  if [[ "$ZSH_LS_PROG" == "lsd" ]]; then
    typeset -ag lsd_params
    lsd_params=("--date" "+%F %T" "--header" "--group-directories-first")

    [[ ! -z $ZSH_LSD_PARAMS ]] && lsd_params=($ZSH_LSD_PARAMS)

    # Keep simple and clear
    alias ls='lsd -F --icon=never --group-directories-first'
    # list detail with directories at the top
    alias ll='lsd -l $lsd_params'
    # ll but sort with time
    alias llt='lsd -lt $lsd_params'
    # ll but sort whit size
    alias lls='lsd -lS --total-size $lsd_params 2>/dev/null'
    # ll but no ignore
    alias la='lsd -Al $lsd_params'
    # ll but no ignore and sort with time
    alias lat='lsd -Alt $lsd_params'
    # ll but no ignore and sort whit size
    alias las='lsd -AlS --total-size $lsd_params 2>/dev/null'
    # list as tree with depth limit
    alias lt='lsd --tree --depth=3 $lsd_params'
    alias tree='lsd --tree --depth=3 $lsd_params'

  elif [[ "$ZSH_LS_PROG" == "eza" ]]; then
    typeset -ag eza_params
    eza_params=("--group"  "--group-directories-first" "--header"
                "--icons=auto" "--time-style" "+%F %T" "--total-size")

    [[ ! -z $ZSH_EZA_PARAMS ]] && eza_params=($ZSH_EZA_PARAMS)

    # Keep simple and clear
    alias ls='eza -F --icons=never --group-directories-first'
        # list detail with directories at the top
    alias ll='eza -l $eza_params'
    # ll but sort with time
    alias llt='eza -lr -s modified $eza_params'
    # ll but sort whit size
    alias lls='eza -lr -s size --total-size $eza_params'
    # ll but no ignore
    alias la='eza -Al $eza_params'
    # ll but no ignore and sort with time
    alias lat='eza -Alr -s modified $eza_params'
    # ll but no ignore and sort whit size
    alias las='eza -Alr -s size --total-size $eza_params'
    # list as tree with depth limit
    alias lt='eza --tree --level=3 $eza_params'
    alias tree='eza --tree --level=3 $eza_params'

  elif [[ "$ZSH_LS_PROG" == "exa" ]]; then

    if [[ -z "$ZSH_LS_NO_WARN" && -z "$ZSH_LS_PREFER_EXA" ]]; then
      print -P "%F{yellow}[zsh-ls] You are using exa as ls program，but it is unmaintained. Please try to use lsd or eza."
    fi

    typeset -ag exa_params
    exa_params=("--group"  "--group-directories-first" "--header"
                "--icons" "--time-style" "long-iso")

    [[ ! -z $ZSH_EXA_PARAMS ]] && exa_params=($ZSH_EXA_PARAMS)

    # Keep simple and clear
    alias ls='exa --no-icons --group-directories-first'
    # list detail with directories at the top
    alias ll='exa -l $exa_params'
    # ll but sort with time
    alias llt='exa -lr -s modified $exa_params'
    # ll but sort whit size
    alias lls='exa -lr -s size $exa_params'
    # ll but no ignore
    alias la='exa -al $exa_params'
    # ll but no ignore and sort with time
    alias lat='exa -alr -s modified $exa_params'
    # ll but no ignore and sort whit size
    alias las='exa -alr -s size $exa_params'
    # list as tree
    alias lt='exa --tree --level=3 $exa_params'
    alias tree='exa --tree --level=3 $exa_params'

  else
    if [[ -z "$ZSH_LS_NO_WARN" && -z "$ZSH_LS_PREFER_LS" ]]; then
      print -P "%F{yellow}[zsh-ls] Fall back to ls. Please check your system."
    fi

    typeset -ag ls_params
    ls_params=("-p" "-h" "--group-directories-first" "--time-style" "long-iso")

    [[ ! -z $ZSH_LS_PARAMS ]] && ls_params=($ZSH_LS_PARAMS)

    # list detail with directories at the top
    alias ll='oriLs -l $ls_params'
    # ll but sort with time
    alias llt='oriLs -lt $ls_params'
    # ll but sort whit size
    alias lls='oriLs -lS $ls_params'
    # ll but no ignore
    alias la='oriLs -Al $ls_params'
    # ll but no ignore and sort with time
    alias lat='oriLs -Alt $ls_params'
    # ll but no ignore and sort whit size
    alias las='oriLs -AlS $ls_params'
    # list as tree
    alias lt='oriTree -L 3'
    alias tree='oriTree -L 3'

  fi
}

# 安装插件
(( $+functions[__uninstall_zsh_ls__] )) && {
  __uninstall_zsh_ls__ || {
    print "Error loading zsh-ls plugin while clean env."
    return 1
  }
}

(( $+functions[__install_zsh_ls__] )) && {
  __install_zsh_ls__ || {
    print "Error loading zsh-ls plugin."
    return 1
  }
}
