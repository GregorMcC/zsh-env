# zsh-env

A zsh plugin that displays environment variable values as you type them.

## Motivation

Ever typed `echo $PATH` just to check what's in it? This plugin shows variable values automatically as you type, so you don't need to run commands just to peek at what a variable contains.

## Installation

### Oh My Zsh

```bash
git clone https://github.com/gregormcc/zsh-env ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-env
```

Add to `~/.zshrc`:

```bash
plugins=(... zsh-env)
```

### Manual

```bash
git clone https://github.com/gregormcc/zsh-env ~/.zsh/zsh-env
echo "source ~/.zsh/zsh-env/zsh-env.plugin.zsh" >> ~/.zshrc
```

## Usage

Type environment variables and see their values appear below:

```bash
$ echo $HOME $PATH ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
$HOME → /Users/yourname
$PATH → /opt/homebrew/bin:/opt/homebrew/sbin:/u...
${ZSH_CUSTOM:-~/.oh-my-zsh/custom} → ~/.oh-my-zsh/custom
↓ 1 more below [Alt+↓ to scroll]
```

**Keyboard shortcuts:**
- `Alt+↓/↑` - Scroll through multiple variables

## Features

- Real-time variable value display
- Supports `${VAR:-default}` parameter expansions
- Auto-redacts sensitive variables (keys, tokens, passwords)
- Scrollable pagination for multiple variables
- Adapts to terminal height

## License

MIT
