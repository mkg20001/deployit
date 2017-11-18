#!/bin/bash

search_apm() {
  if [ "$PLATFORM" == "win" ]; then
    cd "$HOME/AppData/Local/atom"
    find -type f -iname "apm.cmd" > apm.txt
    while read f; do
      if [[ "$f" == *"apm.cmd" ]]; then
        apm_=${f/"apm.cmd"/apm}
        [ ! -e "$apm_" ] || apm="$apm_"
      fi
    done < apm.txt
    rm apm.txt
  else
    which apm && apm=$(which apm) && return 0
    which atom.apm && apm=$(which atom.apm) && return 0
  fi
}

search_apm

$apm install atom-beautify atom-clock atom-html-preview atom-lcov atom-material-syntax atom-material-ui atom-svg-icon-snippets atom-typescript busy-signal change-case coffee-navigator color-picker coverage-gutter coverage-markers debug docker git-checkout git-time-machine imagemin intentions jshint-snippets language-batchfile language-docker language-ejs language-svg lcov-info lint linter linter-coffeescript linter-docker linter-erb linter-htmlhint linter-jshint linter-php linter-shellcheck linter-stylelint linter-ui-default merge-conflicts minimap minimap-git-diff minimap-pigments pigments run slime svg-preview test todo-show

cpf config/atom-config.cson "$HOME/.atom/config.cson"
cpf config/atom-keymap.cson "$HOME/.atom/keymap.cson"
