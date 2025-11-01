# Setting Up zsh-env as a Plugin

To make this available as an installable plugin, follow these steps:

## 1. Initialize Git Repository

If you haven't already:

```bash
cd /Users/gregormccreadie/Development/zsh-env
git init
git add .
git commit -m "Initial commit: zsh-env plugin"
```

## 2. Create GitHub Repository

1. Go to [GitHub](https://github.com/new) and create a new repository
2. Name it `zsh-env` (or whatever you prefer)
3. Don't initialize with README (you already have one)
4. Copy the repository URL (e.g., `https://github.com/yourusername/zsh-env.git`)

## 3. Push to GitHub

```bash
git remote add origin https://github.com/yourusername/zsh-env.git
git branch -M main
git push -u origin main
```

## 4. Update README

Replace `yourusername` in the README.md with your actual GitHub username, then:

```bash
git add README.md
git commit -m "Update README with actual repository URL"
git push
```

## 5. Test Installation

You can now install it using any of the methods in the README:

```bash
# Test manual installation
git clone https://github.com/yourusername/zsh-env ~/.zsh/zsh-env-test
source ~/.zsh/zsh-env-test/zsh-env.plugin.zsh
```

## 6. Optional: Add Tags for Releases

When you want to mark a version:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

Users can then install specific versions:

```bash
# Zinit with version tag
zinit light yourusername/zsh-env@v1.0.0
```

## Optional: Submit to Oh My Zsh

If you want to include this in the official Oh My Zsh plugins:

1. Fork the [Oh My Zsh repository](https://github.com/ohmyzsh/ohmyzsh)
2. Add your plugin to `plugins/zsh-env/`
3. Submit a pull request

