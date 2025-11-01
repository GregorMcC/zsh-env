# zsh-env

A zsh plugin that displays environment variable values inline as you type them in your shell.

## Motivation

Ever typed `echo $PATH` just to check what's in it? Or wondered what `$XDG_CONFIG_HOME` is actually set to? This plugin shows you the values of environment variables as you type them, right below your prompt.

Instead of typing a command and running it just to see what a variable contains, the value appears automatically as soon as you type `$VARIABLE_NAME`. No more mental context switching or interrupting your flow.

## Features

- **Real-time display**: Shows variable values as you type
- **Security-conscious**: Automatically redacts sensitive variables (keys, tokens, passwords)
- **Smart filtering**: Only shows variables that are set (unset variables are skipped)
- **Smart truncation**: Long values are automatically truncated to prevent overflow
- **Pagination**: Scroll through multiple variables with Alt+↓/↑, with clear counts ("↑ 2 more above")
- **Deduplication**: Shows each variable only once, even if used multiple times
- **Adaptive**: Adjusts display based on terminal height
- **Compatible**: Works with Powerlevel10k, Oh My Zsh, and other frameworks

## Installation

First, you'll need to set up a git repository and push this code. Then choose an installation method below.

### Quick Start

Once you have the repository URL (e.g., `https://github.com/yourusername/zsh-env`), the easiest way is to use a plugin manager (see below). For manual installation:

```bash
git clone https://github.com/yourusername/zsh-env ~/.zsh/zsh-env
echo "source ~/.zsh/zsh-env/zsh-env.plugin.zsh" >> ~/.zshrc
```

Then restart your shell or run `source ~/.zshrc`.

### Oh My Zsh

1. Clone the plugin into your custom plugins directory:

```bash
git clone https://github.com/yourusername/zsh-env ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-env
```

2. Add `zsh-env` to your plugins array in `~/.zshrc`:

```bash
plugins=(git zsh-env ...)
```

3. Restart your shell or run `source ~/.zshrc`

### Zinit

Add to your `~/.zshrc`:

```bash
zinit light yourusername/zsh-env
```

Or use turbo mode for faster loading:

```bash
zinit ice wait lucid
zinit light yourusername/zsh-env
```

### Zgenom

Add to your `~/.zshrc`:

```bash
zgenom load yourusername/zsh-env
```

Then regenerate your init script: `zgenom save`

### Antigen

Add to your `~/.zshrc`:

```bash
antigen bundle yourusername/zsh-env
```

### Homebrew (if you publish a tap)

```bash
brew install yourusername/zsh-env/zsh-env
```

Or as a cask (if preferred):

```bash
brew install --cask zsh-env
```

Then add to `~/.zshrc`:

```bash
source $(brew --prefix)/share/zsh-env/zsh-env.plugin.zsh
```

## Usage

Simply start typing environment variables in your shell:

```bash
$ echo $HOME
$HOME → /Users/yourname

$ echo $PATH
$PATH → /opt/homebrew/bin:/opt/homebrew/sbin:/u...

$ echo $HOME $USER $SHELL $PATH $PWD
↑ 2 more above
$SHELL → /bin/zsh
$PATH → /opt/homebrew/bin:/opt/homebrew/sbin:/u...
$PWD → /Users/yourname/projects
↓ 1 more below

$ echo $API_KEY
$API_KEY → ***REDACTED***
```

- Sensitive variables (containing patterns like KEY, SECRET, TOKEN, PASSWORD, etc.) are automatically redacted for security
- Unset variables are automatically skipped (not shown)
- When scrolling, you see clear counts like "↑ 2 more above" or "↓ 3 more below"

### Keyboard Shortcuts

- **Alt+↓** (Alt+Down Arrow): Scroll down to see more variables
- **Alt+↑** (Alt+Up Arrow): Scroll back up
- **Enter**: Execute the command and clear the hints

## Configuration

The plugin adapts automatically to your terminal size:

- Very short terminals (< 20 lines): Shows 1 hint at a time
- Short terminals (20-29 lines): Shows 2 hints at a time  
- Normal terminals (30+ lines): Shows 3 hints at a time

Individual variable values are truncated at 50 characters. To adjust this, find the `max_len=50` line in `_zsh_env_show_hints()` function in `zsh-env.plugin.zsh` and change the value.

### Security

Variables matching these patterns are automatically redacted:
- `*KEY*`, `*SECRET*`, `*TOKEN*`, `*PASSWORD*`, `*PASS*`, `*AUTH*`, `*CREDENTIAL*`, `*PRIVATE*`

To customize the redaction patterns, edit the `_zsh_env_is_sensitive()` function in `zsh-env.plugin.zsh`.

## How It Works

The plugin intercepts keystrokes using zsh's ZLE (Zsh Line Editor), parses the command line for environment variable patterns (`$VAR` or `${VAR}`), looks up their values, and displays them using `zle -M` at the bottom of the terminal.

## Requirements

- Zsh 5.0+
- A terminal that supports ANSI escape codes

## License

MIT

## Troubleshooting

If hints don't appear:
- Make sure you're using zsh (not bash): `echo $ZSH_VERSION`
- Check that the plugin loaded: `which _zsh_env_show_hints` should return a function path
- Try setting a test variable: `export TEST=123` then type `$TEST` in your shell

If Alt+Arrow keys don't work for scrolling:
- Try using different key combinations if your terminal/OS uses different key codes
- Check your terminal's key mapping settings
- The plugin falls back to normal history navigation if no hints are displayed

## Contributing

Issues and pull requests are welcome! Please feel free to submit improvements or bug reports.
