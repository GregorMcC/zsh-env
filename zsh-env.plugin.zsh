#!/usr/bin/env zsh
#
# zsh-env - Shows environment variable values below the prompt
#

typeset -g _ZSH_ENV_PAGE_OFFSET=0
typeset -g _ZSH_ENV_ALL_HINTS=()

_zsh_env_is_sensitive() {
    local upper_name="${1:u}"
    [[ "$upper_name" =~ "(KEY|SECRET|TOKEN|PASSWORD|PASS|AUTH|CREDENTIAL|PRIVATE)" ]]
}

_zsh_env_max_lines() {
    if [[ $LINES -lt 20 ]]; then
        echo 1
    elif [[ $LINES -lt 30 ]]; then
        echo 2
    else
        echo 3
    fi
}

_zsh_env_show_hints() {
    [[ -z "$BUFFER" ]] && return
    
    local buffer="$BUFFER"
    local -a hints
    local -A seen_vars
    local i=1
    
    while [[ $i -le ${#buffer} ]]; do
        if [[ "${buffer[$i]}" == '$' ]]; then
            local matched=0
            local var_name=""
            local var_match=""
            local match_len=0
            
            # Try to match parameter expansion patterns first (${VAR...})
            if [[ "${buffer[$i,-1]}" =~ '^\$\{([A-Za-z_][A-Za-z0-9_]*)' ]]; then
                var_name="${match[1]}"
                # Find the closing brace by counting nested braces
                local j=$((i + 2 + ${#var_name}))
                local brace_count=1
                while [[ $j -le ${#buffer} && $brace_count -gt 0 ]]; do
                    if [[ "${buffer[$j]}" == '{' ]]; then
                        ((brace_count++))
                    elif [[ "${buffer[$j]}" == '}' ]]; then
                        ((brace_count--))
                    fi
                    ((j++))
                done
                
                if [[ $brace_count -eq 0 ]]; then
                    match_len=$((j - i))
                    var_match="${buffer[$i,$((j-1))]}"
                    matched=1
                fi
            # Try simple $VAR pattern
            elif [[ "${buffer[$i,-1]}" =~ '^\$([A-Za-z_][A-Za-z0-9_]*)' ]]; then
                var_name="${match[1]}"
                match_len=${#MATCH}
                var_match="${buffer[$i,$((i+match_len-1))]}"
                matched=1
            fi
            
            if [[ $matched -eq 1 && -n "$var_name" && -z "${seen_vars[$var_name]}" ]]; then
                local var_value=""
                local base_value="${(P)var_name:-}"
                
                # Handle parameter expansion modifiers
                if [[ "$var_match" =~ '^\$\{[^}]+:-' ]]; then
                    # ${VAR:-default} - use default if VAR is unset or empty
                    local default_part="${var_match#*:-}"
                    default_part="${default_part%\}*}"
                    default_part="${default_part%\}}"
                    var_value="${base_value:-$default_part}"
                elif [[ "$var_match" =~ '^\$\{[^}]+:\+' ]]; then
                    # ${VAR:+alt} - use alt if VAR is set and non-empty
                    local alt_part="${var_match#*:+}"
                    alt_part="${alt_part%\}*}"
                    alt_part="${alt_part%\}}"
                    var_value="${base_value:+$alt_part}"
                elif [[ "$var_match" =~ '^\$\{[^}]+:=' ]]; then
                    # ${VAR:=default} - assign default if unset, then use value
                    local default_part="${var_match#*:=}"
                    default_part="${default_part%\}*}"
                    default_part="${default_part%\}}"
                    var_value="${base_value:-$default_part}"
                elif [[ "$var_match" =~ '^\$\{[^}]+:\?' ]]; then
                    # ${VAR:?msg} - error if unset, otherwise use value
                    var_value="$base_value"
                else
                    # Simple ${VAR} or $VAR - just use the value
                    var_value="$base_value"
                fi
                
                if [[ -n "$var_value" ]]; then
                    if _zsh_env_is_sensitive "$var_name"; then
                        var_value="***REDACTED***"
                    else
                        local max_len=50
                        if [[ ${#var_value} -gt $max_len ]]; then
                            var_value="${var_value[1,$((max_len - 3))]}..."
                        fi
                    fi
                    hints+=("$var_match → $var_value")
                    seen_vars[$var_name]=1
                fi
                
                i=$((i + match_len))
                continue
            fi
        fi
        
        ((i++))
    done
    
    _ZSH_ENV_ALL_HINTS=("${hints[@]}")
    _zsh_env_display_page
}

_zsh_env_display_page() {
    if [[ ${#_ZSH_ENV_ALL_HINTS} -eq 0 ]]; then
        zle -M ""
        return
    fi
    
    local max_lines=$(_zsh_env_max_lines)
    local total=${#_ZSH_ENV_ALL_HINTS[@]}
    local start=$((_ZSH_ENV_PAGE_OFFSET + 1))
    local end=$((_ZSH_ENV_PAGE_OFFSET + max_lines))
    
    if [[ $end -gt $total ]]; then
        end=$total
    fi
    
    local display=""
    local has_more_above=0
    local has_more_below=0
    
    if [[ $_ZSH_ENV_PAGE_OFFSET -gt 0 ]]; then
        has_more_above=1
        local count=$_ZSH_ENV_PAGE_OFFSET
        display="↑ $count more above [Alt+↑ to scroll]"
    fi
    
    integer idx
    for ((idx=start; idx<=end; idx++)); do
        if [[ $idx -gt ${#_ZSH_ENV_ALL_HINTS[@]} ]]; then
            break
        fi
        local item="${_ZSH_ENV_ALL_HINTS[$idx]}"
        if [[ -z "$item" ]]; then
            continue
        fi
        
        local max_width=$((COLUMNS - 5))
        
        if [[ ${#item} -gt $max_width ]]; then
            item="${item[1,$((max_width - 3))]}..."
        fi
        
        if [[ -z "$display" ]]; then
            display="$item"
        else
            display="${display}
${item}"
        fi
    done
    
    if [[ $end -lt $total ]]; then
        has_more_below=1
        local count=$((total - end))
        display="${display}
↓ $count more below [Alt+↓ to scroll]"
    fi
    
    zle -M "$display"
}

_zsh_env_self_insert_wrapper() {
    zle .self-insert
    _zsh_env_show_hints
}

_zsh_env_backward_delete_char() {
    zle .backward-delete-char
    _zsh_env_show_hints
}

_zsh_env_delete_char() {
    zle .delete-char
    _zsh_env_show_hints
}

_zsh_env_accept_line() {
    _ZSH_ENV_PAGE_OFFSET=0
    _ZSH_ENV_ALL_HINTS=()
    zle -M ""
    zle .accept-line
}

_zsh_env_scroll_down() {
    if [[ ${#_ZSH_ENV_ALL_HINTS} -eq 0 ]]; then
        zle .down-line-or-history
        return
    fi
    
    local max_lines=$(_zsh_env_max_lines)
    local total=${#_ZSH_ENV_ALL_HINTS[@]}
    local max_offset=$((total - max_lines))
    
    if [[ $_ZSH_ENV_PAGE_OFFSET -lt $max_offset ]]; then
        _ZSH_ENV_PAGE_OFFSET=$((_ZSH_ENV_PAGE_OFFSET + 1))
        _zsh_env_display_page
    fi
}

_zsh_env_scroll_up() {
    if [[ ${#_ZSH_ENV_ALL_HINTS} -eq 0 ]]; then
        zle .up-line-or-history
        return
    fi
    
    if [[ $_ZSH_ENV_PAGE_OFFSET -gt 0 ]]; then
        _ZSH_ENV_PAGE_OFFSET=$((_ZSH_ENV_PAGE_OFFSET - 1))
        _zsh_env_display_page
    fi
}

_zsh_env_precmd() {
    _ZSH_ENV_PAGE_OFFSET=0
    _ZSH_ENV_ALL_HINTS=()
    zle -M "" 2>/dev/null || true
}

if zle -l | grep -q "autosuggest-orig-2-self-insert"; then
    zle -A autosuggest-orig-2-self-insert _zsh_env_wrapped_self_insert
else
    autoload -Uz self-insert
    zle -A self-insert _zsh_env_wrapped_self_insert
fi

zle -N self-insert _zsh_env_self_insert_wrapper
zle -N _zsh_env_backward_delete_char
zle -N _zsh_env_delete_char
zle -N _zsh_env_accept_line
zle -N _zsh_env_scroll_down
zle -N _zsh_env_scroll_up

bindkey -M emacs '^?' _zsh_env_backward_delete_char
bindkey -M emacs '^H' _zsh_env_backward_delete_char
bindkey -M emacs '^[[3~' _zsh_env_delete_char
bindkey -M viins '^?' _zsh_env_backward_delete_char
bindkey -M viins '^[[3~' _zsh_env_delete_char
bindkey -M emacs '^M' _zsh_env_accept_line
bindkey -M viins '^M' _zsh_env_accept_line
bindkey -M emacs '^[[1;3B' _zsh_env_scroll_down
bindkey -M emacs '^[[1;3A' _zsh_env_scroll_up
bindkey -M viins '^[[1;3B' _zsh_env_scroll_down
bindkey -M viins '^[[1;3A' _zsh_env_scroll_up

autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsh_env_precmd 2>/dev/null || true
