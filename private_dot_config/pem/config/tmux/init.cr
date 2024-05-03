
# --------------------------------
# Function List
# --------------------------------
    is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)?$'"

    switch_mouse='set -g mouse ; display "Mouse #{?mouse,ON,OFF}!"'
    switch_vim_mouse='send-keys "#{?mouse,a,b}"'

# --------------------------------
# osc 52
# --------------------------------
run-shell "tmux setenv -g TMUX_VERSION $(tmux -V | cut -c 6-8)"

    if-shell -b '[ "$(echo "$TMUX_VERSION >= 3.3" | bc)" = 1 ]' " \
        set-window-option -g allow-passthrough on "

    # transfer copied text to attached terminal with yank
    # transfer most-recently copied text to attached terminal with yank
    # transfer previously copied text (chosen from a menu) to attached terminal
    if-shell -b '[ "$(echo "3.3 > $TMUX_VERSION  &&  $TMUX_VERSION >= 2.4" | bc)" = 1 ]' " \
        bind-key -T copy-mode-vi Y send-keys -X copy-pipe 'yank > #{pane_tty}' ; \
        bind-key -n M-y run-shell 'tmux save-buffer - | yank > #{pane_tty}' ; \
        bind-key -n M-Y choose-buffer 'run-shell tmux save-buffer -b \"%%%\" - | yank > #{pane_tty}'"


# --------------------------------
# Mouse support
# --------------------------------
    set-option -g mouse on
    # 绑定快捷键来切换鼠标状态
    bind-key -n C-M-M run-shell 'tmux-toggle-mouse toggle'

    # setw -g mode-keys vi 
    set-window-option -g mode-keys vi # 开启vi风格后，支持vi的C-d、C-u、hjkl等快捷键


    bind P paste-buffer
    bind C-v paste-buffer
    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi y send-keys -X copy-selection
    bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

    # prevent tmux from exiting copy mode after selection with mouse
    # bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection -x
    bind-key -T copy-mode-vi MouseDown2Pane paste-buffer -p

    # prevent run command
    bind ] paste-buffer -p


    # unbind mouse2

    bind -n C-M-v copy-mode
    bind -n C-M-b choose-buffer

    bind-key -T copy-mode-vi 'v' send -X begin-selection
    bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel
    # bind -n vi-copy v begin-selection # 绑定v键为开始选择文本
    # bind -n vi-copy y copy-selection # 绑定y键为复制选中文本
    # bind-key -T copy-mode-vi 'v' send -X begin-selection
    # bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
    # bind-key -t vi-copy 'v' begin-selection
    # bind-key -t vi-copy 'y' copy-selection


# --------------------------------
# Setting Zone
# --------------------------------
    set -g base-index 1 # 设置窗口的起始下标为1
    set -g pane-base-index 1 # 设置面板的起始下标为1

    # Ture Color support
    set -g default-terminal "xterm-256color"
    set -ga terminal-overrides ",xterm*:Tc"

    # From: tmux-plugins/tmux-sensible
    set-option -g history-limit 50000

    bind r source-file ~/.tmux.conf \; display "Reload!"

# --------------------------------
# Fast window navigation
# --------------------------------
    bind -n C-M-h select-pane -L
    bind -n C-M-j select-pane -D
    bind -n C-M-k select-pane -U
    bind -n C-M-l select-pane -R

    bind -n C-M-e next-window
    # Credit: https://nju-projectn.github.io/ics-pa-gitbook/ics2023/0.5.html
    bind -n C-M-w new-window -c "#{pane_current_path}"
    bind -n C-M-q previous-window
    
    bind -n C-M-c splitw -h -c '#{pane_current_path}' # 水平方向新增面板，默认进入当前目录
    bind -n C-M-x confirm-before -p "kill-pane #P? (y/n)" kill-pane

# --------------------------------
# vim-tmux-navigator
# --------------------------------
# Smart pane switching with awareness of Vim splits.
# See: https://github.com/christoomey/vim-tmux-navigator

    bind-key -n 'M-H' if-shell "$is_vim" 'send-keys M-H'  'select-pane -L'
    bind-key -n 'M-J' if-shell "$is_vim" 'send-keys M-J'  'select-pane -D'
    bind-key -n 'M-K' if-shell "$is_vim" 'send-keys M-K'  'select-pane -U'
    bind-key -n 'M-L' if-shell "$is_vim" 'send-keys M-L'  'select-pane -R'

    bind-key -n 'M-X' if-shell "$is_vim" 'send-keys M-X'  'confirm-before -p "kill-pane #P? (y/n)" kill-pane'
    bind-key -n 'M-C' if-shell "$is_vim" 'send-keys M-C'  'split-window -h -c "#{pane_current_path}"'

    tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
    if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
        "bind-key -n 'M-\\' if-shell \"$is_vim\" 'send-keys M-\\'  'select-pane -l'"
    if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
        "bind-key -n 'M-\\' if-shell \"$is_vim\" 'send-keys M-\\\\'  'select-pane -l'"






# --------------------------------
# Statue Line Theme
# --------------------------------
    # This tmux statusbar config was created by tmuxline.vim
    # on Thu, 15 Jun 2023
    set -g status-justify "left"
    set -g status "on"
    set -g status-left-style "none"
    set -g message-command-style "fg=#3fc5b7,bg=#3b3b3b"
    set -g status-right-style "none"
    set -g pane-active-border-style "fg=#368aeb"
    set -g status-style "none,bg=#252525"
    set -g message-style "fg=#3fc5b7,bg=#3b3b3b"
    set -g pane-border-style "fg=#3b3b3b"
    set -g status-right-length "100"
    set -g status-left-length "100"
    setw -g window-status-activity-style "none"
    setw -g window-status-separator ""
    setw -g window-status-style "none,fg=#777777,bg=#252525"
    set -g status-left "#[fg=#252525,bg=#368aeb] #S #[fg=#368aeb,bg=#252525,nobold,nounderscore,noitalics]"
    set -g status-right "#[fg=#3b3b3b,bg=#252525,nobold,nounderscore,noitalics]#[fg=#3fc5b7,bg=#3b3b3b] %Y-%m-%d | %H:%M #[fg=#368aeb,bg=#3b3b3b,nobold,nounderscore,noitalics]#[fg=#252525,bg=#368aeb] #h "
    setw -g window-status-format "#[fg=#777777,bg=#252525] #I |#[fg=#777777,bg=#252525] #W "
    setw -g window-status-current-format "#[fg=#252525,bg=#3b3b3b,nobold,nounderscore,noitalics]#[fg=#3fc5b7,bg=#3b3b3b] #I |#[fg=#3fc5b7,bg=#3b3b3b] #W #[fg=#3b3b3b,bg=#252525,nobold,nounderscore,noitalics]"

# --------------------------------
# Plug List
# --------------------------------
     set -g @tpm_plugins '          \
       tmux-plugins/tpm             \
       fcsonline/tmux-thumbs        \
       tmux-plugins/tmux-copycat    \
       fmount/tmux-quickfix         \
     '
    set -g @thumbs-select-fg-color \#3e444e


# --------------------------------
# .tmux.conf ref start
# --------------------------------
    # # source tmux.init
    # if "test -f ~/.config/pem/config/tmux/init.cr" \
    #     "source ~/.config/pem/config/tmux/init.cr"



    # if "test ! -d ~/.config/tmux/plugins/tpm" \
    #    "run 'git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm && ~/.config/tmux/plugins/tpm/bin/install_plugins'"
    # set-environment -g TMUX_PLUGIN_MANAGER_PATH '~/.config/tmux/plugins'
    # # # List of plugins
    # # set -g @plugin 'tmux-plugins/tmux-copycat'

        
    # # Initialize TMUX plugin manager 
    # # (keep this line at the very bottom of tmux.conf)
    # run-shell '~/.config/tmux/plugins/tmux-thumbs/tmux-thumbs.tmux'
    # run '~/.config/tmux/plugins/tpm/tpm'
# --------------------------------
# .tmux.conf ref end
# --------------------------------