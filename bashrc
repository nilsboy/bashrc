### START

# prevent bashrc from loading twice
if [[ $BASHRC_IS_LOADED == $$ ]] ; then
  echo "bashrc already loaded - returning."
  return
fi

# for debugging
# set -o history

USE_CURRENT_DIR_AS_HOME=$1

### Set remote user stuff

if [[ $USE_CURRENT_DIR_AS_HOME ]] ; then
    [[ $REMOTE_USER   ]] || export REMOTE_USER=$(basename $PWD)
    [[ $REMOTE_HOME   ]] || export REMOTE_HOME=$PWD
else
    [[ $REMOTE_USER   ]] || export REMOTE_USER=$USER
    [[ $REMOTE_HOME   ]] || export REMOTE_HOME=$HOME
fi

[[ $REMOTE_BASHRC ]] || export REMOTE_BASHRC="$REMOTE_HOME/.bashrc"
[[ $REMOTE_HOST   ]] || export REMOTE_HOST=${SSH_CLIENT%% *}

### Path

if [[ ! $BASHRC_PATH_ORG ]] ; then
  BASHRC_PATH_ORG=$PATH
fi

unset PATH
if [[ $REMOTE_HOME != $HOME ]] ; then
    PATH=$REMOTE_HOME/.bin:$REMOTE_HOME/bin:
fi
PATH+=~/.bin:~/bin:~/opt/bin
PATH+=:./node_modules/.bin
# PATH+=:~/node_modules/bin
PATH+=:$BASHRC_PATH_ORG
export PATH

# Replace proxy env when using a tunneled ssh proxy
if [[ $ssh_remote_proxy ]] ; then

    http_proxy=http://$ssh_remote_proxy
    https_proxy=http://$ssh_remote_proxy
    ftp_proxy=ftp://$ssh_remote_proxy

    HTTP_PROXY=http://$ssh_remote_proxy
    HTTPS_PROXY=http://$ssh_remote_proxy
    FTP_PROXY=ftp://$ssh_remote_proxy
fi

### Run local rc scripts

if [ -d $REMOTE_HOME/.bashrc.d ] ; then
    for rc in $(ls $REMOTE_HOME/.bashrc.d/* 2>/dev/null) ; do
        source $rc
    done
fi

### Checking if running inside docker

grep docker /proc/1/cgroup &>/dev/null && export BASHRC_INSIDE_DOCKER=1

### Return if not an interactive shell

[[ $PS1 ]] || return

### Env

BASHRC_COLOR_NO_COLOR='\[\e[33;0;m\]'
BASHRC_COLOR_GREEN='\[\e[38;5;2m\]'
BASHRC_BG_COLOR=$BASHRC_COLOR_NO_COLOR

if [[ "$LANG" =~ utf || "$LANG" =~ UTF ]] ; then
    # all good
    true
else
    _available_locales=$(locale -a 2>/dev/null)
    if [[ "$_available_locales" =~ "en_US.utf8" ]] ; then
        LANG="en_US.utf8"
    fi
    unset _available_locales
fi

if [[ ! "$LANG" ]] ; then
    LANG=C
fi

# use english messages on the command line
export LC_MESSAGES=C

export BROWSER=links

# remove domain from hostname if necessary
HOSTNAME=${HOSTNAME%%.*}

export LINES COLUMNS

export BASHRC_TTY=$(tty)

export FTP_PASSIVE=1

# snap workaround
# https://bugs.launchpad.net/snapd/+bug/1575593
export MANPATH=
if type manpath &>/dev/null ; then
  export MANPATH=$(manpath):$(ls -d /snap/*/current/{usr,}/share/man 2>/dev/null | perl -pe 's/\n/:/g')
fi

### Input config

export INPUTRC=$REMOTE_HOME/.inputrc

# set vi edit mode
bind 'set editing-mode vi'

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# case insensitive pathname expansion
shopt -s nocaseglob

# turn off beeping
bind 'set bell-style none'
# xset b off

# keep original version of edited history entries
bind 'set revert-all-at-newline on'

# add slash to symlinks to directoryies on tab completion
bind 'set mark-symlinked-directories on'

# skip directories starting with a dot from tab completion
bind 'set match-hidden-files off'

# case insensitive tab completion
bind 'set completion-ignore-case on'

# treat - and _ as equal in completion
bind 'set completion-map-case on'

# show common postfixes in completion
bind 'set completion-prefix-display-length 1'

# tab completion with single tab (don't ring the bell)
bind 'set show-all-if-ambiguous on'

# don't duplicate completed part off already complete term when within a term
bind 'set skip-completed-text on'

# never ask to show all completions - just do
bind 'set completion-query-items -1'

# don't show completions in pager
bind 'set page-completions off'

# don't expand tilde - disables e-key...
# bind 'tilde-expand off'

# expand hi to underscores
set 'completion-map-case on'

# do not attempt to search the PATH for possible completions
# when completion is attempted on an empty line
shopt -s no_empty_cmd_completion

# reenable ctrl+s for forward history search (XOFF)
stty stop ^-

# reenable ctrl+q (XON)
stty start ^-

# ctrl-l clear screen but stay in current row
bind -x '"\C-l":printf "\33[2J"'

### conveniences

export dotfiles='.!(|.)'

### Aliases

alias    ls='ls --color=auto --time-style=+"%a %F %H:%M" -v '
alias     l='ls -1'
alias    ll='ls -lh'
alias    lr='ls -rt1'
alias   llr='ls -rtlh'
alias    lc='ls -rtlhc'
alias    la='ls -Ah'
alias   lla='ls -lAh'

function lls() {
  ls -1ld *$**
}

# https://github.com/seebi/dircolors-solarized
export LS_COLORS='no=00:fi=00:di=36:ln=35:pi=30;44:so=35;44:do=35;44:bd=33;44:cd=37;44:or=05;37;41:mi=05;37;41:ex=01;31:*.cmd=01;31:*.exe=01;31:*.com=01;31:*.bat=01;31:*.reg=01;31:*.app=01;31:*.txt=32:*.org=32:*.md=32:*.mkd=32:*.h=32:*.c=32:*.C=32:*.cc=32:*.cxx=32:*.objc=32:*.sh=32:*.csh=32:*.zsh=32:*.el=32:*.vim=32:*.java=32:*.pl=32:*.pm=32:*.py=32:*.rb=32:*.hs=32:*.php=32:*.htm=32:*.html=32:*.shtml=32:*.xml=32:*.json=32:*.yaml=32:*.rdf=32:*.css=32:*.js=32:*.man=32:*.0=32:*.1=32:*.2=32:*.3=32:*.4=32:*.5=32:*.6=32:*.7=32:*.8=32:*.9=32:*.l=32:*.n=32:*.p=32:*.pod=32:*.tex=32:*.bmp=33:*.cgm=33:*.dl=33:*.dvi=33:*.emf=33:*.eps=33:*.gif=33:*.jpeg=33:*.jpg=33:*.JPG=33:*.mng=33:*.pbm=33:*.pcx=33:*.pdf=33:*.pgm=33:*.png=33:*.ppm=33:*.pps=33:*.ppsx=33:*.ps=33:*.svg=33:*.svgz=33:*.tga=33:*.tif=33:*.tiff=33:*.xbm=33:*.xcf=33:*.xpm=33:*.xwd=33:*.xwd=33:*.yuv=33:*.aac=33:*.au=33:*.flac=33:*.mid=33:*.midi=33:*.mka=33:*.mp3=33:*.mpa=33:*.mpeg=33:*.mpg=33:*.ogg=33:*.ra=33:*.wav=33:*.anx=33:*.asf=33:*.avi=33:*.axv=33:*.flc=33:*.fli=33:*.flv=33:*.gl=33:*.m2v=33:*.m4v=33:*.mkv=33:*.mov=33:*.mp4=33:*.mp4v=33:*.mpeg=33:*.mpg=33:*.nuv=33:*.ogm=33:*.ogv=33:*.ogx=33:*.qt=33:*.rm=33:*.rmvb=33:*.swf=33:*.vob=33:*.wmv=33:*.doc=31:*.docx=31:*.rtf=31:*.dot=31:*.dotx=31:*.xls=31:*.xlsx=31:*.ppt=31:*.pptx=31:*.fla=31:*.psd=31:*.7z=1;35:*.apk=1;35:*.arj=1;35:*.bin=1;35:*.bz=1;35:*.bz2=1;35:*.cab=1;35:*.deb=1;35:*.dmg=1;35:*.gem=1;35:*.gz=1;35:*.iso=1;35:*.jar=1;35:*.msi=1;35:*.rar=1;35:*.rpm=1;35:*.tar=1;35:*.tbz=1;35:*.tbz2=1;35:*.tgz=1;35:*.tx=1;35:*.war=1;35:*.xpi=1;35:*.xz=1;35:*.z=1;35:*.Z=1;35:*.zip=1;35:*.ANSI-30-black=30:*.ANSI-01;30-brblack=01;30:*.ANSI-31-red=31:*.ANSI-01;31-brred=01;31:*.ANSI-32-green=32:*.ANSI-01;32-brgreen=01;32:*.ANSI-33-yellow=33:*.ANSI-01;33-bryellow=01;33:*.ANSI-34-blue=34:*.ANSI-01;34-brblue=01;34:*.ANSI-35-magenta=35:*.ANSI-01;35-brmagenta=01;35:*.ANSI-36-cyan=36:*.ANSI-01;36-brcyan=01;36:*.ANSI-37-white=37:*.ANSI-01;37-brwhite=01;37:*.log=01;32:*~=01;32:*#=01;32:*.bak=01;36:*.BAK=01;36:*.old=01;36:*.OLD=01;36:*.org_archive=01;36:*.off=01;36:*.OFF=01;36:*.dist=01;36:*.DIST=01;36:*.orig=01;36:*.ORIG=01;36:*.swp=01;36:*.swo=01;36:*,v=01;36:*.gpg=34:*.gpg=34:*.pgp=34:*.asc=34:*.3des=34:*.aes=34:*.enc=34:';

alias f=find.relevant.
alias g='grep -i'
alias ga='grep.and'
alias s='sort'

alias cdt='mkdir -p $REMOTE_HOME/tmp && cd $REMOTE_HOME/tmp'
function cdm() { mkdir -p "$@" && cd "$@" ; }
function cdh() { cd $(cd-history $@) ; } 
function cdf() { cd $(cd-find $@) ; } 

alias type='type -a'

alias shell-turn-off-line-wrapping="tput rmam"
alias shell-turn-on-line-wrapping="tput smam"

alias cp="cp -i"
alias mv="mv -i"
alias df="df -h"
alias du="du -sch"
alias crontab="crontab -i"
alias xargs='xargs -I {} -d \\n'
# aliases with a trailing blank allow for alias expansion of the
# following command word
alias sudo='sudo '

function apts() { apt-cache search --names-only "$1" | grep -i "$@" | less ; }
alias aptg="apt search"
alias aptw="apt show"
alias apti="sudo apt install"
alias aptp="sudo dpkg -P"
alias aptc="sudo apt-get autoremove"
alias apt-list-package-contents="dpkg -L"
alias apt-find-package-containing="dpkg -S"
alias apt-list-installed="apt list --installed | g"

alias normalizefilenames="xmv -nd"
alias m=man-multi-lookup
alias srd=tmux-reattach

alias ps-grep="pgrep -fl"
alias ps-attach="sudo strace -ewrite -s 1000 -p"
alias pgrep="pgrep -af"

alias p=pstree-search
if [[ ! $(type -t pstree) ]] ; then
    alias p="ps axjf"
fi

alias top="top -c"
alias rsync="rsync -h"
alias c=man-cheatsh

function  j() { jobs=$(jobs) bash-jobs ; }
function  t() { tree -C --summary "$@" | less ; }
function td() { tree -d "$@" | less ; }
function csvview() { command csvview "$@" | LESS= less -S ; }

### Vim and less

# git commit needs absolute path
EDITOR=vi
if [[ $REMOTE_HOST ]] ; then
    EDITOR="DISPLAY= $EDITOR"
fi

export EDITOR
export VISUAL="$EDITOR"

alias vie=vi-executable

export LESS="-j0.5 -inRgS"
# Make less more friendly for non-text input files, see lesspipe(1)
if [[ $(type -p lesspipe ) ]] ; then
    eval "$(lesspipe)"
fi
export PAGER=less

export MANWIDTH=80

### Misc

# Get parent process id
function parent() {
    # ps can not deal with PID 0 which might be set when running inside docker
    if [[ $PPID = 0 ]] ; then
        return
    fi
    echo $(ps -p $PPID -o comm=)
}

### Xorg

if [[ $DISPLAY ]] ; then

    # make windows blink when prompt reappears
    if [[ $(type -p wmctrl) ]] ; then
      export BASHRC_PROMPT_WMCTRL=window-blink
    fi

    export BROWSER=firefox
fi

### SSH

alias ssh=ssh-alias
alias scp='rsync --archive --xattrs --acls --partial --partial-dir=rsync-partial --info=progress2 --rsh="ssh"'

function _ssh_completion() {
    perl -ne 'print "$1 " if /^Host (.+)$/' $REMOTE_HOME/.ssh/config
}

if [[ -e $REMOTE_HOME/.ssh/config ]] ; then
    complete -W "$(_ssh_completion)" ssh scp ssh-with-reverse-proxy sshfs \
        sshnocheck sshtunnel vncviewer
    complete -fdW "$(_ssh_completion)" scp
fi

function fixssh() {
    eval $(ssh-agent-env-restore)
}

function nossh() {
    source ssh-agent-env-clear
}

### History

# ignore commands  for history that start  with a space
HISTCONTROL=ignorespace:ignoredups
# HISTIGNORE="truecrypt*:blubb*"
# HISTTIMEFORMAT="[ %Y-%m-%d %H:%M:%S ] "

# Make Bash append rather than overwrite the history on disk
shopt -s histappend

# prevent history truncation
unset HISTFILESIZE

# echo $REMOTE_HOME
export HISTFILE_ETERNAL=$REMOTE_HOME/.bash_eternal_history

if [ ! -e $HISTFILE_ETERNAL ] ; then
    touch $HISTFILE_ETERNAL
    chmod 0600 $HISTFILE_ETERNAL
fi

# TODO: do at logout?
history -a

alias h="bash-eternal-history-search -e -s"

function bashrc-eternal-history-add() {

    if [[ "$PRIVATE_SHELL" ]] ; then
        return
    fi

    local pos
    local cmd
    read -r pos cmd <<<$(history 1)

    [[ "$PREVIOUS_COMMAND" == "$cmd" ]] && return
    [[ "$PREVIOUS_COMMAND" ]] || PREVIOUS_COMMAND="$cmd"
    PREVIOUS_COMMAND="$cmd"

    if [[ "$cmd" == "rm "* ]] ; then
        cmd="# $cmd"
        history -s "$cmd"
    fi

    local quoted_pwd=${PWD//\"/\\\"}

    local line="$USER"
    line="$line $(date +'%F %T')"
    line="$line $BASHPID"
    line="$line \"$quoted_pwd\""
    line="$line \"$BASHRC_PIPE_STATUS\""
    line="$line $cmd"
    echo "$line" >> $HISTFILE_ETERNAL
}

### PROMPT

# This is the default prompt command which is always set.
# It sets some variables to be used by the specialized command prompts.
function bashrc-prompt-command() {

    BASHRC_PIPE_STATUS="${PIPESTATUS[*]}"

    bashrc-eternal-history-add

    [[ $BASHRC_TIMER_START ]] || BASHRC_TIMER_START=$SECONDS

    PS1=$(
        elapsed=$(($SECONDS - $BASHRC_TIMER_START)) \
        jobs=$(jobs) \
        BASHRC_PROMPT_COLORS=1 \
        BASHRC_PROMPT_HELPERS=$BASHRC_PROMPT_HELPERS \
        $BASHRC_PROMPT_COMMAND
    )"$BASHRC_BG_COLOR"

    $BASHRC_PROMPT_WMCTRL

    pipe_status=$BASHRC_PIPE_STATUS bash-print-on-error

    BASHRC_TIMER_START=$SECONDS
}

# Add a helper command to display in the prompt
function prompt-helper-add() {

    cmd=${1?Specify helper command}

    if [[ $BASHRC_PROMPT_HELPERS ]] ; then
        BASHRC_PROMPT_HELPERS=$BASHRC_PROMPT_HELPERS";"
    fi

    BASHRC_PROMPT_HELPERS="$BASHRC_PROMPT_HELPERS""prefixif \$($@)"
}

# Remove all helpers
function prompt-helper-remove-all() {

    unset BASHRC_PROMPT_HELPERS
}

# Set the specified prompt or guess which one to set
function prompt-set() {

    local prompt=$1

    PROMPT_COMMAND=bashrc-prompt-command

    if [[ $prompt ]] ; then

        if [[ $(type -p prompt-$prompt) ]] ; then
            BASHRC_PROMPT_COMMAND=prompt-$prompt
            return
        fi

        if [[ $(type -p prompt-helper-$prompt) ]] ; then
            prompt-helper-add prompt-helper-$prompt
            return
        fi

        echo "Prompt not found $prompt" >&2
        return 1
    fi

    if [[ $(parent) =~ (screen|screen.real|tmux) ]] ; then
        BASHRC_PROMPT_COMMAND=prompt-local
        return
    fi

    if [[ $REMOTE_HOST || $BASHRC_INSIDE_DOCKER ]] ; then
        BASHRC_PROMPT_COMMAND=prompt-host
        return
    fi

    BASHRC_PROMPT_COMMAND=prompt-local
}

# cd to dir used last before logout
function bashrc-set-last-session-pwd() {

    if [[ $BASHRC_IS_LOADED ]] ; then
        return
    fi

    local LAST_PWD=$(bash-eternal-history-search -d -c 1 --existing-only | tail -1)
            OLDPWD=$(bash-eternal-history-search -d -c 2 --existing-only)

    if [[ $LAST_PWD ]] ; then
        cd "$LAST_PWD"
    elif [[ -d "$REMOTE_HOME" ]] ; then
        cdh
    fi
}

# Turn of history for testing passwords etc
function shell-private() {
    export PRIVATE_SHELL=1
    unset HISTFILE
    BASHRC_BG_COLOR=$BASHRC_COLOR_GREEN
}

### bashrc handling

function bashrc-clean-env() {

    unset PROMPT_COMMAND

    # remove aliases
    unalias -a

    # remove functions
    while read funct ; do
        unset -f $funct
    done<<EOF
        $(perl -ne 'foreach (/^function (.+?)\(/) {print "$_\n" }' $REMOTE_BASHRC)
EOF
}

function bashrc-update() {
    (
        set -e
        cd $REMOTE_HOME
        mkdir -p $REMOTE_HOME/.bashrc.d
        wcat https://raw.githubusercontent.com/nilsboy/bashrc/master/bashrc \
          -o .bashrc
    )
    bashrc-reload
    bashrc-unpack
}

function bashrc-reload() {
    bashrc-clean-env
    unset BASHRC_IS_LOADED
    source $REMOTE_BASHRC
}

# Unpack scripts fatpacked to this bashrc
function bashrc-unpack() {

    if [[ -d $REMOTE_HOME/.bin ]] ; then
       rm $REMOTE_HOME/.bin -rf
    fi

    perl - $@ <<'EOF'
        use strict;
        use warnings;

        $/ = undef;
        open(my $f, $ENV{REMOTE_BASHRC}) || die $!;
        my $bashrc = <$f>;

        my $home = $ENV{REMOTE_HOME} || die "REMOTE_HOME not set";
        my $dst_dir = $ENV{REMOTE_HOME} . "/.bin";

        system("mkdir -p $dst_dir") && die $!;

        print STDERR "Exporting apps to $dst_dir...\n";

        my $export_count = 0;
        while ($bashrc =~ /^### fatpacked app ([\w\-\.]+) #*$(.+?)(?=\n^### fatpacked app)/igsm) {

            my $app_name = $1;
            my $app_data = $2;

            $app_data =~ s/^\s+//g;

            my $app_file_name = "$dst_dir/$app_name";

            # print STDERR "Exporting $app_name to $app_file_name...\n";

            open(my $APP_FILE, ">", $app_file_name) || die $!;
            print $APP_FILE $app_data;

            chmod(0755, $app_file_name) || die $!;

            $export_count++;
        }

        print STDERR "Done - $export_count apps exported.\n";
EOF

}

### STARTUP

[ -e "$REMOTE_HOME/.bin" ] || bashrc-unpack

eval $(linux-distribution-info)
if [[ $DISTRIB_ID ]] ; then
  fix_file=bashrc-linux-distribution-fix-$DISTRIB_ID
  if [[ $(type -t $fix_file) ]] ; then
      source $fix_file
  fi
fi

eval $(env-set-vars-from-lc)

prompt-set
bashrc-set-last-session-pwd

export BASHRC_IS_LOADED=$$

# test -n "$REMOTE_HOST" && srd

true

### END
return 0
### fatpacked apps start here
### fatpacked app abs ##########################################################

#!/usr/bin/env perl

# Print the absolute path of a file or dir

use Cwd;

my $file = join(" ", @ARGV);
my $abs = Cwd::abs_path($file);
$abs .= "/" if -d $file;
$abs = "'$abs'" if $abs =~ /\s/;
$abs =~ s/;/\\;/g;
print "$abs\n";

### fatpacked app apt-dump-installed-packages ##################################

#!/bin/bash
# Dump names of all installed packages to a file
# from http://askubuntu.com/a/492343

source bash-helpers

comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u) \
    | grep -v '^lib' \
    | grep -v '^linux-' \
    > installed_packages_on_host_$HOSTNAME

WARN 'This list may contain some extra packages - please recheck!'

### fatpacked app apt-hold-package #############################################

#!/bin/bash

# Prevent a deb package from beeing upgraded

set -e

package_name=${1?package name?}
dpkg --get-selections $package_name
echo $package_name hold | sudo dpkg --set-selections
dpkg --get-selections $package_name

### fatpacked app apt-install-packages-from-file ###############################

#!/bin/bash

# Install packages listed in a file

source bash-helpers

file=${1?file name?}
# perl -pe 's/^(.+)$/$1 install/g' $file | dpkg --set-selections
# apt-get -u dselect-upgrade

xargs -a $file apt-get -qq -y install

exit 0

# apt-get within while breaks while after the first package was installed

INFO "FYI - this will install outstanding upgrades too."

while read package ; do
    INFO "Installing package: $package..."
    (apt-get install -y $package) || ERROR "Cannot install $package"
done <<-EOF
    $(cat $file)
EOF

### fatpacked app apt-popularity ###############################################

#!/usr/bin/env perl

# Search for a debian package, sort by ranking, add description

use strict;
use warnings;
no warnings 'uninitialized';
use autodie;
use File::stat;

my %apps = ();
open( F, qq{apt-cache search --names-only "@{[ join(" ", @ARGV) ]}" |} );
while (<F>) {
    my ( $app, $desc ) = /^(.+?) - (.+)$/;
    next if $app =~ /^lib/;
    $apps{$app}{exists} = 1;
}

my %ranks = ();

my $pop_file = "/tmp/apt-pop";

if ( -e $pop_file ) {
    if ( stat($pop_file)->ctime < time() - 86400 ) {
        qx{wget -qqO- http://popcon.debian.org/by_inst.gz | gunzip > $pop_file}
            && die $!;
    }
}

open( F, $pop_file );
while (<F>) {
    my ( $rank, $app ) = /^(\d+)\s+(\S+)/;

    next if $app =~ /^lib/;

    next if !$app;
    next if !exists $apps{$app};

    $apps{$app}{ranked} = 1;
    $ranks{$rank} = { app => $app };
}

# add apps without a ranking
my $i = 0;
foreach my $app ( keys %apps ) {
    $i++;
    $ranks{"$i"} = { app => $app }
        if !exists $apps{$app}{ranked};
}

print "\n";

foreach my $rank ( sort { $a <=> $b } keys %ranks ) {
    my $app = $ranks{$rank}{app};
    my ($desc) = `apt-cache show $app` =~ /^Description.*?\:(.+?)\n\S/igsm;
    $desc =~ s/^\s+\.$//gm;
    my $header = "### $app " . ( "#" x ( $ENV{COLUMNS} - length($app) - 5 ) );
    print "$header\n\n$desc\n\n";
}

### fatpacked app apt-unhold-package ###########################################

#!/bin/bash

# Return a deb package to its default upgrade state

set -e
package_name=${1?package name?}
dpkg --get-selections $package_name
echo $package_name install | sudo dpkg --set-selections
dpkg --get-selections $package_name

### fatpacked app audio-file-prefix-track-number ###############################

#!/usr/bin/env node
// Add a leading two digit track number to the file name

var fs = require('fs')
var mm = require('musicmetadata')
var sprintf = require('sprint')
var src = process.argv[2]

var parser = mm(fs.createReadStream(src), function (err, metadata) {
    if (err) throw err
    if(!metadata.track.no) {
      throw new Error("No track number found")
    }
    var dst = sprintf("%.2d", metadata.track.no) + "_" + src
    console.log("mv " + src + " -> " + dst)
    fs.renameSync(src, dst)
  }
)


### fatpacked app audio-ogg-from-any ###########################################

#!/bin/bash

# Convert any audio file to ogg

source bash-helpers

dst_type=ogg

if [[ "$1" = "-m" ]] ; then
    dst_type=mp3
    shift
fi

file="$@" 

if [[ ! $file ]] ; then
    DIE "Specify audio file"
fi

file=$(abs $file)

file_prefix=$(filename $file)
file_type=$(extension $file)

perl -e 'exit 1 if "'$file_type'" !~ /(ogg|mp3|flac|wav|mp4|m4a)$/i' \
    || RETURN "Unknown music file format for $file - skipping\n"

INFO "Converting to $dst_type"

# NOTE: not possible with snaps?: uses /tmp/snap.ffmpeg/tmp when specifying /tmp
# tmp=$(mktemp -d)/transcode.flac

tmp=temp-audio-ogg-from-any.flac 

trap 'echo "ERROR - running CLEANUP..." ; test -e "$out_file" && rm -f "$out_file"' ERR

INFO "Transcoding file: $file / type: $file_type to $dst_type"
DEBUG "Using temp file: $tmp"

# pipe does not save the tags
# sox $file -t wav - | oggenc -q6 -o $x.ogg -

if [[ $file_type = $dst_type ]] ; then
    RETURN "File is already an $dst_type file"
fi

out_file="$file".$dst_type

# save to flac first to keep the tags
# cannot convert to ogg directly because I don't know 
# how to specify the ogg quality level with avconv

if [[ $dst_type = ogg ]] ; then
    if [[ $file_type != flac ]] ; then
        DEBUG "Transcoding $file to flac"
        # sox $file -t flac $tmp
        ffmpeg -i "$file" $tmp
        _file="$file"
        file="$tmp"
        tmp="$_file"
    fi
fi

# remove old extension if old format was lossless
# if [[ $file_type = flac || $file_type = ape ]] ; then
#   out_file="$file_prefix".ogg
# fi

DEBUG "Transcoding $file to $dst_type"

INFO "dst_type: $dst_type"

if [[ $dst_type = ogg ]] ; then
    oggenc -q6 -o "$out_file" "$file"
else
    # sox does not copy tags
    # sox "$tmp" -C192 "$file.$dst_type"

    # cannot read flac
    # lame -h "$tmp" "$file.$dst_type"

    # avconv -i "$file" -c:a libmp3lame -b:a 192k -id3v2_version 3 -write_id3v1 1 "$file.$dst_type"
    # the -map_metadata is used to copy the tag...:
    # https://stackoverflow.com/questions/21489719/avconv-flac-to-ogg-conversion-with-metadata-kept
    ffmpeg -loglevel quiet -i "$file" -vn -c:a libmp3lame -b:a 192k -map_metadata 0:s:0 "$out_file"
fi

if [[ -e $tmp ]] ; then
    rm $tmp
fi

rm "$file"

DEBUG "Done"



### fatpacked app audio-split-by-cue ###########################################

#!/bin/bash

# Split an album audio file into several tracks using a cue file

source bash-helpers

audio_file_path=${1?Specify audio file}
wd=$(dirname $audio_file_path)
audio_file=$(basename $audio_file_path)

audio_file_prefix=$(filename $audio_file)
audio_file_type=$(extension $audio_file)

cue_file=$2

cd "$wd"

if [[ ! "$cue_file" ]] ; then
    cue_file=$(filename $audio_file).cue
    cue_file=$(echo $cue_file | perl -pe 's/\.(ogg|flac|ape)//g')
fi

cue_file=$(abs $cue_file)

INFO "Splitting file $audio_file via cue $cue_file"

if [[ ! -f "$cue_file" ]] ; then
    DIE "Cue file not found: $cue_file"
fi

if [[ $audio_file_type = .ogg ]] ; then
    oggsplt -c $cue_file $audio_file
elif [[ $audio_file_type = .mp3 ]] ; then
    mp3splt -c $cue_file $audio_file
else
    DIE "Don't know how to split $audio_file_type files"
fi

rm $audio_file

INFO "Done"


### fatpacked app authorized_keys ##############################################

ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAgEAtdUl549e+o3OTc/PJJs2YeYK4iWKm98IshZCzOzmTUazIG8xUNgcFclbC9YgAdIqQMkabGd9kJYO32jQv08ylP0cDam11KKGLppYz64VOtNYEiQAQN2EPRbGvYfheXvQtfdHt4r7JG6c+5e1XBXkLILiqiXgdg0V3VHPuc//SGpRLCU3V18629jihXz4AgcyEqInm3mAgEDyEVViZAc7zu4HyaBrBWxDAh0ue5KQWkDdxh6vEyPFOTVxslMhEtimtoU3wuzjojSQgJnGa2NGuMGTMyc5KeBb4xfAeXnir+TDqj0lkU2TlDOf1rlDWFRRZiYVWvCvuixx4RfSSmr41h0txrJjiXRApRz/cEOym62GEvVGyu4P9jCvnNufJkV1Du8p1ghELn2+U5YwOLUCnZ+xEetYQyvfmspJXtb5w6ZBm5trlSie7ippWd08BdwTFJLtXVboquIJ1FVuOxg+xesWcmONgVlcmyODwJjDKOeUc8rY0ZPkwEsbb3QZnCFXbsNnTetos7cSriOeFuNGkTrynERt1F23jFu6z+Bv/Im6kjU1tRfFc+kvWLu/jrWQ3i7/hvDfzSD7n0O1LrG5dDgtJGexf54Ogcn7rmPsYMBEjrtWAhrsyuB06Kn4hBvPn/O5xRLp0R49VnLdeJY/53M8xO24Cysa/DQ4XgLIWlE= Nils Boysen

### fatpacked app bak ##########################################################

#!/bin/bash

# Copy a file to ~/backups/ appending a timestamp

set -e

source bash-helpers

file="$@"
bak=$(filename $(filestamp $file))
bak=$REMOTE_HOME/backup/"$bak"

cp -va "$file" "$bak"

### fatpacked app bakm #########################################################

#!/bin/bash

# Move a file to ~/backups/ appending a timestamp

set -e

source bash-helpers

file="$@"
bak=$(filename $(filestamp $file))
bak=$REMOTE_HOME/backup/"$bak"

mv -v "$file" "$bak"

### fatpacked app bakmp ########################################################

#!/bin/bash

# Move a file appending a timestamp

source bash-helpers

file="$@"
bak=$(filestamp $file)

mv -v "$file" "$bak"

### fatpacked app bakp #########################################################

#!/bin/bash

# Backup a file appending a timestamp

source bash-helpers

file="$@"
bak=$(filestamp $file)

if [[ -d $file ]] ; then
  cp -a "$file" "$bak"
else
  cp "$file" "$bak"
fi

echo $bak

### fatpacked app bash-background-jobs-count ###################################

# Display one colored count for background jobs running and stopped

source bash-helpers

total=0
running=0

while read job state crap ; do

    if [[ $job =~ ^\[[0-9]+\] ]] ; then

        total=$(($total+1))

        if [[ $state = Running ]] ; then
            running=$(($running+1))
        fi
    fi

done<<EOF
    $jobs
EOF

color=$GREEN

if [[ $running -gt 0 ]] ; then
    color=$RED
fi

if [[ $total == 0 ]] ; then
    RETURN
fi

RETURN " ${color}$total${NO_COLOR}"


### fatpacked app bash-eternal-history-grep ####################################

#!/usr/bin/env bash

# Grep bash history

source bash-helpers

tac $HISTFILE_ETERNAL | grep -ai "$@" | less

### fatpacked app bash-eternal-history-search ##################################

#!/usr/bin/env perl

# Search specially formatted bash history

use strict;
use warnings;
no warnings 'uninitialized';
use Getopt::Long;
use Cwd;

my $gray        = "\x1b[38;5;243m";
my $reset_color = "\x1b[38;5;0m";
my $red         = "\x1b[38;5;124m";

my $pipe_mode = !-t STDOUT;

if ($pipe_mode) {
    $gray = $reset_color = $red = "";
}

my $opts = {
    "a|all"                     => \my $show_all,
    "e|everything"              => \my $show_everything,
    "existing-only"             => \my $show_existing_only,
    "skip-current-dir"          => \my $skip_current,
    "d|directories"             => \my $show_dirs_only,
    "files"                     => \my $find_files,
    "s|search-directories"      => \my $search_dirs,
    "r|succsessful-result-only" => \my $show_successful,
    "l|commands-here"           => \my $show_local,
    "c|count=i"                 => \my $count,
};
GetOptions(%$opts) or die "Usage:\n" . join( "\n", sort keys %$opts ) . "\n";

my @search = @ARGV;
my $wd     = cwd;

# user 2011-08-20 21:02:47 19202 "dir" "0 1" cmd with options ...
#                  usr  date time  pid   dir   exit codes  cmd
my $hist_regex = '^(.+?) (.+?) (.+?) (\d*?) "(.+?)" "([\d ]+?)" (.+)$';

my $h = $ENV{HISTFILE_ETERNAL};
open( F, "tac $h |" ) || die $!;

my %shown = ();
$count ||= 100;
my @to_show = ();

ENTRY: while (<F>) {
    my (@all) = $_ =~ /$hist_regex/g;
    my ( $user, $date, $time, $pid, $dir, $result, $cmd ) = @all;
    my $was_successful = $result =~ /[0 ]+/g;

    next if $show_successful && !$was_successful;
    next if $dir ne $wd && $show_local;

    my $to_match;
    my $show;

    if ($show_dirs_only) {
        next if $show_existing_only && !-d $dir;
        $to_match        = $dir;
        $show            = $dir;
        $show_everything = 0;
    }
    else {
        $to_match = $cmd;
        $show     = $cmd;
        $show     = $red . $show . $reset_color if !$was_successful;
    }

    if ($search_dirs) {
        $to_match .= " $dir";
    }

    if (@search) {
        foreach my $search (@search) {

            next ENTRY if $to_match !~ /$search/i;

            my $found;
            if ($find_files) {
                foreach ( split( " ", $cmd ) ) {
                    if (/^\//) {
                    }
                    elsif (/^~/) {
                        s/^~/$ENV{HOME}/g;
                    }
                    else {
                        $_ = "$dir/$_";
                    }
                    next if $_ !~ /$search/i;
                    next if !-f $_;
                    $found = $_;
                    last;
                }
                next ENTRY if !$found;
                $to_match = $found;
                $show     = $found;
            }
        }
    }

    next if exists $shown{$to_match};

    $shown{$to_match} = 1;

    $show .= "\n";
    $show
        .= $gray . "   ("
        . join( " ", @all[ 0 .. $#all - 1 ] ) . ")\n"
        . $reset_color
        if $show_everything;

    push( @to_show, $show );

    last if !$show_all && keys %shown == $count;
}

map { print $_ } reverse @to_show;

### fatpacked app bash-helpers #################################################

#!/bin/bash

# Helper functions for shell scripts
# Put in you path and you can use them using "source bash-helpers".

set -e
set -o pipefail

if [[ $BASHRC_PROMPT_COLORS ]] ; then
    NO_COLOR='\[\e[33;0;m\]'
        GRAY='\[\e[38;5;243m\]'
        GREY='\[\e[38;5;243m\]'
       GREEN='\[\e[38;5;2m\]'
      ORANGE='\[\e[38;5;3m\]'
         RED='\[\e[38;5;1m\]'
      PURPLE='\[\e[38;5;5m\]'
        BLUE='\[\e[38;5;21m\]'
      YELLOW='\[\e[38;5;226m\]'
        PINK='\[\e[38;5;13m\]'
else
    NO_COLOR=$(echo -e '\x1b[33;0;m')
        GRAY=$(echo -e '\x1b[38;5;243m')
        GREY=$(echo -e '\x1b[38;5;243m')
       GREEN=$(echo -e '\x1b[38;5;2m')
      ORANGE=$(echo -e '\x1b[38;5;3m')
         RED=$(echo -e '\x1b[38;5;1m')
fi

function _LOG() {

    local level=$1 ; shift

    local log_level_prio
    local crap
    read log_level_prio crap <<<$(_calc_prio $LOG_LEVEL)

    if [[ ! $LOG_LEVEL ]] ; then
        if [[ -t 1 ]] ; then
            log_level_prio=3
        else
            log_level_prio=6
        fi
    fi

    local location

    local prio
    local show_location
    local color

    read prio show_location color <<<$(_calc_prio $level)

    if [[ $prio < $log_level_prio ]] ; then
        return
    fi

    if [[ $show_location > 0 ]] ; then

        local function
        local file

        read location function file <<<$(caller 1)

        if [[ $file ]] ; then
            location=$(basename $file)":"$location
        fi

        if [[ $location ]] ; then
            location=" "$location
        fi
    fi

    if [ -t 1 ] ; then
        echo -e "$color${level}$location> $@${NO_COLOR}" >&2
    else
        echo -e "$(date +'%F %T') ${level}$location> $@" >&2
    fi
}

function _calc_prio() {

    local level=$1

    local prio
    local show_location
    local color

    case $level in
        TRACE) prio=1 ; show_location=1 ; color=$GRAY ;;
        DEBUG) prio=2 ; show_location=0 ; color=$GRAY ;;
        INFO)  prio=3 ; show_location=0 ; color=$GREEN ;;
        WARN)  prio=4 ; show_location=0 ; color=$ORANGE ;;
        ERROR) prio=5 ; show_location=1 ; color=$RED ;;
        FATAL) prio=6 ; show_location=1 ; color=$RED ;;
    esac

    echo $prio $show_location $color
}

function TRACE()  { _LOG "TRACE" "$@" ; }
function DEBUG()  { _LOG "DEBUG" "$@" ; }
function INFO()   { _LOG "INFO " "$@" ; }
function WARN()   { _LOG "WARN " "$@" ; }
function ERROR()  { _LOG "ERROR" "$@" ; }
function DIE()    { _LOG "FATAL" "$@" ; exit 1 ; }
function RETURN() { echo -ne "$@"     ; exit 0 ; }

function EXIT()   {
    if [[ "$@" ]] ; then
        _LOG "INFO"  "$@"
    fi
    exit 0
}

function usefatal() {
    trap DIE ERR
}

function nousefatal() {
    trap ERR
}

function repeat() {
    perl -0777 -e 'print <STDIN> x $ARGV[0]' "$@"
}

# Print a line with a message the length of the screen.
function line() {
    perl - $@ <<'EOF'
        my $msg = " " . join(" ", @ARGV) . " ";
        print "---", $msg , q{-} x ($ENV{COLUMNS} - 3 - length($msg)), "\n\n";
EOF
}

function prefixif() {

    if [[ "$@" ]] ; then
        echo -ne " $@"
        return
    fi

    echo -ne "$@"
}

# Interpret argv using a docopt spec and save a JSON representation into $docopt
function docopt() {

    if [[ $docopt_files ]] ; then
        docopt_files=","$docopt_files
    fi

    local trace=$(docopt-convert $(readlink -f $0)$docopt_files --json --pretty -- "$@" 2>&1)
    TRACE "$trace"

    # print help and die if doc is invalid
    docopt-convert $(readlink -f $0)$docopt_files -- "$@" || return 1

    # save json to $docopt
    docopt=$(docopt-convert $(readlink -f $0)$docopt_files --json -- "$@")
    eval $(docopt-convert $(readlink -f $0)$docopt_files --env -- "$@")
}

### fatpacked app bash-jobs ####################################################

#!/usr/bin/env perl

# Cleaned up bash jobs replacement

# Run like this: jobs=$(jobs) bash-jobs

use strict;
use warnings;
no warnings 'uninitialized';

my $black     = "\x1b[38;5;0m";
my $gray      = "\x1b[38;5;250m";
my $dark_gray = "\x1b[38;5;243m";
my $red       = "\x1b[38;5;124m";

my %cmds      = ();
my %last_args = ();

foreach ( split( "\n", $ENV{jobs} ) ) {

    my ( $jid, $state, $cmd ) = /^(\[\d+\][+-]*)\s+(\S+)\s+(.+)\s*$/;

    next if !$jid;

    $jid =~ s/[\[\]]//g;
    $jid = " $jid" if $jid !~ /\d\d/g;
    my ($wd) = $cmd =~ /\s+\(wd\:\ (.+)\)\s*$/;
    $cmd =~ s/\s+\(wd\:\ (.+)\)\s*$//g;

    $cmd =~ s/^(\w+=\w*\s+)*//g;

    my $args = $cmd;

    ($cmd) = $cmd =~ /^\s*([^\s]+)/;

    my ($last_arg) = $args;
    $last_arg =~ s/(\||\().*$//g;
    $last_arg =~ s/\w*>.*$//g;
    $last_arg =~ s/[\s&]*$//g;
    ($last_arg) = $last_arg =~ /[\s]*([^\s]+|$)$/;
    my $full_last_arg = $last_arg;
    $last_arg =~ s/.*\///g;

    if ( $args eq $cmd ) {
        $args = "";
    }

    if ( $last_arg eq $cmd ) {
        $last_arg = "";
    }

    if ( $cmd eq "(" ) {
        $cmd .= ")";
    }
    else {
        $args = "";
    }

    my $max = $ENV{COLUMNS} - length($cmd) - length($last_arg) - 5 - 1;
    my $length = length($args);

    if ( $length > $max ) {
        my $leave = $max / 2;
        $args
            = substr( $args, 0, $leave - 1 )
            . "$red*$gray"
            . substr( $args, $length - $leave + 1, $leave );
    }

    push( @{ $last_args{$last_arg} }, $jid ) if $last_arg;
    $cmds{$jid} = [ $cmd, $last_arg, $args, $full_last_arg, $state ];
}

# lengthen args that are the same until they are not
foreach my $jid ( keys %last_args ) {

    next if @{ $last_args{$jid} } == 1;

    my %diff       = ();
    my $length     = 0;
    my $max_length = 0;

    while (1) {

        %diff = ();
        $length++;

        foreach my $same_jid ( @{ $last_args{$jid} } ) {

            my $arg = $cmds{$same_jid}[3];

            $max_length = length($arg) if length($arg) > $max_length;

            if ( length($arg) <= $length ) {
                $diff{$arg} = $same_jid;
                next;
            }

            $arg = substr( $arg, length($arg) - $length, length($arg) );

            $diff{$arg} = $same_jid;
        }

        last if keys(%diff) == @{ $last_args{$jid} };
        last if $length == $max_length;
    }

    my $final_length = 0;

    # add everything after the first slash
    foreach my $arg ( keys %diff ) {

        my $jid = $diff{$arg};

        my $org_arg = $cmds{$jid}[3];

        ($arg) = $org_arg =~ /.*\/(.+$arg)$/;

        $arg =~ s#/.+/#/\*/#g;

        $final_length = length($arg) if length($arg) > $final_length;

        $cmds{$jid}[1] = $arg || $org_arg;
    }

    # prefix with space to same length
    foreach my $jid ( values %diff ) {
        my $arg = $cmds{$jid}[1];
        $cmds{$jid}[1] = sprintf( "%${final_length}s", $arg );
    }
}

foreach my $jid ( sort keys %cmds ) {

    my ( $cmd, $last_arg, $args, $full_last_arg, $state ) = @{ $cmds{$jid} };

    my $fg = $black;
    $fg = $red if $state =~ /running/i;

    print $fg;
    printf( "%-3s %s %s %s\n", $jid, $cmd, $last_arg, $gray . $args . $black );
}

### fatpacked app bash-print-on-error ##########################################

# Print error code of last command on failure

source bash-helpers

for item in $pipe_status ; do

    if [ $item != 0 ] ; then
        echo -e "${RED}exit: $pipe_status" >&2
        break
    fi

done

### fatpacked app bash-setup-multi-user-environment ############################

#!/bin/bash

# Share one account with serveral users but create their own environment
#
# Users are identified by their public key and cd'ed to their respective homes.
# Users have their own home and use their own .bashrc.

# Put this in your ~/.bashrc:
# eval $(~/bin/bash-setup-multi-user-environment)

set -e

function find_remote_host_via_ssh() {
    if [[ $SSH_CLIENT ]] ; then
        export REMOTE_HOST=${SSH_CLIENT%% *}
    fi
}

function find_login_via_ssh_key() {

    [[ $SSH_AUTH_SOCK ]] || return 0

    type -p ssh-add 1>/dev/null || return 0

    shopt -s nullglob
    local auth_files=(~/users/*/.ssh/authorized_keys)
    shopt -u nullglob

    [[ $auth_files ]] || return 0

    local agent_key
    while read agent_key ; do

        agent_key=${agent_key%%=*}

        [[ $agent_key ]] || continue;

        local auth_file
        for auth_file in ${auth_files[@]} ; do

            if grep -q "${agent_key}" $auth_file ; then
                REMOTE_USER=${auth_file%%/.ssh/authorized_keys};
                REMOTE_USER=${REMOTE_USER##$HOME/users/};
                return 0
            fi

        done

    done < <(ssh-add -L 2>/dev/null)

    return 0
}

function ask_for_login() {

    local NO_COLOR="\033[0m"
    local RED="\033[0;31m"

    local noagent
    ssh-add -L 1>/dev/null 2>/dev/null || noagent=1

    echo -en $RED

    if [[ $noagent ]] ; then
        return 0
    fi

    echo
    echo "Ups - do I know you?"
    echo
    echo -n "No - I'm new and "

    local sure
    until [[ $sure = "y" ]] ; do

        echo -n "I like to use this login, please: "
        read REMOTE_USER
        echo

        if [[ $REMOTE_USER =~ ^[a-z0-9_]+$ ]] ; then
            true
        elif [[ ! $REMOTE_USER ]] ; then
            REMOTE_USER=anonymous
        else
            echo "Invalid login - please try again."
            echo
            unset sure
            continue
        fi

        echo "Are sure you want to use $REMOTE_USER? (y/n)"
        read sure

    done

    echo -ne $NO_COLOR
}

function create_remote_home() {(
    set -e

    local NO_COLOR="\033[0m"
    local RED="\033[0;31m"

    local ssh_home=$REMOTE_HOME/.ssh
    local authorized_keys=$ssh_home/authorized_keys

    mkdir -p $REMOTE_HOME/{tmp,etc,bin,lib}
    mkdir -p $ssh_home

    if [[ $user = anonymous ]] ; then
        return 0
    fi

    set +e
    ssh-add -L >> $authorized_keys 2>/dev/null
    set -e

    echo -ne $RED

    if [[ $REMOTE_USER = anonymous ]] ; then
        echo
        echo "To get a personalized home directory please activate"
        echo "   your ssh-agent with key forwarding!"
        echo
        echo "If you want to be someone specific remove your ssh public key from:"
        echo "   $REMOTE_HOME/.ssh/authorized_keys"
        echo "   and login again."
        echo
        echo "If you are a script please make sure you are not running"
        echo "   bash interactively to avoid this screen."
        echo
        echo "For now you will be known as anonymous."
    fi

    echo
    echo "Please keep the official home ($HOME) clean."
    echo "Store your own files in $REMOTE_HOME."
    echo "Thank you!"
    echo
    echo "   Use 'cdh' to go to your personal home at $REMOTE_HOME."
    echo "   Use 'cdt' to go to your personal tmp at $REMOTE_HOME/tmp."
    echo
    echo "Have fun!"
    echo
    echo -ne $NO_COLOR
)}

# do not allow ctrl-c
trap '' INT

find_remote_host_via_ssh
find_login_via_ssh_key

if [[ ! $REMOTE_USER ]] ; then
    ask_for_login >&2
    new_user=1
fi

if [[ ! $REMOTE_USER ]] ; then
    REMOTE_USER=anonymous
    new_user=1
fi

export REMOTE_USER
export REMOTE_HOME="$HOME/users/$REMOTE_USER"
export REMOTE_BASHRC="$REMOTE_HOME/.bashrc"

if [[ $new_user ]] ; then
    create_remote_home >&2
fi

# needs trailing ; because eval joins the lines
cat <<-EOF
    export REMOTE_USER=$REMOTE_USER;
    export REMOTE_HOME=$REMOTE_HOME;
    export REMOTE_BASHRC=$REMOTE_BASHRC;
    alias cdh="cd $REMOTE_HOME";
    alias cdt="cd $REMOTE_HOME/tmp";
    alias ssh="ssh -A";
    cd $REMOTE_HOME;
EOF

if [[ -e $REMOTE_BASHRC ]] ; then
    if [[ $REMOTE_USER != anonymous ]] ; then
        echo "source $REMOTE_BASHRC"
    fi
fi

### fatpacked app bash-with-comments ###########################################

#!/usr/bin/env bash

# Remove comments from a bash script and run it

# This allows comments like this:
# app \
#   # description of option
#   -w   \
#   -x   \ # description of option
#   # -y \ # deactivated option
#   -z

script=$1
shift

(
  echo "set -- $*"
  tail -n +2 $script
) \
  | perl -007pe 's/^\s*#.*\n//gm ; s/^\s*#.*\s+//gm' | exec -a "$script" bash

### fatpacked app bashrc-eternal-history-add-simple ############################

#!/bin/bash


# Add an entry to the eternal history

source bash-helpers

cmd="$@"

test -z $HISTFILE_ETERNAL && DIE "Set env var: HISTFILE_ETERNAL"
test -z "$cmd" && DIE "Specify command"

test -z $PRIVATE_SHELL || exit 0

if [[ $cmd == "rm "* ]] ; then
    cmd="# $cmd"
fi

quoted_pwd=${PWD//\"/\\\"}

# update cleanup_eternal_history if changed:
# use LOGNAME when coming from CGI
line="$USER""$LOGNAME"
line="$line $(date +'%F %T')"
line="$line $BASHPID"
line="$line \"$quoted_pwd\""
line="$line \"0\""
line="$line $cmd"
echo "$line" >> $HISTFILE_ETERNAL


### fatpacked app bashrc-helper-hostname #######################################

# Format hostname for bash prompt usage

source bash-helpers

if [[ $BASHRC_INSIDE_DOCKER ]] ; then
  host="docker($HOSTNAME)"
elif [[ "$REMOTE_HOST_ALIAS" ]] ; then
  host=$REMOTE_HOST_ALIAS
else
  host=$HOSTNAME
fi

color=$GREEN

if [[ "$host" =~ (dev|test|git|pet|prod) ]] ; then
  pattern=${BASH_REMATCH[1]}
  case $pattern in
    dev)    color=$GREY ;;
    test)   color=$BLUE ;;
    git)    color=$ORANGE ;;
    pet)    color=$PURPLE ;;
    prod)   color=$RED ;;
    docker) color=$PINK ;;
  esac
fi

echo -n $color$host$NO_COLOR

### fatpacked app bashrc-helper-login-name #####################################

# Format login for bash prompt usage

source bash-helpers

skip_non_root=$1

if [[ ! $USER && $BASHRC_INSIDE_DOCKER ]] ; then
    USER=root
fi

if [[ $USER = "root" ]] ; then
    RETURN "${RED}$USER${NO_COLOR}"
fi

if [[ $skip_non_root ]] ; then
    RETURN;
fi

RETURN $USER


### fatpacked app bashrc-linux-distribution-fix-suse ###########################

# Script to run when logging into a suse machine

unalias crontab

### fatpacked app bashrc-pack ##################################################

#!/usr/bin/env node

// Attach scripts to the bashrc skeleton

const LogDwim = require(`@nilsboy/log-dwim`)
const logger = new LogDwim()
const { TRACE, DEBUG, INFO, WARN, ERROR, DIE, DUMP } = logger

const path = require(`path`)
const fs = require(`fs-extra`)
const glob = require(`glob`).sync
const _ = require(`lodash`)

const wd = path.join(process.env.HOME, `src`, `bin`)
process.chdir(wd)

let bashrc = fs.readFileSync("../dotfiles/bashrc").toString()
let bashrcFileName = path.resolve("../bashrc/bashrc")

let appsCount = 0

let filesToSkip = [
  `README`,
  `package-lock.json`,
]

INFO(`Packing bin...`)
for (const binFileName of glob(path.join(wd, '*'))) {
  if(fs.lstatSync(binFileName).isDirectory()) {
    continue
  }
  if(filesToSkip.includes(path.basename(binFileName))) {
    continue
  }

  DEBUG(`binFileName:`, binFileName)
  const bin = fs.readFileSync(binFileName).toString()
  let description = `fatpacked app ${path.basename(binFileName)}`
  bashrc += _.padEnd("### " + description + " ", 80, `#`) + "\n\n"
  bashrc += bin + "\n"
  appsCount++;
}

bashrc += _.padEnd("### fatpacked apps END ", 80, "#") + "\n\n"
fs.writeFileSync(bashrcFileName, bashrc)

INFO(`Done - apps packed: ${appsCount}`)

### fatpacked app bashrc-unpack-and-run ########################################

#!/usr/bin/env perl

# Run a script that is attached to the bashrc

use strict;
use warnings;

my $app = shift @ARGV || die "Specify app.";

$/ = undef;
open( my $f, $ENV{REMOTE_BASHRC} ) || die $!;
my $bashrc = <$f>;

if ( $bashrc =~ /^### fatpacked app $app #*\n(.*?)(?=\n###)/igsm ) {
    my $app = $1;
    $app =~ s/^\n//g;
    my ($shebang) = $app =~ /(.+)/;
    $app =~ s/(.+)//;

    if ( $shebang =~ /^#!.* perl/ ) {
        eval $app;
        die $@ if $@;
    }
    else {

        $ENV{haha} = $app;

        # print $app;

        $app =~ s/\\/\\\\/gms;

        print `echo "\$haha"`;
        print `eval "\$haha"`;

        exit 0;
    }
}
else {

    die "App $app not found.";
}

### fatpacked app bashrc-upload ################################################

#!/bin/bash

# Generate and deploy fat packed bashrc

set -e

cd ~/src/dotfiles
git pull || echo "Nothing to pull"

cd ~/src/bashrc
git reset --hard HEAD
git pull || echo "Nothing to pull"

cd ~/src/bin
./bashrc-pack

cd ~/src/bashrc
git add bashrc
git commit -m "repackage bashrc"
git push

### fatpacked app bytes-from-human #############################################

#!/usr/bin/env perl

# Convert a size from human friendly to bytes

use strict;
use warnings;
no warnings 'uninitialized';

my $human = $ARGV[0];
defined $human || die "Specify size in human friendly";

my $k = 1024;
my $m = $k * 1024;
my $g = $m * 1024;
my $t = $g * 1024;

foreach my $unit (qw(k m g t)) {
    $human =~ s/$unit/ * \$$unit/ig;
}

print eval $human;

### fatpacked app bytes-to-human ###############################################

#!/usr/bin/env perl

# Convert a size of bytes to human friendly

use strict;
use warnings;
no warnings 'uninitialized';

my $bytes = $ARGV[0] || die "Specify size in bytes";

my $k = 1024;
my $m = $k * 1024;
my $g = $m * 1024;
my $t = $g * 1024;

my $human;

if ($bytes >= $t) {
    $human = sprintf("%.1fT", $bytes / $t);
}
elsif ($bytes >= $g) {
    $human = sprintf("%.1fG", $bytes / $g);
}
elsif ($bytes >= $m) {
    $human = sprintf("%.1fM", $bytes / $m);
}
elsif ($bytes >= $k) {
    $human = sprintf("%.1fK", $bytes / $k);
}
elsif ($bytes == 0) {
    $human = $bytes;
}
else {
    $human = $bytes;
}

$human =~ s/\.0//g;

print $human;

### fatpacked app cd-find ######################################################

#!/usr/bin/env bash

# Search for file or dir in current dir and go there

# source bash-helpers

search="$@"

dir=$(find-and "$search" | head -1)

if ! [[ "$dir" ]] ; then
  pwd
  exit
fi

if [[ -f "$dir" ]] ; then
    dir=$(dirname "$dir")
fi

echo "$dir"

if [[ "$dir" != $(pwd) ]] ; then
  echo "$dir" >&2
fi


### fatpacked app cd-history ###################################################

#!/usr/bin/env bash

# Search history for an existing directory containing string and go there

# source bash-helpers

search="$@"

if ! [[ "$search" ]] ; then
    echo $REMOTE_HOME
    exit
fi

dir=$(bash-eternal-history-search -d --skip-current-dir \
    --existing-only -c 1 "\/[^\/]*$search[^\/]*$"
)

if ! [[ "$dir" ]] ; then
  pwd
  exit
fi

echo "$dir"

if [[ "$dir" != $(pwd) ]] ; then
  echo "$dir" >&2
fi


### fatpacked app chroot-fully-working #########################################

#!/usr/bin/env bash

# Setup fully working change root

source bash-helpers

root=${1?Specify new root dir}

for dir in dev proc sys ; do
    sudo mount --bind /$dir $root/$dir
done

chroot $root

INFO "Possible next steps:"
INFO "Setup networking (i.e. dhclient eth1)"
INFO "Update grub (i.e. fdisk -l ; grub-install /dev/sda)"
INFO "Update grub2 (i.e. update-grub)"

### fatpacked app clear-with-scrollback ########################################

# Clear screen including scrollback buffer

printf "\33[2J"

### fatpacked app command-knows-switch #########################################

#!/usr/bin/env perl

# Check if an app supports specified switch

use strict;
use warnings;

my $app    = $ARGV[0] || die "Specify app.";
my $switch = $ARGV[1] || die "Specify switch.";

my $output = `$app --help 2>&1`;

exit 0 if $output =~ /^\s*$switch/ms;

exit 1;

### fatpacked app cp-merge-directories-by-hardlinks ############################

#!/bin/bash

# Merge two directories on the same disk recursively by using hard links
# and avoiding to copy a file

source bash-helpers

src=${1?specify source directory}
dst=${2?specify destination base directory}

if [[ $dst = . ]] ; then
    dst=$(basename $(abs $src))
fi

src_base=$(basename "$src")
dst="$dst/$src_base"

INFO "copying $src -> $dst"

mkdir -p "$dst"

test -d "$src" || DIE "Not a directory: $src"
test -d "$dst" || DIE "Not a directory: $dst"

src_device=$(stat --format "%d" "$src")
dst_device=$(stat --format "%d" "$dst")
if [[ $src_device != $dst_device ]] ; then
    DIE "$src and $dst have to reside on the same device for hard links to work"
fi

cp -rnl "$src"/* "$dst"/


### fatpacked app cpanm-install ################################################

#!/bin/bash

# Setup home directory based perl environment and cpanm

set -e

existing_cpanm=$(type -p cpanm)
if [[ $existing_cpanm ]] ; then

    if [[ $1 != "--force" ]] ; then
        echo "Found existing cpanm ($existing_cpanm) - use --force if you are sure" >&2
        exit 1
    fi
fi

if [[ ! $HOME =~ ^/ ]] ; then
    echo "Please specify a home starting with a /" >&2
    exit 1
fi

dst=$HOME/perl5
lib=$dst/lib/perl5
bin=$dst/bin
local_lib=$HOME/perldev/lib
local_bin=$HOME/perldev/bin
bashrc=$HOME/.bashrc
bashrc_d=$HOME/.bashrc.d

cpan_dir=$HOME/.cpan
cpanm_dir=$HOME/.cpanm

tmp=$(mktemp -d)
cd $tmp

echo
echo "Using temp dir: $tmp"
echo

echo "downloading cpanm..."

wget --no-check-certificate -q http://xrl.us/cpanm
 
if [[ -d $cpan_dir ]] ; then
    echo "Backing up old $cpan_dir to $tmp/..."
    mv $cpan_dir $tmp/
fi

if [[ -d $cpanm_dir ]] ; then
    echo "Backing up old $cpanm_dir to $tmp/..."
    mv $cpanm_dir $tmp/
fi

chmod +x cpanm
mkdir -p $bin
mv cpanm $bin/

mkdir -p $local_lib $local_bin

echo "updating $bashrc..."

add_msg="# added by cpanm-install"

echo "export PERL5LIB=$local_lib:$lib $add_msg" > bashrc
echo "export PATH=\$PATH:$local_bin:$bin $add_msg" >> bashrc
echo "alias cpanm='cpanm -nq --local-lib $dst' $add_msg" >> bashrc
echo 'alias cpan="(echo use cpanm ; exit 1)" '"$add_msg" >> bashrc

if [[ -d $bashrc_d ]] ; then
    echo '### AUTOMATICALLY GENERATED FILE - DONT EDIT! '"$add_msg" >> bashrc
    echo "adding $bashrc_d/perl..."
    cp bashrc $bashrc_d/0_perl
else

    if [[ ! -e "$bashrc" ]] ; then
        echo "$bashrc does not exist - creating new one..."
        touch $bashrc
    fi

    (cat $bashrc ; echo) | grep -v "$add_msg" >> bashrc
    cp bashrc $bashrc
fi

echo
echo "Perl environment setup complete - please review the changes."
echo
echo "Use 'cpanm ModuleName' to install modules from cpan."
echo "Cpan modules will be installed to your local directory: $dst."
echo
echo "Save your own modules to $local_lib."
echo "Save your own executables to $local_bin."
echo
echo "To run perl script as crons add these lines to your crontab:"
echo "SHELL=/bin/bash"
echo "BASH_ENV=$bashrc"
echo
echo "Please logout and back in for the changes to take effect."
echo

### fatpacked app cpanm-list-locally-installed-modules #########################

#!/usr/bin/env perl

# List all cpanm installed perl modules

use ExtUtils::Installed;
my $instmod = ExtUtils::Installed->new();
foreach my $module ($instmod->modules()) {
    print "$module\n";
}

### fatpacked app cpanm-reinstall-local-modules ################################

#!/bin/bash

# Reinstall all cpanm installed perl modules (i.e. to recompile after server move)

source bash-helpers

INFO "Reinstalling local modules..."
cpanm-list-locally-installed-modules |
    sort |
    cpanm -nq --reinstall

INFO "Done"

### fatpacked app cpanm. #######################################################

#!/usr/bin/env perl

# Allow cpanm to install modules specified via Path/File.pm

map { s/\//\:\:/g ; s/\.pm$//g } $ARGV[$#ARGV];

my @local_lib = ( "--local-lib", "$ENV{REMOTE_HOME}/perl5" );

system("cpanm", "-nq", @local_lib , @ARGV) && exit 1;

### fatpacked app crontab-setup ################################################

#!/bin/bash

# Add default crontab settings to existing crontab

source bash-helpers

(crontab -l 2>/dev/null || echo) > ~/etc/crontab.org

(
cat <<EOF
### Environment ################################################################

SHELL=/bin/bash
BASH_ENV=~/.bashrc

0 0 * * * crontab -l > ~/etc/crontab.local

### ADD JOB NAME HERE ##########################################################

# MAILTO=email1,email2,...
# m h  dom mon dow   command
# @reboot my_script
# @reboot projects-start

################################################################################

EOF
crontab -l
) | crontab -

### fatpacked app csvview ######################################################

#!/usr/bin/env perl

# Quick way to view a csv file on the command line

use warnings;
no warnings qw{uninitialized};

use Getopt::Long;
use Encode;

my $opts = { "c|count=i" => \my $count, };
GetOptions(%$opts) or die "Usage:\n" . join( "\n", sort keys %$opts ) . "\n";

my %field_types = (
    num   => qr/^[\.,\d]+[%gmt]{0,1}$/i,
    nnum  => qr/^[\-\.,\d]+$/,
    alph  => qr/^[a-z]+$/i,
    anum  => qr/^[a-z0-9]+$/i,
    msc   => qr/./i,
    blank => qr/^[\s]*$/,
    empty => qr/^$/,
);

my @field_type_order = qw(num nnum alph anum blank empty msc);

my $file;
my $is_temp_file = 0;
if ( !-t STDIN ) {
    $file         = "/tmp/csvvview.stdin.$$.csv";
    $is_temp_file = 1;

    open( F, ">", $file ) || die $!;
    while (<>) {
        print F $_;
    }
    close(F);

}
else {
    $file = shift @ARGV || die "File?";
}

open( F, $file ) || die $!;

my %stats        = ( File => $file );
my %fields       = ();
my $delimiter    = find_delimiter();
my $screen_lines = $ENV{LINES} - 1;

my $empty_line_regex = qr/^[$delimiter\s]*$/;

my @header;
my $header;
my @column_ids_header;
my $column_ids_header;
my @line;
my $line;

analyze_data();

my $lines_shown = 0;

my $last_line;
open( F, $file ) || die $!;
binmode STDOUT, ":utf8";
while (<F>) {

    s/[\r\n]//g;

    # convert latin to utf8 if necessary
    if (/[\xc0\xc1\xc4-\xff]/) {
        $stats{encoding} = "latin1";
        $_ = decode( "iso-8859-15", $_ );
    }

    if ( $_ =~ $empty_line_regex || $_ =~ /^#/ ) {
        next;
    }

    if ( $lines_shown % $screen_lines == 0 ) {
        print stats()
            . $column_ids_header
            . $header
            . padded_line( \@line, "-" );
        $lines_shown += 4;
        next;
    }

    print padded_line( [ split($delimiter) ] );

    $lines_shown++;
    $last_line = $.;
}

print "\n" x ( $screen_lines
        - ( $lines_shown - int( $lines_shown / $screen_lines ) * $screen_lines )
);

close(F);

sub find_delimiter {

    my $sample;

    open( F, $file ) || die $!;
    my $line = 0;
    while (<F>) {
        next if /^#/;
        s/[\r\n]//g;
        $line++;
        $sample .= $_;
        last if $line == 3;
    }
    close(F);

    my @special_chars      = $sample =~ /([^\w"])/g;
    my %special_char_count = ();
    map { $special_char_count{$_}++ } @special_chars;

    my $delimiter;

    if ( $sample =~ / {3,}/ ) {
        $delimiter = " +";
    }
    else {
        my $max = 0;
        foreach my $special_char ( keys %special_char_count ) {
            next if $special_char_count{$special_char} < $max;
            $delimiter = $special_char;
            $max       = $special_char_count{$special_char};
        }
    }

    $stats{delimiter} = '"' . $delimiter . '"';
    return $delimiter || die "No delimiter found.";
}

sub calculate_alpha_column_name {
    my ($num) = @_;

    my $r;
    while ( $num != 0 ) {
        $r = chr( $num % 26 + 64 ) . $r if $num % 26;
        $num = int( $num / 26 );
    }

    return $r;
}

sub analyze_data {

    my $header_line;
    open( F, $file ) || die $!;

    while (<F>) {

        $stats{format} = "dos" if /\r/;
        s/[\r\n]//g;

        $stats{Lines} = $.;

        if ( $. == 1 ) {
            $header_line = $_;
            next;
        }

        if ( $_ =~ $empty_line_regex ) {
            $stats{"Empty Lines"}++;
            next;
        }

        add_field_stats( [ split($delimiter) ] );
    }
    close(F);

    @header = split( $delimiter, $header_line );
    add_field_stats( \@header, 1 );

    set_field_types();
    create_column_ids_header();
    add_field_stats( \@column_ids_header, 1 );

    $column_ids_header = padded_line( \@column_ids_header );
    $header            = padded_line( \@header );

    my $i = -1;
    foreach my $value (@header) {
        $i++;
        $line[$i] = "-" x $fields{$i}{length};
    }
    $line = padded_line( \@line );

    foreach my $field ( keys %fields ) {

        if ( $fields{$field}{type} eq "blank" ) {
            $stats{"Blank columns"}++;
            next;
        }

        if ( $fields{$field}{type} eq "empty" ) {
            $stats{"Empty columns"}++;
            next;
        }
    }
}

sub add_field_stats {
    my ( $line, $ignore_empty ) = @_;
    my $i = -1;
    foreach my $value (@$line) {
        $i++;
        if ( !$ignore_empty || $fields{$i}{length} ) {
            $fields{$i}{length} = length($value)
                if length($value) > $fields{$i}{length};
        }

        next if $ignore_empty;

        $fields{$i}{values}{$value}++;

        foreach my $field_type (@field_type_order) {
            my $regex = $field_types{$field_type};
            if ( $value =~ $regex ) {
                $fields{$i}{types}{$field_type} = $value;
                last;
            }
        }
    }
}

sub padded_line {
    my ( $in, $pad ) = @_;

    $pad ||= " ";

    my @out;
    my $i2 = -1;
    foreach my $i ( sort { $a <=> $b } keys %fields ) {
        my $value = $in->[$i];
        next if $fields{$i}{type} =~ /empty|blank/;
        $i2++;
        $fields{$i}{name} = $header[$i];
        my $justify = $fields{$i}{type} eq "num" ? "" : "-";
        $out[$i2]
            = sprintf( '%' . $justify . $fields{$i}{length} . 's', $value );
    }
    return join( " | ", @out ) . "\n";
}

sub stats {
    my $s = "File: " . $stats{File};
    local $stats{File};
    delete $stats{File};
    my @r;
    my $i = -1;
    map { $i++; $r[$i] = $_ . ": " . $stats{$_} } sort keys %stats;
    return $s . ", " . join( ", ", @r ) . "\n";
}

sub create_column_ids_header {
    my $i = -1;
    foreach my $value (@header) {
        $i++;
        $column_ids_header[$i]
            = ( $i + 1 ) . " ("
            . calculate_alpha_column_name( $i + 1 ) . ") "
            . $fields{$i}{type} . " "
            . keys( %{ $fields{$i}{values} } );
    }
}

sub set_field_types {
    my $i = -1;
    foreach my $field (@header) {
        $i++;
        foreach my $type (@field_type_order) {
            next if !exists $fields{$i}{types}{$type};
            $fields{$i}{type} = $type;
            last;
        }
    }
}

END {
    if ($is_temp_file) {
        unlink($file) if -e $file;
    }
}

### fatpacked app ctags-index-sources ##########################################

#!/bin/bash

# Create tags for all source directories

set -e

ctags-setup

# Save absolute path in tags file
cd /

ctags -f ~/.vim/var/tags -R ~/src
# $(perl -e 'print join(" ",  grep(!/^\./, @INC))')

### fatpacked app ctags-setup ##################################################

#!/bin/bash

# Save ctags configuration file

# Configured file extensions
# ctags --list-maps=perl

# Configured kinds:
# ctags --list-kinds=perl

# Print tags found in file
# ctags -x file

set -e

# NOTE: \w does not work here inside character classes!

cat > ~/.ctags <<EOF

--regex-sh=
--regex-sh=/^\s*function\s+(\w+)/\1/f,function/
--regex-sh=/^\s*alias\s+=\s*(\w+)=/\1/f,alias/
--regex-sh=/^### ([^#]+) #/\1/f,function/

--regex-vim=/^"### ([^#]+) #/\1/f,function/

--regex-perl=/^\s*(package|class|role)\s+([a-zA-Z0-9:]+)/\2/p,package,packages/
--regex-perl=/^\s*(method|fun)\s+(\w+)/\2/s,subroutine,subroutines/
--regex-perl=/^\s*has\W+(\w+)\W*/\1/a,attribute,attributes/
--regex-perl=/^\s*with\s+(['"])(.+)\1/\2/w,with/
--regex-perl=/^\s*extends\s+(['"])(.+)\1/\2/e,extends,extend/
EOF

exit 0

# --langdef=perl
# --langmap=perl:+.t
# --regex-perl=

--langmap='perl:+.pod' \
--regex-perl='/^\s*use\s+(\w+[\w\:]*?\w*?)/\1/u,use,uses/' \
--regex-perl='/^\s*require\s+(\w+[\w\:]*?\w*?)/\1/r,require,requires/' \
--regex-perl='/^\s*\*(\w+)\s*?=/\1/a,alias,aliases/' \
--regex-perl='/^\s*our\s*?[\$@%](\w+)/\1/o,our,ours/' \
--regex-perl='/^\=head1\s+(.+)/\1/p,pod,Plain Old Documentation/' \
--regex-perl='/^\=head2\s+(.+)/-- \1/p,pod,Plain Old Documentation/' \
--regex-perl='/^\=head[3-5]\s+(.+)/---- \1/p,pod,Plain Old Documentation/' \

### fatpacked app dev-bin-generate-readme ######################################

#!/usr/bin/env perl

# Generate README with descriptions for bin scripts

use strict;
use warnings;
no warnings 'uninitialized';
use Path::Tiny;
use Text::Wrap;
$Text::Wrap::columns = 72;

die "Current dir not called bin" if !path(".")->basename eq "bin";

my $readme = path("README.md");
my ($preamble) = $readme->slurp =~ /(.*## Descriptions)/igms;

$readme->spew("$preamble\n\n");

foreach my $app (sort(path(".")->children)) {

  next if $app->is_dir;
  next
    if $app->basename =~ /^\.|^readme.md$|^package.*json$|^authorized_keys$/i;

  my ($description) = $app->slurp =~ /^=head1 NAME\s+(.+)/m;
  ($description) = $app->slurp =~ /^# (.+?)\n/m    if !$description;
  ($description) = $app->slurp =~ /^\/\/ (.+?)\n/m if !$description;

  $description =~ s/^$app[\s-]*//g;

  # $description = wrap('    ', '    ', $description) if $description;

  print STDERR "Description ends with a dot app: $app\n"
    if $description =~ /\.$/;

  print STDERR "No description found for app: $app\n" if !$description;
  $description ||= "    TODO";

  $readme->append("* [$app](./$app): $description\n");
}

### fatpacked app df. ##########################################################

#!/bin/bash

# Cleaned up df version

source bash-helpers

df -h "$@" \
    | perl -ne 'print if $_ !~ /\/snap\//' \
    | perl -0777 -pe 's/Mounted on/Mounted_on/gm' \
    | perl -0777 -pe 's/^(\S+)\n/$1/gm' \
    | csvview \
    | less -S

### fatpacked app diff-dir #####################################################

#!/usr/bin/env bash

# Diff 2 directories recursively comparing file contents and not file attributes
# (timestamp etc)

source bash-helpers

src=${1:?Specify src}
dst=${2:-.}

rsync -nrclD --delete --exclude /.git --info COPY,DEL,NAME,SYMSAFE $src/ $dst/

### fatpacked app diff-so-fancy ################################################

#!/usr/bin/env bash

# Install diff-so-fancy

exec npx diff-so-fancy


### fatpacked app dir-name-prettifier ##########################################

# shorten prompt dir to max 15 chars

source bash-helpers

dir="$@"

[[ $dir ]] || DIE "Specify directory"

if [[ $dir = $HOME ]] ;  then
    dir="~"
elif [[ $dir = $HOME/ ]] ;  then
    dir="~"
else
    dir=${dir##/*/}
fi

max_length=14
length=${#dir}

if [ $length -gt $(($max_length + 1)) ] ; then

    left_split=$(($max_length-4))
    right_split=4

    right_start=$(($length-$right_split))

    left=${dir:0:$left_split}
    right=${dir:$right_start:$length}

    dir="$left${RED}"*"${NO_COLOR}$right"
    _xtitledir=$left"..."$right

else
    _xtitledir=$dir
fi

RETURN $dir

### fatpacked app docker-ls ####################################################

#!/bin/bash
# List some docker information

echo

line-print Volumes
docker volume ls
echo

line-print Images
docker images
echo

line-print Containers
docker ps -a
echo
line-print

### fatpacked app docker-ubuntu ################################################

#!/bin/bash
# Start a volatile ubuntu docker container

source bash-helpers

cmd="$@"

if ! [[ $1 ]] ; then
  cmd=bash
fi

image=ubuntu:16.04
container=ubuntu-test
remove=--rm

if [[ $IMAGE ]] ; then
    image=$IMAGE
fi

if [[ $CONTAINER ]] ; then
    container=$CONTAINER
    unset remove
fi

mount=~/tmp/docker-home
mkdir -p $mount

docker_home=/root/

sudo docker run $remove --name $container \
    -v $HOME/.bashrc:$docker_home/.bashrc \
    -v $mount:$docker_home \
    -ti $image "$cmd"

### fatpacked app docker-ubuntu-persistent #####################################

#!/bin/bash
# Start a persistent ubuntu docker container

source bash-helpers

cmd="$@"

if ! [[ $1 ]] ; then
  cmd=bash
fi

container=ubuntu-test-persistent

set +e
sudo docker ps -a -f name=$container 2> /dev/null | grep $container &>/dev/null && found=1
set -e

if [[ $found ]] ; then
    INFO "Commiting and reusing existing container with name $container."
    INFO "Commiting may be limited to 127 times by docker."

    sudo docker commit $container $container > /dev/null
    sudo docker rm $container > /dev/null

    image=$container
fi

sudo PATH=$PATH IMAGE=$image CONTAINER=$container $(type -p docker-ubuntu) "$cmd"


### fatpacked app dockerfile. ##################################################

#!/bin/bash
# Build and run a Dockerfile

source bash-helpers

# TODO: test with quotes ie: `sh -c "apt update"`
cmd=${@:-bash --rcfile /root/.bashrc-my}

image=$(basename $(pwd))

old=.git/Dockerfile

diff -q Dockerfile $old &>/dev/null || changed=1
if [[ $changed ]] ; then
  INFO "Building image $image"
  docker build -t $image .
  cp Dockerfile $old
fi

remove=--rm

sudo docker run \
  $remove \
  -v $HOME/.bashrc:/root/.bashrc-my \
  -v $HOME/.bin:/root/.bin \
  -v $(pwd):/root/pwd \
  -ti \
  --entrypoint '' \
  $image \
  $cmd


### fatpacked app docopt-convert ###############################################

#!/usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

use Docopt;
use JSON;
use autobox::Core;
use Path::Tiny;
use Try::Tiny;

my $options  = docopt();
my $app_argv = $options->{"<argv>"};

my $doc;
my $basename;

foreach my $doc_file_name ($options->{"<file.docopt>"}->split(",")) {

    my $doc_file = path($doc_file_name);

    my $current_doc .= $doc_file->slurp;
    if ($current_doc =~ /^### docopt [#|\n]*(.+)/sm) {
        $current_doc = $1;
    }

    $doc .= $current_doc;
    $basename ||= $doc_file->basename;
}

my $docopt_ran = 0;

$doc =~ s/\$0/$basename/gm;

parse_external_doc($doc, $app_argv);

sub parse_external_doc {
    my ($doc, $argv) = @_;

    my $app_options = docopt(doc => $doc, argv => $argv);

    $docopt_ran = 1;

    convert_booleans($app_options);
    my $env_vars = generate_env_vars($app_options);

    my $json =
        JSON->new->pretty($options->{'--pretty'})->encode($app_options);

    $json =~ s/"boolean:(true|false)"/$1/gm;

    print $json     if $options->{'--json'};
    print $env_vars if $options->{'--env'};
}

sub generate_env_vars {
    my ($app_options) = @_;

    my $env_vars;

    foreach my $key (keys %$app_options) {

        my $value = $app_options->{$key};

        next if $value =~ /^\s*$/;

        $key =~ s/\W/_/g;
        $key =~ s/^_*//g;
        $key =~ s/_*$//g;

        $key = "docopt_" . $key;

        $value = 1 if $value =~ /^boolean:true$/;
        $value = 0 if $value =~ /^boolean:false$/;

        $env_vars .= "export $key='$value'; ";
    }

    return $env_vars;
}

sub convert_booleans {
    my ($twig) = @_;

    if (!ref $twig eq 'HASH') {
        return;
    }

    $twig->each(
        sub {
            my ($key, $value) = @_;
            rec($value) if ref($value) eq 'HASH';
            $twig->{$key} = $value == 1 ? "boolean:true" : "boolean:false"
                if ref $value eq 'boolean';
        }
    );
}

# Prevent docopt to exit with 0 if --help is specified
END { exit 1 if !$docopt_ran; }

__END__

=head1 NAME

docopt-convert - Convert a docopt specification

=head1 SYNOPSIS

    docopt-convert [options] <file.docopt> -- [<argv>...]

    Options: 
    -h --help     Show this screen.
    --json        Output JSON
    --env         Output environment variables for eval
    -p --pretty   Pretty print JSON


### fatpacked app dos2unix #####################################################

#!/bin/bash

# Convert line endings from dos to unix

perl -i -pe 's/\r//g' "$@"

### fatpacked app env-grep #####################################################

# Grep environment

var="$@"

if [[ -z var ]] ; then
  var=.
fi

env --null | perl -pe 's/\n/\\n/g ; s/\0/\n/g' | grep -i "$var" | grep -v LS_COLORS

### fatpacked app env-set-vars-from-lc #########################################

#!/bin/bash

# Set env vars prefixed with LC_BASHRC_ without the prefix
# This file has to be sourced to affect the running shell.

source bash-helpers

for prefixed_var in $(compgen -e LC_BASHRC_) ; do
  [[ $prefixed_var =~ ^LC_BASHRC_(.+)$ ]]
  var=${BASH_REMATCH[1]}
  echo export $var=${!prefixed_var}
done

### fatpacked app env-show #####################################################

#!/bin/bash

# Display infos about the system

function SHOW()  {
    local var=$1
    shift
    echo "$GREEN$var$NO_COLOR: $@"
}


while read v ; do
    SHOW $v ${!v}
done<<EOF
    DISTRIBUTION
    REMOTE_USER
    REMOTE_HOME
    REMOTE_HOST
    REMOTE_BASHRC
    HISTFILE_ETERNAL
    SHELL
    PATH
    PERL5LIB
EOF

SHOW Uname $(uname -a)
SHOW Kernel $(cat /proc/version)
SHOW "64-bit-CPU?" $(grep flags /proc/cpuinfo | perl -0777 -ne 'print /\blm\b/ ? "yes" : "no"')

ubuntu_version=$(cat /etc/issue | perl -ne 'print $1 if /ubuntu (\d+\.\d+)/i')

if [[ $ubuntu_version ]] ; then
    SHOW Ubuntu $ubuntu_version
else
    SHOW Linux $(cat /etc/issue.net)
fi

if [[ -e /var/run/reboot-required ]] ; then
  echo
  echo 'REBOOT REQUIRED'
  echo
fi

### fatpacked app extension ####################################################

#!/bin/bash

# Find the extension of a filename

source bash-helpers

file="$@"

if [[ ! "$file" ]] ; then
  DIE "Specify filename"
fi

# remove optional trailing slash
file=${file%/}

filename=$(basename -- "$file")
extension="${filename##*.}"

if [[ $extension = $filename ]] ; then
  exit 0
fi

extension=.$extension

if [[ $file = $extension ]] ; then
  exit 0
fi

echo $extension

### fatpacked app file-add-line-if-new #########################################

#!/usr/bin/env perl

# Add a line to a file if a line matching regex is not found

use autodie;

my $file  = $ARGV[0] || die "Specify file";
my $regex = $ARGV[1] || die "Specify regex";
my $line  = $ARGV[2] || die "Specify line";

$line .= "\n";

my @out;
open( F, "<", $file );
while (<F>) {
    if (/$regex/) {
        exit 0;
    }
    push( @out, $_ );
}
close( F );

push(@out, $line) if ! $found;

local $/;
open(F, ">", $file);
print F join("", @out);
close(F);

### fatpacked app file-compress-if-size-reaches ################################

#!/usr/bin/env perl

# Compress a file depending on size

use strict;
use warnings;
use File::stat;

my $max_human = $ARGV[0];
defined $max_human || die "Specify size in human size";
shift @ARGV;
my $file = join(" ", @ARGV);
$file || die "Specify file";

my $max_bytes = `bytes-from-human $max_human`;
defined $max_bytes || die "Cannot convert size:" . $!;

$max_bytes--;

if (stat($file)->size < $max_bytes || $file =~ /.zip$/i) {
    print $file;
    exit 0;
}

system(qq{zip "$file.zip" "$file" >/dev/null})
    && die "Error ziping $file: " . $!;

print "$file.zip";

### fatpacked app file-public-upload ###########################################

#!/bin/bash
# Share a file on a public space

source bash-helpers

file="$@"

tmpfile=$( mktemp -t transferXXX )

if ! [[ $file ]] ; then
    if tty -s ; then
        DIE Specify file}
    else
        file=$tmpfile
        cat - > $tmpfile
        dst="file.txt"
    fi
else
    dst=$(basename "$file" | perl -pe 's/[^a-zA-Z0-9._-]+/_/g ; s/_+/_/g ; s/_+$//g')
fi

client="wget -q -O - --method PUT --body-file="
if [[ $(type -t curl) ]] ; then
    client="curl --progress-bar --upload-file "
fi

dst=https://transfer.sh/$dst

INFO "Uploading using: $client$file $dst (5GB max)..."
$client"${file}" $dst
INFO "Done"

trap 'rm $tmpfile' ERR EXIT

### fatpacked app file-template-filler #########################################

#!/usr/bin/env perl

# Create a file from a template

use strict;
use warnings;

use File::Copy;

die "Usage: filltemplate" .
    " file_to_create_from_template field1=value1 field2=value2 ...\n"
    if @ARGV < 2;

my ($file, @tuples) = @ARGV;
my $template = $file. ".template";

die "Template not found: $template" if !-e $template;
die "Specify mappings." if !@tuples;

$/ = undef;

open(my $templatef, "<", $template) || die $!;
my $data = <$templatef>;
close($templatef);

for my $tuple (@tuples) {

    my ($name, $value) = $tuple =~ /^(.+?)=(.+)$/;

    $name = "TEMPL_" . uc($name);

    die "No such field: $name\n" if $data !~ /$name/;

    $data =~ s/$name/$value/igm;
}

my $temp = "/tmp/$file.$$"; 
open(my $tempf, ">", $temp) || die $!;
print $tempf $data;
close($tempf);

move($temp, $file) || die $!;

### fatpacked app filename #####################################################

#!/bin/bash

# Find the filename without the extension of a filename

source bash-helpers

file="$@"

if [[ ! "$file" ]] ; then
  DIE "Specify filename"
fi

# remove optional trailing slash
file=${file%/}

basename=$(basename -- "$file")
filename=${basename%.*}

if [[ $filename = '' ]] ; then
  echo $basename
  exit 0
fi

echo $filename

### fatpacked app files-replace-from-env #######################################

#!/bin/bash
# Replace files with content from environment variables
#
# Example:
# OVERLAY_FILE_1_NAME="la/le/lu.conf"
# OVERLAY_FILE_1_DATA=$(<settings_local.py)
#
# OVERLAY_FILE_2_NAME="la/le li/lu.conf"
# OVERLAY_FILE_2_DATA="my new data"

set -e

IFS='<newline>'

for file_env in ${!OVERLAY_FILE_*} ; do

    if [[ ! $file_env =~ _NAME$ ]] ; then
        continue;
    fi

    data_env=${file_env%%_NAME}_DATA

    file=${!file_env}
    data=${!data_env}

    echo "Replacing $file with \$$data_env" >&2
    dirname=$(dirname "$file")

    mkdir -p "$dirname"
    echo "$data" > "$file"
done


### fatpacked app filestamp ####################################################

#!/bin/bash

# Create a new backup filename with a timestamp; replace an existing timestamp

source bash-helpers

file="$@"

if [[ ! "$file" ]] ; then
  DIE "Specify filename"
fi

dirname=$(dirname $file)/
filename=$(filename $file)
basename=$(basename $filename)
extension=$(extension $file)

if [[ $filename =~ (.+)(_copy_[[:digit:]]{8}_[[:digit:]]{6}$) ]] ; then
  filename=${BASH_REMATCH[1]}
  filename=$(filename $filename)
fi

# echo ${BASH_REMATCH[*]}

postfix=_copy_$(date +%Y%m%d_%H%M%S)

bak=$dirname$filename$extension$postfix$extension

echo $bak

### fatpacked app find-from-date ###############################################

# Find files newer than date

find -maxdepth 1 -type f -printf "%CF %CH:%CM %h/%f\n" \
    | perl -ne 'print substr($_, 17) if m#^\Q'$@'\E#'

### fatpacked app find-largest-directories #####################################

#!/bin/bash

# Find largest directories recursively from current directory

find . -mount -type d \
    | xargs -I {} du -sh {} \
    | sort -rh \
    | less


### fatpacked app find-largest-files ###########################################

#!/bin/bash

# Find largest files recursively from current directory

find . -mount -type f -printf "%k %p\n" \
    | sort -rg \
    | cut -d \  -f 2- \
    | xargs -I {} du -sh {} \
    | less

### fatpacked app find-newest ##################################################

# Recursively find newest files

find -type f -printf "%CF %CH:%CM %h/%f\n" | sort | tac | less

### fatpacked app find-older-than-days #########################################

# Recursively find files oder than days

find . -type f -ctime +$1 | less

### fatpacked app find.relevant. ###############################################

#!/usr/bin/env bash

# Find usually relevant files

source bash-helpers

regex="$@"

if [[ $regex ]] ; then
  regex='-and -regex .*'$regex'.*'
fi

find \
  -H \
  -mount \
  -type f \
  -not -regex ".*/\..*" \
  -and -not -regex ".*\(node_modules\).*" \
  $regex


### fatpacked app git-env-validate #############################################

#!/bin/bash

# Ensure git-scm is configured appropriately

set -e

source bash-helpers

git config --global --get user.name  > /dev/null && DIE 'Global user name set!'
git config --global --get user.email > /dev/null && DIE 'Global user email set!'

exit 0

### fatpacked app git-ignore ###################################################

#!/bin/bash

# Download and save a default .gitignore for a specific environment

source bash-helpers

if [[ ! -d .git ]] ; then
    DIE "You need to be in the root of a git managed directory"
fi

environment=${1?Specify environment}
environment=$(echo $environment | perl -pe '$_ = ucfirst $_')

url=https://raw.githubusercontent.com/github/gitignore/master/$environment.gitignore

INFO "Fetching gitignore for $environment from $url..."
wget -qO - $url >> .gitignore

INFO "Appended to .gitignore"

### fatpacked app git-modified #################################################

#!/bin/sh -e

# List all modified files since last git commit

# from https://github.com/jasoncodes/ctrlp-modified.vim/blob/master/lib/modified.sh
if [ -e .git/MERGE_HEAD ] || [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ] || [ -e .git/CHERRY_PICK_HEAD ]; then
  git status --porcelain -z | tr '\0' '\n' | grep '^[^?][^ ?] ' | cut -d ' ' -f 2-
else
  FILES="$(git status --porcelain -z --untracked-files=all | tr '\0' '\n')"
  if [ -n "$FILES" ]; then
    echo "$FILES" | cut -c 4- | tr '\n' '\0' | xargs -0 find 2> /dev/null
  fi
fi

### fatpacked app git-project ##################################################

# Print git project root dir name

basename $(git rev-parse --show-toplevel 2>/dev/null) 2>/dev/null

### fatpacked app git-reset-head ###############################################

#!/bin/bash

# Discard all current changes in directory

set -e

source bash-helpers

git reset --hard HEAD
git clean -df
git checkout .

### fatpacked app git-reset-head-to ############################################

#!/bin/bash

# Discard commits dating back to specified commit

set -e

source bash-helpers

commit_id=${1?Specify commit id}

git reset --hard $commit_id

INFO "Push now with: git push origin HEAD --force"

### fatpacked app git-reset-origin #############################################

#!/bin/bash

# Discard all current changes in directory to origin/master

set -e

source bash-helpers

git reset --hard origin/master
git clean -df
git checkout .

### fatpacked app git-root #####################################################

# Print git project root

git rev-parse --show-toplevel 2>/dev/null || abs .


### fatpacked app git.all ######################################################

#!/usr/bin/env bash

# Add, commit and push in one step

source bash-helpers

comment="$@"

git add -A .
if [[ ! "$comment" ]] ; then
  git.commit
else
  git.commit -m "$(cat ~/.gitmessage)$comment"
fi
git push

### fatpacked app git.setup ####################################################

# Setup git configuration

source bash-helpers

bak ~/.gitconfig

cat > ~/.gitconfig <<''EOF
[core]
  color = false
  ; pager = vi
[pager]
  branch = cat
[color]
  ; log = false
  ; ui = auto
  ; diff = auto
  ; status = auto
  ; branch = auto
[pack]
  threads = 0
[alias]
  all = !git.all
  a = add -A .
  co = checkout
  c = commit
  s = status -uall
  r = remote -v
  fetch-all = fetch --all
  l = "log --graph --decorate --all --date=format:'%F %T' --pretty='%C(auto) %h %d %s %C(#BCBCBC) | %cr | %cd | %an'"
  ll = "log --graph --decorate --date=format:'%F %T' --pretty='%C(auto) %h %d %s %C(#BCBCBC) | %cr | %cd | %an'"
  log-patches = log -p
  log-date-relative = log --date=relative
  log-file = log --follow -p --
  files-all-ever = !git log --pretty=format: --name-only --diff-filter=A | uniq-unsorted | tac
  b = branch --list -vva --sort=committerdate
  d = diff -- ':(exclude)package-lock.json' .
  push-all-branches = push --all -u
[push]
  default = simple
[commit]
	verbose = true
  template = ~/.gitmessage 
[diff "nodiff"]
  command = /bin/true
[user]
	email = you@example.com
	name = Your Name
EOF

### fatpacked app git.user.check ###############################################

#!/bin/bash

# Check if global user is set

git config --global user.name 2>/dev/null && DIE "Global git user.name is set"
git config --global user.email 2>/dev/null && DIE "Global git user.email is set"

### fatpacked app github.clone.user ############################################

#!/usr/bin/env bash

# Clone all github repos of a user

source bash-helpers

type curl &>/dev/null || pkexec apt install curl
type jq &>/dev/null || pkexec apt install jq

user=${1:?Specify user}

curl -s "https://api.github.com/users/$user/repos?per_page=1000" \
  | jq -r ".[].ssh_url" \
  | xargs -L1 git clone

### fatpacked app gnome-send-to-mail-images ####################################

#!/usr/bin/perl

=pod

=head1 Send_Resized_Image_Via_Email

# Resize one or more images and add them as attachements
to a new compose email window of the Evolution or Thunderbird email client.

=head1 Prerequisites

Needs imagemagick

=head1 Installation

=over

=item - wget https://raw.githubusercontent.com/nilsboy/bin/master/gnome-send-to-mail-images-setup | bash
        or

=item - copy script to ~/.local/share/nautilus/scripts/

=item - rename the script to match what you want to see in the gnome file
context menu

=back

=head1 Usage

=over

=item - to use thunderbird as email client instead of evolution change
    $use_thunderbird = 0 to $use_thunderbird = 1

=item - select one or more images in Gnome-Nautilus

=item - right click on one of the images

=item - select scripts->"name you gave the script"

=item - compose window now opens with resized image/s as attachment

=back

=cut

my $use_thunderbird = 1;

use strict;
use warnings;
no warnings 'uninitialized';

use File::Basename;

my $imgsize = "x600";

my $evolution_cmd   = "/usr/bin/evolution mailto:";
my $thunderbird_cmd = qq{/usr/bin/thunderbird -compose "attachment='};

my $first         = 1;
my $found         = 0;
foreach my $infile (@ARGV) {

    next if !-e $infile;

    $found = 1;

    my $outfile = basename($infile);
    my $image_type;
    ( $outfile, $image_type ) = $outfile =~ /^(.+)\.(.+?)$/;

    $outfile = "/tmp/${outfile}_verkleinert.$image_type";

    qx { /usr/bin/convert -antialias -scale $imgsize "$infile" "$outfile" };

    if ($first) {
        $evolution_cmd .= "?";
        $first--;
    }
    else {
        $evolution_cmd   .= "\\&";
        $thunderbird_cmd .= ",";
    }

    $evolution_cmd   .= qq{attach="$outfile"};
    $thunderbird_cmd .= qq{file://$outfile};
}

$thunderbird_cmd .= q{'"};

exit if !$found;

if ($use_thunderbird) {
    qx { $thunderbird_cmd };
    exit 0;
}
qx { $evolution_cmd };

### fatpacked app gnome-send-to-mail-images-setup ##############################

#!/bin/bash

# Download and setup gnome-send-to-mail-images

set -e

# Does not seem to work in a pipe...
# (sudo apt-get install imagemagick)

dir=~/.local/share/nautilus/scripts

mkdir -p $dir
cd $dir

wget -q https://raw.githubusercontent.com/nilsboy/bin/master/gnome-send-to-mail-images
chmod +x gnome-send-to-mail-images

if [[ $LANG =~ de ]] ; then
    mv gnome-send-to-mail-images Bild_per_Email_verschicken
fi

echo "OK - script installed"

### fatpacked app gnome-terminal-prevent-cursor-blinking #######################

#!/usr/bin/env bash

# Prevent the gnome-terminal cursor from blinking

source bash-helpers

gconftool-2 --set /apps/gnome-terminal/profiles/Default/cursor_blink_mode --type string off


### fatpacked app gotroot ######################################################

#!/bin/bash

# Make sure we're running as root

source bash-helpers

if [[ $USER != root ]] ; then
    DIE "Please run as root"
fi

### fatpacked app grep-before ##################################################

#!/usr/bin/env perl

# Print file contens before a specified regex first matches

while (<STDIN>) {
  exit 0 if /@ARGV/i;
  print;
}

exit 1;

### fatpacked app grep-from ####################################################

#!/usr/bin/env perl

# Print file contens from where a specified regex first matches

use strict;
use warnings;

my $found;
while (<STDIN>) {
    $found = 1 if /@ARGV/i;
    print if $found;
}

exit 1 if !$found;

### fatpacked app grep-goo #####################################################

#!/usr/bin/env perl

# Or-grep but list matching patterns instead of matching lines
#
# Only longest matches are returned.

my $matches;
while ( my $line = <STDIN> ) {
    foreach my $regex ( sort { length($b) <=> length($a) } @ARGV ) {
        next if $line !~ /$regex/ig;
        $matches++;
        print "$regex\n" x $line =~ s/$regex//ig;
    }
}

exit 1 if !$matches;

### fatpacked app grep-list ####################################################

# Grep for a list of values

grep -xFf $@

### fatpacked app grep-or ######################################################

#!/usr/bin/env perl

# or-grep list matching lines

use strict;
use warnings;

my $matches;
while (my $line = <STDIN>) {
  foreach my $regex (@ARGV) {
    next if $line !~ /$regex/i;
    $matches++;
    print $line;
    last;
  }
}

exit 1 if !$matches;

### fatpacked app grep-or-with-header ##########################################

#!/usr/bin/env perl
# or-grep and print paragraph headers

use strict;
use warnings;

my @regexes = @ARGV;
my $matches;
my $last_blank;
my $last_header;
while (my $line = <STDIN>) {

  my $is_header = 0;
  my $first     = $. == 1;

  if ($line =~ /^\s*$/) {
    $last_blank = 1;
  }
  else {
    if ($last_blank || $first) {
      $last_blank  = 0;
      $is_header   = 1;
      $last_header = $line;
    }
  }

  if (matches_any($line)) {
    $matches++;

    if ($is_header) {
      $last_header = "";
    }

    if ($last_header) {

      # Check for pipe
      if (-t STDOUT && $matches > 1) {
        print "\n";
      }
      print $last_header;
      $last_header = "";
    }

    print $line;
    next;
  }

}

exit 1 if !$matches;

sub matches_any {
  my $line = shift;

  foreach my $regex (@regexes) {
    return 1 if $line =~ /$regex/i;
  }

  return 0;
}


### fatpacked app grep.and #####################################################

#!/usr/bin/env perl

# Search for lines matching one or more perl regex patterns

use strict;
use warnings;
no warnings 'uninitialized';

my $red      = "\x1b[38;5;124m";
my $no_color = "\x1b[33;0m";

if (!-t STDOUT) {
  $red = $no_color = "";
}

my @patterns = @ARGV;

LINE: while (<STDIN>) {
  my $org = $_;

  foreach my $pattern (@patterns) {
    if (!s/($pattern)/$red$1$no_color/gi) {
      next LINE;
    }
  }

  print $org;
}

### fatpacked app grep.with.context ############################################

#!/usr/bin/perl

# Grep for a regex and display matches with context

# TODO limit match count
# TODO limit input

use strict;
use warnings;
no warnings 'uninitialized';

$/ = undef;
my $data    = <STDIN>;
my $pattern = $ARGV[0];

my $gray     = "\x1b[38;5;243m";
my $green    = "\x1b[32;5;250m";
my $red      = "\x1b[38;5;124m";
my $no_color = "\x1b[33;0m";

my $positions = match_all_positions($pattern, $data);

my $context   = 100;
my $max_width = 70;
my $prefix    = "    ";
my $separator = "\n$prefix" . "_" x $max_width . "\n\n";

my @wrapped_matches;
foreach my $pos (@$positions) {
  my ($start, $end) = @$pos;

  my $context_start = $start - $context < 0 ? 0 : $start - $context;
  my $pre   = substr($data, $context_start, $start - $context_start);
  my $match = substr($data, $start,         $end - $start);
  my $post  = substr($data, $end,           $context);
  my $all   = $pre . $match . $post;

  my $wrapped = join("\n", unpack("(A$max_width)*", $all));

  my $pre_wrapped = substr($wrapped, 0, length($pre));
  my $match_wrapped =
    $red . substr($wrapped, length($pre), length($match)) . $no_color;
  my $post_wrapped = substr($wrapped, length($pre) + length($match));

  my $all_wrapped = $pre_wrapped . $match_wrapped . $post_wrapped;

  $all_wrapped =~ s/^/$prefix/gm;
  $all_wrapped =~ s/\n+$/\n/gm;

  push(@wrapped_matches, $all_wrapped);
}

print $separator . join($separator, @wrapped_matches) . $separator;

sub match_all_positions {
  my ($regex, $string) = @_;
  my @ret;
  while ($string =~ /$regex/igm) {
    push @ret, [ $-[0], $+[0] ];
  }
  return \@ret;
}

### fatpacked app groups-reload-memberships ####################################

# Start new shell to "reload" changes to the list of groups the user belongs to

exec su -l $USER

### fatpacked app hd-set-spin-timeout ##########################################

#!/bin/bash
# Activate spindown and set spindown timeout on (buggy - i.e. Seagate) hard drives that don't do it themselfes

# See http://howtoeverything.net/linux/hardware/why-some-hard-disks-wont-spin-down-hdparm

source bash-helpers

# list spindown timeout on all hds
# sudo hdparm -B /dev/sd?

# test if spindown works
# sudo hdparm -y /dev/sdb

label=${1?Specify drive label}
path=/dev/disk/by-label/$label

# set workaround mode for buggy drives
sudo hdparm -B255 $path

# set timeout specified in multiples of 5s
sudo hdparm -S180 $path

### fatpacked app head-warn ####################################################

#!/usr/bin/perl
# Limit input lines and warn if more lines are left

use strict;
use warnings;
no warnings 'uninitialized';

my $count = 0;
my $limit = 100;

if($ARGV[0] =~ /-(\d+)/) {
  $limit = $1;
}

my $red      = "\x1b[38;5;124m";
my $no_color = "\x1b[33;0m";

if (!-t STDERR) {
    $red = $no_color = "";
}

my $last;
while(<STDIN>) {
  $count++;

  if($count == $limit + 1) {
    print $last;
    print STDERR $red . "### Limit of $limit exceeded. ###" . $no_color . "\n";
    exit 0;
  }

  print $last if $last;

  $last = $_;
}

print $last;

### fatpacked app html-strip ###################################################

#!/usr/bin/env perl

# Strip HTML of tags and entities

use strict;
use warnings;

use HTML::Strip;

undef $/;

print HTML::Strip->new()->parse( <> );

### fatpacked app http-echo-server #############################################

# Test HTTP server that response with the request

npx --ignore-existing @nilsboy/http-echo-server "$@"

### fatpacked app internalip ###################################################

#!/bin/sh

# get internal IP address
# used for outgoing Internet connections
# see: https://github.com/rsp/scripts/blob/master/internalip.md

resolve() {
	(gethostip -d $1 || getent ahostsv4 $t | grep RAW | awk '{print $1; exit}') 2>/dev/null
}
noip() {
	[ -n "$(echo $1 | tr -d '0-9.\n')" ]
}

[ -n "$1" ] && t=$1 || t='8.8.8.8'

noip $t && t=$(resolve $t)

[ -n "$t" ] || { echo Cannot resolve domain $1 >&2; exit 1; }

ip route get $t | awk '{print $NF; exit}'


### fatpacked app java-decompile-jar ###########################################

#!/bin/bash

# Recursively decompile a jar including contained jars

source bash-helpers

set -e

org_jar=${1?Specify jar}
tmp_dir=$(basename $org_jar).decompiled

mkdir $tmp_dir
cp $org_jar $tmp_dir/

cd $tmp_dir

while true ; do

    for jar in $(find -iname "*.jar") ; do

        INFO "Unpacking jar: $jar..."
        jar xf $jar
        rm $jar

    done

    if [[ ! $(find -iname "*.jar") ]] ; then
        break
    fi

done

INFO "Decompiling classes..."

set +e
for class in `find . -name '*.class'`; do

    if jad -d $(dirname $class) -s java -lnc $class 2>/dev/null 1>/dev/null ; then
        rm $class
    else
        ERROR "Can not be decompiled: $class"
    fi

done

### fatpacked app java-install-oracle-java-v8 ##################################

#!/bin/bash
# Install oracle java 8

source bash-helpers

gotroot

INFO "For more info see: http://www.webupd8.org/2012/09/install-oracle-java-8-in-ubuntu-via-ppa.html"

add-apt-repository ppa:webupd8team/java
apt-get update

apt-get install oracle-java8-installer

### fatpacked app js-format-using-prettydiff ###################################

#!/usr/bin/env node

// Javascript formatter using "npm install prettydiff"

var prettydiff = require("prettydiff");

var js = "";

process.stdin.on("data", receiveStdinChunk)
	.on("end", beautifyToStdout);

function receiveStdinChunk(chunk) {
	js += chunk.toString();
}

function beautifyToStdout() {

	var output = prettydiff.api({
		source: js,
		mode: "beautify",
		lang: "javascript",
		report: false,
		preserve: true,
		varword: "each",
		wrap: 80,
		correct: true,
		quoteconvert: "double"
	});

	// remove report
	output.pop();

	process.stdout.write(output.toString());
}

### fatpacked app json-tidy ####################################################

#!/usr/bin/env perl

# Tidy a json file and sort hash keys to make the output diffable

use strict;
use warnings;
use JSON::PP;
use Sort::Naturally;
use Path::Tiny;

my $json = JSON::PP->new->filter_json_object(
    sub {
        my $o = shift;

        if (ref $o eq 'HASH') {

            while (my ($key, $value) = each %$o) {

                if (ref $value eq 'HASH' && !%$value) {
                    delete $o->{$key};
                    next;
                }

                if (ref $value eq 'ARRAY' && !@$value) {
                    delete $o->{$key};
                    next;
                }
            }
        }

        return ();
    }
);

if (@ARGV) {
    foreach my $file (@ARGV) {
        my $path = path($file);
        my $in   = $json->decode($path->slurp);
        $path->spew(
            $json->pretty->sort_by(
                sub {
                    ncmp($JSON::PP::a, $JSON::PP::b);
                }
                )->encode($in)
        );
    }
}
else {
    undef $/;
    my $in = <STDIN> || exit;
    $in = $json->decode($in);
    print $json->pretty->sort_by(
        sub {
            ncmp($JSON::PP::a, $JSON::PP::b);
        }
    )->encode($in);
}


### fatpacked app json2yaml ####################################################

#!/usr/bin/env bash

# Install and run json2yaml

exec npx json2yaml -d 9999 "$@"

### fatpacked app keyboard-backlight-permanently-off ###########################

#!/usr/bin/env bash

# Turn keyboard backlight off permanently

source bash-helpers

gotroot

sudo apt install sysfsutils

cat << EOF >> /etc/sysfs.conf
devices/platform/dell-laptop/leds/dell\:\:kbd_backlight/brightness = 0
EOF


### fatpacked app keyboard-disable-caps-lock-console ###########################

#!/bin/bash

# Map caps lock to escape for consoles

(
    echo `dumpkeys | grep -i keymaps` ; \
    echo keycode 58 = Escape \
) | sudo loadkeys -

### fatpacked app keyboard-remap-keys-xwindows #################################

#!/bin/bash
# Map caps lock to escape etc for X

# See also
# man xkeyboard-config
# man setxkbmap

dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:escape','altwin:ctrl_alt_win']"

# dconf write /org/gnome/desktop/input-sources/xkb-options "['ctrl:ctrl_ralt']"
# dconf write /org/gnome/desktop/input-sources/xkb-options "['ctrl:swap_lalt_lctl']"

exit

# Deprecated since Ubuntu 14.04:

if [[ $(xmodmap -pke | grep -i caps) ]] ; then
    xmodmap -e "remove lock = Caps_Lock" -e "keysym Caps_Lock = Escape"
fi


### fatpacked app keyboard-reset ###############################################

#!/usr/bin/env perl

# Reset keyboard settings

use strict;
use warnings;

my $current = `setxkbmap -query`;

die "Error querying current keyboard setting." if !$current;

print "Current keyboard settings:\n$current\n";

my ($rules)   = $current =~ /rules:\s+(\S+)/igm;
my ($model)   = $current =~ /model:\s+(\S+)/igm;
my ($layout)  = $current =~ /layout:\s+(\S+)/igm;
my ($variant) = $current =~ /variant:\s+(\S+)/igm;

$rules   ||= "evdev";
$model   ||= "pc105";
$layout  ||= "de";
$variant ||= "nodeadkeys";

my $cmd =
    "setxkbmap -model $model -layout $layout -variant $variant -rules $rules";

print STDERR "Running: $cmd\n";
print `$cmd`;

### fatpacked app line-print ###################################################

#!/usr/bin/env perl
# Draw a line on the terminal spanning the whole width optionally including a message

use strict;
no warnings 'uninitialized';

my $msg;
if(@ARGV) {
    $msg = " " . join(" ", @ARGV) . " ";
}
print "---", $msg , q{-} x ($ENV{COLUMNS} - 3 - length($msg)), "\n\n";

### fatpacked app linux-distribution-info ######################################

#!/usr/bin/env bash

# List linux distribution variables

source bash-helpers

if [[ -e /etc/lsb-release ]] ; then
    cat /etc/lsb-release
    exit
fi

if [[ -e /etc/debian_version ]] ; then
    echo DISTRIB_ID=debian
    exit
fi

echo DISTRIB_ID=$(cat /etc/*{version,release} 2>/dev/null \
        | perl -0777 -ne 'print lc $1 if /(debian|suse|redhat)/igm')

### fatpacked app ls-creation-time #############################################

# List the creation time of a file

source bash-helpers

file="$@"

if [[ ! "$file" ]] ; then
    DIE "Specify file"
fi

filesystem=$(df --output=source "$file" | tail -1)
inode=$(stat --printf=%i "$file")
date=$(sudo debugfs -R "stat <$inode>" $filesystem 2>/dev/null \
    | perl -007 -ne 'print "$1\n" if /crtime.*--(.+)/i')

formatted_date=$(date -d "$date" +"%F %T %a")
echo $formatted_date $file

### fatpacked app mail-setup-local-delivery ####################################

#!/usr/bin/env bash

# Setup local mail delivery on ubuntu 18.04

source bash-helpers

gotroot

forwardRootTo=${1:?Specify username to forward root mail to.}

apt-get install postfix mailutils mutt

bak /etc/aliases

cat << EOF > /etc/aliases
# See man 5 aliases for format
postmaster:    root
root: $forwardRootTo@localhost
EOF

newaliases
service postfix restart

if [[ -e /root/.forward ]] ; then
  bakmp /root/.forward
fi

if [[ -e /home/$forwardRootTo/.forward ]] ; then
  bakmp /home/$forwardRootTo/.forward
fi

### fatpacked app man-cheatsh ##################################################

#!/usr/bin/env bash

# the only cheat sheet you need

curl https://cheat.sh/"$@"?style=autumn

### fatpacked app man-explain-options ##########################################

#!/usr/bin/env perl

# Display man page infos about command line options

use strict;
use warnings;
no warnings 'uninitialized';

my $cl = join( " ", @ARGV ) || die "Specify command line.";
my ( $command, $options ) = $cl =~ /^(\S+) (.+)$/;
die "Specify options." if !$options;

my @options            = $options =~ /(-{1,2}\S+)/g;
my @normalized_options = ();

foreach my $option (@options) {

    # split grouped options (starting with a single dash)
    if ( $option =~ /^-[^-]{2,}/g ) {
        foreach my $single_option ( split( //, $option ) ) {
            next if $single_option eq "-";
            push( @normalized_options, "-" . $single_option );
        }
    }
    else {
        push( @normalized_options, $option );
    }
}

@options = @normalized_options;

die "No options found." if ! @options;

my $man = `man $command` || die "Cannot open man page for $command";

my @unknown_options = ();

print "$command:\n";

foreach my $option (@options) {

    my $option_regex = $option;

    if($option =~ /^--(\w+)/) {
        my $bare_option = $1;
        $bare_option =~ s/^no//g;
        $option_regex .= "|--no" . $bare_option . "|--\\[no\\]" . $bare_option . "|-no-" . $bare_option;
    }

    $option_regex = "(" . $option_regex . ")";

    # TODO: support:
    # -c, --count
    # --color-lineno=color
    # ack -s -H --nocolor --nogroup --column --smart-case --follow --count --flush --with-filename -c
    # --nocolor
    # --[no]color, --[no]colour
    # -H, --with-filename

    # print "checking option: $option / $option_regex\n";
    my ($space, $desc) = $man =~ /^(\s+)(?:(?:-{1,2}\w+, )*|\s+)($option_regex\W.+?)^\1-/ms;

    if ( !$desc ) {
        push( @unknown_options, $option );
        next;
    }
    $desc =~ s/\n$//gms;
    print "   $desc\n";
}

print STDERR "No description found for options: "
    . join( ", ", @unknown_options ) . "\n"
    if @unknown_options;

### fatpacked app man-multi-lookup #############################################

#!/bin/bash

# Lookup help for a command in several places

source bash-helpers

set +e

COLUMNS=80

# format output in pipes too
MAN_KEEP_FORMATTING=1 

function _printifok() {
  local msg=$1 ; shift
  local cmd="$*"

  local out=$($cmd 2>/dev/null)
  if [[ -z $out ]] ; then
    return 1
  fi
  line $msg
  echo "${out[@]}"
  echo
}

function _printifany() {
  local msg=$1
  local cmd=$2
  type $cmd &>/dev/null || return

  local out=$($cmd --help 2>&1)
  # perldoc
  if [[ -z $out ]] ; then
    return
  fi

  line $msg
  echo "${out[@]}"
  echo
}

cmd=$1 ; shift
arg="$1"

if [[ $arg =~ ^-- ]] ; then
   arg="+/$arg"
elif [[ $arg =~ ^- ]] ; then
   arg="+/^\\s+$arg"
elif [[ $arg ]] ; then
   arg="+/$arg"
else
   arg='+/^--- .+ -+$'
fi

(
_printifok options man-explain-options $cmd "$@"
_printifok help help -m $cmd
_printifok man man -a $cmd
_printifany "--help" $cmd
_printifok README npm-readme $cmd
_printifok perldoc perldoc -f $cmd

if [[ $ALL ]] ; then
  _printifok related man -k $cmd
  _printifok "apt show" apt-cache show $cmd
  _printifok "apt search" apt-cache search $cmd
fi
) | LESS="-inRgSj.5" less "$arg"

### fatpacked app man-online ###################################################

#!/bin/bash

# Lookup a man page on the internet

cmd=$1
(
    wcat -s http://man.cx/$cmd \
        | perl -0777 -pe 's/^.*\n(?=\s*NAME\s*$)|\n\s*COMMENTS.*$//smg' \
        | perl -0777 -pe 'exit 1 if /Sorry, I don.t have this manpage/' \
        && echo

) | LESS="-j.5 -inRg" less $arg

### fatpacked app markdown-view ################################################

#!/usr/bin/env node

// View markdown in the terminal

var fs = require('fs');

var marked = require('marked');
var TerminalRenderer = require('marked-terminal');

marked.setOptions({
    renderer: new TerminalRenderer()
});

console.log(marked(fs.readFileSync(process.argv[2])
    .toString()));

### fatpacked app mem-empty-swap-to-ram ########################################

#!/bin/bash

# Empty swap back to ram if possible

# based on https://help.ubuntu.com/community/SwapFaq

source bash-helpers

gotroot

mem=$(LC_ALL=C free  | awk '/Mem:/ {print $4}')
swap=$(LC_ALL=C free | awk '/Swap:/ {print $3}')

if [ $mem -lt $swap ]; then
    DIE "Not enough RAM to write swap back, nothing done."
fi

swapoff -a && 
swapon -a

INFO "Done"

### fatpacked app mem-swap-per-process #########################################

#!/bin/bash

# Show swap usage per process
# see also http://www.cyberciti.biz/faq/linux-which-process-is-using-swap/

smem "$@"

### fatpacked app mount. #######################################################

#!/usr/bin/env bash

# Show mounts without snap etc

source bash-helpers

mount "$@" | grep -v 'appimage' | grep -v 'snap'

### fatpacked app mount.overlay ################################################

#!/usr/bin/env bash

# Mount a directory over another

source bash-helpers

gotroot

lower=${1:?Specify lower directory}
upper=${2:?Specify upper directory}
merged=$upper
merged=${merged/\//}
workdir=.$merged.overlay-work

INFO "Mounting $lower + $merged -> $merged"

INFO "Creating temp workdir for overlayfs: $workdir"
mkdir -p $workdir

sudo mount \
  -t overlay none \
  -o "lowerdir=$lower,upperdir=$upper,workdir=$workdir" \
  $upper

### fatpacked app mouse.jiggle #################################################

#!/usr/bin/env bash

# Jiggle mouse to prevent system idle

source bash-helpers

delay=${1:-60}

while true ; do
  xdotool mousemove_relative 1 0
  xdotool mousemove_relative -- -1 0
  sleep $delay
done

### fatpacked app mybackup #####################################################

#!/usr/bin/env bash

# create a backup

source bash-helpers

# if run from cron
if [[ -z $USER ]] ; then
  USER=$LOGNAME
fi

drives=/media/$USER/*backup*

set +e
mounts=$(ls -d $drives 2>/dev/null | wc -l)
set -e

if [[ $mounts == 0 ]] ; then
  DIE "No backup drive found - please connect drive."
fi

if [[ $mounts > 1 ]] ; then
  DIE "Too many backup drives found - please disconnect all but one."
fi

drive=$(ls -d $drives)

src=${1:?Specify directory to backup}
basename=$(basename "$src")
basename=${basename/\//}

if [[ -z "$basename" ]] ; then
  DIE "Specify directory to backup"
fi

if ! [[ -d "$src" ]] ; then
  DIE "No such directory: $src"
fi

dst=$drive/${basename}_backup
dst_current=$dst/$basename

INFO "Backing up $src -> $dst"

timestamp=$(date +%Y%m%d_%H%M%S)
history=../history/${basename}_${timestamp}

app_id="5774adbf-d22e-48dc-b0ed-6fb0a8abc901"
id_file=$dst/.$app_id

if [[ -d "$dst" ]] ; then
  if [[ ! -e "$id_file" ]] ; then
    DIE "Directory already exists: $dst"
  fi
fi

mkdir -p $dst_current
touch $id_file

set -x

rsync \
  --verbose \
  --archive \
  --partial --partial-dir=rsync-partial \
  --delete \
  --delete-excluded \
  -b --backup-dir $history \
  --exclude /.cache \
  --exclude /.thumbnails \
  --exclude /.Trash \
  --exclude /.local/share/Trash \
  --exclude /.Xauthority \
  $src/ $dst_current/

set +x

INFO "Backup done."


### fatpacked app mysql. #######################################################

#!/bin/bash

# Fix mysql prompt to show real hostname - NEVER localhost

source bash-helpers

host=$(perl -e '"'"$*"'" =~ /[-]+h(?:ost(?:=*))*\ ([^ \\.]+)/ && print $1')
database=$(perl -e '"'"$*"'" =~ /([-]+d(?:atabase(?:=))*\ ([^ \\.]+)|(\w+$))/ && print $1')

if [[ ! $host || $host = localhost ]] ; then
    host=$HOSTNAME
fi

if ! [[ $database ]] ; then
    DIE "Cannot identify database"
fi

history_dir=$REMOTE_HOME/.mysql/history
history_file=$history_dir/$database"@"$host

mkdir -p $history_dir

# MYSQL_PS1="\\u@${GREEN}$h${NO_COLOR}:${RED}\\d db${NO_COLOR}> " \
xtitle "mysql@$host" && \
    MYSQL_PS1="\\u@$host:\\d db> " \
    MYSQL_HISTFILE=$history_file mysql $0 \
        --default-character-set=utf8 \
        --show-warnings --pager="less -FX" "$@"

### fatpacked app mysqldump-structure ##########################################

#!/usr/bin/env bash

# Dump the structure without the data of a mysql database

source bash-helpers

host=${1:?Specify host}
database=${2:?Specify database}
user=${3:?Specify user}
password=${4:?Specify password}

mysqldump \
  --protocol=TCP \
  --single-transaction \
  --skip-comments \
  --skip-set-charset \
  -d \
  -u $user \
  --password="$password" \
  --host $host \
  $database


### fatpacked app neovim-setup #################################################

#!/usr/bin/env bash

# Setup neovim

source bash-helpers

sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim

sudo apt-get install python-dev python-pip python3-dev python3-pip

pip3 install --user neovim

### fatpacked app net-find-free-port ###########################################

#!/bin/bash

# Find an unused port

set -e

port=$1
ports="32768..61000";

if [[ $port ]] ; then
    ports="$port,$ports";
fi

netstat  -atn \
    | perl -0777 -ne '@ports = /tcp.*?\:(\d+)\s+/imsg ; for $port ('$ports') {if(!grep(/^$port$/, @ports)) { print $port; last } }'

### fatpacked app net-forward-port #############################################

#!/bin/bash

# Forward an incoming port to a different port
# Often needed to map a privileged port to an unprivileged one.

source bash-helpers

src=${1?Specify incoming port}
dst=${2?Specify outgoing port}

sudo iptables -t nat -A PREROUTING -p tcp --dport $src -j REDIRECT --to-port $dst

### fatpacked app net-ip2name ##################################################

#!/usr/bin/env perl

# Replace ip adresses with host names inside of text

use strict;
use warnings;
no warnings 'uninitialized';
use Socket;

$| = 1;

my %found = ( "0.0.0.0" => "0.0.0.0" );

while (<>) {

    foreach my $ip_and_port (/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?:\:\d+)*)/g)
    {
        my ( $ip, $port ) = split( ":", $ip_and_port );

        if ( $ip =~ /\.255/ ) {
            $found{$ip} = $ip;
        }

        my $name
            = $found{$ip} || gethostbyaddr( inet_aton($ip), AF_INET ) || $ip;

        $found{$ip} = $name;

        $name = $name . ":" . $port if $port;

        if ( length($name) < length($ip_and_port) ) {
            $name = sprintf( "%-" . length($ip_and_port) . "s", $name );
        }

        s/\Q$ip_and_port\E/$name/g;
    }

    print;
}

### fatpacked app net-open-ports ###############################################

# List all open ports

netstat -tapnu | less -S

### fatpacked app net-remote-shell #############################################

#!/bin/bash

# Create shell access on a free port

# TODO

set -x
fifo

(
    set -e

    port=$(freeport)
    fifo=$(tempfile)

    echo "using port: $port"
    echo "using fifo: $fifo"

    if [ -e $fifo ] ; then
        rm -f $fifo
    fi

    mkfifo $fifo

    # nc -k respawns

    cat $fifo \
        | /bin/sh -i 2>&1 \
        | nc -l 127.0.0.1 $port
    > $fifo
)

if [ -e $fifo ] ; then
    echo "removing fifo: $fifo"
#    rm -f $fifo
fi

### fatpacked app net-scan-private-network #####################################

# Scan for hosts in private network

nmap -sn 192.168.0.0/16

### fatpacked app net-wlan-rtl8723be-wrong-antenna-fix #########################

#!/usr/bin/env bash

# Fix wrong antenna problem of rtl8723be wlan adaptor
# Used in HP 250 laptops

source bash-helpers

gotroot

echo "options rtl8723be ant_sel=1" > /etc/modprobe.d/rtl8723be.conf

### fatpacked app net.dns.dump #################################################

#!/usr/bin/env bash

# dump all infos on a domain

source bash-helpers

dig "$@" any

INFO type257
dig "$@" type257

### fatpacked app net.dns.local ################################################

#!/usr/bin/env bash

# Show local DNS status

source bash-helpers

systemd-resolve --status

### fatpacked app net.firewall.setup.example ###################################

#!/usr/bin/env bash

# Firewall setup example
# Copy this to ~/bin/firewall.setup and adapt it.

source bash-helpers

sudo ufw --force reset

## from external
sudo ufw limit ssh/tcp comment 'ssh'
# sudo ufw allow in on tun0 to any port 4662 comment 'rtorrent'

## from internal
# sudo ufw allow in on eno1 from 192.168.0.0/16 to any port 5000 comment 'webserver'
# sudo ufw allow in on eno1 from 192.168.0.0/16 to any port 8000 comment 'webserver-file-manager'
# sudo ufw allow in on eno1 proto udp from 192.168.0.0/16 to any port 1714:1764 comment 'kde connect'
# sudo ufw allow in on eno1 proto tcp from 192.168.0.0/16 to any port 1714:1764 comment 'kde connect'

sudo ufw reload
sudo ufw enable
sudo ufw status

### fatpacked app net.serve.dir ################################################

#!/usr/bin/env bash

# Serve current directory files via http

source bash-helpers

npm install -g serve
serve --port 5001 .

### fatpacked app net.serve.file-manager #######################################

#!/usr/bin/env bash

# Serve a file manager for the current directory via http

source bash-helpers

dir=$(pwd)
INFO "Serving current directory: $dir"
npm install -g node-file-manager
npx node-file-manager -p 5002 -d $dir

### fatpacked app net.serve.json ###############################################

#!/bin/bash

# JSON backed rest server

source bash-helpers

name=${1?Specify server dir}
port=$(net-find-free-port)

INFO "Starting rest server - documentation: https://www.npmjs.com/package/json-server"

mkdir -p "$name/public"

cd "$name"

db="db.json"

if [ ! -e $db ] ; then
    echo '{ "list" : [], "map": {} }' > $db
    echo '<b>'"$name"'</b> - rest service' > public/index.html
fi

npx json-server --port $port --watch $db

### fatpacked app node-install #################################################

#!/bin/bash

# Install latest node version

source bash-helpers

DIE 'Use nvm-setup instead'

node_dst=~/opt/node
node_bin=~/opt/bin/node
npm_bin=~/opt/bin/npm
backup=~/opt/node-install.backup.$(date +%Y%m%d_%H%M%S)

if [[ -e $node_dst || -h $node_dst || -e $node_bin || -h $node_bin || -e $npm_bin || -h $npm_bin ]] ; then

    if [[ $1 != "--force" ]] ; then
        DIE "Found existing node in ~/opt - use --force if you are sure"
    fi

    INFO "Backing up existing node to $backup"
    mkdir -p $backup
fi

wd=$(mktemp -d --suffix=.node-install)
cd $wd

bits=$(uname -m | perl -ne 'print $1 if /_(32|64)$/')

url=https://nodejs.org/dist/latest

file=$(wget -q -O - $url | perl -ne 'print $1 if /(node-v[\d\.]+-linux-x'$bits'.tar.gz)/i')
url=$url/$file
dir=$(echo $file | perl -pe 's/\.tar.gz//g')

INFO "Downloading: $url"
wget -q $url

INFO "Extracting to $dir"
tar xfz $file

rm $file

mkdir -p ~/opt/bin

node_dst_versioned=~/opt/$dir

for file in $node_dst $node_dst_versioned $node_bin $npm_bin ; do
    if [ -e $file ] || [ -d $file ] || [ -L $file ] ; then
        INFO "Backing up $file to $backup/..."
        mv $file $backup/
    fi
done

mv $dir $node_dst_versioned

cd ~/opt
ln -s $dir node

cd ~/opt/bin
ln -s ../node/bin/node .

PATH=$PATH:~/opt/$dir/bin
npm-set-global-modules-dir
npm-set-proxy-from-environment

INFO "Installing newest npm via npm"
npm install -g npm@latest >/dev/null

INFO "Done."



### fatpacked app note #########################################################

#!/bin/bash

# View quick notes in notes.md file

less $0"s.md"

### fatpacked app notes.md #####################################################

# Ubuntu Setup

Stuff to do when setting up a fresh ubuntu installation.

## Checkout setup scripts

`path-grep setup`

## Setup Firewall

`ubuntu-setup-firewall`

## Setup SSH

`ssh-server-turn-off-password-authentication`

## Turn off crash reports

```sh
echo enabled=0 >> /etc/default/apport
```

## Setup local mail delivery

`mail-setup-local-delivery`

## Setup crontab

`crontab-setup`

# SSH

- tunnel (reverse/port forwarding):
  - forward: ssh -v -L 3333:localhost:443 host
  - reverse: ssh -nNT [via host] -R [local src port]:[dst host]:[dst port]
  - socks proxy: ssh -D 1080 host -p port / tsocks program
  - keep tunnel alive: autossh
- mount using ssh: sshfs / shfs

# apt

- apt-cache depends -i

# Bash

- expand only if files exist: shopt -s nullglob / for x in \*.ext ; ...
- unaliased version of a program: prefix with slash i.e.: \ls file

# BIOS

- infos of system: getSystemId

## Chroot to fix broken system using live-cd

```sh
cd / mount -t ext4 /dev/sda1 /mnt
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -o bind /dev /mnt/dev
cp -L /etc/resolv.conf /mnt/etc/resolv.conf
chroot /mnt /bin/bash
...
exit
umount /mnt/{proc,sys,dev}
umount /mnt
```

# Compiling

- basic steps

```sh
apt-get install build-essential
sudo apt-get build-dep Paketname
./configure sudo checkinstall -D
```

# Console

- switch console: chvty
- turn off console-blanking: `echo -ne "\033[9;0]" > /dev/tty0`
- lock: ctrl+s / unlock: ctrl+q

# Encoding

- `recode UTF-8..ISO-8859-1 file_name`
- convmv: filename encoding conversion tool

## luit - Locale and ISO 2022 support for Unicode terminals

```sh
luit -encoding 'ISO 8859-15' ssh legacy_machine
```

# Processes

- continue a stoped disowned job: sudo kill -SIGCONT \$PID

# Networking

- fuser
- `lsof -i -n`

# Recovery

## Recover removed but still open file (fd = file descriptor)

```sh
lsof | grep -i "$file"
cp /proc/$pid/fd/$fd $new_file
```

- recover partition: ddrescue
- recover deleted files: foremost jpg -o out_dir -i image_file

# SFTP

- use specifc key file `sftp -o IdentityFile=~/.ssh/$keyfile $user@\$host`
- use password `ltp -u login,pass sftp://host`

# User Management

- newgrp - log in with the new group
- sg - execute command as different group ID
- Add user group editor - to be started via the ubuntu menu
  `sudo apt-get install gnome-system-tools`

# Xorg

- `ssh -X host x2x -west -to :4.0`

# Encryption

## fsck encrypted volume

```sh
sudo cryptsetup luksOpen /dev/hda5 mydisk
fsck /dev/mapper/mydisk
```

### fatpacked app npm-readme ###################################################

#!/usr/bin/env node

// Find and print README.md of node executable

var fs = require("fs")
var path = require("path")
var exec = require("child_process").execSync

const [, , cmd] = process.argv

var executable = exec(`bash -c "cd / && type -p '${cmd}'"`)
  .toString()
  .trim()

var executableDir = path.dirname(executable)
var linkDst = executable

try {
  linkDst = fs.readlinkSync(executable)
} catch (e) {
  // might not be a link
}

var abs = path.join(executableDir, linkDst)
var modulePath = abs.replace(/(^.+node_modules\/(@.+?\/)*.+?\/).+$/, "$1")
var readme = modulePath + "README.md"

if (!fs.existsSync(readme)) {
  process.exit(0)
}

fs.createReadStream(readme).pipe(process.stdout)

### fatpacked app npm-set-global-modules-dir ###################################

# Make npm use local dir for modules

source bash-helpers
dir=~/node_modules

INFO "Setting global node_modules dir to $dir"
npm config set prefix=$dir


### fatpacked app npm-set-proxy-from-environment ###############################

# Set proxy from environment

source bash-helpers

if [[ $http_proxy ]] ; then
    INFO "Setting npm proxy to $http_proxy"
    npm config set proxy $http_proxy
fi

if [[ $https_proxy ]] ; then
    INFO "Setting npm https-proxy to $https_proxy"
    npm config set https-proxy $https_proxy
fi


### fatpacked app nvm-setup ####################################################

#!/usr/bin/env bash

# Setup nvm (node version manager)

source bash-helpers

node_version=${1:?Specify node_version e.g. v8.1.3 or stable}

wget --no-check-certificate -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash

mkdir -p ~/.bashrc.d

cat << ''EOF > ~/.bashrc.d/nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# if [[ ! -z $NVM_BIN ]] ; then
#   export NODE_PATH=$(echo ${NVM_BIN%%/bin}/lib/node_modules)
# fi
EOF

unset npm_config_prefix

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

nvm install $node_version
npm install -g npm@latest >/dev/null
npm config delete prefix

echo "Installed node version: `node --version`."

INFO "Starting new shell with ready to use node environment."
exec bash

### fatpacked app once #########################################################

#!/usr/bin/env perl

# Print stdin once if it has changed since last time

use strict;
use warnings;
no warnings 'uninitialized';

my $file = $ARGV[0] || die "Specify cache file";
$file = "/tmp/once_" . $ENV{USER} . "_" . $file;

undef $/;

my $data = <STDIN>;
my $old_data;

if (-e $file) {
    open(my $fileh, "<", $file) || die $!;
    $old_data = <$fileh>;
}

exit 0 if $data eq $old_data;

print $data;

open(my $fileh, ">", $file)
    or die "cannot open > $file: $!";
print $fileh $data;

### fatpacked app package.json #################################################

{
  "name": "bin",
  "version": "1.0.0",
  "description": "bin",
  "main": "index.js",
  "dependencies": {
    "@nilsboy/log-dwim": "^1.0.0",
    "glob": "^7.1.2",
    "lodash": "^4.17.4"
  },
  "devDependencies": {},
  "scripts": {
    "test": "test"
  },
  "repository": {
    "type": "git",
    "url": "git"
  },
  "author": "nilsboy",
  "license": "ISC"
}

### fatpacked app password-generate ############################################

#!/usr/bin/env bash

# Generate a list of random and secure passwords

source bash-helpers

apg -M SN -n 20

### fatpacked app path-edit ####################################################

#!/usr/bin/env bash

# Edit $PATH
# Usage: eval `path-edit`

echo export PATH=${PATH} | vipe

### fatpacked app path-grep ####################################################

#!/bin/bash

# Find an executable in path

compgen -c | sort -u | grep -i "$@"

### fatpacked app path-list ####################################################

#!/usr/bin/env bash

# List PATH enties one per line

source bash-helpers

echo $PATH | perl -pe 's/:/\n/g' | uniq-unsorted

### fatpacked app perl-force-stacktrace ########################################

# Force stracktrace output from a perl script

perl -Mdiagnostics=-traceonly "$@"

### fatpacked app perl-install-deps-for-module #################################

#!/bin/bash

# Install all CPAN dependencies for a module

perl-install-module lib::xi
perl -c -Mlib::xi=-nq "$@"

### fatpacked app perl-install-latest-stable-perl ##############################

#!/bin/bash

# Install latest stable perl via perlbrew

set -e

perlbrew install stable --notest

echo "Now installed perl versions:"
perlbrew list

echo
echo "to install all currently installed modues to new version use:"
echo "    perl-install-modules-into-perl-version (version)"
echo
echo "to switch to new version use: perlbrew swith (version)"

### fatpacked app perl-install-module ##########################################

#!/bin/bash

# Quickly check if a module is installed - if not install it

perl -M"$@" -e "1;" 2>/dev/null && exit 0
cpanm $1

### fatpacked app perl-install-modules-into-perl-version #######################

#!/bin/bash

# Install all modules from one perlbrew managed perl installation into another

source bash-helpers

version=$1

if [[ ! $version ]] ; then
    perlbrew list
    DIE "Specify perl version."
fi

perlbrew list-modules | perlbrew exec --with $version cpanm -nq

### fatpacked app perl-install-perlbrew ########################################

#!/bin/bash

# Install perlbrew

set -e
wget -qqO- http://install.perlbrew.pl | bash > /dev/null
source ~/perl5/perlbrew/etc/bashrc
perlbrew init > /dev/null
perlbrew install-cpanm > /dev/null

INFO "You have to re-login now for changes to take effect."

### fatpacked app perl-module-create ###########################################

#!/usr/bin/env perl

# Identify a perl class name in a line of code and open or create its file

use strict;
use warnings;

use Path::Tiny;

my $code = join(" ", @ARGV);

my ($module) = $code =~ /([\w]+\:\:[\w\:]+)/;

if (!$module) {
    $code =~ s/^\s*(use|require|package)//g;
    ($module) = $code =~ /([\w\:]+)/;
}

$module || die "Specify module";
$module =~ s/\n//g;

my $path = `pmpath $module`;

# wtf errors on stdout?
if ($path !~ /no such/i) {
    print $path;
    exit 0;
}

$path = $module;
$path =~ s/\:\:/\//g;
$path =~ s/$/.pm/g;

my $base_dir = $ENV{PERL5LIB} || die "Set PERL5LIB environment variable";
$path = $base_dir . "/" . $path;

$path = path($path);

if (!$path->exists) {
    $path->touchpath;
}

print $path;

### fatpacked app perl-module-edit #############################################

# Edit perl module that is located within perls module path

perl-module-find "$@" | vi-choose-file-from-list 1

### fatpacked app perl-module-find #############################################

#!/bin/bash

# Find a perl module or script

find $(perl -e 'print join (" ", @INC)') -iname "*$@*.pm" 2>/dev/null \
    | cat

### fatpacked app perl-module-version ##########################################

#!/bin/bash

# Print version of an installed perl module

perl -M"$@" -e 'print $ARGV[0]->VERSION . "\n"' "$@"

### fatpacked app perl-plack-test-server #######################################

#!/bin/bash

# Start a plack server for debugging with autoreloading of changed files

source bash-helpers

clear-with-scrollback

# plackup -L Shotgun --port 5000 ${1?Specify psgi file}
plackup -R ~/perldev --port 5000 ${1?Specify psgi file}

### fatpacked app perl-profile #################################################

#!/bin/bash

# Profile a perl app and display the html results

set -e

perl-install-module Devel::NYTProf

set -x

script=$(basename $1)
dir=/tmp/nytprof.$script.$(date +%F_%H%M%S)
mkdir $dir
file=$dir/nytprof.out

NYTPROF=file=$file perl -d:NYTProf "$@"

nytprofhtml --file $file --out $dir

if [ -e nytprof.out ] ; then
    rm nytprof.out
fi

see $dir/index.html

### fatpacked app perl-upgrade-outdated-modules ################################

#!/bin/bash

# Upgrade installed perl modules if a new version is available

perlbrew list-modules | cpanm

### fatpacked app pipe-wrapper #################################################

#!/usr/bin/env bash

# Emulate a pipe for a program that does not support one itself like eslint

source bash-helpers

file=$(tempfile)
original=$file.org

trap 'test -e $file && rm $file ; rm $original' ERR EXIT

tee -a $original > $file

set +e
"$@" $file &>/dev/null || error=1
set -e

if [[ $error ]]; then
    cat $original
    exit 1
fi

cat $file

### fatpacked app pm2-logrotate-config #########################################

#!/usr/bin/env bash

# Display the config of the logrotate module of pm2

source bash-helpers

pm2 get pm2-logrotate

### fatpacked app pm2-setup ####################################################

#!/usr/bin/env bash

# Setup pm2 including log rotation

source bash-helpers

npm install -g pm2

pm2 install pm2-logrotate

# Keep max 3 MB of log data (uncompressed) for each day of the
# month then compress it.
#
# Every new chunk will overwrite any already rotated data for the day.
# The last chunk of the day may contain much less that max_size.
pm2 set pm2-logrotate:rotateInterval '0 0 */1 * *'
pm2 set pm2-logrotate:retain 31
pm2 set pm2-logrotate:dateFormat 'DD'
pm2 set pm2-logrotate:max_size 3M
pm2 set pm2-logrotate:compress true

# Check every 10 minutes for max file size.
pm2 set pm2-logrotate:workerInterval 600


### fatpacked app projects-start. ##############################################

#!/usr/bin/env bash

# Start all local projects that have a start script

source bash-helpers

for dir in ~/projects/* ; do
  project=$(basename $dir)
  if [ ! -d $dir ] ; then
    continue
  fi
  INFO "Found project: $project"
  exe=$dir/bin/project-start
  
  if [ -x $exe ] ; then
    INFO "Starting $project via $exe"
    cd $dir
    ./bin/project-start || ERROR "Could not start: $exe"
  else
    WARN "Cannot start project: $project - no start file: $exe"
  fi
done

### fatpacked app prompt-dir ###################################################

# Prompt containing only the prettified current directory

dir-name-prettifier $PWD
echo -n "$GREY> $NO_COLOR"

### fatpacked app prompt-dir-full ##############################################

# Prompt containing the current directory ony

echo -n "$PWD$GREY> $NO_COLOR"

### fatpacked app prompt-helper-git ############################################

#!/usr/bin/env perl
# Add git status information to prompt

use strict;
use warnings;
no warnings 'uninitialized';

my $red      = '\[\e[38;5;9m\]';
my $grey     = '\[\e[38;5;243m\]';
my $green    = '\[\e[38;5;2m\]';
my $blue     = '\[\e[38;5;6m\]';
my $no_color = '\[\e[33;0;m\]';

# test data
my $git = <<'git';
# branch.oid <commit>
# branch.head branch
# branch.upstream upstream/branch
# branch.upstream branch
# branch.ab +3 -3
u unmerged
1 changed
2 renamed
? untracked
! ignored
git

$git = `git status --branch --porcelain=v2 2>/dev/null` || exit;

my ($branch)   = $git =~ /^# branch.head (.+)$/gm;
my ($upstream) = $git =~ /^# branch.upstream (.+)$/gm;
my ($remote, $remote_branch) = $upstream =~ /(.+?)\/(.+)/;
($remote_branch) = $upstream if ! $remote_branch;
my ($ahead, $behind)   = $git =~ /^# branch.ab (\+.+) (\-.+)$/gm;
# ignored is only shown if specified with git status --ignored
my ($changes) = $git =~ /^[u12\?\!]/m;

# my $project = `git rev-parse --show-toplevel 2>/dev/null`;
# ($project) = $project =~ /.*\/([^\/]+)\n/;

my $branch_color = $red if $branch eq '(detached)';
my $branch_info =  ($remote_branch . $ahead . $behind ne '' || $branch eq '(detached)' ? '@' . $branch_color . $branch . $no_color : '' );
$branch_info = '' if $branch eq $remote_branch;

my ($branch_prefix) = $branch =~ /^((.*?\/)*.{1,4})/;

print ""
  . $grey
  # . "| "
  # . $project
  . ($changes ? $red . '@' . $grey : '@')
  . $branch_color . $branch_prefix . $grey
  . ($ahead ne '+0' ? $red . $ahead . $grey : '')
  . ($behind ne '-0' ? $red . $behind . $grey : '' )
  . ($remote_branch && $remote_branch ne $branch ? '=>' . $red . $remote_branch . $grey : '' )
  # . " |"
  . $no_color
;

### fatpacked app prompt-host ##################################################

# Prompt containing the current hostname

source bash-helpers

time-humanize-seconds $elapsed
eval $BASHRC_PROMPT_HELPERS
echo -n " "
bashrc-helper-login-name
echo -n "$GREY@$NO_COLOR"
bashrc-helper-hostname
echo -n "$GREY:$NO_COLOR"
dir-name-prettifier $PWD
jobs=$jobs bash-background-jobs-count
echo -n "$GREY> $NO_COLOR"

### fatpacked app prompt-local #################################################

# Prompt for local shells - without hostname

source bash-helpers

time-humanize-seconds "$elapsed"
eval $BASHRC_PROMPT_HELPERS
prefixif $(bashrc-helper-login-name 1)
prefixif $(dir-name-prettifier $PWD)
jobs=$jobs bash-background-jobs-count
echo -n "$GREY>$NO_COLOR "

### fatpacked app prompt-plain #################################################

# Static prompt

echo -n "$(basename $SHELL)> "

### fatpacked app prompt-spare #################################################

# Prompt without user name

dir-name-prettifier $PWD
jobs=$jobs bash-background-jobs-count
echo -n "> "

### fatpacked app proxy-setup-env ##############################################

#!/bin/bash

# Set proxy environment variables

port=${1:-8080}

for proto in http https ftp ; do
    export ${proto}_proxy=$proto://localhost:$port/
done

### fatpacked app proxyserver ##################################################

#!/bin/bash

# Install and run a proxyserver from the cpan

set -e

source bash-helpers

perl-install-module HTTP::Proxy

port=${1:-8080}
name=proxyserver_$port

if pidof $name >/dev/null ; then
    INFO "Proxy server already running on port $port"
    exit 0
fi

port=$port \
exec -a $name \
    perl -MHTTP::Proxy -e 'HTTP::Proxy->new(port => $ENV{port})->start' &
disown -har

INFO "Proxy server is now running on port $port."

### fatpacked app ps-watch #####################################################

# Watch a process

watch -n1 "ps -A | grep -i $@ | grep -v grep"

### fatpacked app pstree-search ################################################

# Display or search pstree, exclude current process

search=${@:-,$PPID}

switches="-apl";
command-knows-switch pstree -g && switches=$switches"g"

pstree $switches \
    | perl -ne '$x = "xxSKIPme"; print if $_ !~ /[\|`]\-\{[\w-_]+},\d+$|less.+\+\/'$1'|$x/' \
    | less "+/$search"

### fatpacked app publicip #####################################################

#!/bin/bash

# Find own public ip when behind proxy

wget -qqO- http://checkip.dyndns.org \
    | perl -ne '/Address\: (.+?)</i || die; print $1'

### fatpacked app README.md ####################################################

# My shell tools

See bashrc-pack for how I append them to my bashrc.

Most of the tools are implemented in bash or core perl so they don't have
additional dependencies and run directly on any current linux distro.

Most bash scripts depend on my bash-helpers script - so make sure it's
in your path.

## Descriptions

* [abs](./abs): Print the absolute path of a file or dir
* [apt-dump-installed-packages](./apt-dump-installed-packages): Dump names of all installed packages to a file
* [apt-hold-package](./apt-hold-package): Prevent a deb package from beeing upgraded
* [apt-install-packages-from-file](./apt-install-packages-from-file): Install packages listed in a file
* [apt-popularity](./apt-popularity): Search for a debian package, sort by ranking, add description
* [apt-unhold-package](./apt-unhold-package): Return a deb package to its default upgrade state
* [audio-file-prefix-track-number](./audio-file-prefix-track-number): Add a leading two digit track number to the file name
* [audio-ogg-from-any](./audio-ogg-from-any): Convert any audio file to ogg
* [audio-split-by-cue](./audio-split-by-cue): Split an album audio file into several tracks using a cue file
* [bak](./bak): Copy a file to ~/backups/ appending a timestamp
* [bakm](./bakm): Move a file to ~/backups/ appending a timestamp
* [bakmp](./bakmp): Move a file appending a timestamp
* [bakp](./bakp): Backup a file appending a timestamp
* [bash-background-jobs-count](./bash-background-jobs-count): Display one colored count for background jobs running and stopped
* [bash-eternal-history-grep](./bash-eternal-history-grep): Grep bash history
* [bash-eternal-history-search](./bash-eternal-history-search): Search specially formatted bash history
* [bash-helpers](./bash-helpers): Helper functions for shell scripts
* [bash-jobs](./bash-jobs): Cleaned up bash jobs replacement
* [bash-print-on-error](./bash-print-on-error): Print error code of last command on failure
* [bash-setup-multi-user-environment](./bash-setup-multi-user-environment): Share one account with serveral users but create their own environment
* [bash-with-comments](./bash-with-comments): Remove comments from a bash script and run it
* [bashrc-eternal-history-add-simple](./bashrc-eternal-history-add-simple): Add an entry to the eternal history
* [bashrc-helper-hostname](./bashrc-helper-hostname): Format hostname for bash prompt usage
* [bashrc-helper-login-name](./bashrc-helper-login-name): Format login for bash prompt usage
* [bashrc-linux-distribution-fix-suse](./bashrc-linux-distribution-fix-suse): Script to run when logging into a suse machine
* [bashrc-pack](./bashrc-pack): Attach scripts to the bashrc skeleton
* [bashrc-unpack-and-run](./bashrc-unpack-and-run): Run a script that is attached to the bashrc
* [bashrc-upload](./bashrc-upload): Generate and deploy fat packed bashrc
* [bytes-from-human](./bytes-from-human): Convert a size from human friendly to bytes
* [bytes-to-human](./bytes-to-human): Convert a size of bytes to human friendly
* [cd-find](./cd-find): Search for file or dir in current dir and go there
* [cd-history](./cd-history): Search history for an existing directory containing string and go there
* [chroot-fully-working](./chroot-fully-working): Setup fully working change root
* [clear-with-scrollback](./clear-with-scrollback): Clear screen including scrollback buffer
* [command-knows-switch](./command-knows-switch): Check if an app supports specified switch
* [cp-merge-directories-by-hardlinks](./cp-merge-directories-by-hardlinks): Merge two directories on the same disk recursively by using hard links
* [cpanm-install](./cpanm-install): Setup home directory based perl environment and cpanm
* [cpanm-list-locally-installed-modules](./cpanm-list-locally-installed-modules): List all cpanm installed perl modules
* [cpanm-reinstall-local-modules](./cpanm-reinstall-local-modules): Reinstall all cpanm installed perl modules (i.e. to recompile after server move)
* [cpanm.](./cpanm.): Allow cpanm to install modules specified via Path/File.pm
* [crontab-setup](./crontab-setup): Add default crontab settings to existing crontab
* [csvview](./csvview): Quick way to view a csv file on the command line
* [ctags-index-sources](./ctags-index-sources): Create tags for all source directories
* [ctags-setup](./ctags-setup): Save ctags configuration file
* [dev-bin-generate-readme](./dev-bin-generate-readme): Generate README with descriptions for bin scripts
* [df.](./df.): Cleaned up df version
* [diff-dir](./diff-dir): Diff 2 directories recursively comparing file contents and not file attributes
* [diff-so-fancy](./diff-so-fancy): Install diff-so-fancy
* [dir-name-prettifier](./dir-name-prettifier): shorten prompt dir to max 15 chars
* [docker-ls](./docker-ls): List some docker information
* [docker-ubuntu](./docker-ubuntu): Start a volatile ubuntu docker container
* [docker-ubuntu-persistent](./docker-ubuntu-persistent): Start a persistent ubuntu docker container
* [docopt-convert](./docopt-convert): Convert a docopt specification
* [dos2unix](./dos2unix): Convert line endings from dos to unix
* [env-grep](./env-grep): Grep environment
* [env-set-vars-from-lc](./env-set-vars-from-lc): Set env vars prefixed with LC_BASHRC_ without the prefix
* [env-show](./env-show): Display infos about the system
* [extension](./extension): Find the extension of a filename
* [file-add-line-if-new](./file-add-line-if-new): Add a line to a file if a line matching regex is not found
* [file-compress-if-size-reaches](./file-compress-if-size-reaches): Compress a file depending on size
* [file-public-upload](./file-public-upload): Share a file on a public space
* [file-template-filler](./file-template-filler): Create a file from a template
* [filename](./filename): Find the filename without the extension of a filename
* [files-replace-from-env](./files-replace-from-env): Replace files with content from environment variables
* [filestamp](./filestamp): Create a new backup filename with a timestamp; replace an existing timestamp
* [find-from-date](./find-from-date): Find files newer than date
* [find-largest-directories](./find-largest-directories): Find largest directories recursively from current directory
* [find-largest-files](./find-largest-files): Find largest files recursively from current directory
* [find-newest](./find-newest): Recursively find newest files
* [find-older-than-days](./find-older-than-days): Recursively find files oder than days
* [find.relevant.](./find.relevant.): Find usually relevant files
* [git-env-validate](./git-env-validate): Ensure git-scm is configured appropriately
* [git-ignore](./git-ignore): Download and save a default .gitignore for a specific environment
* [git-modified](./git-modified): List all modified files since last git commit
* [git-project](./git-project): Print git project root dir name
* [git-reset-head](./git-reset-head): Discard all current changes in directory
* [git-reset-head-to](./git-reset-head-to): Discard commits dating back to specified commit
* [git-reset-origin](./git-reset-origin): Discard all current changes in directory to origin/master
* [git-root](./git-root): Print git project root
* [git.all](./git.all): Add, commit and push in one step
* [git.setup](./git.setup): Setup git configuration
* [git.user.check](./git.user.check): Check if global user is set
* [github.clone.user](./github.clone.user): Clone all github repos of a user
* [gnome-send-to-mail-images](./gnome-send-to-mail-images): Resize one or more images and add them as attachements
* [gnome-send-to-mail-images-setup](./gnome-send-to-mail-images-setup): Download and setup gnome-send-to-mail-images
* [gnome-terminal-prevent-cursor-blinking](./gnome-terminal-prevent-cursor-blinking): Prevent the gnome-terminal cursor from blinking
* [gotroot](./gotroot): Make sure we're running as root
* [grep-before](./grep-before): Print file contens before a specified regex first matches
* [grep-from](./grep-from): Print file contens from where a specified regex first matches
* [grep-goo](./grep-goo): Or-grep but list matching patterns instead of matching lines
* [grep-list](./grep-list): Grep for a list of values
* [grep-or](./grep-or): or-grep list matching lines
* [grep-or-with-header](./grep-or-with-header): or-grep and print paragraph headers
* [grep.and](./grep.and): Search for lines matching one or more perl regex patterns
* [grep.with.context](./grep.with.context): Grep for a regex and display matches with context
* [groups-reload-memberships](./groups-reload-memberships): Start new shell to "reload" changes to the list of groups the user belongs to
* [hd-set-spin-timeout](./hd-set-spin-timeout): Activate spindown and set spindown timeout on (buggy - i.e. Seagate) hard drives that don't do it themselfes
* [head-warn](./head-warn): Limit input lines and warn if more lines are left
* [html-strip](./html-strip): Strip HTML of tags and entities
* [http-echo-server](./http-echo-server): Test HTTP server that response with the request
* [internalip](./internalip): get internal IP address
* [java-decompile-jar](./java-decompile-jar): Recursively decompile a jar including contained jars
* [java-install-oracle-java-v8](./java-install-oracle-java-v8): Install oracle java 8
* [js-format-using-prettydiff](./js-format-using-prettydiff): Javascript formatter using "npm install prettydiff"
* [json-tidy](./json-tidy): Tidy a json file and sort hash keys to make the output diffable
* [json2yaml](./json2yaml): Install and run json2yaml
* [keyboard-backlight-permanently-off](./keyboard-backlight-permanently-off): Turn keyboard backlight off permanently
* [keyboard-disable-caps-lock-console](./keyboard-disable-caps-lock-console): Map caps lock to escape for consoles
* [keyboard-remap-keys-xwindows](./keyboard-remap-keys-xwindows): Map caps lock to escape etc for X
* [keyboard-reset](./keyboard-reset): Reset keyboard settings
* [line-print](./line-print): Draw a line on the terminal spanning the whole width optionally including a message
* [linux-distribution-info](./linux-distribution-info): List linux distribution variables
* [ls-creation-time](./ls-creation-time): List the creation time of a file
* [mail-setup-local-delivery](./mail-setup-local-delivery): Setup local mail delivery on ubuntu 18.04
* [man-cheatsh](./man-cheatsh): the only cheat sheet you need
* [man-explain-options](./man-explain-options): Display man page infos about command line options
* [man-multi-lookup](./man-multi-lookup): Lookup help for a command in several places
* [man-online](./man-online): Lookup a man page on the internet
* [markdown-view](./markdown-view): View markdown in the terminal
* [mem-empty-swap-to-ram](./mem-empty-swap-to-ram): Empty swap back to ram if possible
* [mem-swap-per-process](./mem-swap-per-process): Show swap usage per process
* [mount.](./mount.): Show mounts without snap etc
* [mount.overlay](./mount.overlay): Mount a directory over another
* [mouse.jiggle](./mouse.jiggle): Jiggle mouse to prevent system idle
* [mybackup](./mybackup): create a backup
* [mysql.](./mysql.): Fix mysql prompt to show real hostname - NEVER localhost
* [mysqldump-structure](./mysqldump-structure): Dump the structure without the data of a mysql database
* [neovim-setup](./neovim-setup): Setup neovim
* [net-find-free-port](./net-find-free-port): Find an unused port
* [net-forward-port](./net-forward-port): Forward an incoming port to a different port
* [net-ip2name](./net-ip2name): Replace ip adresses with host names inside of text
* [net-open-ports](./net-open-ports): List all open ports
* [net-remote-shell](./net-remote-shell): Create shell access on a free port
* [net-scan-private-network](./net-scan-private-network): Scan for hosts in private network
* [net-wlan-rtl8723be-wrong-antenna-fix](./net-wlan-rtl8723be-wrong-antenna-fix): Fix wrong antenna problem of rtl8723be wlan adaptor
* [net.dns.dump](./net.dns.dump): dump all infos on a domain
* [net.dns.local](./net.dns.local): Show local DNS status
* [net.firewall.setup.example](./net.firewall.setup.example): Firewall setup example
* [net.serve.dir](./net.serve.dir): Serve current directory files via http
* [net.serve.file-manager](./net.serve.file-manager): Serve a file manager for the current directory via http
* [net.serve.json](./net.serve.json): JSON backed rest server
* [node-install](./node-install): Install latest node version
* [note](./note): View quick notes in notes.md file
* [notes.md](./notes.md): Ubuntu Setup
* [npm-readme](./npm-readme): Find and print README.md of node executable
* [npm-set-global-modules-dir](./npm-set-global-modules-dir): Make npm use local dir for modules
* [npm-set-proxy-from-environment](./npm-set-proxy-from-environment): Set proxy from environment
* [nvm-setup](./nvm-setup): Setup nvm (node version manager)
* [once](./once): Print stdin once if it has changed since last time
* [password-generate](./password-generate): Generate a list of random and secure passwords
* [path-edit](./path-edit): Edit $PATH
* [path-grep](./path-grep): Find an executable in path
* [path-list](./path-list): List PATH enties one per line
* [perl-force-stacktrace](./perl-force-stacktrace): Force stracktrace output from a perl script
* [perl-install-deps-for-module](./perl-install-deps-for-module): Install all CPAN dependencies for a module
* [perl-install-latest-stable-perl](./perl-install-latest-stable-perl): Install latest stable perl via perlbrew
* [perl-install-module](./perl-install-module): Quickly check if a module is installed - if not install it
* [perl-install-modules-into-perl-version](./perl-install-modules-into-perl-version): Install all modules from one perlbrew managed perl installation into another
* [perl-install-perlbrew](./perl-install-perlbrew): Install perlbrew
* [perl-module-create](./perl-module-create): Identify a perl class name in a line of code and open or create its file
* [perl-module-edit](./perl-module-edit): Edit perl module that is located within perls module path
* [perl-module-find](./perl-module-find): Find a perl module or script
* [perl-module-version](./perl-module-version): Print version of an installed perl module
* [perl-plack-test-server](./perl-plack-test-server): Start a plack server for debugging with autoreloading of changed files
* [perl-profile](./perl-profile): Profile a perl app and display the html results
* [perl-upgrade-outdated-modules](./perl-upgrade-outdated-modules): Upgrade installed perl modules if a new version is available
* [pipe-wrapper](./pipe-wrapper): Emulate a pipe for a program that does not support one itself like eslint
* [pm2-logrotate-config](./pm2-logrotate-config): Display the config of the logrotate module of pm2
* [pm2-setup](./pm2-setup): Setup pm2 including log rotation
* [projects-start.](./projects-start.): Start all local projects that have a start script
* [prompt-dir](./prompt-dir): Prompt containing only the prettified current directory
* [prompt-dir-full](./prompt-dir-full): Prompt containing the current directory ony
* [prompt-helper-git](./prompt-helper-git): Add git status information to prompt
* [prompt-host](./prompt-host): Prompt containing the current hostname
* [prompt-local](./prompt-local): Prompt for local shells - without hostname
* [prompt-plain](./prompt-plain): Static prompt
* [prompt-spare](./prompt-spare): Prompt without user name
* [proxy-setup-env](./proxy-setup-env): Set proxy environment variables
* [proxyserver](./proxyserver): Install and run a proxyserver from the cpan
* [ps-watch](./ps-watch): Watch a process
* [pstree-search](./pstree-search): Display or search pstree, exclude current process
* [publicip](./publicip): Find own public ip when behind proxy
* [rel](./rel): Create a relative path from an absolute path
* [replace](./replace): Change the contens of text files by perl expression
* [rest-post-json](./rest-post-json): Send a POST request to a website
* [run-and-capture](./run-and-capture): Run a program and pretty print all its outputs
* [screen-reattach](./screen-reattach): Reattach to a screen session
* [sleepuntil](./sleepuntil): Sleep until a specific date and time
* [sort-by-file-modification](./sort-by-file-modification): Sort a list of file names by their modification time
* [sort-by-path-depth](./sort-by-path-depth): Sort input by depth of path
* [ssh-agent-env-clear](./ssh-agent-env-clear): Remove connection to ssh-agent
* [ssh-agent-env-grab](./ssh-agent-env-grab): Save ssh-agent environemnt variables to be loaded in another session or on
* [ssh-agent-env-restore](./ssh-agent-env-restore): Dump ssh-agent vars stored by ssh-agent-env-grab
* [ssh-alias](./ssh-alias): Send remote host alias to remote host to display in prompt etc
* [ssh-copy-id.](./ssh-copy-id.): Copy one public key instead of all
* [ssh-no-check](./ssh-no-check): SSH without host key checks
* [ssh-persistent-reverse-tunnel-setup](./ssh-persistent-reverse-tunnel-setup): Setup a persistent reverse tunnel
* [ssh-register-my-key](./ssh-register-my-key): Register my ssh key
* [ssh-server-turn-off-password-authentication](./ssh-server-turn-off-password-authentication): Change local sshd config to disallow password authentication and restart sshd
* [ssh-with-reverse-proxy](./ssh-with-reverse-proxy): Proxy traffic of a remote host through localhost
* [ssl-create-self-signed-certificate](./ssl-create-self-signed-certificate): Create a self signed certificate
* [ssl-strip](./ssl-strip): Remove ssl encryption from https and other protocols
* [sudo.](./sudo.): Keep path with sudo
* [term-bg-switch](./term-bg-switch): Switch terminal background color
* [term-color-test](./term-color-test): most color mappings taken from xterm-colortest
* [term-flash](./term-flash): Flash the terminal background
* [term-line-wrap-off](./term-line-wrap-off): Turn off shell line wrapping
* [term-line-wrap-on](./term-line-wrap-on): Turn off shell line wrapping
* [text-from-any](./text-from-any): Convert any file to text
* [text-quote](./text-quote): Quote text
* [text-remove-comments](./text-remove-comments): Remove comment from text
* [time-dehumanize](./time-dehumanize): Convert a humanized time spec into seconds
* [time-humanize-seconds](./time-humanize-seconds): Return a humanly comprehendable representation of an amount of seconds
* [time-stamp-to-date](./time-stamp-to-date): Print date for a timestamp
* [tmux-flash](./tmux-flash): Flash the current pane background
* [tmux-reattach](./tmux-reattach): Reattach or create a new tmux session
* [tmux-session](./tmux-session): Start a named tmux session with 10 tabs
* [tmux-setup](./tmux-setup): Setup tmux config
* [tmux-synchronized-panes-toggle](./tmux-synchronized-panes-toggle): Toggle synchronized tmux panes
* [tmux-xpanes](./tmux-xpanes): Awesome tmux-based terminal divider
* [top-mem](./top-mem): View top ordered by memory usage
* [trash](./trash): Move a file to a trash dir at the files location
* [tree](./tree): List a directory as a tree
* [tree-diff](./tree-diff): Diff two directory structures
* [ubuntu-setup-automatic-updates](./ubuntu-setup-automatic-updates): Make sure update and backports soures are activated
* [ubuntu-unity-set-time-format](./ubuntu-unity-set-time-format): Set time format of ubuntu unity desktop clock
* [uniq-unsorted](./uniq-unsorted): uniq replacement without the need for sorted input
* [unix2dos](./unix2dos): Convert line endings from unix to dos
* [url](./url): Print absolute SSH url of a file or directory
* [url-decode](./url-decode): Decode a string from URL notation
* [url-encode](./url-encode): Encode a string to URL notation
* [user-add](./user-add): Add a new user to the system without hassle
* [vi-executable](./vi-executable): Find an executable in the path and edit it
* [vi-from-perl-inc](./vi-from-perl-inc): Find an executable in the perl %INC and edit it
* [video-dvd-install-decss](./video-dvd-install-decss): Install decss for encrypted dvd playback
* [video-dvd-rip](./video-dvd-rip): Rip and transcode a video dvd
* [video-transcode](./video-transcode): Transcode a media file to x264 preserving all video, audio and subtitle tracks
* [vidir.](./vidir.): more save vidir
* [vim-edit](./vim-edit): Edit input fields with vim
* [vim-firefox](./vim-firefox): Vim to use from firefox addon its-all-text
* [vim-setup](./vim-setup): Setup vim environment
* [vim-url](./vim-url): Print absolute SSH url of a file or directory in vim syntax
* [vipe](./vipe): Edit stdin in a pipe using vim
* [vnc-server-setup-upstart-script](./vnc-server-setup-upstart-script): Setup remote desktop access via ssh and vnc right from the login screen of
* [vnc-start-vino](./vnc-start-vino): Start vino vnc server
* [vnc-vino-preferences](./vnc-vino-preferences): Set vino preferences
* [vncviewer](./vncviewer): preconfigured to use ssh
* [wcat](./wcat): Easily dump a web site
* [window-blink](./window-blink): Blink current window
* [x2x-east](./x2x-east): Share input devices with another host
* [xdg-cache-home](./xdg-cache-home): Return xdg cache home
* [xmv](./xmv): Rename files by perl expression
* [xtitle](./xtitle): Change the title of a x window

### fatpacked app rel ##########################################################

#!/bin/bash

# Create a relative path from an absolute path

abs "$@" | perl -pe "s#^('|)($HOME/)#\$1#g"

### fatpacked app replace ######################################################

#!/usr/bin/env perl

# Change the contens of text files by perl expression

use strict;
use warnings;
no warnings 'uninitialized';
use Getopt::Long;

my $red      = "\x1b[38;5;124m";
my $no_color = "\x1b[33;0m";
my $dry      = 1;

my $opts = {
    "e|eval=s"  => \my $op,
    "x|execute" => sub { $dry = 0 },
};
GetOptions(%$opts) || usage();
$op || usage();

sub usage { die "Usage:\n" . join( "\n", sort keys %$opts ) . "\n"; }

my $file_count;
my $files_changed = 0;
my $example_file;

while (<STDIN>) {

    $file_count++;

    local $/ = undef;

    chomp;
    my $file = $_;
    $file =~ s/\n//g;

    open( F, $file ) || die $!;
    my $data = <F>;
    close(F) || die $!;

    $_ = $data;

    eval $op;
    die $@ if $@;

    next if $_ eq $data;

    $files_changed++;
    $example_file = $file;

    next if $dry;

    $data = $_;

    open( F, ">", $file ) || die $!;
    print F $data;
    close(F) || die $!;
}

exit 1 if !$files_changed;

print STDERR "$files_changed of $file_count files changed"
    . " (example: $example_file)"
    . ( $dry ? "$red - dry run.$no_color" : "" ) . "\n";

### fatpacked app rest-post-json ###############################################

#!/bin/bash

# Send a POST request to a website

source bash-helpers

file=${1?Specify file containing json post data}
url=${2?Specify url to post to}

curl -H "Content-Type: application/json" -X POST -d "@${file}" "$url"

### fatpacked app run-and-capture ##############################################

#!/usr/bin/env perl

# Run a program and pretty print all its outputs

use strict;
use warnings;
no warnings 'uninitialized';
use Cwd qw(abs_path);
use POSIX qw(strftime);

use Capture::Tiny ':all';

my ( $stdout, $stderr, $exit_code ) = capture {
    system(@ARGV);
};

$exit_code = $exit_code >> 8;

chomp($stdout);
if ($stdout) {
    $stdout = "--- STDOUT " . ( "-" x 69 ) . "\n" . $stdout . "\n";
}

chomp($stderr);
if ($stderr) {
    $stderr = "--- STDERR " . ( "-" x 69 ) . "\n" . $stderr . "\n";
}

my $exit_code_message;
if (defined $exit_code) {
    $exit_code_message
        = "--- EXITED WITH " . ( "-" x 64 ) . "\n" . $exit_code . "\n";
}

my $output
    = "--- SHELL COMMAND "
    . ( "-" x 62 ) . "\n"
    . join( " ", @ARGV ) . "\n"
    . "--- LAUNCHED FROM "
    . ( "-" x 62 ) . "\n"
    . abs_path() . "\n"
    . "--- LAUNCHED AT "
    . ( "-" x 64 ) . "\n"
    . strftime("%F %T", localtime) . "\n"
    . $exit_code_message
    . $stdout
    . $stderr
    . ( "-" x 80 ) . "\n";

print STDOUT $output;

exit $exit_code;


### fatpacked app screen-reattach ##############################################

#!/bin/bash

# Reattach to a screen session

ssh-agent-env-grab

(
    xtitle screen@$HOSTNAME
    screen -rd $session && exit
    screen -rd && exit

    xtitle "Terminal"

    exit 1

) && clear

### fatpacked app sleepuntil ###################################################

#!/usr/bin/env bash

# Sleep until a specific date and time

source bash-helpers

arg1=${1:?Specify date and time as e.g. 12:30 or 2019-10-19 11:05 or 10 tomorrow}
time_spec="$@"

now_seconds=$(date +%s)
then_seconds=$(date -d "$time_spec" +%s)

sleep_seconds=$(($then_seconds - $now_seconds))
target_date=$(date -d "$time_spec" '+%F %T')

INFO "Sleeping for $sleep_seconds seconds until $target_date."

if [[ $sleep_seconds -lt 0 ]] ; then
  WARN "No time to sleep."
  sleep_seconds=0
fi

sleep $sleep_seconds
INFO "Waking up from sleep."

### fatpacked app sort-by-file-modification ####################################

#!/usr/bin/env bash

# Sort a list of file names by their modification time

perl -MFile::stat -e 'map { print "$_\n" } sort { stat($a)->mtime <=> stat($b)->mtime } map {$_ =~ s/\n//g ; $_} <>'

### fatpacked app sort-by-path-depth ###########################################

#!/bin/bash

# Sort input by depth of path

perl -n -e '$x = $_; $x =~ tr%/%%cd; print length($x), " $_";' \
    | sort -k 1n -k 2 \
    | perl -pe 's/^\S+ //' 

### fatpacked app ssh-agent-env-clear ##########################################

#!/bin/bash

# Remove connection to ssh-agent

echo "# this has to be sourced from within the current shell"
ssh-agent-env-grab \
    && unset SSH_AUTH_SOCK SSH_CLIENT SSH_CONNECTION SSH_TTY

### fatpacked app ssh-agent-env-grab ###########################################

#!/bin/bash

# Save ssh-agent environemnt variables to be loaded in another session or on
# reconnect inside screen or tmux.

SSHVARS="SSH_CLIENT SSH_TTY SSH_AUTH_SOCK SSH_CONNECTION DISPLAY"

for x in ${SSHVARS} ; do
    (eval echo $x=\$$x) | sed  's/=/="/
                                s/$/"/
                                s/^/export /'
done 1>$REMOTE_HOME/.ssh/agent_env

### fatpacked app ssh-agent-env-restore ########################################

#!/bin/bash

# Dump ssh-agent vars stored by ssh-agent-env-grab

# source this file to load the vars in your current shell

cat $REMOTE_HOME/.ssh/agent_env

### fatpacked app ssh-alias ####################################################

#!/bin/bash

# Send remote host alias to remote host to display in prompt etc

source bash-helpers
opts="$@"

remote_host=$(echo $opts | perl -ne 'print $3 if /(-\S+\s+|\S+=\S+\s+)*(\w+@)*(\S+)/i')

# ServerAliveInterval=5 make sure there is ssh traffic so no firewall closes
#     the connection
# GSSAPIAuthentication=no - usually not used - speeds up connection time

LC_BASHRC_REMOTE_HOST_ALIAS=$remote_host \
  ssh -AC -o GSSAPIAuthentication=no -o ServerAliveInterval=5 \
  "$opts"

### fatpacked app ssh-copy-id. #################################################

#!/usr/bin/env bash

# Copy one public key instead of all

source bash-helpers

ssh-copy-id -i ~/.ssh/id_rsa.pub "$@"

### fatpacked app ssh-no-check #################################################

#!/bin/bash

# SSH without host key checks

ssh -A \
    -q \
    -o CheckHostIP=no \
    -o UserKnownHostsFile=/dev/null \
    -o StrictHostKeyChecking=no \
    "$@"

### fatpacked app ssh-persistent-reverse-tunnel-setup ##########################

#!/bin/bash

# Setup a persistent reverse tunnel

source bash-helpers

set -e

ssh_key_file=~/.ssh/reverse-tunnel

if [[ -e $ssh_key_file ]] ; then
    DIE "$ssh_key_file already exists"
fi

server=${1?Server?}
port=${2?Port?}

ssh-keygen -q -t rsa -b 2048 -P "" -f $ssh_key_file

INFO "Add this new public key to tunnel@$server"
cat $ssh_key_file.pub

INFO "Adding ~/.ssh/config entry..."

cat << EOF >> ~/.ssh/config

Host reverse-tunnel-server
    Hostname $server
    Port $port
    User tunnel
    IdentityFile $ssh_key_file
    RemoteForward 0 localhost:22
    CheckHostIP no
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
    ServerAliveInterval 60
    Compression yes
EOF

CMD="bash -c '(while true ; do ssh -N reverse-tunnel-server 2>&1 ; sleep 300 ; done 0<&- | logger -i) &' # reverse tunnel dont edit"

INFO "Adding crontab entry..."
((crontab -l || echo) | grep -v "# reverse tunnel dont edit" ; echo "@reboot $CMD") | crontab -

INFO "Starting tunnel now..."
echo $CMD | bash

INFO "done."

### fatpacked app ssh-register-my-key ##########################################

#!/usr/bin/env bash

# Register my ssh key

source bash-helpers

mkdir -p $REMOTE_HOME/.ssh
cat $REMOTE_HOME/.bin/authorized_keys >> ~/.ssh/authorized_keys

### fatpacked app ssh-server-turn-off-password-authentication ##################

#!/bin/bash
# Change local sshd config to disallow password authentication and restart sshd

set -e

gotroot

cat << EOF >> /etc/ssh/sshd_config
# added by ssh-server-turn-off-password-authentication
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM no
EOF

service ssh restart

### fatpacked app ssh-with-reverse-proxy #######################################

#!/bin/bash

# Proxy traffic of a remote host through localhost
# i.e. if the remote host has no access to the cpan or
# other parts of the internet

set -e

host=${1?specify host}
port=${2:-59347}

pidof proxy > /dev/null || npx proxy -p $port &

ssh -A -t $host -R $port:localhost:$port \
    http_proxy=http://localhost:$port \
    https_proxy=http://localhost:$port \
    ftp_proxy=ftp://localhost:$port \
    HTTP_PROXY=http://localhost:$port \
    HTTPS_PROXY=http://localhost:$port \
    FTP_PROXY=ftp://localhost:$port \
    ssh_remote_proxy=localhost:$port \
    bash -i

### fatpacked app ssl-create-self-signed-certificate ###########################

#!/bin/bash

# Create a self signed certificate

set -e

source bash-helpers

host=${1?Specify host}

if [[ -e server-key.pem ]] ; then
    DIE "File server-key.pem exists"
fi

if [[ -e server-cert.pem ]] ; then
    DIE "File server-cert.pem exists"
fi

openssl req -x509 -newkey rsa:1024 \
    -keyout server-key.pem \
    -out server-cert.pem \
    -days 365 -nodes \
    -subj "/C=DE/ST=SH/L=Germany/CN=$host"

ls server-key.pem server-cert.pem

### fatpacked app ssl-strip ####################################################

#!/bin/bash

# Remove ssl encryption from https and other protocols

source bash-helpers

in=$1
out=$2

if [[ $@ < 2 ]] ; then
    die "usage: sslstrip [in_host:]in_port out_host:out_port"
fi

cmd="sudo stunnel -c -d $in -r $out -f"
INFO "running: $cmd"
xtitle "ssl-strip $cmd" && $cmd

### fatpacked app sudo. ########################################################

#!/usr/bin/env bash

# Keep path with sudo

cmd=${1:?Specify cmd}

exec sudo env PATH=$PATH "$@"

### fatpacked app term-bg-switch ###############################################

#!/usr/bin/env bash

# Switch terminal background color
# Press <ctrl-c> to keep the current background color.

source bash-helpers

while true ; do
  printf \\e[?5h
  sleep 1
  printf \\e[?5l
  sleep 1
done

### fatpacked app term-color-test ##############################################

#!/usr/bin/perl

# most color mappings taken from xterm-colortest
# at http://www.frexx.de/xterm-256-notes/data/xterm-colortest

use strict;
use warnings;
no warnings 'uninitialized';

while (<DATA>) {

    print "\n\n" if $. == 17;

    next if /^$/;

    print "\n" if ( $. - 1 ) % 6 == 0;

    my ( $space, $id, $rgb ) = /^(\s*)(\S+);(\S+)$/;

    my $fg = "\x1b[38;5;${id}m";
    my $bg = "\x1b[48;5;${id}m  ";

    print $space . $id . ":$fg $rgb $bg \x1b[33;5;0m ";
}

print "\n\n";

__DATA__
  0;000000
  1;aa0000
  2;00aa00
  3;aa5500
  4;0000aa
  5;aa00aa
  6;00aaaa
  7;aaaaaa
  8;555555
  9;ff5555
 10;55ff55
 11;ffff55
 12;5555ff
 13;ff55ff
 14;55ffff
 15;ffffff


 16;000000
 17;00005f
 18;000087
 19;0000af
 20;0000d7
 21;0000ff
 22;005f00
 23;005f5f
 24;005f87
 25;005faf
 26;005fd7
 27;005fff
 28;008700
 29;00875f
 30;008787
 31;0087af
 32;0087d7
 33;0087ff
 34;00af00
 35;00af5f
 36;00af87
 37;00afaf
 38;00afd7
 39;00afff
 40;00d700
 41;00d75f
 42;00d787
 43;00d7af
 44;00d7d7
 45;00d7ff
 46;00ff00
 47;00ff5f
 48;00ff87
 49;00ffaf
 50;00ffd7
 51;00ffff
 52;5f0000
 53;5f005f
 54;5f0087
 55;5f00af
 56;5f00d7
 57;5f00ff
 58;5f5f00
 59;5f5f5f
 60;5f5f87
 61;5f5faf
 62;5f5fd7
 63;5f5fff
 64;5f8700
 65;5f875f
 66;5f8787
 67;5f87af
 68;5f87d7
 69;5f87ff
 70;5faf00
 71;5faf5f
 72;5faf87
 73;5fafaf
 74;5fafd7
 75;5fafff
 76;5fd700
 77;5fd75f
 78;5fd787
 79;5fd7af
 80;5fd7d7
 81;5fd7ff
 82;5fff00
 83;5fff5f
 84;5fff87
 85;5fffaf
 86;5fffd7
 87;5fffff
 88;870000
 89;87005f
 90;870087
 91;8700af
 92;8700d7
 93;8700ff
 94;875f00
 95;875f5f
 96;875f87
 97;875faf
 98;875fd7
 99;875fff
100;878700
101;87875f
102;878787
103;8787af
104;8787d7
105;8787ff
106;87af00
107;87af5f
108;87af87
109;87afaf
110;87afd7
111;87afff
112;87d700
113;87d75f
114;87d787
115;87d7af
116;87d7d7
117;87d7ff
118;87ff00
119;87ff5f
120;87ff87
121;87ffaf
122;87ffd7
123;87ffff
124;af0000
125;af005f
126;af0087
127;af00af
128;af00d7
129;af00ff
130;af5f00
131;af5f5f
132;af5f87
133;af5faf
134;af5fd7
135;af5fff
136;af8700
137;af875f
138;af8787
139;af87af
140;af87d7
141;af87ff
142;afaf00
143;afaf5f
144;afaf87
145;afafaf
146;afafd7
147;afafff
148;afd700
149;afd75f
150;afd787
151;afd7af
152;afd7d7
153;afd7ff
154;afff00
155;afff5f
156;afff87
157;afffaf
158;afffd7
159;afffff
160;d70000
161;d7005f
162;d70087
163;d700af
164;d700d7
165;d700ff
166;d75f00
167;d75f5f
168;d75f87
169;d75faf
170;d75fd7
171;d75fff
172;d78700
173;d7875f
174;d78787
175;d787af
176;d787d7
177;d787ff
178;d7af00
179;d7af5f
180;d7af87
181;d7afaf
182;d7afd7
183;d7afff
184;d7d700
185;d7d75f
186;d7d787
187;d7d7af
188;d7d7d7
189;d7d7ff
190;d7ff00
191;d7ff5f
192;d7ff87
193;d7ffaf
194;d7ffd7
195;d7ffff
196;ff0000
197;ff005f
198;ff0087
199;ff00af
200;ff00d7
201;ff00ff
202;ff5f00
203;ff5f5f
204;ff5f87
205;ff5faf
206;ff5fd7
207;ff5fff
208;ff8700
209;ff875f
210;ff8787
211;ff87af
212;ff87d7
213;ff87ff
214;ffaf00
215;ffaf5f
216;ffaf87
217;ffafaf
218;ffafd7
219;ffafff
220;ffd700
221;ffd75f
222;ffd787
223;ffd7af
224;ffd7d7
225;ffd7ff
226;ffff00
227;ffff5f
228;ffff87
229;ffffaf
230;ffffd7
231;ffffff
232;080808
233;121212
234;1c1c1c
235;262626
236;303030
237;3a3a3a
238;444444
239;4e4e4e
240;585858
241;626262
242;6c6c6c
243;767676
244;808080
245;8a8a8a
246;949494
247;9e9e9e
248;a8a8a8
249;b2b2b2
250;bcbcbc
251;c6c6c6
252;d0d0d0
253;dadada
254;e4e4e4
255;eeeeee

### fatpacked app term-flash ###################################################

#!/usr/bin/env bash

# Flash the terminal background

source bash-helpers

function cleanup() {
  printf \\e[?5l
}
trap cleanup ERR INT

message="$@"

if [[ $TMUX ]] ; then
  exec tmux-flash "$message"
fi

echo "$message"
while true ; do
  tmux set -g window-active-style 'bg=colour9'
  # printf \\e[?5h
  sleep 1
  tmux set -g window-active-style 'bg=colour231'
  # printf \\e[?5l
  sleep 1
done

### fatpacked app term-line-wrap-off ###########################################

# Turn off shell line wrapping

printf '\033[?7l'

### fatpacked app term-line-wrap-on ############################################

# Turn off shell line wrapping

printf '\033[?7h'

### fatpacked app text-from-any ################################################

#!/bin/bash
# Convert any file to text

source bash-helpers

file="$@"

INFO "Converting file $file"

# if [[ -e txt ]] ; then
#   DIE 'txt directory exists'
# fi

extension=$(extension $file)
type=$(file -b --mime-type "$file")
out="txt/$file"
dir="txt/"`dirname "$file"`
mkdir -p "$dir"

DEBUG "type: $type"

if [[ "$type" =~ "text" ]] ; then
    RETURN
fi

if [[ "$type" =~ "xml" ]] ; then
    RETURN
fi

if [[ "$type" =~ "x-msaccess" ]] ; then
    for table in $(mdb-tables "$file") ; do
        INFO "Exporting database table $table..."
        mdb-export -D '%F %T' "$file" "$table" > "$out.table-$table.csv"
    done
    RETURN
fi

if [[ "$extension" = ".pdf" ]] ; then
    pdftotext "$file" "$out.txt"
    RETURN
fi

if [[ "$extension" = ".xlsx" ]] ; then
    xlsx2csv -s 0 "$file" "$out.csv"
    RETURN
fi

if [[ "$extension" = ".docx" ]] ; then
    docx2txt "$file" "$out.txt"
    RETURN
fi

if [[ "$extension" = ".doc" ]] ; then
    catdoc "$file" > "$out.txt"
    RETURN
fi

DIE "Unknown file extension: $extension for $file"


### fatpacked app text-quote ###################################################

# Quote text

fmt -s | perl -pe 's/^/> /g' -

### fatpacked app text-remove-comments #########################################

# Remove comment from text

perl -ne 'print if ! /^#/ && ! /^$/' -

### fatpacked app time-dehumanize ##############################################

#!/usr/bin/env perl

# Convert a humanized time spec into seconds

use strict;
use warnings;

my ($human) = $ARGV[0] || die "Specify humanized time";

my $s = 1;
my $m = $s * 60;
my $h = $m * 60;
my $d = $h * 24;
my $w = $d * 7;
my $y = $d * 365;

my ($amount, $unit) = $human =~ /^(\d+)(.)$/g;
$amount || die "Cannot find amount in $human";
$unit   || die "Cannot find unit in $human";

print $amount * eval("\$" . $unit);

### fatpacked app time-humanize-seconds ########################################

# Return a humanly comprehendable representation of an amount of seconds

source bash-helpers

secs=${1:-0}

if  [ $secs -ge 359999 ] ; then # 99 h
    human=$(($secs / 60 / 60 / 24))d
elif [ $secs -ge 5999 ] ; then # 99 m
    human=$(($secs / 60 / 60))h
elif [ $secs -ge 60 ] ; then
    human=$(($secs / 60))m
else
    human=$secs"s"
fi

if [ ${#human} = 2 ] ; then
    human=" "$human
fi

RETURN $GREY"$human"$NO_COLOR

### fatpacked app time-stamp-to-date ###########################################

#!/usr/bin/env perl

# Print date for a timestamp

use strict;
use warnings;
use POSIX;

my $timestamp = $ARGV[0] || die "Timestamp?";

print strftime( "%F %T", localtime( substr( $timestamp, 0, 10 ) ) ) . "\n";

### fatpacked app tmux-flash ###################################################

#!/usr/bin/env bash

# Flash the current pane background

source bash-helpers

function cleanup() {
  tmux set window-active-style 'bg=default'
  tmux set window-style 'bg=default'
}
trap cleanup ERR INT

message="$@"

# Only blink specific pane - see also: $TMUX_PANE
# select-pane -t:.1 -P 'bg=red' 

echo "$message"
while true ; do
  tmux set window-active-style 'bg=black'
  tmux set window-style 'bg=black'
  sleep 1
  tmux set window-active-style 'bg=white'
  tmux set window-style 'bg=white'
  sleep 1
done


### fatpacked app tmux-reattach ################################################

#!/bin/bash

# Reattach or create a new tmux session

wanted_session=$1
session=$wanted_session

if [[ ! $session ]] ; then
    session=main
fi

ssh-agent-env-grab

(
    xtitle tmux@$HOSTNAME
    if tmux has-session -t $session ; then
        exec tmux -2 att -d -t $session
    fi


    if [[ ! $wanted_session ]] ; then
        if tmux has-session ; then
            exec tmux -2 att -d
        fi
    fi

    tmux-session $session
    exec tmux -2 att -d -t $session

    xtitle "Terminal"

    exit 1

) && clear


### fatpacked app tmux-session #################################################

#!/bin/sh

# Start a named tmux session with 10 tabs

set -e

session=${1?Specify session name}

tmux new-session -d -s $session -n ""

tmux new-window -n ""
tmux new-window -n ""
tmux new-window -n ""
tmux new-window -n ""
tmux new-window -n ""
tmux new-window -n ""
tmux new-window -n ""
tmux new-window -n ""
tmux new-window -n ""

# tmux split-window -d -v -t $session:1 'ssh workflow@qualle3'
# tmux split-window -d -v -t $session:1 'ssh workflow@qualle2'

# tmux send-keys -t $session:1.0 C-l
# tmux send-keys -t $session:1.1 C-l
# tmux send-keys -t $session:1.2 C-l

tmux select-window -t $session:1

# xtitle "$session" tmux -2 attach-session -d -t $session

### fatpacked app tmux-setup ###################################################

#!/usr/bin/env bash

# Setup tmux config

source bash-helpers

dir=$(mktemp -d)
cd $dir

wget -q https://raw.githubusercontent.com/nilsboy/dotfiles/master/tmux.conf

mv tmux.conf ~/.tmux.conf

### fatpacked app tmux-synchronized-panes-toggle ###############################

#!/bin/bash

# Toggle synchronized tmux panes

tmux set-window-option synchronize-panes

### fatpacked app tmux-xpanes ##################################################

#!/usr/bin/env bash

# Awesome tmux-based terminal divider

readonly XP_SHELL="/usr/bin/env bash"

# @Author Yamada, Yasuhiro
# @Filename xpanes

set -u
readonly XP_VERSION="4.1.1"

## trap might be updated in 'xpns_pre_execution' function
trap 'rm -f "${XP_CACHE_HOME}"/__xpns_*$$; rm -f "${XP_DEFAULT_SOCKET_PATH}"' EXIT

## --------------------------------
# Error constants
## --------------------------------
# Undefined or General errors
readonly XP_EUNDEF=1

# Invalid option/argument
readonly XP_EINVAL=4

# Could not open tty.
readonly XP_ETTY=5

# Invalid layout.
readonly XP_ELAYOUT=6

# Impossible layout: Small pane
readonly XP_ESMLPANE=7

# Log related exit status is 2x.
## Could not create a directory.
readonly XP_ELOGDIR=20

## Could not directory to store logs is not writable.
readonly XP_ELOGWRITE=21

# User's intentional exit is 3x
## User exit the process intentionally by following warning message.
readonly XP_EINTENT=30

## All the panes are closed before processing due to user's options/command.
readonly XP_ENOPANE=31

# Necessary commands are not found
readonly XP_ENOCMD=127

# ===============

# XP_THIS_FILE_NAME is supposed to be "xpanes".
readonly XP_THIS_FILE_NAME="${0##*/}"
readonly XP_THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%N}}")" && pwd)"
readonly XP_ABS_THIS_FILE_NAME="${XP_THIS_DIR}/${XP_THIS_FILE_NAME}"

# Prevent cache directory being created under root / directory in any case.
# This is quite rare case (but it can be happened).
readonly XP_USER_HOME="${HOME:-/tmp}"

# Basically xpanes follows XDG Base Direcotry Specification.
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-0.6.html
XDG_CACHE_HOME="${XDG_CACHE_HOME:-${XP_USER_HOME}/.cache}"
readonly XP_CACHE_HOME="${XDG_CACHE_HOME}/xpanes"

# This is supposed to be xpanes-12345(PID)
readonly XP_SESSION_NAME="${XP_THIS_FILE_NAME}-$$"
# Temporary window name is tmp-12345(PID)
readonly XP_TMP_WIN_NAME="tmp-$$"
readonly XP_EMPTY_STR="EMPTY"

readonly XP_SUPPORT_TMUX_VERSION_LOWER="1.8"

# Check dependencies just in case.
# Even POSIX compliant commands are only used in this program.
# `xargs`, `sleep`, `mkfifo` are omitted because minimum functions can work without them.
readonly XP_DEPENDENCIES="${XP_DEPENDENCIES:-tmux grep sed tr od echo touch printf cat sort pwd cd mkfifo}"

## --------------------------------
# User customizable shell variables
## --------------------------------
TMUX_XPANES_EXEC=${TMUX_XPANES_EXEC:-tmux}
TMUX_XPANES_PANE_BORDER_FORMAT="${TMUX_XPANES_PANE_BORDER_FORMAT:-#[bg=green,fg=black] #T #[default]}"
TMUX_XPANES_PANE_BORDER_STATUS="${TMUX_XPANES_PANE_BORDER_STATUS:-bottom}"
TMUX_XPANES_PANE_DEAD_MESSAGE=${TMUX_XPANES_PANE_DEAD_MESSAGE:-'\033[41m\033[4m\033[30m Pane is dead: Press [Enter] to exit... \033[0m\033[39m\033[49m'}
XP_DEFAULT_TMUX_XPANES_LOG_FORMAT="[:ARG:].log.%Y-%m-%d_%H-%M-%S"
TMUX_XPANES_LOG_FORMAT="${TMUX_XPANES_LOG_FORMAT:-${XP_DEFAULT_TMUX_XPANES_LOG_FORMAT}}"
XP_DEFAULT_TMUX_XPANES_LOG_DIRECTORY="${XP_CACHE_HOME}/logs"
TMUX_XPANES_LOG_DIRECTORY="${TMUX_XPANES_LOG_DIRECTORY:-${XP_DEFAULT_TMUX_XPANES_LOG_DIRECTORY}}"

## --------------------------------
# Initialize Options
## --------------------------------
# options which work individually.
readonly XP_FLAG_OPTIONS="[hVdetxs]"
# options which need arguments.
readonly XP_ARG_OPTIONS="[ISclnCRB]"
readonly XP_DEFAULT_LAYOUT="tiled"
readonly XP_DEFAULT_REPSTR="{}"
readonly XP_DEFAULT_CMD_UTILITY="echo {} "
readonly XP_SSH_CMD_UTILITY="ssh -o StrictHostKeyChecking=no {} "
XP_OPTIONS=()
XP_ARGS=()
XP_STDIN=()
XP_BEGIN_ARGS=()
XP_IS_PIPE_MODE=0
XP_OPT_IS_SYNC=1
XP_OPT_DRY_RUN=0
XP_OPT_ATTACH=1
XP_OPT_LOG_STORE=0
XP_REPSTR=""
XP_DEFAULT_SOCKET_PATH_BASE="${XP_CACHE_HOME}/socket"
XP_DEFAULT_SOCKET_PATH="${XP_DEFAULT_SOCKET_PATH_BASE}.$$"
XP_SOCKET_PATH="${XP_SOCKET_PATH:-${XP_DEFAULT_SOCKET_PATH}}"
XP_NO_OPT=0
XP_OPT_CMD_UTILITY=0
XP_CMD_UTILITY=""
XP_LAYOUT="${XP_DEFAULT_LAYOUT}"
XP_MAX_PANE_ARGS=""
XP_OPT_SET_TITLE=0
XP_OPT_CHANGE_BORDER=0
XP_OPT_EXTRA=0
XP_OPT_SPEEDY=0
XP_OPT_SPEEDY_AWAIT=0
XP_OPT_USE_PRESET_LAYOUT=0
XP_OPT_CUSTOM_SIZE_COLS=
XP_OPT_CUSTOM_SIZE_ROWS=
XP_OPT_BULK_COLS=
XP_WINDOW_WIDTH=
XP_WINDOW_HEIGHT=
XP_COLS=
XP_COLS_OFFSETS=
XP_OPT_DEBUG=0
XP_OPT_IGNORE_SIZE_LIMIT=0

## --------------------------------
# Logger
#   $1 -- Log level (i.e Warning, Error)
#   $2 -- Message
#   i.e
#      xpanes:Error: invalid option.
#
# This log format is created with reference to openssl's one.
#   $ echo | openssl -a
#   openssl:Error: '-a' is an invalid command.
## --------------------------------
xpns_msg() {
  local _loglevel="$1"
  local _msgbody="$2"
  local _msg="${XP_THIS_FILE_NAME}:${_loglevel}: ${_msgbody}"
  printf "%s\\n" "${_msg}" >&2
}

xpns_msg_info() {
  xpns_msg "Info" "$1"
}

xpns_msg_warning() {
  xpns_msg "Warning" "$1"
}

xpns_msg_debug() {
  if [[ $XP_OPT_DEBUG -eq 1 ]];then
    xpns_msg "Debug" "$(date "+[%F_%T]"):${FUNCNAME[1]}:$1"
  fi
}

xpns_msg_error() {
  xpns_msg "Error" "$1"
}

xpns_usage_warn() {
  xpns_usage_short >&2
  echo "Try '${XP_THIS_FILE_NAME} --help' for more information." >&2
}

xpns_usage_short() {
  cat << _EOS_
Usage: ${XP_THIS_FILE_NAME} [OPTIONS] [argument ...]
Usage(Pipe mode): command ... | ${XP_THIS_FILE_NAME} [OPTIONS] [<command> ...]
_EOS_
}

xpns_usage() {
  cat <<USAGE
Usage:
  ${XP_THIS_FILE_NAME} [OPTIONS] [argument ...]

Usage(Pipe mode):
  command ... | ${XP_THIS_FILE_NAME} [OPTIONS] [<command> ...]

OPTIONS:
  -h,--help                    Display this help and exit.
  -V,--version                 Output version information and exit.
  -B <begin-command>           Run <begin-command> before processing <command> in each pane. Multiple options are allowed.
  -c <command>                 Set <command> to be executed in each pane. Default is \`echo {}\`.
  -d,--desync                  Make synchronize-panes option off in new window.
  -e                           Execute given arguments as is. Same as \`-c '{}'\`
  -I <repstr>                  Replacing one or more occurrences of <repstr> in command provided by -c or -B. Default is \`{}\`.
  -C NUM,--cols=NUM            Number of columns of window layout.
  -R NUM,--rows=NUM            Number of rows of window layout.
  -l <layout>                  Set the preset of window layout. Recognized layout arguments are:
                               t    tiled
                               eh   even-horizontal
                               ev   even-vertical
                               mh   main-horizontal
                               mv   main-vertical
  -n <number>                  Set the maximum number of <argument> taken for each pane.
  -s                           Speedy mode: Run command without opening an interactive shell.
  -ss                          Speedy mode AND close a pane automatically at the same time as process exiting.
  -S <socket-path>             Set a full alternative path to the server socket.
  -t                           Display each argument on the each pane's border as their title.
  -x                           Create extra panes in the current active window.
  --log[=<directory>]          Enable logging and store log files to ~/.cache/xpanes/logs or <directory>.
  --log-format=<FORMAT>        Make name of log files follow <FORMAT>. Default is \`${XP_DEFAULT_TMUX_XPANES_LOG_FORMAT}\`.
  --ssh                        Same as \`-t -s -c 'ssh -o StrictHostKeyChecking=no {}'\`.
  --stay                       Do not switch to new window.
  --bulk-cols=NUM1[,NUM2 ...]  Set number of columns on multiple rows (i.e, "2,2,2" represents 2 cols x 3 rows).
  --debug                      Print debug message.

Copyright (c) 2019 Yamada, Yasuhiro
Released under the MIT License.
https://github.com/greymd/tmux-xpanes
USAGE
}

# Show version number
xpns_version() {
  echo "${XP_THIS_FILE_NAME} ${XP_VERSION}"
}

# Get version number for tmux
xpns_get_tmux_version() {
  local _tmux_version=""
  if ! ${TMUX_XPANES_EXEC} -V &> /dev/null; then
    # From tmux 0.9 to 1.3, there is no -V option.
    _tmux_version="tmux 0.9-1.3"
  else
    _tmux_version="$( ${TMUX_XPANES_EXEC} -V )"
  fi
  ( read -r _ _ver; echo "${_ver}" ) <<<"${_tmux_version}"
}

# Check whether the prefered tmux version is greater than host's tmux version.
# $1 ... Prefered version.
# $2 ... Host tmux version(optional).
# In case of tmux version is 1.7, the result will be like this.
# 0 is true, 1 is false.
##  arg  -> result
#   func 1.5  1.7 -> 0
#   func 1.6  1.7 -> 0
#   func 1.7  1.7 -> 0
#   func 1.8  1.7 -> 1
#   func 1.9  1.7 -> 1
#   func 1.9a 1.7 -> 1
#   func 2.0  1.7 -> 1
xpns_tmux_is_greater_equals() {
  local _check_version="$1"
  local _tmux_version="${2:-$(xpns_get_tmux_version)}"
  # Simple numerical comparison does not work because there is the version like "1.9a".
  if [[ "$( (echo "${_tmux_version}"; echo "${_check_version}") | sort -n | head -n 1)" != "${_check_version}" ]];then
    return 1
  else
    return 0
  fi
}

xpns_get_local_tmux_conf() {
  local _conf_name="$1"
  local _session="${2-}"
  {
    if [[ -z "${_session-}" ]];then
      ${TMUX_XPANES_EXEC} show-window-options
    else
      ${TMUX_XPANES_EXEC} -S "${_session}" show-window-options
    fi
  } | grep "^${_conf_name}" \
    | ( read -r _ _v; printf "%s\\n" "${_v}" )
}

xpns_get_global_tmux_conf() {
  local _conf_name="$1"
  local _session="${2-}"
  {
    if [[ -z "${_session-}" ]];then
      ${TMUX_XPANES_EXEC} show-window-options -g
    else
      ${TMUX_XPANES_EXEC} -S "${_session}" show-window-options -g
    fi
  } | grep "^${_conf_name}" \
    | ( read -r _ _v; printf "%s\\n" "${_v}" )
}

# Disable allow-rename because
# window separation does not work correctly
# if "allow-rename" option is on
xpns_suppress_allow_rename () {
  local _default_allow_rename="$1"
  local _session="${2-}"
  if [[ "${_default_allow_rename-}" == "on"  ]]; then
    ## Temporary, disable "allow-rename"
    xpns_msg_debug "'allow-rename' option is 'off' temporarily."
    if [[ -z "${_session-}" ]];then
      ${TMUX_XPANES_EXEC} set-window-option -g allow-rename off
    else
      ${TMUX_XPANES_EXEC} -S "${_session}" set-window-option -g allow-rename off
    fi
  fi
}

# Restore default "allow-rename"
# Do not write like 'xpns_restore_allow_rename "some value" "some value" > /dev/null'
# In tmux 1.6, 'tmux set-window-option' might be stopped in case of redirection.
xpns_restore_allow_rename () {
  local _default_allow_rename="$1"
  local _session="${2-}"
  if [[ "${_default_allow_rename-}" == "on"  ]]; then
    xpns_msg_debug "Restore original value of 'allow-rename' option."
    if [[ -z "${_session-}" ]];then
      ${TMUX_XPANES_EXEC} set-window-option -g allow-rename on
    else
      ${TMUX_XPANES_EXEC} -S "${_session}" set-window-option -g allow-rename on
    fi
  fi
}

# func "11" "2"
#  => 6
# 11 / 2 = 5.5 => ceiling => 6
xpns_ceiling () {
  local _divide="$1";shift
  local _by="$1"
  printf "%s\\n" $(( ( _divide + _by - 1 ) / _by ))
}

# func "10" "3"
#  => 4 3 3
# Divide 10 into 3 parts as equally as possible.
xpns_divide_equally () {
  local _number="$1";shift
  local _count="$1"
  local _upper _lower _upper_count _lower_count
  _upper="$(xpns_ceiling "$_number" "$_count")"
  _lower=$(( _upper - 1 ))
  _lower_count=$(( _upper * _count - _number ))
  _upper_count=$(( _count - _lower_count ))
  eval "printf '${_upper} %.0s' {1..$_upper_count}"
  (( _lower_count > 0 )) && eval "printf '${_lower} %.0s' {1..$_lower_count}"
}

# echo 3 3 3 3 | func
# => 3 6 9 12
xpns_nums_accumulate_sum () {
  local s=0
  while read -r n; do
    ((s = s + n ))
    printf "%s " "$s"
  done < <( cat | tr ' ' '\n')
}

# func 3 2 2 2
# => 4 4 1
#
# For example, "3 2 2 2" represents following cell positions
#   1  2  3
# 1 [] [] [] => 3 rows
# 2 [] []    => 2 rows
# 3 [] []    => 2 rows
# 4 [] []    => 2 rows
#
# After the transposition, it must be "4 4 1" which represents below
#   1  2  3  4
# 1 [] [] [] [] => 4 rows
# 2 [] [] [] [] => 4 rows
# 3 []          => 1 rows
xpns_nums_transpose () {
  local _colnum="$1"
  local _spaces=
  local _result=
  xpns_msg_debug "column num = $_colnum, input = $*"
  _spaces="$(for i in "$@";do
    printf "%${i}s\\n"
  done)"

  # 'for' statement does not work somehow
  _result="$(while read -r i; do
    ## This part is depending on the following 'cut' behavior
    ## $ echo 1234 | cut -c 5
    ## => result is supposed to be empty
    printf "%s\\n" "$_spaces" | cut -c "$i" | grep -c ' '
  done < <(xpns_seq 1 "${_colnum}") | xargs)"
  xpns_msg_debug "result = $_result"
  printf "%s\\n" "$_result"
}

# Adjust size of columns and rows in accordance with given N
# func <col> <row> <N>
# i.e:
#     func "" "" 20
#       => returns 4 5
#     func "6" 0 20
#       => returns 6 4
xpns_adjust_col_row() {
  local col="${1:-0}" ;shift
  local row="${1:-0}" ;shift
  local N="$1"   ;shift
  local fix_col_flg
  local fix_row_flg
  (( col != 0 )) && fix_col_flg=1 || fix_col_flg=0
  (( row != 0 )) && fix_row_flg=1 || fix_row_flg=0

  # This is just a author (@greymd)'s preference.
  if (( fix_col_flg == 0 )) && (( fix_row_flg == 0 )) && (( N == 2)) ;then
    col=2
    row=1
    printf "%d %d\\n" "${col}" "${row}"
    return
  fi

  # If both valures are provided, col is used.
  if (( fix_col_flg == 1 )) && (( fix_row_flg == 1 ));then
    row=0
    fix_row_flg=0
  fi
  # This algorhythm is almost same as tmux default
  #   https://github.com/tmux/tmux/blob/2.8/layout-set.c#L436
  while (( col * row < N )) ;do
    (( fix_row_flg != 1 )) && (( row = row + 1 ))
    if (( col * row < N ));then
      (( fix_col_flg != 1 )) &&  (( col = col + 1 ))
    fi
  done
  printf "%d %d\\n" "${col}" "${row}"
}

# Make each line unique by adding index number
# echo aaa bbb ccc aaa ccc ccc | xargs -n 1 | xpns_unique_line
#  aaa-1
#  bbb-1
#  ccc-1
#  aaa-2
#  ccc-2
#  ccc-3
#
# Eval is used because associative array is not supported before bash 4.2
xpns_unique_line () {
  local _val_name
  while read -r line; do
    _val_name="__xpns_hash_$(printf "%s" "${line}" | xpns_value2key)"
    # initialize variable
    eval "${_val_name}=\${${_val_name}:-0}"
    # increment variable
    eval "${_val_name}=\$(( ++${_val_name} ))"
    printf "%s\\n" "${line}-$(eval printf "%s" "\$${_val_name}")"
  done
}

#
# Generate log file names from given arguments.
# Usage:
#        echo <arg1> <arg2> ... | xpns_log_filenames <FORMAT>
# Return:
#        File names.
# Example:
#        $ echo aaa bbb ccc aaa ccc ccc | xargs -n 1 | xpns_log_filenames '[:ARG:]_[:PID:]_%Y%m%d.log'
#        aaa-1_1234_20160101.log
#        bbb-1_1234_20160101.log
#        ccc-1_1234_20160101.log
#        aaa-2_1234_20160101.log
#        ccc-2_1234_20160101.log
#        ccc-3_1234_20160101.log
#
xpns_log_filenames () {
  local _arg_fmt="$1"
  local _full_fmt=
  _full_fmt="$(date "+${_arg_fmt}")"
  cat \
    | \
    # 1st argument + '-' + unique number (avoid same argument has same name)
    xpns_unique_line \
    | while read -r _arg
    do
      cat <<<"${_full_fmt}" \
        | sed "s/\\[:ARG:\\]/${_arg}/g" \
        | sed "s/\\[:PID:\\]/$$/g"
    done
}

## --------------------------------
# Normalize directory by making following conversion.
#  * Tilde expansion.
#  * Remove the slash '/' at the end of the dirname.
# Usage:
#        xpns_normalize_directory <direname>
# Return:
#        Normalized <dirname>
## --------------------------------
xpns_normalize_directory() {
  local _dir="$1"
  # Remove end of slash '/'
  _dir="${_dir%/}"
  # tilde expansion
  _dir="${_dir/#~/${HOME}}"
  printf "%s\\n" "${_dir}"
}

## --------------------------------
# Ensure existence of given directory
# Usage:
#        xpns_is_valid_directory <direname>
# Return:
#        Absolute path of the <dirname>
## --------------------------------
xpns_is_valid_directory() {
  local _dir="$1"
  local _checkfile="${XP_THIS_FILE_NAME}.$$"
  # Check directory.
  if [[ ! -d "${_dir}" ]]; then
    # Create directory
    if mkdir "${_dir}"; then
      xpns_msg_info "${_dir} is created."
    else
      xpns_msg_error "Failed to create ${_dir}"
      exit ${XP_ELOGDIR}
    fi
  fi
  # Try to create file.
  #   Not only checking directory permission,
  #   but also i-node and other misc situations.
  if ! touch "${_dir}/${_checkfile}"; then
    xpns_msg_error "${_dir} is not writable."
    rm -f "${_dir}/${_checkfile}"
    exit ${XP_ELOGWRITE}
  fi
  rm -f "${_dir}/${_checkfile}"
}

# Convert array to string which is can be used as command line argument.
# Usage:
#       xpns_arr2args <array object>
# Example:
#       array=(aaa bbb "ccc ddd" eee "f'f")
#       xpns_arr2args "${array[@]}"
#       @returns "'aaa' 'bbb' 'ccc ddd' 'eee' 'f\'f'"
# Result:
xpns_arr2args() {
  local _arg=""
  # If there is no argument, usage will be shown.
  if [[ $# -lt 1 ]]; then
    return 0
  fi
  for i in "$@" ;do
    _arg="${i}"
    # Use 'cat <<<"input"' command instead of 'echo',
    # because such the command recognizes option like '-e'.
    cat <<<"${_arg}" \
      | \
      # Escaping single quotations.
      sed "s/'/'\"'\"'/g" \
      | \
      # Surround argument with single quotations.
      sed "s/^/'/;s/$/' /" \
      | \
      # Remove new lines
      tr -d '\n'
  done
}

# Extract first field to generate window name.
# ex, $2     =  'aaa bbb ccc'
#   return   =  aaa-12345(PID)
xpns_generate_window_name() {
  local _unprintable_str="${1-}"; shift
  # Leave first 200 characters to prevent
  # the name exceed the maximum length of tmux window name (2000 byte).
  printf "%s\\n" "${1:-${_unprintable_str}}" \
    | ( read -r _name _ && printf "%s\\n" "${_name:0:200}-$$" )
}

# Convert string to another string which can be handled as tmux window name.
xpns_value2key() {
  od -v -tx1 -An  | tr -dc 'a-zA-Z0-9' | tr -d '\n'
}

# Restore string encoded by xpns_value2key function.
xpns_key2value() {
  read -r _key
  # shellcheck disable=SC2059
  printf "$(printf "%s" "$_key" | sed 's/../\\x&/g')"
}

# Remove empty lines
# This function behaves like `awk NF`
xpns_rm_empty_line() {
  { cat; printf "\\n";} | while IFS= read -r line;do
    # shellcheck disable=SC2086
    set -- ${line-}
    if [[ $# != 0 ]]; then
      printf "%s\\n" "${line}"
    fi
  done
}

# Extract matched patterns from string
# $ xpns_extract_matched "aaa123bbb" "[0-9]{3}"
# => "123"
xpns_extract_matched() {
  local _args="$1" ;shift
  local _regex="($1)"
  if [[ $_args =~ $_regex ]];then
    printf "%s" "${BASH_REMATCH[0]}"
  fi
}

# Enable logging feature to the all the panes in the target window.
xpns_enable_logging() {
  local _window_name="$1"     ; shift
  local _index_offset="$1"    ; shift
  local _log_dir="$1"         ; shift
  local _log_format="$1"      ; shift
  local _unprintable_str="$1" ; shift
  local _args=("$@")
  local _args_num=$(($# - 1))
  # Generate log files from arguments.
  local _idx=0
  while read -r _logfile ; do
    # Start logging
    xpns_msg_debug "Start logging pipe-pane(cat >> '${_log_dir}/${_logfile}')"
    ${TMUX_XPANES_EXEC} \
      pipe-pane -t "${_window_name}.$(( _idx + _index_offset ))" \
      "cat >> '${_log_dir}/${_logfile}'" # Tilde expansion does not work here.
    _idx=$(( _idx + 1 ))
  done < <(
  for i in $(xpns_seq 0 "${_args_num}")
  do
    # Replace empty string.
    printf "%s\\n" "${_args[i]:-${_unprintable_str}}"
  done | xpns_log_filenames "${_log_format}"
  )
}

## Print "1" on the particular named pipe
xpns_notify() {
  local _wait_id="$1" ; shift
  local _fifo=
  _fifo="${XP_CACHE_HOME}/__xpns_${_wait_id}"
  xpns_msg_debug "Notify to $_fifo"
  printf "%s\\n" 1 > "$_fifo" &
}

xpns_notify_logging() {
  local _window_name="$1" ; shift
  local _args_num=$(($# - 1))
  for i in $(xpns_seq 0 "${_args_num}"); do
    xpns_notify "log_${_window_name}-${i}-$$"
  done
}

xpns_notify_sync() {
  local _window_name="$1" ; shift
  local _args_num=$(($# - 1))
  for i in $(xpns_seq 0 "${_args_num}"); do
    xpns_notify "sync_${_window_name}-${i}-$$" &
  done
}

xpns_is_window_alive() {
  local _window_name="$1" ;shift
  local _speedy_await_flag="$1" ;shift
  local _def_allow_rename="$1" ;shift
  if ! ${TMUX_XPANES_EXEC} display-message -t "$_window_name" -p > /dev/null 2>&1 ;then
    xpns_msg_info "All the panes are closed before displaying the result."
    if [[ "${_speedy_await_flag}" -eq 0 ]] ;then
      xpns_msg_info "Use '-s' option instead of '-ss' option to avoid this behavior."
    fi
    xpns_restore_allow_rename "${_def_allow_rename-}"
    exit ${XP_ENOPANE}
  fi
}

xpns_inject_title() {
  local _target_pane="$1" ;shift
  local _message="$1"     ;shift
  local _pane_tty=
  _pane_tty="$( ${TMUX_XPANES_EXEC} display-message -t "${_target_pane}" -p "#{pane_tty}" )"
  printf "\\033]2;%s\\033\\\\" "${_message}" > "${_pane_tty}"
  xpns_msg_debug "target_pane=${_target_pane} pane_title=${_message} pane_tty=${_pane_tty}"
}

xpns_is_pane_title_required() {
  local _title_flag="$1"   ; shift
  local _extra_flag="$1"   ; shift
  local _pane_border_status=
  _pane_border_status=$(xpns_get_local_tmux_conf "pane-border-status")
  if [[ $_title_flag -eq 1 ]]; then
    return 0
  elif [[ ${_extra_flag} -eq 1 ]] && \
       [[ "${_pane_border_status}" != "off" ]] && \
       [[ -n "${_pane_border_status}" ]] ;then
    ## For -x option
    # Even the -t option is not specified, it is required to inject pane title here.
    # Because user expects the title is displayed on the pane if the original window is
    # generated from tmux-xpanes with -t option.
    return 0
  fi
  return 1
}

# Set pane titles for each pane for -t option
xpns_set_titles() {
  local _window_name="$1"  ; shift
  local _index_offset="$1" ; shift
  local _index=0
  local _pane_index=
  for arg in "$@"
  do
    _pane_index=$(( _index + _index_offset ))
    xpns_inject_title "${_window_name}.${_pane_index}" "${arg}"
    _index=$(( _index + 1 ))
  done
}

# Send command to the all the panes in the target window.
xpns_send_commands() {
  local _window_name="$1"  ; shift
  local _index_offset="$1" ; shift
  local _repstr="$1"       ; shift
  local _cmd="$1"          ; shift
  local _index=0
  local _pane_index=
  local _exec_cmd=
  for arg in "$@"
  do
    _exec_cmd="${_cmd//${_repstr}/${arg}}"
    _pane_index=$(( _index + _index_offset ))
    ${TMUX_XPANES_EXEC} send-keys -t "${_window_name}.${_pane_index}" "${_exec_cmd}" C-m
    _index=$(( _index + 1 ))
  done
}

# Separate window vertically, when the number of panes is 1 or 2.
xpns_organize_panes() {
  local _window_name="$1" ; shift
  local _args_num="$1"
  ## ----------------
  # Default behavior
  ## ----------------
  if [[ "${_args_num}" -eq 1 ]]; then
    ${TMUX_XPANES_EXEC} select-layout -t "${_window_name}" even-horizontal
  elif [[ "${_args_num}" -gt 1 ]]; then
    ${TMUX_XPANES_EXEC} select-layout -t "${_window_name}" tiled
  fi
  ## ----------------
  # Update layout
  ## ----------------
  if [[ "${XP_LAYOUT}" != "${XP_DEFAULT_LAYOUT}" ]]; then
    ${TMUX_XPANES_EXEC} select-layout -t "${_window_name}" "${XP_LAYOUT}"
  fi
}

#
# Generate sequential number descending order.
# seq is not used because old version of
# seq does not generate descending oorder.
# $ xpns_seq 3 0
# 3
# 2
# 1
# 0
#
xpns_seq () {
  local _num1="$1"
  local _num2="$2"
  eval "printf \"%d\\n\" {$_num1..$_num2}"
}

xpns_wait_func() {
  local _wait_id="$1"
  local _fifo="${XP_CACHE_HOME}/__xpns_${_wait_id}"
  local _arr=("$_fifo")
  local _fifo_arg=
  _fifo_arg=$(xpns_arr2args "${_arr[@]}")
  xpns_msg_debug "mkfifo $_fifo"
  mkfifo "${_fifo}"
  xpns_msg_debug "grep -q 1 ${_fifo_arg}"
  printf "%s\\n" "grep -q 1 ${_fifo_arg}"
}

# Split a new window into multiple panes.
#
xpns_split_window() {
  local _window_name="$1"     ; shift
  local _log_flag="$1"        ; shift
  local _title_flag="$1"      ; shift
  local _speedy_flag="$1"     ; shift
  local _await_flag="$1"      ; shift
  local _pane_base_index="$1" ; shift
  local _repstr="$1"          ; shift
  local _cmd_template="$1"    ; shift
  local _exec_cmd=
  local _sep_count=0
  local args=("$@")
  _last_idx=$(( ${#args[@]} - 1 ))

  for i in $(xpns_seq $_last_idx 0)
  do
    xpns_msg_debug "Index:${i} Argument:${args[i]}"
    _sep_count=$((_sep_count + 1))
    _exec_cmd="${_cmd_template//${_repstr}/${args[i]}}"

    ## Speedy mode
    if [[ $_speedy_flag -eq 1 ]]; then

      _exec_cmd=$(xpns_inject_wait_command "${_log_flag}" "${_title_flag}" "${_speedy_flag}" "${_await_flag}" "$i" "${_exec_cmd}")
      # Execute command as a child process of default-shell.
      ${TMUX_XPANES_EXEC} split-window -t "${_window_name}" -h -d "${_exec_cmd}"
    else
      # Open login shell and execute command on the interactive screen.
      ${TMUX_XPANES_EXEC} split-window -t "${_window_name}" -h -d
    fi
    # Restraining that size of pane's width becomes
    # less than the minimum size which is defined by tmux.
    if [[ ${_sep_count} -gt 2 ]]; then
      ${TMUX_XPANES_EXEC} select-layout -t "${_window_name}" tiled
    fi
  done
}

#
# Create new panes to the  existing window.
# Usage:
#    func <window name> <offset of index> <number of pane>
#
xpns_prepare_extra_panes() {
  local _window_name="$1"     ; shift
  local _pane_base_index="$1" ; shift
  local _log_flag="$1"        ; shift
  local _title_flag="$1"      ; shift
  local _speedy_flg="$1"      ; shift
  local _await_flg="$1"       ; shift
  # specify a pane which has the biggest index number.
  #   Because pane_id may not be immutable.
  #   If the small number of index is specified here, correspondance between pane_title and command can be slip off.
  ${TMUX_XPANES_EXEC} select-pane -t "${_window_name}.${_pane_base_index}"

  # split window into multiple panes
  xpns_split_window \
    "${_window_name}" \
    "${_log_flag}" \
    "${_title_flag}" \
    "${_speedy_flg}" \
    "${_await_flg}" \
    "${_pane_base_index}" \
    "$@"
}

xpns_get_joined_begin_commands () {
  local _commands="$1"
  if [[ "${#XP_BEGIN_ARGS[*]}" -lt 1 ]]; then
    printf "%s" "${_commands}"
    return
  fi
  printf "%s\\n" "${XP_BEGIN_ARGS[@]}" "${_commands}"
}

xpns_inject_wait_command () {
  local _log_flag="$1"    ; shift
  local _title_flag="$1"  ; shift
  local _speedy_flg="$1"  ; shift
  local _await_flg="$1"   ; shift
  local _idx="$1"         ; shift
  local _exec_cmd="$1"    ; shift

  ## Speedy mode + logging
  if [[ "${_log_flag}" -eq 1 ]] && [[ "${_speedy_flg}" -eq 1 ]]; then
    # Wait for start of logging
    # Without this part, logging thread may start after new process is finished.
    # Execute function to wait for logging start.
    _exec_cmd="$(xpns_wait_func "log_${_window_name}-${_idx}-$$")"$'\n'"${_exec_cmd}"
  fi

  ## Speedy mode (Do not allow to close panes before the separation is finished).
  if [[ "${_speedy_flg}" -eq 1 ]]; then
    _exec_cmd="$(xpns_wait_func "sync_${_window_name}-${_idx}-$$")"$'\n'${_exec_cmd}
  fi

  ## -s: Speedy mode (Not -ss: Speedy mode + nowait)
  if [[ "${_await_flg}" -eq 1 ]]; then
    local _msg
    _msg="$(xpns_arr2args "${TMUX_XPANES_PANE_DEAD_MESSAGE}" | sed 's/"/\\"/g')"
    _exec_cmd="${_exec_cmd}"$'\n'"${XP_SHELL} -c \"printf -- ${_msg} >&2 && read\""
  fi
  printf "%s" "${_exec_cmd}"
}

xpns_new_window () {
  local _window_name="$1" ; shift
  local _attach_flg="$1"  ; shift
  local _speedy_flg="$1"  ; shift
  local _exec_cmd="$1"    ; shift
  local _window_id=

  # Create new window.
  if [[ "${_attach_flg}" -eq 1 ]]; then
    if [[ "${_speedy_flg}" -eq 1 ]]; then
      _window_id=$(${TMUX_XPANES_EXEC} new-window -n "${_window_name}" -F '#{window_id}' -P "${_exec_cmd}")
    else
      _window_id=$(${TMUX_XPANES_EXEC} new-window -n "${_window_name}" -F '#{window_id}' -P )
    fi
  else
    # Keep background
    if [[ "${_speedy_flg}" -eq 1 ]]; then
      _window_id=$(${TMUX_XPANES_EXEC} new-window -n "${_window_name}" -F '#{window_id}' -P -d "${_exec_cmd}")
    else
      _window_id=$(${TMUX_XPANES_EXEC} new-window -n "${_window_name}" -F '#{window_id}' -P -d)
    fi
  fi
  printf "%s" "${_window_id}"
}

xpns_new_pane_vertical () {
  local _window_id="$1"   ; shift
  local _cell_height="$1" ; shift
  local _speedy_flg="$1"  ; shift
  local _exec_cmd="$1"    ; shift
  local _pane_id=
  if [[ "${_speedy_flg}" -eq 1 ]]; then
    _pane_id="$(${TMUX_XPANES_EXEC} split-window -t "$_window_id" -v -d -l "${_cell_height}" -F '#{pane_id}' -P "${_exec_cmd}")"
  else
    _pane_id="$(${TMUX_XPANES_EXEC} split-window -t "$_window_id" -v -d -l "${_cell_height}" -F '#{pane_id}' -P)"
  fi
  printf "%s\\n" "${_pane_id}"
}

xpns_split_pane_horizontal () {
  local _target_pane_id="$1" ; shift
  local _cell_width="$1"     ; shift
  local _speedy_flg="$1"     ; shift
  local _exec_cmd="$1"       ; shift
  if [[ "${_speedy_flg}" -eq 1 ]]; then
    ${TMUX_XPANES_EXEC} split-window -t "$_target_pane_id" -h -d -l "$_cell_width" "${_exec_cmd}"
  else
    ${TMUX_XPANES_EXEC} split-window -t "$_target_pane_id" -h -d -l "$_cell_width"
  fi
}

xpns_prepare_window () {
  local _window_name="$1"     ; shift
  local _log_flag="$1"        ; shift
  local _title_flag="$1"      ; shift
  local _attach_flg="$1"      ; shift
  local _speedy_flg="$1"      ; shift
  local _await_flg="$1"       ; shift
  local _repstr="$1"          ; shift
  local _cmd_template="$1"    ; shift
  local _args=("$@")
  local _window_height="$XP_WINDOW_HEIGHT"
  local _window_width="$XP_WINDOW_WIDTH"
  local _col="$XP_OPT_CUSTOM_SIZE_COLS"
  local _row="$XP_OPT_CUSTOM_SIZE_ROWS"
  local _cols=("${XP_COLS[@]}")
  local _cols_offset=("${XP_COLS_OFFSETS[@]}")
  local _exec_cmd=
  local _pane_id=
  local _first_pane_id=
  local _window_id=
  local _cell_height=
  local _cell_width=
  local _top_pane_height=
  local _current_pane_width=
  local i=
  local j=
  local _rest_col=
  local _rest_row=
  local _offset=

  _cell_height=$(( ( _window_height - _row + 1 ) / _row ))
  ## Insert first element
  _exec_cmd="${_cmd_template//${_repstr}/${_args[0]}}"
  _exec_cmd="$(xpns_inject_wait_command "${_log_flag}" "${_title_flag}" "${_speedy_flg}" "${_await_flg}" 0 "${_exec_cmd}")"
  _window_id=$(xpns_new_window "${_window_name}" "${_attach_flg}" "${_speedy_flg}" "${_exec_cmd}")
  _first_pane_id=$(${TMUX_XPANES_EXEC} display-message -t "$_window_id" -p -F '#{pane_id}' | head -n 1)

  ## Start from last row
  for (( i = _row - 1 ; i > 0 ; i-- ));do
    _col="${_cols[i]}"
    _cell_width=$(( ( _window_width - _col + 1 ) / _col ))
    xpns_msg_debug "_col=$_col"
    (( _offset = _cols_offset[i] ))
    for (( j = 0 ; j < _col ; j++ ));do
      if (( j == 0 )) ;then
        (( idx = _offset - _col ))
        # Create new row
        # Insert first element of the row first
        _exec_cmd="${_cmd_template//${_repstr}/${_args[idx]}}"
        _exec_cmd="$(xpns_inject_wait_command "${_log_flag}" "${_title_flag}" "${_speedy_flg}" "${_await_flg}" "${idx}" "${_exec_cmd}")"
        _pane_id=$(xpns_new_pane_vertical "${_window_name}" "${_cell_height}" "${_speedy_flg}" "${_exec_cmd}")
      fi
      # Separate row into columns
      if (( j != 0 )) ;then
        (( idx = _offset - j ))
        _exec_cmd="${_cmd_template//${_repstr}/${_args[idx]}}"
        _exec_cmd="$(xpns_inject_wait_command "${_log_flag}" "${_title_flag}" "${_speedy_flg}" "${_await_flg}" "${idx}" "${_exec_cmd}")"
        ## Separate row into columns
        _current_pane_width=$(${TMUX_XPANES_EXEC} display-message -t "$_pane_id" -p '#{pane_width}' | head -n 1)
        _rest_col=$(( _col - j + 1 ))
        _cell_width=$(( ( _current_pane_width - _rest_col + 1 ) / _rest_col ))
        xpns_split_pane_horizontal "$_pane_id" "$_cell_width" "${_speedy_flg}" "${_exec_cmd}"
      fi
    done

    # Adjust height
    _top_pane_height=$(${TMUX_XPANES_EXEC} display-message -t "$_window_id" -p '#{pane_height}' | head -n 1)
    _rest_row=$(( i ))
    xpns_msg_debug "_top_pane_height=$_top_pane_height _rest_row=$_rest_row"
    _cell_height=$(( ( _top_pane_height - _rest_row + 1 ) / _rest_row ))
  done

  # Split first row into columns
  _col="${_cols[0]}"
  _cell_width=$(( ( _window_width - _col + 1 ) / _col ))
  for (( j = 1 ; j < _col ; j++ ));do
    idx=$(( _cols_offset[0] - j ))
    # Adjust width
    _current_pane_width=$(${TMUX_XPANES_EXEC} display-message -t "$_first_pane_id" -p '#{pane_width}' | head -n 1)
    _rest_col=$(( _col - j + 1 ))
    _cell_width=$(( ( _current_pane_width - _rest_col + 1 ) / _rest_col ))
    ## Split top row into columns
    _exec_cmd="${_cmd_template//${_repstr}/${_args[idx]}}"
    _exec_cmd="$(xpns_inject_wait_command "${_log_flag}" "${_title_flag}" "${_speedy_flg}" "${_await_flg}" "${idx}" "${_exec_cmd}")"
    xpns_split_pane_horizontal "${_first_pane_id}" "${_cell_width}" "${_speedy_flg}" "${_exec_cmd}"
  done
}

xpns_is_session_running() {
  local _socket="$1"
  ${TMUX_XPANES_EXEC} -S "${_socket}" list-session > /dev/null 2>&1
}

# Remove unnecessary session files as much as possible
# to let xpanes avoids to load old .tmux.conf.
xpns_clean_session() {
  if [[ "${XP_SOCKET_PATH}" != "${XP_DEFAULT_SOCKET_PATH}" ]]; then
    return
  fi
  # Delete old socket file (xpanes v3.1.0 or before).
  if [[ -e "${XP_DEFAULT_SOCKET_PATH_BASE}" ]]; then
    if ! xpns_is_session_running "${XP_DEFAULT_SOCKET_PATH_BASE}" ;then
      xpns_msg_debug "socket(${XP_DEFAULT_SOCKET_PATH_BASE}) is not running. Remove it"
      rm -f "${XP_DEFAULT_SOCKET_PATH_BASE}"
    fi
  fi
  for _socket in "${XP_CACHE_HOME}"/socket.* ;do
    xpns_msg_debug "file = ${_socket}"
    if ! xpns_is_session_running "${_socket}" ;then
      xpns_msg_debug "socket(${_socket}) is not running. Remove it"
      rm -f "${_socket}"
    else
      xpns_msg_debug "socket(${_socket}) is running. Keep ${_socket}"
    fi
  done
}

#
# Split a new window which was created by tmux into multiple panes.
# Usage:
#    xpns_prepare_preset_layout_window <window name> <offset of index> <number of pane> <attach or not>
#
xpns_prepare_preset_layout_window() {
  local _window_name="$1"     ; shift
  local _pane_base_index="$1" ; shift
  local _log_flag="$1"        ; shift
  local _title_flag="$1"      ; shift
  local _attach_flg="$1"      ; shift
  local _speedy_flg="$1"      ; shift
  local _await_flg="$1"       ; shift
  # Create new window.
  if [[ "${_attach_flg}" -eq 1 ]]; then
    ${TMUX_XPANES_EXEC} new-window -n "${_window_name}"
  else
    # Keep background
    ${TMUX_XPANES_EXEC} new-window -n "${_window_name}" -d
  fi

  # specify a pane which has the youngest number of index.
  ${TMUX_XPANES_EXEC} select-pane -t "${_window_name}.${_pane_base_index}"

  # split window into multiple panes
  xpns_split_window \
    "${_window_name}" \
    "${_log_flag}" \
    "${_title_flag}" \
    "${_speedy_flg}" \
    "${_await_flg}" \
    "${_pane_base_index}" \
    "$@"

  ### If the first pane is still remaining,
  ### panes cannot be organized well.
  # Delete the first pane
  ${TMUX_XPANES_EXEC} kill-pane -t "${_window_name}.${_pane_base_index}"

  # Select second pane here.
  #   If the command gets error, it would most likely be caused by user (XP_ENOPANE).
  #   Suppress error message here and announce it in xpns_execution.
  ${TMUX_XPANES_EXEC} select-pane -t "${_window_name}.${_pane_base_index}" > /dev/null 2>&1
}

# Check whether given command is in the PATH or not.
xpns_check_env() {
  local _cmds="$1"
  while read -r cmd ; do
    if ! type "${cmd}" > /dev/null 2>&1; then
      if [[ "${cmd}" == "tmux" ]] && [[ "${TMUX_XPANES_EXEC}" == "tmux" ]]; then
        xpns_msg_error "${cmd} is required. Install ${cmd} or set TMUX_XPANES_EXEC variable."
        exit ${XP_ENOCMD}
      elif [[ "${cmd}" != "tmux" ]]; then
        xpns_msg_error "${cmd} is required."
        exit ${XP_ENOCMD}
      fi
    fi
  done < <(echo "${_cmds}" | tr ' ' '\n')

  if ! mkdir -p "${XP_CACHE_HOME}";then
    xpns_msg_warning "failed to create cache directory '${XP_CACHE_HOME}'."
  fi

  # Do not omit this part, this is used by testing.
  TMUX_XPANES_TMUX_VERSION="${TMUX_XPANES_TMUX_VERSION:-$(xpns_get_tmux_version)}"
  if ( xpns_tmux_is_greater_equals \
    "${XP_SUPPORT_TMUX_VERSION_LOWER}" \
    "${TMUX_XPANES_TMUX_VERSION}" ) ;then
    : "Supported tmux version"
  else
    xpns_msg_warning \
"'${XP_THIS_FILE_NAME}' may not work correctly! Please check followings.
* tmux is installed correctly.
* Supported tmux version is installed.
  Version ${XP_SUPPORT_TMUX_VERSION_LOWER} and over is officially supported."
  fi

  return 0
}

xpns_pipe_filter() {
  local _number="${1-}"
  if [[ -z "${_number-}" ]]; then
    cat
  else
    xargs -n "${_number}"
  fi
}

xpns_set_args_per_pane() {
  local _pane_num="$1"; shift
  local _filtered_args=()
  while read -r _line; do
    _filtered_args+=("${_line}")
  done < <(xargs -n "${_pane_num}" <<<"$(xpns_arr2args "${XP_ARGS[@]}")")
  XP_ARGS=("${_filtered_args[@]}")
}

xpns_get_window_height_width() {
  local _height=
  local _width=
  local _result=
  local _dev=
  local _pattern='^([0-9]+)[ \t]+([0-9]+)$'

  if ! type stty > /dev/null 2>&1; then
    xpns_msg_debug "'stty' does not exist: Failed to get window height and size. Skip checking"
    return 1
  fi

  ## This condition is used for unit testing
  if [[ -z "${XP_IS_PIPE_MODE-}" ]]; then
    if [[ ! -t 0 ]]; then
      XP_IS_PIPE_MODE=1
    fi
  fi
  if [[ $XP_IS_PIPE_MODE -eq 0 ]]; then
    if _result=$(stty size 2> /dev/null) && [[ "$_result" =~ $_pattern ]];then
      _height="${BASH_REMATCH[1]}"
      _width="${BASH_REMATCH[2]}"
      xpns_msg_debug "window height: $_height, width: $_width"
      printf "%s\\n" "$_height $_width"
      return 0
    fi
  else
    if ! type ps > /dev/null 2>&1 ;then
      xpns_msg_debug "'ps' does not exist: Failed to get window height and size. Skip checking"
      return 1
    fi
    { read -r; read -r _dev; } < <(ps -o tty -p $$)
    ## If it's Linux, -F option is used
    if _result=$(stty -F "/dev/${_dev}" size 2> /dev/null) && [[ "$_result" =~ $_pattern ]];then
      _height="${BASH_REMATCH[1]}"
      _width="${BASH_REMATCH[2]}"
      xpns_msg_debug "window height: $_height, width: $_width"
      printf "%s\\n" "$_height $_width"
      return 0
    fi
    ## If it's BSD, macOS, -F option is used
    if _result=$(stty -f "/dev/${_dev}" size 2> /dev/null) && [[ "$_result" =~ $_pattern ]];then
      _height="${BASH_REMATCH[1]}"
      _width="${BASH_REMATCH[2]}"
      xpns_msg_debug "window height: $_height, width: $_width"
      printf "%s\\n" "$_height $_width"
      return 0
    fi
    return 1
  fi
  return 1
}

xpns_check_cell_size_bulk() {
  local _cell_num="$1"    ; shift
  local _bulk_cols="$1"   ; shift
  local _win_height="$1"  ; shift
  local _win_width="$1"   ; shift
  local _ignore_flag="$1" ; shift
  local _all_cols=()
  # shellcheck disable=SC2178
  local _cols=0
  local _rows=0
  local _sum_cell=0
  IFS="," read -r -a _all_cols <<< "${_bulk_cols}"
  _rows="${#_all_cols[@]}"
  for i in "${_all_cols[@]}"; do
    (( i >= _cols )) && (( _cols = i ))
    (( _sum_cell = _sum_cell + i ))
  done
  if (( _sum_cell != _cell_num )) ;then
    xpns_msg_error "Number of cols does not equals to the number of arguments."
    xpns_msg_error "Expected (# of args) : $_cell_num, Actual (--bulk-cols) : $_sum_cell)."
    return ${XP_ELAYOUT:-6}
  fi
  local cell_height=$(( ( _win_height - _rows + 1 ) / _rows ))
  local cell_width=$(( ( _win_width - _cols + 1 ) / _cols ))

  ## Display basic information
  xpns_msg_debug "Window: { Height: $_win_height, Width: $_win_width }"
  xpns_msg_debug "Cell: { Height: $cell_height, Width: $cell_width }"
  xpns_msg_debug "# Of Panes: ${_cell_num}"
  xpns_msg_debug "         | Row[0] --...--> Row[MAX]"
  xpns_msg_debug "    -----+------------------------..."
  xpns_msg_debug "    Col[]| ${_all_cols[*]}"
  xpns_msg_debug "    -----+------------------------..."

  if [[ "$_ignore_flag" -ne 1 ]] && ( (( cell_height < 2 )) || (( cell_width < 2 )) ); then
    xpns_msg_error "Expected pane size is too small (height: $cell_height lines, width: $cell_width chars)"
    return ${XP_ESMLPANE:-7}
  fi
  printf "%s\\n" "${_cols} ${_rows} ${_all_cols[*]}"
}

xpns_check_cell_size() {
  local _cell_num="$1"    ; shift
  local _cols="$1"        ; shift
  local _rows="$1"        ; shift
  local _win_height="$1"  ; shift
  local _win_width="$1"   ; shift
  local _ignore_flag="$1" ; shift
  local _all_cols_num=
  local _all_rows=()

  if [[ -n "${_cols-}" ]] && [[ -n "${_rows-}" ]];then
    xpns_msg_warning "Both col size and row size are provided. Col size is preferentially going to be applied."
  fi
  ## if col is only defined
  if [[ -n "${_cols-}" ]] ;then
    read -r _cols _rows < <(xpns_adjust_col_row "${_cols-}" 0 "${_cell_num}")
    IFS=" " read -r -a _all_rows <<< "$(xpns_divide_equally "${_cell_num}" "${_cols}")"
    _all_cols_num="$(xpns_nums_transpose "${_all_rows[@]}")"

  ## if row is only defined
  elif [[ -n "${_rows-}" ]] ;then
    read -r _cols _rows < <(xpns_adjust_col_row 0 "${_rows-}" "${_cell_num}")
    _all_cols_num="$(xpns_divide_equally "${_cell_num}" "${_rows}")"

  ## if both are undefined
  else
    read -r _cols _rows < <(xpns_adjust_col_row 0 0 "${_cell_num}")
    _all_cols_num="$(xpns_divide_equally "${_cell_num}" "${_rows}")"
  fi

  local cell_height=$(( ( _win_height - _rows + 1 ) / _rows ))
  local cell_width=$(( ( _win_width - _cols + 1 ) / _cols ))

  ## Display basic information
  xpns_msg_debug "Window: { Height: $_win_height, Width: $_win_width }"
  xpns_msg_debug "Cell: { Height: $cell_height, Width: $cell_width }"
  xpns_msg_debug "# Of Panes: ${_cell_num}"
  xpns_msg_debug "         | Row[0] --...--> Row[MAX]"
  xpns_msg_debug "    -----+------------------------..."
  xpns_msg_debug "    Col[]| ${_all_cols_num}"
  xpns_msg_debug "    -----+------------------------..."

  if [[ "$_ignore_flag" -ne 1 ]] && ( (( cell_height < 2 )) || (( cell_width < 2 )) ); then
    xpns_msg_error "Expected pane size is too small (height: $cell_height lines, width: $cell_width chars)"
    return "${XP_ESMLPANE:-7}"
  fi
  printf "%s\\n" "${_cols} ${_rows} ${_all_cols_num}"
}

# Execute from Normal mode1
xpns_pre_execution() {
  local _opts4args=""
  local _args4args=""

  if [[ ${XP_OPT_EXTRA} -eq 1 ]];then
    xpns_msg_error "'-x' must be used within the running tmux session."
    exit ${XP_EINVAL}
  fi

  # Run as best effort.
  # Because after the tmux session is created, cols and rows would be provided by tmux.
  IFS=" " read -r XP_WINDOW_HEIGHT XP_WINDOW_WIDTH < <(xpns_get_window_height_width) && {
    local _arg_num="${#XP_ARGS[@]}"
    local _cell_num _tmp_col_row_cols _tmp_cols
    if [[ -n "$XP_MAX_PANE_ARGS" ]] && (( XP_MAX_PANE_ARGS > 1 ));then
      _cell_num=$(( _arg_num / XP_MAX_PANE_ARGS ))
    else
      _cell_num="${_arg_num}"
    fi
    if [[ -n "${XP_OPT_BULK_COLS}" ]]; then
      _tmp_col_row_cols="$(xpns_check_cell_size_bulk \
        "${_cell_num}" \
        "${XP_OPT_BULK_COLS}" \
        "${XP_WINDOW_HEIGHT}" \
        "${XP_WINDOW_WIDTH}" \
        "${XP_OPT_IGNORE_SIZE_LIMIT:-0}")"
      local _exit_status="$?"
      [[ $_exit_status -eq ${XP_ELAYOUT} ]] && exit ${XP_ELAYOUT}
      [[ $_exit_status -eq ${XP_ESMLPANE} ]] && exit ${XP_ESMLPANE}
    else
      _tmp_col_row_cols="$(xpns_check_cell_size \
        "${_cell_num}" \
        "${XP_OPT_CUSTOM_SIZE_COLS-}" \
        "${XP_OPT_CUSTOM_SIZE_ROWS-}" \
        "${XP_WINDOW_HEIGHT}" \
        "${XP_WINDOW_WIDTH}" \
        "${XP_OPT_IGNORE_SIZE_LIMIT:-0}")"
      [[ $? -eq ${XP_ESMLPANE} ]] && exit ${XP_ESMLPANE}
    fi

    IFS=" " read -r XP_OPT_CUSTOM_SIZE_COLS XP_OPT_CUSTOM_SIZE_ROWS _tmp_cols <<< "$_tmp_col_row_cols"
    IFS=" " read -r -a XP_COLS <<< "${_tmp_cols}"
    IFS=" " read -r -a XP_COLS_OFFSETS <<< "$(printf "%s\\n" "${XP_COLS[*]}" | xpns_nums_accumulate_sum)"
    xpns_msg_debug "Options: $(xpns_arr2args "${XP_OPTIONS[@]}")"
    xpns_msg_debug "Arguments: $(xpns_arr2args "${XP_ARGS[@]}")"
  }

  # Append -- flag.
  # Because any arguments may have `-`
  if [[ ${XP_NO_OPT} -eq 1 ]]; then
    XP_ARGS=("--" "${XP_ARGS[@]}")
  fi

  # If there is any options, escape them.
  if [[ -n "${XP_OPTIONS[*]-}" ]]; then
    _opts4args=$(xpns_arr2args "${XP_OPTIONS[@]}")
  fi
  _args4args=$(xpns_arr2args "${XP_ARGS[@]}")

  # Run as best effort
  xpns_clean_session || true

  # Create new session.
  ${TMUX_XPANES_EXEC} -S "${XP_SOCKET_PATH}" new-session \
    -s "${XP_SESSION_NAME}" \
    -n "${XP_TMP_WIN_NAME}" \
    -d "${XP_ABS_THIS_FILE_NAME} ${_opts4args} ${_args4args}"

  # Avoid attaching (for unit testing).
  if [[ ${XP_OPT_ATTACH} -eq 1 ]]; then
    if ! ${TMUX_XPANES_EXEC} -S "${XP_SOCKET_PATH}" attach-session -t "${XP_SESSION_NAME}" \
      && [[ ${XP_IS_PIPE_MODE} -eq 1 ]]; then
      ## In recovery case, overwrite trap to keep socket file
      trap 'rm -f "${XP_CACHE_HOME}"/__xpns_*$$;' EXIT

      xpns_msg "Recovery" \
"Execute below command line to re-attach the new session.

${TMUX_XPANES_EXEC} -S ${XP_SOCKET_PATH} attach-session -t ${XP_SESSION_NAME}

"
      exit ${XP_ETTY}
    fi
  fi
}

# Execute from inside of tmux session
xpns_execution() {
  local _pane_base_index=
  local _window_name=
  local _last_args_idx=
  local _def_allow_rename=
  local _pane_count=0

  if [[ ${XP_IS_PIPE_MODE} -eq 0 ]] && [[ -n "${XP_MAX_PANE_ARGS-}" ]];then
    xpns_set_args_per_pane "${XP_MAX_PANE_ARGS}"
  fi

  ## Fix window size and define pane size
  {
    local  _tmp_col_row_cols _tmp_cols
    IFS=" " read -r XP_WINDOW_HEIGHT XP_WINDOW_WIDTH < \
      <(${TMUX_XPANES_EXEC} display-message -p '#{window_height} #{window_width}')
    if [[ -n "${XP_OPT_BULK_COLS}" ]]; then
      _tmp_col_row_cols="$(xpns_check_cell_size_bulk \
        "${#XP_ARGS[@]}" \
        "${XP_OPT_BULK_COLS}" \
        "${XP_WINDOW_HEIGHT}" \
        "${XP_WINDOW_WIDTH}" \
        "${XP_OPT_IGNORE_SIZE_LIMIT:-0}")"
      local _exit_status="$?"
      [[ $_exit_status -eq ${XP_ELAYOUT} ]] && exit ${XP_ELAYOUT}
      [[ $_exit_status -eq ${XP_ESMLPANE} ]] && exit ${XP_ESMLPANE}
    else
      _tmp_col_row_cols="$(xpns_check_cell_size \
        "${#XP_ARGS[@]}" \
        "${XP_OPT_CUSTOM_SIZE_COLS-}" \
        "${XP_OPT_CUSTOM_SIZE_ROWS-}" \
        "${XP_WINDOW_HEIGHT}" \
        "${XP_WINDOW_WIDTH}" \
        "${XP_OPT_IGNORE_SIZE_LIMIT:-0}")"
      [[ $? -eq ${XP_ESMLPANE} ]] && exit ${XP_ESMLPANE}
    fi
    IFS=" " read -r XP_OPT_CUSTOM_SIZE_COLS XP_OPT_CUSTOM_SIZE_ROWS _tmp_cols <<< "$_tmp_col_row_cols"
    IFS=" " read -r -a XP_COLS <<< "${_tmp_cols}"
    IFS=" " read -r -a XP_COLS_OFFSETS <<< "$(printf "%s\\n" "${XP_COLS[*]}" | xpns_nums_accumulate_sum)"
    xpns_msg_debug "Options: $(xpns_arr2args "${XP_OPTIONS[@]}")"
    xpns_msg_debug "Arguments: $(xpns_arr2args "${XP_ARGS[@]}")"
  }

  _pane_base_index=$(xpns_get_global_tmux_conf 'pane-base-index')
  _last_args_idx=$((${#XP_ARGS[@]} - 1))
  _def_allow_rename="$(xpns_get_global_tmux_conf 'allow-rename')"

  xpns_suppress_allow_rename "${_def_allow_rename-}"
  XP_CMD_UTILITY="$(xpns_get_joined_begin_commands "${XP_CMD_UTILITY}")"

  if [[ ${XP_OPT_EXTRA} -eq 1 ]];then
    # Reuse existing window name
    # tmux 1.6 does not support -F option
    _window_name="$( ${TMUX_XPANES_EXEC} display -p -F "#{window_id}" )"
    _pane_count="$( ${TMUX_XPANES_EXEC} list-panes | grep -c . )"
    _pane_base_index=$(( _pane_base_index + _pane_count - 1 ))
    _pane_active_pane_id=$(${TMUX_XPANES_EXEC} display -p -F "#{pane_id}")
  else
    _window_name=$(
      xpns_generate_window_name \
        "${XP_EMPTY_STR}" \
        "${XP_ARGS[0]}" \
        | xpns_value2key)
  fi

  ## --------------------
  # Prepare window and panes
  ## --------------------
  if [[ ${XP_OPT_EXTRA} -eq 1 ]];then
    xpns_prepare_extra_panes \
      "${_window_name}" \
      "${_pane_base_index}" \
      "${XP_OPT_LOG_STORE}" \
      "${XP_OPT_SET_TITLE}" \
      "${XP_OPT_SPEEDY}" \
      "${XP_OPT_SPEEDY_AWAIT}" \
      "${XP_REPSTR}" \
      "${XP_CMD_UTILITY}" \
      "${XP_ARGS[@]}"
  elif [[ ${XP_OPT_USE_PRESET_LAYOUT} -eq 1 ]];then
    xpns_prepare_preset_layout_window \
      "${_window_name}" \
      "${_pane_base_index}" \
      "${XP_OPT_LOG_STORE}" \
      "${XP_OPT_SET_TITLE}" \
      "${XP_OPT_ATTACH}" \
      "${XP_OPT_SPEEDY}" \
      "${XP_OPT_SPEEDY_AWAIT}" \
      "${XP_REPSTR}" \
      "${XP_CMD_UTILITY}" \
      "${XP_ARGS[@]}"
  elif [[ ${XP_OPT_USE_PRESET_LAYOUT} -eq 0 ]];then
    xpns_prepare_window \
      "${_window_name}" \
      "${XP_OPT_LOG_STORE}" \
      "${XP_OPT_SET_TITLE}" \
      "${XP_OPT_ATTACH}" \
      "${XP_OPT_SPEEDY}" \
      "${XP_OPT_SPEEDY_AWAIT}" \
      "${XP_REPSTR}" \
      "${XP_CMD_UTILITY}" \
      "${XP_ARGS[@]}"
  fi

  ## With -ss option, it is possible to close all the panes as of here.
  ## Check status of the window. If no window exists, there is nothing to do execpt to exit.
  xpns_msg_debug "xpns_is_window_alive:1: After window separation"
  xpns_is_window_alive "${_window_name}" "${XP_OPT_SPEEDY_AWAIT}" "${_def_allow_rename-}"

  if [[ ${XP_OPT_EXTRA} -eq 1 ]];then
    # Set offset to avoid sending command to the original pane.
    _pane_base_index=$((_pane_base_index + 1))
    # Avoid to make layout even-horizontal even if there are many panes.
    # in xpns_organize_panes
    _last_args_idx=$((_last_args_idx + _pane_count))
    # Re-select the windown that was active before.
    ${TMUX_XPANES_EXEC} select-pane -t "${_window_name}.${_pane_active_pane_id}"
  fi

  if [[ ${XP_OPT_LOG_STORE} -eq 1 ]]; then
    xpns_enable_logging \
      "${_window_name}" \
      "${_pane_base_index}" \
      "${TMUX_XPANES_LOG_DIRECTORY}" \
      "${TMUX_XPANES_LOG_FORMAT}" \
      "${XP_EMPTY_STR}" \
      "${XP_ARGS[@]}"

    if [[ $XP_OPT_SPEEDY -eq 1 ]]; then
      xpns_notify_logging \
        "${_window_name}" \
        "${XP_ARGS[@]}"
    fi
  fi

  xpns_msg_debug "xpns_is_window_alive:2: After logging"
  xpns_is_window_alive "${_window_name}" "${XP_OPT_SPEEDY_AWAIT}" "${_def_allow_rename-}"

  # Set pane titles for each pane.
  if xpns_is_pane_title_required "${XP_OPT_SET_TITLE}" "${XP_OPT_EXTRA}" ;then
    xpns_set_titles \
      "${_window_name}" \
      "${_pane_base_index}" \
      "${XP_ARGS[@]}"
  fi

  if [[ $XP_OPT_SPEEDY -eq 1 ]];then
    xpns_notify_sync \
      "${_window_name}" \
      "${XP_ARGS[@]}"
  fi

  xpns_msg_debug "xpns_is_window_alive:3: After setting title"
  xpns_is_window_alive "${_window_name}" "${XP_OPT_SPEEDY_AWAIT}" "${_def_allow_rename-}"

  # Sending operations for each pane.
  # With -s option, command is already sent.
  if [[ $XP_OPT_SPEEDY -eq 0 ]]; then
    xpns_send_commands \
      "${_window_name}" \
      "${_pane_base_index}" \
      "${XP_REPSTR}" \
      "${XP_CMD_UTILITY}" \
      "${XP_ARGS[@]}"
  fi

  xpns_msg_debug "xpns_is_window_alive:4: After sending commands"
  xpns_is_window_alive "${_window_name}" "${XP_OPT_SPEEDY_AWAIT}" "${_def_allow_rename-}"

  ## With -l <layout>, panes are organized.
  ## As well as -x, they are re-organized.
  if [[ $XP_OPT_USE_PRESET_LAYOUT -eq 1 ]] || [[ ${XP_OPT_EXTRA} -eq 1 ]]; then
    xpns_organize_panes \
      "${_window_name}" \
      "${_last_args_idx}"
  fi

  # Enable broadcasting
  if [[ ${XP_OPT_IS_SYNC} -eq 1 ]] && [[ ${XP_OPT_EXTRA} -eq 0 ]]; then
    ${TMUX_XPANES_EXEC} \
      set-window-option -t "${_window_name}" \
      synchronize-panes on
  fi

  ## In case of -t option
  if [[ ${XP_OPT_SET_TITLE} -eq 1 ]] && [[ ${XP_OPT_CHANGE_BORDER} -eq 1 ]]; then
    # Set border format
    ${TMUX_XPANES_EXEC} \
      set-window-option -t "${_window_name}" \
      pane-border-format "${TMUX_XPANES_PANE_BORDER_FORMAT}"
    # Show border status
    ${TMUX_XPANES_EXEC} \
      set-window-option -t "${_window_name}" \
      pane-border-status "${TMUX_XPANES_PANE_BORDER_STATUS}"
  fi

  # In case of -x, this statement is skipped to keep the original window name
  if [[ ${XP_OPT_EXTRA} -eq 0 ]];then
    # Restore original window name.
    ${TMUX_XPANES_EXEC} \
      rename-window -t "${_window_name}" \
      -- "$(printf "%s\\n" "${_window_name}" | xpns_key2value)"
  fi

  xpns_restore_allow_rename "${_def_allow_rename-}"
}

## ----------------
# Arrange options for pipe mode
#  * argument -> command
#  * stdin -> argument
## ----------------
xpns_switch_pipe_mode() {
  local _pane_num4new_term=""
  if [[ -n "${XP_ARGS[*]-}" ]] && [[ -n "${XP_CMD_UTILITY-}" ]]; then
    xpns_msg_error "Both arguments and other options (like '-c', '-e') which updates <command> are given."
    exit ${XP_EINVAL}
  fi

  if [[ -z "${TMUX-}" ]]; then
    xpns_msg_warning "Attached session is required for 'Pipe mode'."
    # This condition is used when the following situations.
    #   * Enter from outside of tmux session(Normal mode1)
    #   * Pipe mode.
    #   * -n option.
    #
    # For example:
    #     (Normal mode1)$ echo {a..g} | ./xpanes -n 2
    # => This will once create the new window like this.
    #     (inside of tmux session)$ ./xpanes '-n' '2' 'a' 'b' 'c' 'd' 'e' 'f' 'g'
    #     => After the window is closed, following panes would be left.
    #     (pane 1)$ echo a b
    #     (pane 2)$ echo c d
    #     (pane 3)$ echo e f
    #     (pane 4)$ echo g
    # In order to create such the query,
    # separate all the argument into minimum tokens
    # with xargs -n 1
    if [[ -n "${XP_MAX_PANE_ARGS-}" ]]; then
      _pane_num4new_term=1
    fi
  fi

  while read -r line;
  do
    XP_STDIN+=("${line}")
  done < <(cat | xpns_rm_empty_line | \
    xpns_pipe_filter "${_pane_num4new_term:-${XP_MAX_PANE_ARGS}}")


  # Merge them into command.
  if [[ -n "${XP_ARGS[*]-}" ]]; then
    # Attention: It might be wrong result if IFS is changed.
    XP_CMD_UTILITY="${XP_ARGS[*]}"
  fi

  # If there is empty -I option or user does not assign the <repstr>,
  # Append the space and <repstr> at the end of the <command>
  # This is same as the xargs command of GNU.
  # i.e,
  #   $ echo 10 | xargs seq
  #     => seq 10
  # Whith is same as
  #   $ echo 10 | xargs -I@ seq @
  #     => seq 10
  if [[ -z "${XP_REPSTR}" ]]; then
    XP_REPSTR="${XP_DEFAULT_REPSTR}"
    if [[ -n "${XP_ARGS[*]-}" ]]; then
      XP_CMD_UTILITY="${XP_ARGS[*]-} ${XP_REPSTR}"
    fi
  fi

  # Deal with stdin as arguments.
  XP_ARGS=("${XP_STDIN[@]-}")
}

xpns_layout_short2long() {
  sed \
    -e 's/^t$/tiled/' \
    -e 's/^eh$/even-horizontal/' \
    -e 's/^ev$/even-vertical/' \
    -e 's/^mh$/main-horizontal/' \
    -e 's/^mv$/main-vertical/' \
    -e ';'
}

xpns_is_valid_layout() {
  local _layout="${1-}"
  local _pat='^(tiled|even-horizontal|even-vertical|main-horizontal|main-vertical)$'
  if ! [[ $_layout =~ $_pat ]]  ; then
    xpns_msg_error "Invalid layout '${_layout}'."
    exit ${XP_ELAYOUT}
  fi
}

xpns_warning_before_extra() {
  local _ans=
  local _synchronized=
  _synchronized="$(xpns_get_local_tmux_conf "synchronize-panes")"
  if [[ "on" == "${_synchronized}" ]];then
    xpns_msg_warning "Panes are now synchronized.
'-x' option may cause unexpected behavior on the synchronized panes."
    printf "Are you really sure? [y/n]: "
    read -r _ans
    if ! [[ "${_ans-}" =~ ^[yY]  ]]; then
      return 1
    fi
  fi
}

xpns_load_flag_options() {
  if [[ "$1" =~ h ]]; then
    xpns_usage
    exit 0
  fi
  if [[ "$1" =~ V ]]; then
    xpns_version
    exit 0
  fi
  if [[ "$1" =~ x ]]; then
    XP_OPT_EXTRA=1
    XP_OPT_USE_PRESET_LAYOUT=1 ## Layout presets must be used with -x
    if ! xpns_warning_before_extra; then
      exit ${XP_EINTENT}
    fi
  fi
  if [[ "$1" =~ d ]]; then
    XP_OPT_IS_SYNC=0
  fi
  if [[ "$1" =~ e ]]; then
    XP_REPSTR="{}"
    XP_CMD_UTILITY="{}"
  fi
  if [[ "$1" =~ t ]]; then
    if ( xpns_tmux_is_greater_equals 2.3 ) ; then
      XP_OPT_SET_TITLE=1
      XP_OPT_CHANGE_BORDER=1
    else
      xpns_msg_warning "-t option cannot be used by tmux version less than 2.3. Disabled."
      sleep 1
    fi
  fi
  if [[ "$1" =~ s ]]; then
    XP_OPT_SPEEDY=1
    XP_OPT_SPEEDY_AWAIT=1
  fi
  if [[ "$1" =~ ss ]]; then
    XP_OPT_SPEEDY_AWAIT=0
  fi
  return 1
}

xpns_load_arg_options() {
  # Extract flag options only.
  local _pattern=
  xpns_load_flag_options "$(xpns_extract_matched "$1" "^-${XP_FLAG_OPTIONS}+")" > /dev/null
  if [[ "$1" =~ ^-${XP_FLAG_OPTIONS}*I ]]; then
    # Behavior like this.
    # -IAAA       -- XP_REPSTR="AAA"
    # -I AAA BBB  -- XP_REPSTR="AAA", XP_ARGS=("BBB")
    # -I"AAA BBB" -- XP_REPSTR="AAA BBB"
    # -IAAA BBB   -- XP_REPSTR="AAA", XP_ARGS=("BBB")
    # -I -d ...   -- XP_REPSTR=""
    _pattern="^-${XP_FLAG_OPTIONS}*I(.+)"
    if [[ "$1" =~ $_pattern ]]; then
      XP_REPSTR="${BASH_REMATCH[1]}"
      return 0
    elif ! [[ "$2" =~ ^-.* ]]; then
      XP_REPSTR="$2"
      return 0
    else
      xpns_msg_error "invalid argument '$2' for -I option"
      exit ${XP_EINVAL}
    fi
  elif [[ "$1" =~ ^-${XP_FLAG_OPTIONS}*l ]]; then
    _pattern="^-${XP_FLAG_OPTIONS}*l(.+)"
    if [[ "$1" =~ $_pattern ]]; then
      XP_OPT_USE_PRESET_LAYOUT=1
      XP_LAYOUT="$(cat <<<"${BASH_REMATCH[1]}" | xpns_layout_short2long)"
      xpns_is_valid_layout "${XP_LAYOUT}"
      return 0
    elif ! [[ "$2" =~ ^-.* ]]; then
      XP_OPT_USE_PRESET_LAYOUT=1
      XP_LAYOUT="$(cat <<<"$2" |  xpns_layout_short2long )"
      xpns_is_valid_layout "${XP_LAYOUT}"
      return 0
    else
      xpns_msg_error "invalid argument '$2' for -l option"
      exit ${XP_EINVAL}
    fi
  elif [[ "$1" =~ ^-${XP_FLAG_OPTIONS}*c ]]; then
    _pattern="^-${XP_FLAG_OPTIONS}*c(.+)"
    if [[ "$1" =~ $_pattern ]]; then
      XP_CMD_UTILITY="${BASH_REMATCH[1]}"
      XP_OPT_CMD_UTILITY=1
      return 0
    elif ! [[ "$2" =~ ^-.* ]]; then
      XP_CMD_UTILITY="$2"
      XP_OPT_CMD_UTILITY=1
      return 0
    else
      xpns_msg_error "invalid argument '$2' for -c option"
      exit ${XP_EINVAL}
    fi
  elif [[ "$1" =~ ^-${XP_FLAG_OPTIONS}*n ]]; then
    _pattern="^-${XP_FLAG_OPTIONS}*n([0-9]+)"
    if [[ "$1" =~ $_pattern ]]; then
      XP_MAX_PANE_ARGS="${BASH_REMATCH[1]}"
      return 0
    elif [[ "$2" =~ ^[0-9]+$ ]]; then
      XP_MAX_PANE_ARGS="$2"
      return 0
    else
      xpns_msg_error "invalid argument '$2' for -n option"
      exit ${XP_EINVAL}
    fi
  elif [[ "$1" =~ ^-${XP_FLAG_OPTIONS}*S ]]; then
    _pattern="^-${XP_FLAG_OPTIONS}*S(.+)"
    if [[ "$1" =~ $_pattern ]]; then
      XP_SOCKET_PATH="${BASH_REMATCH[1]}"
      return 0
    elif ! [[ "$2" =~ ^-.* ]]; then
      XP_SOCKET_PATH="$2"
      return 0
    else
      xpns_msg_error "invalid argument '$2' for -S option"
      exit ${XP_EINVAL}
    fi
  elif [[ "$1" =~ ^-${XP_FLAG_OPTIONS}*C ]]; then
    _pattern="^-${XP_FLAG_OPTIONS}*C([0-9]+)"
    if [[ "$1" =~ $_pattern ]]; then
      XP_OPT_CUSTOM_SIZE_COLS="${BASH_REMATCH[1]}"
      return 0
    elif [[ "$2" =~ ^[0-9]+$ ]];then
      XP_OPT_CUSTOM_SIZE_COLS="$2"
      return 0
    else
      xpns_msg_error "invalid argument '$2' for -C option"
      exit ${XP_EINVAL}
    fi
  elif [[ "$1" =~ ^-${XP_FLAG_OPTIONS}*R ]]; then
    _pattern="^-${XP_FLAG_OPTIONS}*R([0-9]+)"
    if [[ "$1" =~ $_pattern ]]; then
      XP_OPT_CUSTOM_SIZE_ROWS="${BASH_REMATCH[1]}"
      return 0
    elif [[ "$2" =~ ^[0-9]+$ ]];then
      XP_OPT_CUSTOM_SIZE_ROWS="$2"
      return 0
    else
      xpns_msg_error "invalid argument '$2' for -R option"
      exit ${XP_EINVAL}
    fi
  elif [[ "$1" =~ ^-${XP_FLAG_OPTIONS}*B ]]; then
    _pattern="^-${XP_FLAG_OPTIONS}*B(.+)"
    if [[ "$1" =~ $_pattern ]]; then
      XP_BEGIN_ARGS+=("${BASH_REMATCH[1]}")
      return 0
    else
      XP_BEGIN_ARGS+=("$2")
      return 0
    fi
  fi
  return 0
}

xpns_load_long_options() {
  if [[ "$1" =~ ^--help$ ]]; then
    xpns_usage
    exit 0
  elif [[ "$1" =~ ^--version$ ]]; then
    xpns_version
    exit 0
  elif [[ "$1" =~ ^--desync$ ]]; then
    XP_OPT_IS_SYNC=0
    return 1
  elif [[ "$1" =~ ^--log-format=.*$ ]]; then
    XP_OPT_LOG_STORE=1
    TMUX_XPANES_LOG_FORMAT="${1#--log-format=}"
    return 1
  elif [[ "$1" =~ ^--log ]]; then
    XP_OPT_LOG_STORE=1
    if [[ "$1" =~ ^--log=.*$  ]]; then
      TMUX_XPANES_LOG_DIRECTORY="${1#--log=}"
    fi
    return 1
  elif [[ "$1" =~ ^--ssh$ ]]; then
    XP_CMD_UTILITY="${XP_SSH_CMD_UTILITY}"
    # Enable -t option as well
    XP_OPT_SET_TITLE=1
    XP_OPT_CHANGE_BORDER=1
    # Enable -s option
    XP_OPT_SPEEDY=1
    XP_OPT_SPEEDY_AWAIT=1
    return 1
  elif [[ "$1" =~ ^--stay$ ]]; then
    XP_OPT_ATTACH=0
    return 1
  elif [[ "$1" =~ ^--cols=[0-9]+$ ]]; then
    XP_OPT_CUSTOM_SIZE_COLS="${1#--cols=}"
    return 1
  elif [[ "$1" =~ ^--rows=[0-9]+$ ]]; then
    XP_OPT_CUSTOM_SIZE_ROWS="${1#--rows=}"
    return 1
  elif [[ "$1" =~ ^--bulk-cols=[0-9,]*[0-9]+$ ]]; then
    XP_OPT_BULK_COLS="${1#--bulk-cols=}"
    return 1
  elif [[ "$1" =~ ^--debug$ ]]; then
    XP_OPT_DEBUG=1
    return 1
  elif [[ "$1" =~ ^--dry-run$ ]]; then # For unit testing
    XP_OPT_DRY_RUN=1
    return 1
  elif [[ "$1" =~ ^--ignore-size-limit$ ]]; then
    XP_OPT_IGNORE_SIZE_LIMIT=1
    return 1

  ## ----------------
  # Other options
  ## ----------------
  else
    xpns_msg_error "invalid option -- '${1#--}'"
    xpns_usage_warn
    exit ${XP_EINVAL}
  fi
}

xpns_parse_options() {
  while (( $# > 0 )); do
    case "$1" in
      --)
      if [[ ${XP_NO_OPT} -eq 1 ]]; then
        XP_ARGS+=("$1")
        shift
      else
        # Disable any more options
        XP_NO_OPT=1
        shift
      fi
      ;;
      ## ----------------
      # Long options
      ## ----------------
      --*)
      if [[ ${XP_NO_OPT} -eq 1 ]]; then
        XP_ARGS+=("$1")
        shift
      else
        local _shift_count="0"
        xpns_load_long_options "$@"
        _shift_count="$?"
        [[ "${_shift_count}" = "1" ]] && XP_OPTIONS+=("$1") && shift
      fi
      ;;
      ## ----------------
      # Short options
      ## ----------------
      -*)
      if [[ ${XP_NO_OPT} -eq 1 ]]; then
        XP_ARGS+=("$1")
        shift
      else
        local _shift_count="0"
        if [[ "$1" =~ ^-${XP_FLAG_OPTIONS}*${XP_ARG_OPTIONS}. ]];then
          xpns_load_arg_options "$@"
          XP_OPTIONS+=("$1") && shift
        elif [[ "$1" =~ ^-${XP_FLAG_OPTIONS}*${XP_ARG_OPTIONS}$ ]] && [[ -n "${2-}" ]];then
          xpns_load_arg_options "$@"
          _shift_count="$?"
          XP_OPTIONS+=("$1" "$2") && shift && shift
        elif [[ "$1" =~ ^-${XP_FLAG_OPTIONS}+$  ]];then
          xpns_load_flag_options "$1"
          XP_OPTIONS+=("$1") && shift
        ## ----------------
        # Other options
        ## ----------------
        else
          xpns_msg_error "Invalid option -- '${1#-}'"
          xpns_usage_warn
          exit ${XP_EINVAL}
        fi
      fi
      ;;
      ## ----------------
      # Other arguments
      ## ----------------
      *)
      XP_ARGS+=("$1")
      XP_NO_OPT=1
      shift
      ;;
    esac
  done

  # If there is any standard input from pipe,
  # 1 line handled as 1 argument.
  if [[ ! -t 0 ]]; then
    XP_IS_PIPE_MODE=1
    xpns_switch_pipe_mode
  fi

  # When no argument arr given, exit.
  if [[ -z "${XP_ARGS[*]-}" ]]; then
    xpns_msg_error "No arguments."
    xpns_usage_warn
    exit ${XP_EINVAL}
  fi

  if [[ -n "${XP_OPT_CUSTOM_SIZE_COLS-}" ]] || [[ -n "${XP_OPT_CUSTOM_SIZE_ROWS-}" ]]; then
    if [[ "$XP_OPT_EXTRA" -eq 1 ]]; then
      xpns_msg_warning "The columns/rows options (-C, --cols, -R, --rows) cannot be used with -x option. Ignored."
    elif [[ "$XP_OPT_EXTRA" -eq 0 ]] && [[ "${XP_OPT_USE_PRESET_LAYOUT}" -eq 1 ]]; then
      # This part is required to keep backward compatibility.
      ## Users can simulate xpanes v3.x to set : alias xpanes="xpanes -lt"
      xpns_msg_info "Columns/rows option (-C, --cols, -R, --rows) and -l option are provided. Disable -l. "
      XP_OPT_USE_PRESET_LAYOUT=0
    fi
  fi

  # Set default value in case of empty.
  XP_CMD_UTILITY="${XP_CMD_UTILITY:-${XP_DEFAULT_CMD_UTILITY}}"
  XP_REPSTR="${XP_REPSTR:-${XP_DEFAULT_REPSTR}}"

  # To set command on pre_execution, set -c option manually.
  if [[ ${XP_OPT_CMD_UTILITY} -eq 0 ]];then
    XP_OPTIONS+=("-c" "${XP_CMD_UTILITY}")
  fi

}

## --------------------------------
# Main function
## --------------------------------
xpns_main() {
  xpns_parse_options ${1+"$@"}
  xpns_check_env "${XP_DEPENDENCIES}"
  ## --------------------------------
  # Parameter validation
  ## --------------------------------
  # When do dry-run flag is enabled, skip running (this is used to execute unit test of itself).
  if [[ ${XP_OPT_DRY_RUN} -eq 1 ]]; then
    return 0
  fi
  # Validate log directory.
  if [[ ${XP_OPT_LOG_STORE} -eq 1 ]]; then
    TMUX_XPANES_LOG_DIRECTORY=$(xpns_normalize_directory "${TMUX_XPANES_LOG_DIRECTORY}")
    xpns_is_valid_directory "${TMUX_XPANES_LOG_DIRECTORY}" && \
    TMUX_XPANES_LOG_DIRECTORY=$(cd "${TMUX_XPANES_LOG_DIRECTORY}" && pwd)
  fi
  ## --------------------------------
  # If current shell is outside of tmux session.
  ## --------------------------------
  if [[ -z "${TMUX-}" ]]; then
    xpns_pre_execution
  ## --------------------------------
  # If current shell is already inside of tmux session.
  ## --------------------------------
  else
    xpns_execution
  fi
  exit 0
}

## --------------------------------
# Entry Point
## --------------------------------
xpns_main ${1+"$@"}

### fatpacked app top-mem ######################################################

# View top ordered by memory usage

exec top -c -o '%MEM'

### fatpacked app trash ########################################################

#!/bin/bash

# Move a file to a trash dir at the files location

source bash-helpers

file="$@"

if [[ ! "$file" ]] ; then
    DIE "Specify file"
fi

dir=$(dirname "$file")
trash="$dir/.trash"
mkdir -p "$trash"

mv "$file" "$trash/"

### fatpacked app tree #########################################################

#!/usr/bin/env perl

# List a directory as a tree

use strict;
use warnings;
no warnings 'uninitialized';

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

use File::stat;

binmode STDOUT, ":encoding(UTF-8)";
use File::Basename;
use Cwd qw(abs_path getcwd);
use File::Spec;

use Getopt::Long;
Getopt::Long::Configure("bundling");
my %o                  = ();
my @option_definitions = (
    "directories-only|d", "summary",
    "all|a",              "colors!",
    "ascii",              "eval|e=s",
    "exec|execute|x=s",   "include=s",
    "grep|g=s",           "exclude=s",
    "empty!",             "v|verbose",
    "info|i",             "warnings!",
    "mounted!",           "stats",
    "age",                "size|s",
    "entry-count",        "html",
    "abs",                "scm-exclude|C"
);

GetOptions(\%o, @option_definitions)
    or die "Usage:\n" . join("\n", sort @option_definitions) . "\n";

$o{empty}    = 1 if !defined $o{empty};
$o{warnings} = 1 if !defined $o{warnings};
$o{mounted}  = 0 if !defined $o{mounted};
$o{colors}   = 1 if !defined $o{colors};
if ($o{"scm-exclude"} && !$o{a}) {
    $o{exclude} = qr/\/((\.(git|cvs|svn))|node_modules|bower_components)/;
}

if ($ENV{LANG} !~ /utf/i) {
    $o{ascii} = 1;
}

if ($o{info}) {
    $o{age}           = 1;
    $o{size}          = 1;
    $o{'entry-count'} = 1;
}

if ($o{grep}) {
    $o{include} = ".*" . $o{grep} . ".*";
    $o{empty}   = 0;
}
if ($o{include}) {
    $o{all} = 1;
}

$ARGV[0] ||= getcwd;

my $root_dev;

foreach my $root_dir (@ARGV) {

    $root_dir = File::Spec->rel2abs($root_dir);
    $root_dev = stat($root_dir)->dev;
    $root_dir =~ s/\/$//g;

    if ($o{v}) {
        print STDERR "Using options: \n", Dumper \%o;
    }

    Path->new(
        name        => basename($root_dir),
        parent_name => dirname($root_dir),
        is_root     => 1,
        multiple    => @ARGV > 1,
    )->print;
}

package Path;

use Data::Dumper;
use File::stat;

my ($blue, $green, $red, $gray, $no_color);
my ($graph_vertical, $graph_t, $graph_l, $graph_line);
my %warnings;
my %stats;

sub init {
    if ($o{colors}) {
        $blue     = "\x1b[38;5;4m";
        $green    = "\x1b[38;5;2m";
        $red      = "\x1b[38;5;1m";
        $gray     = "\x1b[38;5;7m";
        $no_color = "\x1b[33;5;0m";
    }

    if ($o{html}) {
        $blue     = q{<font color="blue">};
        $green    = q{<font color="green">};
        $red      = q{<font color="red">};
        $gray     = q{<font color="gray">};
        $no_color = q{</font>};
    }

    $graph_vertical = "\x{2502}";
    $graph_t        = "\x{251c}";
    $graph_l        = "\x{2514}";
    $graph_line     = "\x{2500}";

    if ($o{ascii}) {
        $graph_vertical = "|";
        $graph_t        = "+";
        $graph_l        = "+";
        $graph_line     = "-";
    }
}

sub print {
    my ($self) = @_;

    %warnings = ();
    %stats    = ();

    $self->add_children;
    $self->add_warnings;

    if ($o{html}) {
        print "<pre>\n";
    }

    $self->_print;
    $self->print_warnings;
    $self->print_stats;

    if ($o{html}) {
        print "</pre>\n";
        print "<hr noshade>\n" if $self->multiple;
    }
}

sub _print {
    my ($self, $parent, $is_parent_last_entry, $prefix) = @_;

    $self->prefix($prefix);

    my $name = $self->name;
    $name = $self->abs if $o{abs} && $self->is_root;

    print $self->prefix
        . $self->dir_prefix($is_parent_last_entry)
        . $self->color
        . $name
        . $self->link_info
        . $no_color
        . ($o{warnings} ? $self->warnings : "")
        . $self->info . "\n";

    my $next_prefix = $is_parent_last_entry ? "  " : $graph_vertical . " ";
    $next_prefix = $self->prefix . $next_prefix;
    $next_prefix = "" if $self->is_root;

    my $entry_count         = keys %{ $self->entries };
    my $current_entry_count = 0;
    foreach my $path_name (sort keys %{ $self->entries }) {

        $current_entry_count++;
        my $is_last_entry = $current_entry_count == $entry_count;

        my $path = $self->entries->{$path_name};

        if ($path->is_dir) {
            $path->_print($self, $is_last_entry, $next_prefix);
            next;
        }

        my $name = $path->name;
        if ($path->count > 1) {
            $name =
                  $red
                . $path->count . "x "
                . ($path->is_dir() ? $blue : $green)
                . $path->normalized_marking
                . $no_color;
        }

        print $self->prefix
            . $self->file_prefix($is_parent_last_entry, $is_last_entry)
            . $path->color
            . $name
            . $path->link_info
            . ($o{warnings} ? $path->warnings : "")
            . $path->info
            . $no_color . "\n";
    }
}

sub link_info {
    my ($self) = @_;
    return if !$self->is_link;
    return "$red -> " . readlink($self->abs) . $no_color;
}

sub print_warnings {

    return if !%warnings;
    return if !$o{warnings};

    print "\n${red}Warnings:${no_color}\n", dumps(\%warnings, $red), "\n";
}

sub print_stats {

    return if !%stats;
    return if !$o{stats};

    print "\nStats:\n", dumps(\%stats), "\n";
}

sub dumps {
    my ($ref, $color) = @_;

    $Data::Dumper::Sortkeys = 1;
    $Data::Dumper::Terse    = 1;
    $Data::Dumper::Indent   = 1;
    $Data::Dumper::Pair     = ": ";

    my $s = Dumper $ref;
    $s =~ s/['{}]*//g;
    $s =~ s/,$//gm;
    $s =~ s/\s+$//gms;
    $s =~ s/\n\n//gm;
    $s =~ s/^\n//gm;
    $s =~ s/^/$color/gms;
    $s =~ s/$/$no_color/gms;

    # $s = $color . $s . $no_color;
    $s .= "\n";
    return $s;
}

sub humanize_secs {
    my ($secs) = @_;

    my $m = 60;
    my $h = $m * 60;
    my $d = $h * 24;
    my $w = $d * 7;
    my $y = $d * 365;

    my $m99 = $m * 99;
    my $h99 = $h * 99;
    my $d99 = $d * 99;

    my $human;

    if ($secs >= $y) {
        $human = sprintf("%.1fy", $secs / $y);
    }
    elsif ($secs >= $d99) {
        $human = sprintf("%0dw", $secs / $w);
    }
    elsif ($secs >= $h99) {
        $human = sprintf("%0dd", $secs / $d);
    }
    elsif ($secs >= $m99) {
        $human = sprintf("%0dh", $secs / $h);
    }
    elsif ($secs >= $m) {
        $human = sprintf("%0dm", $secs / $m);
    }
    else {
        $human = $secs . "s";
    }

    $human =~ s/\.0(\D)/$1/g;

    return $human;
}

sub humanize_bytes {
    my ($bytes) = @_;

    my $k = 1024;
    my $m = $k * 1024;
    my $g = $m * 1024;
    my $t = $g * 1024;

    my $human;

    if ($bytes >= $t) {
        $human = sprintf("%.1fT", $bytes / $t);
    }
    elsif ($bytes >= $g) {
        $human = sprintf("%.1fG", $bytes / $g);
    }
    elsif ($bytes >= $m) {
        $human = sprintf("%.1fM", $bytes / $m);
    }
    elsif ($bytes >= $k) {
        $human = sprintf("%.1fK", $bytes / $k);
    }
    elsif ($bytes == 0) {
        $human = $bytes;
    }
    else {
        $human = $bytes;
    }

    return $human;
}

BEGIN {
    for my $accessor (qw( color prefix name parent_name is_root count multiple))
    {
        no strict 'refs';
        *{$accessor} = sub {
            my $self = shift;
            return $self->{$accessor} if !@_;
            $self->{$accessor} = shift;
        };
    }
}

sub warnings {
    my ($self) = @_;
    return if !$self->{warnings};
    return
          " "
        . $red
        . join("$no_color, $red", @{ $self->{warnings} })
        . $no_color;
}

sub info {
    my ($self) = @_;

    my @info;

    if ($o{'entry-count'}) {
        push(@info, "Entries: " . (keys %{ $self->entries } || 0))
            if $self->is_dir;
    }

    if ($o{age}) {
        push(@info, $self->age);
    }

    if ($o{size}) {
        push(@info, $self->size);
    }

    if ($o{eval}) {
        $_ = $self->abs;
        my $eval = eval { $o{eval} };
        die $@ if $@;
        push(@info, $eval);
    }

    if ($o{exec}) {
        my $exec = $o{exec};
        my $abs  = $self->abs;
        $exec =~ s/\{\}/'$abs'/g;
        print STDERR "Executing in the shell: $exec\n" if $o{v};
        $exec = `$exec`;
        $exec =~ s/\n+$//g;
        $exec =~ s/\n/ | /g;
        $exec =~ s/^ +//g;
        push(@info, $exec);
    }

    return if !@info;
    return " " . $gray . join(", ", @info) . $no_color;
}

sub file_prefix {
    my ($self, $is_last_dir_entry, $is_last_entry) = @_;

    my $fork     = $is_last_entry     ? $graph_l : $graph_t;
    my $dir_fork = $is_last_dir_entry ? " "      : $graph_vertical;
    if ($self->is_root) {
        $dir_fork = "";
    }
    else {
        $dir_fork .= " ";
    }

    return $dir_fork . $fork . $graph_line . " ";
}

sub dir_prefix {
    my ($self, $is_last_entry) = @_;

    return if $self->is_root;

    my $fork = $is_last_entry ? $graph_l : $graph_t;

    return $fork . $graph_line . " ";
}

sub new {
    init;
    my $class = shift;
    my %p     = @_;
    return bless { %p, color => $blue }, $class;
}

sub has_entries {
    my ($self) = @_;
    keys %{ $self->{entries} } != 0;
}

sub entries {
    my ($self) = @_;
    $self->{entries} ||= {};
    return $self->{entries};
}

sub is_mounted {
    my ($self) = @_;

    my $dev = stat($self->abs)->dev;

    if ($dev != $root_dev) {
        return 1;
    }

    return 0;
}

sub add {
    my ($self, $path) = @_;

    if (!$path->is_dir && $o{include}) {
        return 0 if $path->abs !~ /$o{include}/i;
    }

    return 0 if $path->abs =~ /$o{exclude}/i;

    $path->add_warnings;

    if ($path->is_dir) {

        $path->color($blue);
        $stats{Directories}++;

        if ($path->name =~ /^\.(git|svn)/) {
        }
        elsif (!stat($path->abs)) {
        }
        elsif ($path->is_mounted) {
        }
        elsif (!$path->is_link) {
            $path->add_children;
        }

        $path->add_to_global_warnings;

        if ($path->name =~ /^\./) {
            return if !$o{all};
        }

        if (!$path->has_entries && !$o{empty}) {
            return;
        }

        $self->entries->{ $path->name } = $path;
        return;
    }

    if ($o{'directories-only'}) {
        return;
    }

    $path->color($green);

    $path->add_to_global_warnings;

    if ($path->name =~ /^\./) {
        return if !$o{all};
    }

    my ($extension) = $path->name =~ /\.([^\.]+)$/;
    $extension = "" if $path->name !~ /\./;
    $extension = "" if $extension =~ /^\d+$/;

    $stats{Files}++;
    $stats{'File extensions'}{$extension}++;

    my $path_key = $path->name;

    if ($o{summary}) {
        $path_key = $path->normalized;
        $path->count(1);
    }

    if (exists $self->entries->{$path_key}) {
        $self->entries->{$path_key}{count}++;
    }
    else {
        $self->entries->{$path_key} = $path;
    }
}

sub add_warning {
    my ($self, $warning) = @_;
    push(@{ $self->{warnings} }, $warning);
}

sub add_warnings {
    my ($self) = @_;

    if ($self->name =~ /^\./) {
        $self->add_warning('DOTFILE');
    }

    $self->add_warning("PRECEDING SPACE") if $self->name =~ /^\ /;
    $self->add_warning("TRAILING SPACE")  if $self->name =~ /\ $/;

    if ($self->name =~ /^\.(git|svn)/) {
        $self->add_warning("SCM DIR");
    }

    if (!stat $self->abs) {
        $self->add_warning("READ ERROR");
    }
    else {

        if ($self->is_mounted) {
            $self->add_warning("MOUNTED");
        }

        if ($self->is_link) {
            $self->add_warning("LINK");
        }
    }

}

sub add_to_global_warnings {
    my ($self) = @_;

    foreach my $warning (@{ $self->{warnings} }) {
        $warnings{$warning}++;
    }
}

sub add_children {
    my ($self) = @_;

    my $dirh;
    if (!opendir($dirh, $self->abs)) {
        $self->add_warning("ERROR: " . $!);
        return;
    }

    while (my $entry = readdir($dirh)) {

        next if $entry =~ /^\.{1,2}$/;

        my $path = Path->new(parent_name => $self->abs, name => $entry,);

        $self->add($path);
    }
    closedir($dirh) || die $!;
}

sub is_dir {
    my ($self) = @_;
    return -d $self->abs;
}

sub is_link {
    my ($self) = @_;
    return -l $self->abs;
}

sub abs {
    my ($self) = @_;

    return $self->name if !$self->parent_name;
    return $self->parent_name . "/" . $self->name;
}

sub normalized {
    my ($self) = @_;

    my $normalized = $self->name;
    $normalized =~ s/[0-9a-f\W\d\s_]{2,}//gi;
    return $normalized;
}

sub normalized_marking {
    my ($self) = @_;

    my $entry_color = $self->is_dir() ? $blue : $green;

    my $normalized = $self->name;
    $normalized =~ s/([0-9a-f\-]{2,}|[\W\d\s_]{2,})/${red}$^N$entry_color/gi;
    return $normalized;
}

sub age {
    my ($self) = @_;

    my $stat = stat($self->abs) || return;

    my $age   = time - $stat->mtime;
    my $h_age = humanize_secs($age);
    $h_age = $red . $h_age . $no_color if $h_age =~ /[sm]/;
    return "Changed: $h_age";
}

sub size {
    my ($self) = @_;

    return if $self->is_dir;

    my $stat = stat($self->abs) || return;

    my $size       = $stat->size;
    my $blocks     = $stat->blocks;
    my $block_size = $stat->blksize;

    my $alloc = $blocks * 512;
    my $done  = 100;
    $done = $alloc / ($size / 100) if $size != 0;
    $done = int($done);

    my $info = $gray . "Size: " . humanize_bytes($size);

    return $info if $done >= 100;

    $self->add_warning("INCOMPLETE");

    return
          $gray
        . "Size: "
        . humanize_bytes($alloc) . "/"
        . humanize_bytes($size)
        . " - ${red}$done\%"
        . $gray;
}



### fatpacked app tree-diff ####################################################

#!/bin/bash

# Diff two directory structures

left=$1 ; shift
right=$1 ; shift

diff=diff

if [[ $(type -p colordiff) ]] ; then
    diff=colordiff
fi

$diff -y \
    <(tree --no-colors --ascii $@ "$left") \
    <(tree --no-colors --ascii $@ "$right") \
    | less

### fatpacked app ubuntu-setup-automatic-updates ###############################

#!/bin/bash

# Make sure update and backports soures are activated

# Updates - should be activated otherwise regular updates might fail because
#    of missing/outdated dependencies
# Backports - should be activated - by default only installed manually
# Proposed - don't activate - aproved packages move to updates anyway

source bash-helpers

DIE "Deprecated"

INFO "Including updates and backports in sources list..."

gotroot

bak /etc/apt/sources.list

file-add-line-if-new /etc/apt/sources.list '^deb http://\S+\s+'$DISTRIB_CODENAME'-updates.*$'   'deb http://archive.ubuntu.com/ubuntu '$DISTRIB_CODENAME'-updates   main restricted universe multiverse'
file-add-line-if-new /etc/apt/sources.list '^deb http://\S+\s+'$DISTRIB_CODENAME'-backports.*$' 'deb http://archive.ubuntu.com/ubuntu '$DISTRIB_CODENAME'-backports main restricted universe multiverse'

apt-get update

### fatpacked app ubuntu-unity-set-time-format #################################

#!/bin/bash

# Set time format of ubuntu unity desktop clock

dconf write /com/canonical/indicator/datetime/time-format "'custom'"
dconf write /com/canonical/indicator/datetime/custom-time-format "'KW%V | %a | %F | %R'"

### fatpacked app uniq-unsorted ################################################

#!/usr/bin/env perl

# uniq replacement without the need for sorted input
use strict;
use warnings;

my %seen;

while (<STDIN>) {
    print if !exists $seen{$_};
    $seen{$_} = 1;
}

### fatpacked app unix2dos #####################################################

#!/bin/bash

# Convert line endings from unix to dos

perl -i -pe 's/\n/\r\n/' "$@"

### fatpacked app url ##########################################################

#!/usr/bin/env perl

# Print absolute SSH url of a file or directory

use strict;
use warnings FATAL => 'all';

my $hostname = `hostname` || die "Error getting hostname";
$hostname =~ s/\n//g;

my $rel = qx{rel "@ARGV"};
$rel =~ s/\n$//g;
$rel = "\"$rel\"" if $rel =~ /\s|;/;
print "$ENV{USER}\@" . $hostname . ":$rel\n"

### fatpacked app url-decode ###################################################

#!/bin/bash

# Decode a string from URL notation
# https://stackoverflow.com/questions/296536/how-to-urlencode-data-for-curl-command

echo -n "$@" | perl -pe 's/\%(\w\w)/chr hex $1/ge'

### fatpacked app url-encode ###################################################

#!/bin/bash

# Encode a string to URL notation
# https://stackoverflow.com/questions/296536/how-to-urlencode-data-for-curl-command

echo -n "$@" | perl -pe 's/(\W)/sprintf("%%%02X", ord($1))/ge'

### fatpacked app user-add #####################################################

#!/bin/bash

# Add a new user to the system without hassle

source bash-helpers

user=${1?Specify user name}
shift

if [[ ! $(id $user 2> /dev/null) ]] ; then
    sudo adduser --disabled-password --quiet --gecos "" $user "$@"

    sudo mkdir -p /home/$user/.ssh/
    sudo cp ~/.ssh/authorized_keys /home/$user/.ssh/
    sudo cp ~/.bashrc /home/$user/
    sudo chown -R $user:$user /home/$user
fi

ssh $user@localhost


### fatpacked app vi-executable ################################################

#!/bin/bash

# Find an executable in the path and edit it

set -e

file=$(type -p $@)

command eval $EDITOR "$file"

### fatpacked app vi-from-perl-inc #############################################

#!/bin/bash

# Find an executable in the perl %INC and edit it

set -e

file=$(perldoc -lm "$@")

command eval $EDITOR "$file"

### fatpacked app video-dvd-install-decss ######################################

# Install decss for encrypted dvd playback

# https://help.ubuntu.com/community/RestrictedFormats/PlayingDVDs

sudo apt-get install libdvdread4
sudo /usr/share/doc/libdvdread4/install-css.sh

### fatpacked app video-dvd-rip ################################################

# Rip and transcode a video dvd

# Use `lsdvd -a` to inspect dvd to choose titles and audio tracks.

# TODO: title tracks need to be specified starting from 0
# TODO: audio tracks need to be specified starting from 0

source bash-helpers

tracks="$@"

if [[ ! $tracks ]] ; then
    tracks=x
fi

for track in $tracks ; do

    if [[ $track = x ]] ; then
        track=""
    fi

    INFO "Ripping track: $track..."
    mpv --dvd-device /dev/sr1 dvdnav://$track --stream-dump dvd-$track.vob || true
    # mpv dvd://$track --stream-dump dvd-$track.vob || true
    INFO "Done ripping track: $track"
done

# eject /dev/dvd || WARN "Cannot eject dvd - skipping"

INFO "Encoding..."

for track in $@ ; do
    INFO "Transcoding track: $track"
    video-transcode dvd-$track.vob
    INFO "Done transcoding track: $track"
done

INFO "All done"

### fatpacked app video-transcode ##############################################

#!/usr/bin/env bash-with-comments

# Transcode a media file to x264 preserving all video, audio and subtitle tracks
#
# For deinterlacing set DEINTERLACE env var.

# NOTE: for libfdk_aac on Ubuntu 18.04 use snap:
# sudo snap install ffmpeg --devmode

source bash-helpers

# fix aspect "flag" - make 4:3 to display as 16:9 for NTSC:
# mkvpropedit *.mkv --edit track:v1 --set display-width=853

infile="$*"
INFO "Encoding $infile..."

# video quality - crf:
# A change of ±6 should result in about half/double the file size, although your results might vary.
# lower values would result in better quality (at the expense of higher file sizes).
# http://slhck.info/articles/crf
# default crf: 23
# less is better
# DVD needs 23? / the lower the res the higher quality neede?
crf=29

# Even though apparently all dvds are interlaced - usually results seem to be better without deinterlacing.
# deinterlace
if [[ $DEINTERLACE ]] ; then
  deinterlacer="-vf yadif"
  deinterlaced_name="-deinterlaced"
  WARN '#################################### Deinterlacing!'
fi

## AUDIO
# -cutoff: default is 14000Hz for audio
#
# 224 kbit 6-ch AAC seems to be the current standard (2020-06-28).
audio="-c:a libfdk_aac -b:a 224k -cutoff 20000"

if [[ $STEREO ]] ; then
  audio="-c:a libfdk_aac -vbr 5 -cutoff 20000 -ac 2"
  stereo_name="-stereo"
  WARN '#################################### Forcing stereo!'
fi

# Audio "hi-fi transparency demands data rates of at least 128 kbit/s CBR. The
# MPEG-2 audio tests showed that AAC meets the requirements referred to as
# "transparent" for the ITU at 128 kbit/s for stereo, and 320 kbit/s for 5.1 audio."
# (https://en.wikipedia.org/wiki/Advanced_Audio_Coding)
#
# Audio codec options:
# https://www.ffmpeg.org/ffmpeg-codecs.html
# ac3 is the best quality audio encoder directly included in libav - see:
# https://trac.ffmpeg.org/wiki/Encode/HighQualityAudio
# libfdk_aac is the best aac encoder.

# outfile=$(basename "$infile").crf${crf}-aac${deinterlaced_name}${stereo_name}.mkv
outfile="$infile".tmp.mkv
nfoDir=$(dirname "$infile")/nfo
nfo="$nfoDir/recode.nfo"

if [[ -e $outfile ]] ; then
  DIE "Outfile: $outfile exists."
fi

# prevent ffmpeg from reading stdin (problem with bash-with-comments)
< /dev/null \
ffmpeg \
  # shows -vf option like yadif etc.
  -loglevel verbose \
  #
  -i "$infile" \
  #
  # include all video streams
  -map 0:v \
  #
  -c:v libx264 \
  -crf $crf \
  $deinterlacer \
  #
  # May prevent "Too many packets buffered for output stream":
  # Had this problem with a DVD ISO.
  -max_muxing_queue_size 9999 \
  #
  # TODO: Only reencode if not aac etc already.
  #
  # NOTE: -vbr reports an error but that message is supposably wrong (http://www.ffmpeg-archive.org/FDK-AAC-OUTPUTS-CBR-AUDIO-STREAM-ONLY-td4670348.html)
  # The bitrate does seam to fluctuate.
  # "the VBR setting is unsupported and only works with some parameter combinations"
  #
  # include all audio streams
  -map 0:a \
  #
  $audio \
  #
  # passthrou
  # -c:a copy \
  #
  # downmix to 2 channels (ignores the subwoofer channel)
  $stereo \
  #
  # include all subtitle streams
  -map 0:s? \
  # copy subtitles as is
  -c:s copy \
  #
  $outfile

INFO "Done: $infile"

mkdir -p "$nfoDir"
echo "$infile reencoded with crf: ${crf}" >> "$nfo"

mv "$outfile" "$infile"
mv "$infile" "$infile.reenc_x264.mkv"

if [[ $DEINTERLACE ]] ; then
  WARN '#################################### Deinterlacing!'
fi

if [[ $STEREO ]] ; then
  WARN '#################################### Forcing stereo!'
fi


### fatpacked app vidir. #######################################################

#!/usr/bin/env bash

# more save vidir

source bash-helpers

qmv -R -f do "$@"

### fatpacked app vim-edit #####################################################

#!/usr/bin/env bash

# Edit input fields with vim

# Make sure vim's exit code is 0 - otherwise nothing will be saved.
# Created files are kept in /tmp - see below.

# Setup:
# - Put script in you path.
# - Add custom shortcut (i.e. ctrl+e) in gnome settings and set command to:
#   bash -l -c vim-edit

source bash-helpers

tmp=$(mktemp --suffix=.vim-edit.txt)

# NOTE: use -f to include dialogs etc?
window=$(xdotool getwindowfocus)

xdotool key ctrl+a ctrl+c

xclip -o > $tmp

gnome-terminal --maximize --wait -- vi $tmp

cat $tmp | xclip -selection clip

xdotool windowactivate --sync $window
xdotool key ctrl+v

# clear (unstick) modifier key of original shortcut i.e. ctrl+e
xdotool keyup ctrl

### fatpacked app vim-firefox ##################################################

#!/bin/bash
# Vim to use from firefox addon its-all-text

export REMOTE_HOME=$HOME

exec gnome-terminal -x ~/.bin/vi "$@"

### fatpacked app vim-setup ####################################################

#!/bin/bash

# Setup vim environment

source bash-helpers

INFO "Setting up vim config..."

VIM_DIR=$REMOTE_HOME/.vim/
mkdir -p $VIM_DIR
cd $VIM_DIR

if [[ -e .git ]] ; then
  INFO "Updating existing setup..."
  git-reset-origin
  git pull
else
  INFO "Cloning git dotvim repo..."
  git clone --depth 1 https://github.com/nilsboy/dotvim.git .
fi

INFO "Starting vim to download plugins..."

exec vi

### fatpacked app vim-url ######################################################

#!/usr/bin/env perl

# Print absolute SSH url of a file or directory in vim syntax

use strict;
use warnings FATAL => 'all';

my $url = qx{url "@ARGV"};
$url =~ s/\n//g;

$url =~ s/\:/\//;
$url =~ s/^/scp:\/\//g;

print "$url\n";

### fatpacked app vipe #########################################################

#!/bin/bash

# Edit stdin in a pipe using vim
# Based on https://old.reddit.com/r/vim/comments/3oo156/whats_your_best_vim_related_shell_script/

function cleanup() { test -e "$TOVIMTMP" && rm "$TOVIMTMP" ; }
trap cleanup ERR EXIT

set -e

TOVIMTMP=/tmp/tovim_tmp_`date +%Y-%m-%d_%H-%M-%S`.`uuid`.txt
cat > $TOVIMTMP 
vi $TOVIMTMP < /dev/tty > /dev/tty
cat $TOVIMTMP 


### fatpacked app vnc-server-setup-upstart-script ##############################

#!/bin/bash

# Setup remote desktop access via ssh and vnc right from the login screen of
# lightdm.

set -e

sudo apt-get install x11vnc

sudo tee /etc/init/lightdm-vnc.conf >/dev/null <<'EOF'
# to reload: sudo initctl emit login-session-start
start on login-session-start
script
set +e
killall -9 x11vnc
set -e
/usr/bin/x11vnc \
    -norc \
    -localhost \
    -forever \
    -solid \
    -nopw \
    -nocursor \
    -wireframe \
    -wirecopyrect \
    -xkb \
    -auth /var/run/lightdm/root/:0 \
    -noxrecord \
    -noxfixes \
    -noxdamage \
    -rfbport 5900 \
    -scale 3/4:nb \
    -o /var/log/lightdm-vnc.log \
    -bg
end script
EOF

    sudo tee -a /etc/lightdm/lightdm.conf >/dev/null <<-'EOF'

[VNCServer]
enabled=true
EOF

sudo initctl reload-configuration
sudo initctl emit login-session-start

echo "check if vino is running!"

### fatpacked app vnc-start-vino ###############################################

# Start vino vnc server

/usr/lib/vino/vino-server --display :0 &

### fatpacked app vnc-vino-preferences #########################################

# Set vino preferences

vino-preferences

### fatpacked app vncviewer ####################################################

#!/bin/bash

# vncviewer preconfigured to use ssh

host=$1
port=${2:-0}

export VNC_VIA_CMD="/usr/bin/ssh -C -f -L %L:%H:%R %G sleep 20"

$(type -pf vncviewer) -encoding tight \
    -compresslevel 9 -quality 5 -x11cursor -via $host localhost:$port

### fatpacked app wcat #########################################################

#!/usr/bin/env perl

# Easily dump a web site

use strict;
use warnings;
no warnings 'uninitialized';
use Data::Dumper;
use File::Copy;
use Getopt::Long;
Getopt::Long::Configure("bundling");

my $opts = {
    "h|only-show-response-headers" => \my $show_headers,
    "s|strip-tags"                 => \my $strip_tags,
    "f|save-to-file"               => \my $to_file,
    "r|replace"                    => \my $overwrite,
    "o|out-file=s"                 => \my $file,
};
GetOptions(%$opts) or die "Usage:\n" . join( "\n", sort keys %$opts ) . "\n";

my $url = $ARGV[0] || die "Specify URL.";

if ( $url !~ m#^(.+?)://# ) {
    $url = "http://$url";
}

if ($to_file) {
    if ( !$file ) {
        ($file) = $url =~ m#^.+?://.*?/([^\/]+)$#;
    }
    die "Error creating file name from url." if !$file;
    die "File exists: $file" if -f $file && !$overwrite;
}

my $options = "--no-check-certificate ";
if ($show_headers) {
    $options .= "-S ";
}

my $content = `wget $options -qqO- "$url"` || die "Request failed. $!";

exit 0 if $show_headers;

die "Empty response from $url." if !$content;

if ($strip_tags) {
    $content =~ s#<\s*script.+?>.+?</script>##imsg;
    $content =~ s#<\s*head.+?>.+?</head>##imsg;
    $content =~ s#\n+##igms;
    $content =~ s#<(br)/*>#\n#igms;
    $content =~ s#<(li).*?>#\* #igms;
    $content =~ s#</(li).*?>#\n#igms;
    $content =~ s#</(p|div).*?>#\n\n#igms;
    $content =~ s#</h\d+.*?>#\n\n#igms;
    $content =~ s#<.+?/>\n*##igms;
    $content =~ s#<td.*?>#\t#igms;
    $content =~ s#</tr.*?>#\n#igms;

    $content =~ s#<.+?>##igms;

    $content =~ s#&minus;#-#igms;
    $content =~ s#&gt;#>#igms;
    $content =~ s#&lt;#<#igms;
    $content =~ s#&\w+;# #igms;
    $content =~ s/&#\d+;/ /igms;
}

if ( $to_file || $file ) {
    my $tmp_file = "/tmp/wcat.$$.$file";
    open( F, ">", $tmp_file ) || die "Cannot write to file: $tmp_file: $!";
    print F $content;
    close(F);
    move( $tmp_file, $file ) || die "Cannot move to file $file: $!";
}
else {
    print $content;
}

### fatpacked app window-blink #################################################

#!/usr/bin/env bash

# Blink current window

source bash-helpers

[[ ! "$DISPLAY" ]] || exit 0
[[ ! "$WINDOWID" ]] || exit 0

wmctrl -i -r $WINDOWID -b "add,DEMANDS_ATTENTION"

### fatpacked app x2x-east #####################################################

#!/usr/bin/env bash

# Share input devices with another host

source bash-helpers

host=${1:?Specify host}

ssh -X $host x2x -east -to $DISPLAY

### fatpacked app xdg-cache-home ###############################################

#!/usr/bin/env bash

# Return xdg cache home

source bash-helpers

subdir="$1"
subdir=$(echo $subdir | perl -pe 's/^.*\/(.+)/$1/')

if [[ ! $XDG_CACHE_HOME ]] ; then
  XDG_CACHE_HOME=$REMOTE_HOME/.cache
fi

if [[ $subdir ]] ; then
  XDG_CACHE_HOME=$XDG_CACHE_HOME/$subdir/
fi

mkdir -p $XDG_CACHE_HOME

RETURN $XDG_CACHE_HOME

### fatpacked app xmv ##########################################################

#!/usr/bin/env perl

# Rename files by perl expression
# Protects against duplicate resulting file names.

use strict;
use warnings;
no warnings 'uninitialized';

use File::Basename;
use File::Copy qw(mv);
use File::stat;

use File::Path qw(make_path);
use Getopt::Long;
Getopt::Long::Configure('bundling');

my $dry = 1;

my $opts = {
    'x|execute' => sub { $dry = 0 },
    'd|include-directories' => \my $include_directories,
    'n|normalize'           => \my $normalize,
    'e|execute-perl=s'      => \my $op,
    'S|dont-split-off-dir'  => \my $dont_split_off_dir,
};
GetOptions(%$opts) or die "Usage:\n" . join( "\n", sort keys %$opts ) . "\n";

if ( join( " ", @ARGV ) eq "-" ) {
    @ARGV = map {/(.+)\n/} <STDIN>;
}

if ( !@ARGV ) {
    die "Usage: xmv [-x] [-d] [-n] [-l file] [-S] [-e perlexpr] [filenames]\n";
}

my %will                  = ();
my %was                   = ();
my $abort                 = 0;
my $COUNT                 = 0;
my $empty_file_name_count = 0;

for (@ARGV) {

    next if /^\.{1,2}$/;

    my $abs  = $_;
    my $dir  = dirname($_);
    my $file = basename($_);

    if ($dont_split_off_dir) {
        $dir  = "";
        $file = $_;
    }

    $dir = "" if $dir eq ".";
    $dir .= "/" if $dir;

    $abs = $dir . $file;
    my $was = $file;
    $_ = $file;

    $_ = normalize($abs) if $normalize;

    # vars to use in perlexpr
    $COUNT++;
    $COUNT = sprintf( "%0" . length( scalar(@ARGV) ) . "d", $COUNT );
    my $DIR  = dirname($abs);
    my $FILE = basename($abs);

    if ($op) {
        eval $op;
        die $@ if $@;
    }

    my $will = $dir . $_;

    if ( !-e $abs ) {
        warn "no such file: '$was'";
        $abort = 1;
        next;
    }

    if ( -d $abs && !$include_directories ) {
        next;
    }

    my $other = $will{$will} if exists $will{$will};
    if ($other) {
        warn "name '$will' for '$abs' already taken by '$other'.";
        $abort = 1;
        next;
    }

    next if $will eq $abs;

    if ( -e $will ) {
        warn "file '$will' already exists.";
        $abort = 1;
        next;
    }

    $will{$will} = $abs;
    $was{$abs}   = $will;
}

exit 1 if $abort;

foreach my $was ( sort keys %was ) {

    my $will = $was{$was};

    print "moving '$was' -> '$will'\n";

    next if $dry;

    # system("mv", $was, $will) && die $!;
    my $stat = stat($was) || die $!;
    my $dir = dirname($will);

    if ( !-d $dir ) {
        make_path($dir) || die "Error creating directory: $dir";
    }

    mv( $was, $will ) || die $!;
    utime( $stat->atime, $stat->mtime, $will ) || die $!;
}

sub normalize {
    my ($abs) = @_;
    $_ = basename($abs);

    s/&/_and_/g;
    s/^.*?\.(?:net|com)(?=\W.+)//gi;
    s/[^\w.-]+/_/g;
    s/_\././g;
    s/\._/./g;
    s/_+/_/g;
    s/\.+/./g;
    s/^[\._-]+//g;
    s/[\._-]+$//g;

    if ( !$_ ) {
        $empty_file_name_count++;
        $_ = "_empty_file_name." . $empty_file_name_count;
    }

    return $_
}

### fatpacked app xtitle #######################################################

#!/bin/bash

# Change the title of a x window

case "$TERM" in
    *term | rxvt)
        echo -ne "\033]0;$*\007"
        ;;
    screen)
        # echo -ne "%{ESC_#$WINDOW %m:%c3ESC\\%}%h (%m:%.)%# "
        # echo -ne "\033]$*\033\]"
        ;;
    *)
        ;;
esac

### fatpacked apps END #########################################################

