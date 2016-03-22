# here-script
Simple shell utility to quickly run scripts in specific directories.

Have commands you only run in certain places of your filesystem only a few keystrokes away ! Define rules to match your current working directory and make your commands available immediately.

## Rulebooks

The rulebooks define which directories will have which _here-scripts_. For example to make your basic git commands available in any Git repo :

``` YAML
rules: # Match directories whose hierarchy contains a `.git/` directory
    - sibling: .git/
actions:
    - # use with `hs l`
        binding: l
        title: pull
        description: Pull from origin.
        shell: git pull
    - # use with `hs p`
        binding: p
        title: push
        description: Push to origin
        shell: git push
    - # use with `hs c`
        binding: c
        title: commit
        description: Commit
        shell: git commit
```

Each rulebook has a set of `rules` and a set of `actions` and is written using YAML. Right now they are to be located in `~/.config/rules/`.

## Showing available _here-scripts_

Use either `hs -w` or `hs --what` to know which _here-scripts_ are available in the current location :

```
$ hs --what
        l       Pull from origin
        p       Push to origin
        c       Commit
$
```

You can also use the _oneline_ format in order to print it in places like your shell prompt using `hs -w oneline` ( example with my _fish_ prompt ) :

```
┬─[vitar67@host:~/Code/here-script]─[16:19:33]─[l pull, p push, c commit]
╰─>$
```
