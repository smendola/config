# AI commit messages

The `git` function in `~/.aliases` generates a commit message for these commands:

```sh
git commit -m ai
git commit -m x
git commit -am x
```

The literal messages `ai` and `x` are placeholders. Other explicit messages,
or commits without `-m`, use Git's default behavior. Generation runs during
Git's editor step, against the index Git
prepared for that commit. Generation failure or empty output aborts the commit.

Create `~/.config/ai-commit.sh` (or set `AI_COMMIT_CONFIG` to another file):

```bash
generate_ai_commit_comment() {
  my-ai-command
}
```

This Bash function receives a prompt and staged diff on standard input. It must
print only the commit message to standard output and return nonzero on failure.
Send diagnostics to stderr. Implement it using your preferred CLI or API;
if a CLI expects a prompt argument, read stdin with `prompt=$(cat)` and pass
`"$prompt"` to it. The staged diff is sent to whichever provider you configure.

The configuration is sourced as Bash, so it can define helpers and read API
credentials from your environment. It is not committed to this repository.
To bypass generation, use an explicit message or invoke `command git` directly.
The function also supports the dotfiles repository when run in `$HOME`.
The editor helper lives at `~/.local/bin/ai-commit-editor`.
