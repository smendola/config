#!/usr/bin/env bash
# Claude Code statusLine — mirrors the sm.zsh-theme prompt style
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
host=$(hostname -s)
model=$(echo "$input" | jq -r '.model.display_name // ""')

# Git branch (from workspace, skip optional locks)
branch=""
if git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null); then
  branch=$(git -C "$git_root" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$git_root" rev-parse --short HEAD 2>/dev/null)
fi

# Staged / unstaged indicators matching the theme:
#   green dot = staged, yellow dot = unstaged, red dot = untracked
git_info=""
if [ -n "$branch" ]; then
  staged=""
  unstaged=""
  untracked=""
  if git -C "$cwd" diff --cached --quiet 2>/dev/null; then : ; else staged="\033[32m●\033[0m"; fi
  if git -C "$cwd" diff --quiet 2>/dev/null; then : ; else unstaged="\033[33m●\033[0m"; fi
  if [ -n "$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null)" ]; then untracked="\033[31m●\033[0m"; fi
  git_info=" \033[32m[${branch}${staged}${unstaged}${untracked}\033[32m]\033[0m"
fi

# Context usage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx=""
if [ -n "$used_pct" ]; then
  ctx=$(printf " \033[36mctx:%.0f%%\033[0m" "$used_pct")
fi

# Compose
printf " \033[37m%s\033[0m \033[1;33m%s\033[0m%b%b \033[38;5;253m%s\033[0m" \
  "$host" "$cwd" "$git_info" "$ctx" "$model"
