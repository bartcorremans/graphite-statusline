# graphite-statusline

Simple script that outputs position in the current [Graphite](https://graphite.dev) stack, e.g. "3/4".

Intended to be used in a terminal powerline, e.g. [p10k](https://github.com/romkatv/powerlevel10k).

## Requirements

The output includes an icon that requires a [Nerd font](https://www.nerdfonts.com/#home) to be installed and used by your terminal.

The icon is `nf-oct-stack` (`\uf51e`).

You can of course remove it or swap it for something else.

## Example usage

### p10k

Create a custom prompt in `~/.p10k.zsh` (or wherever your p10k config is):

```sh
function prompt_graphite() {
    if [[ -d .git ]] || git rev-parse --git-dir > /dev/null 2>&1; then
        local stack=$(~/graphite-statusline/graphite-stack.sh)
        p10k segment -f 66 -t "$stack"
    fi
}
```

Also in the p10k config, add it to the prompt:

```sh
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    # ...other elements
    vcs
    graphite
    # ...other elements
)
```
