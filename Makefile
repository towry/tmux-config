all: source
install:
	./install.sh
source: install
	tmux source-file "$$HOME/.tmux.conf" && tmux display "Reloaded configuration -------"
