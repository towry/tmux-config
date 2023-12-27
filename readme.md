# Tmux Configuration

Tmux configuration, that supercharges your [tmux](https://tmux.github.io/) and builds cozy and cool terminal environment.

## Table of contents

1. [Installation](#installation)
1. [General settings](#general-settings)
1. [Key bindings](#key-bindings)
1. [Status line](#status-line)
1. [Nested tmux sessions](#nested-tmux-sessions)
1. [Copy mode](#copy-mode)
1. [Clipboard integration](#clipboard-integration)
1. [iTerm2 and tmux integration](#iterm2-and-tmux-integration)

## Installation

Prerequisites:

- tmux >= "v2.4"
- OSX, Linux (tested on Ubuntu 14 and CentOS7), FreeBSD (tested on 11.1)

On OSX you can install latest 2.6 version with `brew install tmux`. On Linux it's better to install from source, because official repositories usually contain outdated version. For example, CentOS7 - v1.8 from base repo, Ubuntu 14 - v1.8 from trusty/main. For how to install from source, see this [gist](https://gist.github.com/P7h/91e14096374075f5316e) or just google it.

To install tmux-config:

```
$ git clone https://github.com/towry/tmux-config.git
$ ./tmux-config/install.sh
```

`install.sh` script does following:

- copies files to `~/.tmux` directory
- symlink tmux config file at `~/.tmux.conf`, existing `~/.tmux.conf` will be backed up
- [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) will be installed at default location `~/.tmux/plugins/tpm`, unless already presemt
- required tmux plugins will be installed

Finally, you can jump into a new tmux session:

```
$ tmux new
```

## General settings

Windows and pane indexing starts from `1` rather than `0`. Scrollback history limit is set to `20000`. Automatic window renameing is turned off. Aggresive resizing is on. Message line display timeout is `1.5s`. Mouse support in `on`.

256 color palette support is turned on, make sure that your parent terminal is configured propertly. See [here](https://unix.stackexchange.com/questions/1045/getting-256-colors-to-work-in-tmux) and [there](https://github.com/tmux/tmux/wiki/FAQ)

```
# parent terminal
$ echo $TERM
xterm-256color

# jump into a tmux session
$ tmux new
$ echo $TERM
screen-256color
```

## Key bindings

So `~/.tmux.conf` overrides default key bindings for many action, to make them more reasonable, easy to recall and comforable to type.

Press `<prefix>:` to open command palette, search term `list-keys` and press
enter to open it, you can view all the key bindings. Alternately, use
`<prefix>?` to open the key bindings view.

## Status line

You might want to hide status bar using `<prefix> M-s` keybinding.

## Nested tmux sessions

One prefers using tmux on local machine to supercharge their terminal emulator experience, other use it only for remote scenarios to retain session/state in case of disconnect. Things are getting more complex, when you want to be on both sides. You end up with nested session, and face the question: **How you can control inner session, since all keybindings are caught and handled by outer session?**. Community provides several possible solutions.

The most common is to press `C-b` prefix twice. First one is caught by local session, whereas second is passed to remote one. Nothing extra steps need to be done, this works out of the box. However, root keytable bindings are still handled by outer session, and cannot be passed to inner one.

Second attempt to tackle this issue, is to [setup 2 individual prefixes](https://simplyian.com/2014/03/29/using-tmux-remotely-within-a-local-tmux-session/), `C-b` for local session, and `C-a` for remote session. And, you know, it feels like:

![tmux in tmux](http://i.imgur.com/HQBdV1J.jpg)

And finally accepted solution, turn off all keybindings and key prefix handling in outer session, when working with inner one. This way, outer session just sits aside, without interfering keystrokes passed to inner session. Credits to [http://stahlke.org/dan/tmux-nested/](http://stahlke.org/dan/tmux-nested/) and this [Github issue](https://github.com/tmux/tmux/issues/237)

So, how it works. When in outer session, simply press `F12` to toggle off all keybindings handling in outer session. Now work with inner session using the same keybinding scheme and same keyprefix. Press `F12` to turn on outer session back.

![nested sessions](https://user-images.githubusercontent.com/768858/33151636-84a0bab2-cfe1-11e7-9d5d-412525689c9b.gif)

You might notice that when key bindings are "OFF", special `[OFF]` visual indicator is shown in the status line, and status line changes its style (colored to gray).

### Local and remote sessions

Remote session is detected by existence of `$SSH_CLIENT` variable. When session is remote, following changes are applied:

- status line is docked to bottom; so it does not stack with status line of local session
- some widgets are removed from status line: battery, date time. The idea is to economy width, so on wider screens you can open two remote tmux sessions in side-by-side panes of single window of local session.

You can apply remote-specific settings by extending `~/.tmux/.tmux.remote.conf` file.

## Copy mode

There are some tweaks to copy mode and scrolling behavior, you should be aware of.

There is a keybinding to enter Copy mode: `<prefix>[`. Once in copy mode, you have several scroll controls:

- scroll by line: `M-Up`, `M-down`
- scroll by half screen: `M-PageUp`, `M-PageDown`
- scroll by whole screen: `PageUp`, `PageDown`
- scroll by mouse wheel, scroll step is changed from `5` lines to `2`

`Space` starts selection, `Enter` copies selection and exits copy mode. List all items in copy buffer using `prefix C-p`, and paste most recent item from buffer using `prexix p`.

`y` just copies selected text and is equivalent to `Enter`, `Y` copies whole line, and `D` copies by the end of line.

Also, note, that when text is copied any trailing new lines are stripped. So, when you paste buffer in a command prompt, it will not be immediately executed.

You can also select text using mouse. Default behavior is to copy text and immediately cancel copy mode on `MouseDragEnd` event. This is annoying, because sometimes I select text just to highlight it, but tmux drops me out of copy mode and reset scroll by the end. I've changed this behavior, so `MouseDragEnd` does not execute `copy-selection-and-cancel` action. Text is copied, but copy mode is not cancelled and selection is not cleared. You can then reset selection by mouse click.

![copy and scroll](https://user-images.githubusercontent.com/768858/33231146-e390afc8-d1f8-11e7-80ad-6977fc3a5df7.gif)

## Clipboard integration

When you copy text inside tmux, it's stored in private tmux buffer, and not shared with system clipboard. Same is true when you SSH onto remote machine, and attach to tmux session there. Copied text will be stored in remote's session buffer, and not shared/transported to your local system clipboard. And sure, if you start local tmux session, then jump into nested remote session, copied text will not land in your system clipboard either.

This is one of the major limitations of tmux, that you might just decide to give up using it. Let's explore possible solutions:

- share text with OSX clipboard using **"pbcopy"**
- share text with OSX clipboard using [reattach-to-user-namespace](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard) wrapper to access "pbcopy" from tmux environment (seems on OSX 10.11.5 ElCapitan this is not needed, since I can still access pbcopy without this wrapper).
- share text with X selection using **"xclip"** or **"xsel"** (store text in primary and clipboard selections). Works on Linux when DISPLAY variable is set.

All solutions above are suitable for sharing tmux buffer with system clipboard for local machine scenario. They still does not address remote session scenarios. What we need is some way to transport buffer from remote machine to the clipboard on the local machine, bypassing remote system clipboard.

There are 2 workarounds to address remote scenarios.

Use **[ANSI OSC 52](https://en.wikipedia.org/wiki/ANSI_escape_code#Escape_sequences)** escape [sequence](https://blog.vucica.net/2017/07/what-are-osc-terminal-control-sequences-escape-codes.html) to talk to controlling/parent terminal and pass buffer on local machine. Terminal should properly undestand and handle OSC 52. Currently, only iTerm2 and XTerm support it. OSX Terminal, Gnome Terminal, Terminator do not.

Second workaround is really involved and consists of [local network listener and SSH remote tunneling](https://apple.stackexchange.com/a/258168):

- SSH onto target machine with remote tunneling on
  ```
  ssh -R 2222:localhost:3333  alexeys@192.168.33.100
  ```
- When text is copied inside tmux (by mouse, by keyboard by whatever configured shortcut), pipe text to network socket on remote machine
  ```
  echo "buffer" | nc localhost 2222
  ```
- Buffer will be sent thru SSH remote tunnel from port `2222` on remote machine to port `3333` on local machine.
- Setup a service on local machine (systemd service unit with socket activation), which listens on network socket on port `3333`, and pipes any input to `pbcopy` command (or `xsel`, `xclip`).

This tmux-config does its best to integrate with system clipboard, trying all solutions above in order, and falling back to OSC 52 ANSI escape sequences in case of failure.

On OSX you might need to install `reattach-to-user-namespace` wrapper: `brew install reattach-to-user-namespace`, and make sure OSC 52 sequence handling is turned on in iTerm. (Preferences -> General -> Applications in Terminal may access clipboard).

On Linux, make sure `xclip` or `xsel` is installed. For remote scenarios, you would still need to setup network listener and use SSH remote tunneling, unless you terminal emulators supports OSC 52 sequences.

## iTerm2 and tmux integration

If you're an iTerm use same to me, most likely you already have a muscle memory for most common actions and keybindings (split pane, focus pane, fullscreen pane, move between tabs, create new tab, etc). When I switched to tmux, I found new key table more difficult: more keys to type, don't forget to enter `prefix` and recall if you've already pressed it or not (compare `C-a, c` with "⌘T", or `C-a ->` with "⌘⌥->"). iTerm2 keybinding was so natural to me, so I decided to remap most common keybindings to tell iTerm2 to execute corresponding tmux actions.

You can setup new profile in iTerm preferences to override default keybindings, to tell iTerm to send pre-configured sequences of keys, that will trigger corresponding action in tmux.

![iterm preferences](https://user-images.githubusercontent.com/768858/33185301-54afc402-d08a-11e7-9622-232a4607df8b.png)

For example, when "^⌘↑" pressed, sequence of bytes `0x01 0x1b 0x5b 0x31 0x3b 0x35 0x41` are sent through terminal to running tmux instance, that interprets them as `C-a C-↑` keybinding and triggers `resize-pane -U` according to our `.tmux.conf` configuration.

You can get binary representation of any keys, using `showkey` or `od` commands

```
$od -t x1

^A^[[1;5A   // press C-a C-↑ on your keyboard
0000000 01 1b 5b 31 3b 35 41
0000007
```

```
$ showkey -a
Press any keys - Ctrl-D will terminate this program

^A        1 0001 0x01
^[[1;5A  27 0033 0x1b
         91 0133 0x5b
         49 0061 0x31
         59 0073 0x3b
         53 0065 0x35
         65 0101 0x41
```

You can remap whatever key in this way, but I do this only for those ones, which have similar analogous action in tmux and are most common(resize pane, zoom pane, create new window, etc). See table with keybindings above.

As additional step, you can setup this new iTerm profile as default one, and tell it to jump into tmux session right off the start.

![iterm tmux default profile](https://user-images.githubusercontent.com/768858/33185302-54d36b78-d08a-11e7-96b9-7ab3069fc369.png)

You can then go full screen in iTerm, so iTerm tabs and frame do not distract you (anyway now you're using iTerm just as a tunnel to your tmux, everything else happens inside tmux).

![full screen mode](https://user-images.githubusercontent.com/768858/33185303-54fa0378-d08a-11e7-8fd3-068f0af712c7.png)
