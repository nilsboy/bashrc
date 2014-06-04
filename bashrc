### START ######################################################################

USE_CURRENT_DIR_AS_HOME=$1

PERL5LIB=~/perldev/lib

if [[ -e ~/perl5/perlbrew/etc/bashrc ]] ; then
    source ~/perl5/perlbrew/etc/bashrc
fi

if [[ ! $PERLBREW_PERL ]] ; then
    PERL5LIB=$PERL5LIB:~/perl5/lib/perl5
fi

export PERL5LIB

if [[ ! $BASHRC_IS_LOADED ]] ; then
    export PATH=~/.bin:~/bin:~/opt/bin:$PATH
fi

### Set remote user stuff ######################################################

if [[ $USE_CURRENT_DIR_AS_HOME ]] ; then

    [[ $REMOTE_USER   ]] || export REMOTE_USER=$(basename $PWD)
    [[ $REMOTE_HOME   ]] || export REMOTE_HOME=$PWD

else

    [[ $REMOTE_USER   ]] || export REMOTE_USER=$USER
    [[ $REMOTE_HOME   ]] || export REMOTE_HOME=$HOME
fi

[[ $REMOTE_BASHRC ]] || export REMOTE_BASHRC="$REMOTE_HOME/.bashrc"
[[ $REMOTE_HOST   ]] || export REMOTE_HOST=${SSH_CLIENT%% *}

if [[ ! $BASHRC_IS_LOADED && $REMOTE_HOME != $HOME ]] ; then
    export PATH=$REMOTE_HOME/.bin:$REMOTE_HOME/bin:$PATH
fi

### Run local rc scripts #######################################################

if [ -d $REMOTE_HOME/.bashrc.d ] ; then
    for rc in $(ls $REMOTE_HOME/.bashrc.d/* 2>/dev/null) ; do
        source $rc
    done
fi

### Return if not an interactive shell #########################################

[[ $PS1 ]] || return

### Env ########################################################################

BASHRC_COLOR_NO_COLOR='\[\e[33;0;m\]'
BASHRC_COLOR_GREEN=$(echo -e "\x1b[38;5;2m")
BASHRC_BG_COLOR=$BASHRC_COLOR_NO_COLOR

export LANG="de_DE.UTF-8"
# export LC_ALL="de_DE.UTF-8"
# export LC_CTYPE="de_DE.UTF-8"

# use english messages on the command line
export LC_MESSAGES=C

export BROWSER=links

# remove domain from hostname if necessary
HOSTNAME=${HOSTNAME%%.*}

# set distribution info

export LINES COLUMNS

export BASHRC_TTY=$(tty)

export FTP_PASSIVE=1

### Input config ###############################################################

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

# don't expand tilde - disables e-key?!?
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

### Aliases ####################################################################

alias  ls='ls --color=auto --time-style=+"%a %F %H:%M" -v '
alias  ll='ls -lh'
alias   l='ls -1'
alias  lr='ls -rt1'
alias llr='ls -rtlh'
alias  lc='ls -rtlhc'
alias  la='ls -1d \.*'
alias lla='ls -lhd \.*'

# https://github.com/seebi/dircolors-solarized
export LS_COLORS='no=00:fi=00:di=36:ln=35:pi=30;44:so=35;44:do=35;44:bd=33;44:cd=37;44:or=05;37;41:mi=05;37;41:ex=01;31:*.cmd=01;31:*.exe=01;31:*.com=01;31:*.bat=01;31:*.reg=01;31:*.app=01;31:*.txt=32:*.org=32:*.md=32:*.mkd=32:*.h=32:*.c=32:*.C=32:*.cc=32:*.cxx=32:*.objc=32:*.sh=32:*.csh=32:*.zsh=32:*.el=32:*.vim=32:*.java=32:*.pl=32:*.pm=32:*.py=32:*.rb=32:*.hs=32:*.php=32:*.htm=32:*.html=32:*.shtml=32:*.xml=32:*.json=32:*.yaml=32:*.rdf=32:*.css=32:*.js=32:*.man=32:*.0=32:*.1=32:*.2=32:*.3=32:*.4=32:*.5=32:*.6=32:*.7=32:*.8=32:*.9=32:*.l=32:*.n=32:*.p=32:*.pod=32:*.tex=32:*.bmp=33:*.cgm=33:*.dl=33:*.dvi=33:*.emf=33:*.eps=33:*.gif=33:*.jpeg=33:*.jpg=33:*.JPG=33:*.mng=33:*.pbm=33:*.pcx=33:*.pdf=33:*.pgm=33:*.png=33:*.ppm=33:*.pps=33:*.ppsx=33:*.ps=33:*.svg=33:*.svgz=33:*.tga=33:*.tif=33:*.tiff=33:*.xbm=33:*.xcf=33:*.xpm=33:*.xwd=33:*.xwd=33:*.yuv=33:*.aac=33:*.au=33:*.flac=33:*.mid=33:*.midi=33:*.mka=33:*.mp3=33:*.mpa=33:*.mpeg=33:*.mpg=33:*.ogg=33:*.ra=33:*.wav=33:*.anx=33:*.asf=33:*.avi=33:*.axv=33:*.flc=33:*.fli=33:*.flv=33:*.gl=33:*.m2v=33:*.m4v=33:*.mkv=33:*.mov=33:*.mp4=33:*.mp4v=33:*.mpeg=33:*.mpg=33:*.nuv=33:*.ogm=33:*.ogv=33:*.ogx=33:*.qt=33:*.rm=33:*.rmvb=33:*.swf=33:*.vob=33:*.wmv=33:*.doc=31:*.docx=31:*.rtf=31:*.dot=31:*.dotx=31:*.xls=31:*.xlsx=31:*.ppt=31:*.pptx=31:*.fla=31:*.psd=31:*.7z=1;35:*.apk=1;35:*.arj=1;35:*.bin=1;35:*.bz=1;35:*.bz2=1;35:*.cab=1;35:*.deb=1;35:*.dmg=1;35:*.gem=1;35:*.gz=1;35:*.iso=1;35:*.jar=1;35:*.msi=1;35:*.rar=1;35:*.rpm=1;35:*.tar=1;35:*.tbz=1;35:*.tbz2=1;35:*.tgz=1;35:*.tx=1;35:*.war=1;35:*.xpi=1;35:*.xz=1;35:*.z=1;35:*.Z=1;35:*.zip=1;35:*.ANSI-30-black=30:*.ANSI-01;30-brblack=01;30:*.ANSI-31-red=31:*.ANSI-01;31-brred=01;31:*.ANSI-32-green=32:*.ANSI-01;32-brgreen=01;32:*.ANSI-33-yellow=33:*.ANSI-01;33-bryellow=01;33:*.ANSI-34-blue=34:*.ANSI-01;34-brblue=01;34:*.ANSI-35-magenta=35:*.ANSI-01;35-brmagenta=01;35:*.ANSI-36-cyan=36:*.ANSI-01;36-brcyan=01;36:*.ANSI-37-white=37:*.ANSI-01;37-brwhite=01;37:*.log=01;32:*~=01;32:*#=01;32:*.bak=01;36:*.BAK=01;36:*.old=01;36:*.OLD=01;36:*.org_archive=01;36:*.off=01;36:*.OFF=01;36:*.dist=01;36:*.DIST=01;36:*.orig=01;36:*.ORIG=01;36:*.swp=01;36:*.swo=01;36:*,v=01;36:*.gpg=34:*.gpg=34:*.pgp=34:*.asc=34:*.3des=34:*.aes=34:*.enc=34:';

export GREP_OPTIONS="--color=auto"

alias f=find-and
alias g=find-or-grep

alias cdt='cd $REMOTE_HOME/tmp'
alias type='type -a'

alias shell-turn-off-line-wrapping="tput rmam"
alias shell-turn-on-line-wrapping="tput smam"

alias cp="cp -i"
alias mv="mv -i"
alias crontab="crontab -i"
alias xargs='xargs -I {} -d \\n'

alias apts="apt-cache search"
alias aptw="apt-cache show"
alias apti="sudo apt-get install"
alias aptp="sudo dpkg -P"
alias aptc="sudo apt-get autoremove"
alias aptl="dpkg -l | g "

alias normalizefilenames="xmv -ndx"
alias m=man-multi-lookup
alias pm=perl-module-find
alias srd=tmux-reattach

alias ps-grep="pgrep -fl"
alias ps-attach="sudo strace -ewrite -s 1000 -p"

alias p=pstree-search
if [[ ! $(type -t pstree) ]] ; then
    alias p="ps axjf"
fi

function  j() { jobs=$(jobs) bash-jobs ; }
function  t() { tree --summary "$@" | less ; }
function td() { tree -d "$@" | less ; }
function csvview() { csvview "$@" | LESS= less -S ; }

### Vim and less ###############################################################

export VIM_HOME=$REMOTE_HOME/.vim

EDITOR=vi
if [[ $REMOTE_HOST ]] ; then
    EDITOR="DISPLAY= $EDITOR"
fi

if [[ -e $VIM_HOME/vimrc ]] ; then
    EDITOR="$EDITOR -u $VIM_HOME/vimrc"
else
    EDITOR="$EDITOR -i $REMOTE_HOME/._viminfo"
fi

export EDITOR
export VISUAL="$EDITOR"
alias vi="$EDITOR"

alias v=vi-choose-file-from-list
alias vie=vi-from-path
alias vif=vi-from-find
alias vih=vi-from-history
alias vip="perldoc -lm"

export LESS="-j0.5 -inRgS"
# Make less more friendly for non-text input files, see lesspipe(1)
if [[ $(type -p lesspipe ) ]] ; then
    eval "$(lesspipe)"
fi
export PAGER=less

export MANWIDTH=80

### Misc #######################################################################

# Get parent process id
function parent() {
    echo $(ps -p $PPID -o comm=)
}

# Search history for an existing directory containing string and go there
function cdh() {

    if ! [[ $@ ]] ; then
        cd $REMOTE_HOME
        return
    fi

    local dir=$(bash-eternal-history-search -d --skip-current-dir \
        --existing-only -c 1 "\/[^\/]*$@[^\/]*$"
    )

    if [[ ! "$dir" ]] ; then
        return 1
    fi

    cd "$dir"
}

# Search for file or dir in cur dir and go there
function cdf() {

    local entry=$(f "$@" | head -1)

    if [[ ! "$entry" ]] ; then
        return 1
    fi

    if [[ -f "$entry" ]] ; then
        entry=$(dirname "$entry")
    fi

    cd "$entry"
}


# Create dir and cd into it
function cdm() {
    mkdir "$@" || return 1
    cd "$@"
}

### Xorg #######################################################################

if [[ $DISPLAY ]] ; then

    keyboard-disable-caps-lock-xwindows

    # make windows blink if prompt appears
    if [[ $(type -p wmctrl) ]] ; then
        export BASHRC_PROMPT_WMCTRL="wmctrl -i -r $WINDOWID -b add,DEMANDS_ATTENTION"
    fi

    export BROWSER=firefox
fi

### SSH ########################################################################

alias ssh="ssh -A"

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
    ssh-agent-env-clear
}

### History ####################################################################

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

history -a

alias h="bash-eternal-history-search -e -s"

function bashrc-eternal-history-add() {

    if [[ $BASHRC_NO_HISTORY ]] ; then
        return
    fi

    local history1
    local history2

    while read -r pos cmd ; do

        if [[ ! $history2 ]] ; then
            history2="$cmd"
            continue
        fi

        [[ $history1 ]] || history1="$cmd"

    done<<-EOF
        $(history 2)
EOF

    [[ $history1 = $history2 ]] && return

    cmd=$history1

    if [[ $cmd == "rm "* ]] ; then
        cmd="# $cmd"
        history -s "$cmd"
    fi

    local quoted_pwd=${PWD//\"/\\\"}

    # update cleanup_eternal_history if changed:
    local line="$USER"
    line="$line $(date +'%F %T')"
    line="$line $BASHPID"
    line="$line \"$quoted_pwd\""
    line="$line \"$BASHRC_PIPE_STATUS\""
    line="$line $cmd"
    echo "$line" >> $HISTFILE_ETERNAL
}

### PROMPT #####################################################################

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

    if [[ $REMOTE_HOST ]] ; then
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
function godark() {
    BASHRC_NO_HISTORY=1
    unset HISTFILE
    BASHRC_BG_COLOR=$BASHRC_COLOR_GREEN
}

### bashrc handling ############################################################

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
        wcat tinyurl.com/phatbashrc2 -o .bashrc
    )
    bashrc-reload
    bashrc-unpack
}

function bashrc-reload() {
    bashrc-clean-env
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
        while ($bashrc =~ /^### fatpacked app ([\w-]+) #*$(.+?)(?=^###)/igsm) {

            my $app_name = $1;
            my $app_data = $2;

            $app_data =~ s/^\s+//g;

            my $app_file_name = "$dst_dir/$app_name";

            # print STDERR "Exporting $app_name to $app_file_name...\n";

            open(my $APP_FILE, ">", $app_file_name) || die $!;
            print $APP_FILE $app_data;
            print $APP_FILE
                "\n# This app was created automatically and may be overridden"
                . " - DONT TOUCH THIS!\n";

            chmod(0755, $app_file_name) || die $!;

            $export_count++;
        }

        print STDERR "Done - $export_count apps exported.\n";
EOF

}

### STARTUP ####################################################################

[ -e "$REMOTE_HOME/.bin" ] || bashrc-unpack

prompt-set
bashrc-set-last-session-pwd

export BASHRC_IS_LOADED=1

### END ########################################################################
return 0

### fatpacked apps start here ##################################################
### fatpacked app README #######################################################

Tools that make my shell life easier and are too big to fit into my bashrc.

Most of the tools are implemented in core perl so they do not need additional
modules from CPAN and thus can be used directly on most unix systems.

Descriptions:

abs:
    Print the absolute path of a file or dir
alternative:
    Find an on disk executable alternative
alternative-run:
    Find an on disk executable alternative and run it
app-knows-switch:
    Check if an app supports specified switch
apt-hold-package:
    Prevent a deb package from beeing upgraded
apt-pop:
    Search for a debian package, sort by ranking, add description
apt-unhold-package:
    Return a deb package to its default upgrade state
archive:
    Archive a file appending a timestamp
bak:
    Backup a file appending a timestamp
bash-background-jobs-count:
    Display one colored count for background jobs running and stopped
bash-eternal-history-search:
    Search specially formatted bash history
bash-helpers:
    Helper functions for shell scripts
bash-jobs:
    Cleaned up bash jobs replacement
bash-print-on-error:
    Print error code of last command on failure
bash-setup-multi-user-environment:
    Share one account with serveral users but create their own
    environment
bashrc-eternal-history-add:
    Add entry to the eternal bash history
bashrc-helper-hostname:
    Format hostname for bash prompt usage
bashrc-helper-login-name:
    Format login for bash prompt usage
bashrc-pack:
    Attach scripts to the bashrc skeleton
bashrc-unpack-and-run:
    Run a script that is attached to the bashrc
cp-merge-directories:
    Merge two directories on the same disk recursively by using hard
    links
cpanm:
    Allow cpanm to install modules specified via Path/File.pm
csvview:
    Quick way to view a csv file on the command line
dev-bin-generate-readme:
    Generate README with descriptions for bin scripts
dev-deploy-fat-bashrc:
    Generate and deploy fat packed bashrc
df:
    Cleaned up df version
dir-diff:
    Diff two directory structures
dir-name-prettifier:
    shorten prompt dir to max 15 chars
distribution-fix:
    Set conveniences depending on distribution
docopt-convert:
    Convert a docopt specification
dos2unix:
    Convert line endings from dos to unix
env-grep:
    Grep environment
env-show:
    Display infos about the system
file-template-filler:
    Create a file from a template
find-and:
    Find files excluding dotfiles optional matching several strings
find-from-date:
    Find files newer than date
find-largest-files:
    Find largest files recursively from current directory
find-newest:
    Recursively find newest files
find-older-than-days:
    Recursively find files oder than days
find-or-grep:
    Find a file or grep stdin
git-env-validate:
    Ensure git-scm is configured appropriately
git-reset-head:
    Discard commits dating back to specified commit
gnome-send-to-mail-images:
    Resize one or more images and add them as attachements
grep-and:
    Search for lines matching one or more perl regex patterns
grep-before:
    Print file contens before a specified regex first matches
grep-from:
    Print file contens from where a specified regex first matches
grep-goo:
    Or-grep but list matching patterns instead of matching lines
grep-list:
    Grep for a list of values
grep-or:
    or-grep list matching lines
java-decompile-jar:
    Recursively decompile a jar including contained jars
json-tidy:
    Tidy a json file and sort hash keys to make the output diffable
keyboard-disable-caps-lock-console:
    Map caps lock to escape for consoles
keyboard-disable-caps-lock-xwindows:
    Map caps lock to escape for X
keyboard-reset:
    Reset keyboard settings
man-explain-options:
    Display man page infos about command line options
man-multi-lookup:
    Lookup help for a command in several places
man-online:
    Lookup a man page on the internet
mysql:
    Fix mysql prompt to show real hostname - NEVER localhost
net-find-free-port:
    Find an unused port
net-open-ports:
    List all open ports
note:
    File of notes and a way to query them
path-grep:
    Find an executable in path
perl-install-deps-for-module:
    Install all CPAN dependencies for a module
perl-install-latest-stable-perl:
    Install latest stable perl via perlbrew
perl-install-module:
    Quickly check if a module is installed - if not install it
perl-install-modules-into-perl-version:
    Install all modules from one perlbrew managed perl installation
    into another
perl-install-perlbrew:
    Install perlbrew
perl-module-edit:
    Edit perl module that is located within perls module path
perl-module-find:
    Find a perl module or script
perl-module-version:
    Print version of an installed perl module
perl-named-process:
    Set process name of perl process to script name. Usefull when run
    via /usr/bin/env
perl-profile:
    Profile a perl app and display the html results
perl-setup-local-lib:
    Setup user dir for cpan perl libs using local::lib and cpanm
perl-upgrade-outdated-modules:
    Upgrade installed perl modules if a new version is available
prompt-dir:
    Prompt containing only the prettified current directory
prompt-dir-full:
    Prompt containing the current directory ony
prompt-helper-git:
    Add git status information to prompt
prompt-host:
    Prompt containing the current hostname
prompt-local:
    Prompt for local shells - without hostname
prompt-plain:
    Static prompt
prompt-spare:
    Prompt without user name
proxy-setup-env:
    Set proxy environment variables
proxyserver:
    Install and run a proxyserver from the cpan
ps-watch:
    Watch a process
pstree-search:
    Display or search pstree, exclude current process
publicip:
    Find own public ip when behind proxy
rel:
    Create a relative path from an absolute path
replace:
    Change the contens of text files by perl expression
shell-color-test:
    most color mappings taken from xterm-colortest
shell-open-access-on-freeport:
    Create shell access on a free port
ssh-agent-env-clear:
    Remove connection to ssh-agent
ssh-agent-env-grab:
    Save ssh-agent environemnt variables to be loaded in another
    session or on
ssh-agent-env-restore:
    Dump ssh-agent vars stored by ssh-agent-env-grab
ssh-no-check:
    SSH without host key checks
ssh-persistent-reverse-tunnel-setup:
    Setup a persistent reverse tunnel
ssh-with-reverse-proxy:
    Proxy traffic of a remote host through localhost
ssl-create-self-signed-certificate:
    Create a self signed certificate
ssl-strip:
    Remove ssl encryption from https and other protocols
text-quote:
    Quote text
text-remove-comments:
    Remove comment from text
time-humanize-seconds:
    Return a humanly comprehendable representation of an amount of
    seconds
time-stamp-to-date:
    Print date for a timestamp
tmux-reattach:
    Reattach to a screen or tmux session
tree:
    List a directory as a tree
uniq-unsorted:
    uniq replacement without the need for sorted input
unix2dos:
    Convert line endings from unix to dos
url:
    Print absolute SSH url of a file or directory
vi-choose-file-from-list:
    Edit a file from a list on STDIN
vi-from-find:
    Recursively search for a file and open it in vim - TODO
vi-from-history:
    Search eternal history for an existing file an open it in vi
vi-from-path:
    Find an executable in the path and edit it
vnc-server-setup-upstart-script:
    Setup remote desktop access via ssh and vnc right from the login
    screen of
vnc-start-vino:
    Start vino vnc server
vnc-vino-preferences:
    Set vino preferences
vncviewer:
    preconfigured to use ssh
wcat:
    Easily dump a web site
webserver-serve-current-directory:
    Serve current directory files via http
wikipedia-via-dns:
    Query wikipedia via DNS
xmv:
    Rename files by perl expression
xtitle:
    Change the title of a x window

### fatpacked app abs ##########################################################

#!/usr/bin/env perl

# Print the absolute path of a file or dir

use Cwd;
my $file = $ARGV[0] || ".";
my $abs = Cwd::abs_path($file);
$abs .= "/" if -d $file;
$abs = "'$abs'" if $abs =~ /\s/;
$abs =~ s/;/\\;/g;
print "$abs\n";

### fatpacked app alternative ##################################################

#!/bin/bash

# Find an on disk executable alternative

source bash-helpers

app=${1?Specify app}

if ! [[ $app =~ / ]] ; then
    DIE "Specify absolute path to executable."
fi

if ! [ -x $app ] ; then
    DIE "Specify existing executable."
fi

base=$(basename $app)

INFO "Searching for alternative for $base ($app)"

while read candidate ; do

    if [[ $candidate = $app ]] ; then
        continue
    fi

    if [[ $candidate = $REMOTE_HOME/.bin/$base ]] ; then
        continue
    fi

    INFO "Found alternative $candidate"

    RETURN $candidate

done <<EOF
    $(type -ap $base || echo $app)
EOF

DIE "No alternative found for $base ($app)"

### fatpacked app alternative-run ##############################################

#!/bin/bash

# Find an on disk executable alternative and run it

set -e

source bash-helpers

app=$1 ; shift

if [[ $SHLVL -gt 20 ]] ; then
    DIE "Recursion depth of $SHLVL detected."
fi

alternative=$(alternative $app)

exec $alternative "$@"

### fatpacked app app-knows-switch #############################################

#!/usr/bin/env perl

# Check if an app supports specified switch

use strict;
use warnings;

my $app    = $ARGV[0] || die "Specify app.";
my $switch = $ARGV[1] || die "Specify switch.";

my $output = `$app --help 2>&1`;

exit 0 if $output =~ /^\s*$switch/ms;

exit 1;

### fatpacked app apt-hold-package #############################################

#!/bin/bash

# Prevent a deb package from beeing upgraded

set -e

package_name=${1?package name?}
dpkg --get-selections $package_name
echo $package_name hold | sudo dpkg --set-selections
dpkg --get-selections $package_name

### fatpacked app apt-pop ######################################################

#!/usr/bin/env perl

# Search for a debian package, sort by ranking, add description

use strict;
use warnings;
no warnings 'uninitialized';
use Data::Dumper;
use autodie;

my %apps = ();
open( F, qq{apt-cache search "@{[ join(" ", @ARGV) ]}" |} );
while (<F>) {
    my ( $app, $desc ) = /^(.+?) - (.+)$/;
    next if $app =~ /^lib/;
    $apps{$app}{exists} = 1;
}

my %ranks = ();

open( F, qq{wget -qqO- http://popcon.debian.org/by_inst.gz | gunzip |} );
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
    $ranks{"_$i"} = { app => $app }
        if !exists $apps{$app}{ranked};
}

print "\n";

foreach my $rank ( sort { $a <=> $b } keys %ranks ) {
    my $app    = $ranks{$rank}{app};
    my ($desc) = `apt-cache show $app` =~ /^Description.*?\:(.+?)\n\S/igsm;
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

### fatpacked app archive ######################################################

#!/bin/bash

# Archive a file appending a timestamp

set -e

source bash-helpers

file=${1?filename not specified}
file=$(perl -pe 's/\/$//g' <<<$file)
bak=$REMOTE_HOME/backup/$file"_"$(date +%Y%m%d_%H%M%S)

INFO "Archiving to: $file -> $bak"

mv $file $bak

### fatpacked app bak ##########################################################

#!/bin/bash

# Backup a file appending a timestamp

set -e

source bash-helpers

file=${1?filename not specified}
bak=$file"_"$(date +%Y%m%d_%H%M%S)

INFO "Backing up: $file -> $bak"

if [ -d $file ] ; then
    cp -r $file $bak
else
    cp $file $bak
fi

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


### fatpacked app bash-eternal-history-search ##################################

#!/usr/bin/env perl

# Search specially formatted bash history

use strict;
use warnings;
no warnings 'uninitialized';
use Data::Dumper;
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
my $hist_regex = '^(.+) (.+) (.+) (\d*) "(.+)" "([\d ]+)" (.+)$';

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
         RED='\[\e[38;5;9m\]'
else
    NO_COLOR=$(echo -e '\x1b[33;0;m')
        GRAY=$(echo -e '\x1b[38;5;243m')
        GREY=$(echo -e '\x1b[38;5;243m')
       GREEN=$(echo -e '\x1b[38;5;2m')
      ORANGE=$(echo -e '\x1b[38;5;')
         RED=$(echo -e '\x1b[38;5;9m')
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
}

### fatpacked app bash-jobs ####################################################

#!/usr/bin/env perl

# Cleaned up bash jobs replacement

# Run like this: jobs=$(jobs) bash-jobs

use strict;
use warnings;
no warnings 'uninitialized';
use Data::Dumper;

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

### fatpacked app bashrc-eternal-history-add ###################################

# Add entry to the eternal bash history

source bash-helpers

$HISTFILE_ETERNAL || DIE "Set HISTFILE_ETERNAL"
$history1 || DIE "Specify history 1"
$history2 || DIE "Specify history 2"

if [[ $BASHRC_NO_HISTORY ]] ; then
    exit 0
fi

# TODO remove history position (by splitting)
# history1=$(history 1)
# history2=$(history 2)

[[ $history1 = $history2 ]] && EXIT;

read -r pos cmd <<< $history1

if [[ $cmd == "rm "* ]] ; then
    cmd="# $cmd"
    history -s "$cmd"
fi

quoted_pwd=${PWD//\"/\\\"}

# update cleanup_eternal_history if changed:
line="$USER"
line="$line $(date +'%F %T')"
line="$line $BASHPID"
line="$line \"$quoted_pwd\""
line="$line \"$bashrc_last_return_values\""
line="$line $cmd"
echo "$line" >> $HISTFILE_ETERNAL

### fatpacked app bashrc-helper-hostname #######################################

# Format hostname for bash prompt usage

source bash-helpers

echo -n $GREEN${HOSTNAME}$NO_COLOR

### fatpacked app bashrc-helper-login-name #####################################

# Format login for bash prompt usage

source bash-helpers

skip_non_root=$1

if [[ $USER = "root" ]] ; then
    RETURN "${RED}$USER${NO_COLOR}"
fi

if [[ $skip_non_root ]] ; then
    RETURN;
fi

RETURN $USER

### fatpacked app bashrc-pack ##################################################

#!/usr/bin/env perl

# Attach scripts to the bashrc skeleton

use strict;
use warnings;
use Path::Tiny;

die "Not in bin dir." if path(".")->absolute->basename ne "bin";

my $bashrc_skel = path("../dotfiles/bashrc");
my $bashrc_phat = path("../bashrc/bashrc");

$bashrc_skel->copy($bashrc_phat);

my $apps_count = 0;

foreach my $bin (sort (path(".")->children)) {

    next if $bin->is_dir;

    # say STDERR "Packing $bin...";

    my $description = "fatpacked app $bin";

    $bashrc_phat->append("### ", $description, " ",
        "#" x (80 - length($description) - 5) . "\n\n");

    $bashrc_phat->append($bin->slurp, "\n");

    $apps_count++;
}

$bashrc_phat->append("### END fatpacked apps ", "#" x 57, "\n");

print "Done - apps packed: $apps_count\n";

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

### fatpacked app cp-merge-directories #########################################

#!/bin/bash

# Merge two directories on the same disk recursively by using hard links
# and avoiding to copy a file

source bash-helpers

src=${1?specify source directory}
dst=${2?specify destination directory}

test -d "$src" || DIE "Not a directory: $src"
test -d "$dst" || DIE "Not a directory: $dst"

src_device=$(stat --format "%d" "$src")
dst_device=$(stat --format "%d" "$dst")

if [[ $src_device != $dst_device ]] ; then
    DIE "$src and $dst have to reside on the same device for hard links to work"
fi

cp -rnl "$src"/* "$dst"/

### fatpacked app cpanm ########################################################

#!/usr/bin/env perl

# Allow cpanm to install modules specified via Path/File.pm

map { s/\//\:\:/g ; s/\.pm$//g } @ARGV;

system("alternative-run", "$0", "-nq" , @ARGV) && exit 1;

### fatpacked app csvview ######################################################

#!/usr/bin/env perl

# Quick way to view a csv file on the command line

use warnings;
no warnings qw{uninitialized};
use Data::Dumper;

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

my $readme = path("README");
my ($preamble) = $readme->slurp =~ /(.+Descriptions\:)/igms;

$readme->spew("$preamble\n\n");

foreach my $app (sort(path(".")->children)) {

    next if $app->is_dir;
    next if $app->basename eq "README";

    my ($description) = $app->slurp =~ /^=head1 NAME\s+(.+)/m;
    ($description) = $app->slurp =~ /^# (.+?)\n/m if !$description;

    $description =~ s/^$app[\s-]*//g;

    $description = wrap('    ', '    ', $description) if $description;

    print STDERR "Description ends with a dot app: $app\n"
        if $description =~ /\.$/;

    print STDERR "No description found for app: $app\n" if !$description;
    $description ||= "    TODO";

    $readme->append("$app:\n$description\n");
}

### fatpacked app dev-deploy-fat-bashrc ########################################

#!/bin/bash

# Generate and deploy fat packed bashrc

set -e

cd ~/src/bashrc
git reset --hard HEAD
git pull || echo "Nothing to pull"

cd ~/src/bin
./bashrc-pack

cd ~/src/bashrc
git add bashrc
git commit -m "new fat pack"
git push

### fatpacked app df ###########################################################

#!/bin/bash

# Cleaned up df version

source bash-helpers

if [[ $@ ]] ; then
    alternative-run $0 "$@"
    EXIT
fi

alternative-run $0 -h \
    | perl -0777 -pe 's/Mounted on/Mounted_on/gm' \
    | perl -0777 -pe 's/^(\S+)\n/$1/gm' \
    | csvview \
    | less -S

### fatpacked app dir-diff #####################################################

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

### fatpacked app distribution-fix #############################################

# Set conveniences depending on distribution

# TODO

if [[ -e /etc/lsb-release ]] ; then
    . /etc/lsb-release
    DISTRIBUTION=${DISTRIB_ID,,}
elif [[ -e /etc/debian_version ]] ; then
    DISTRIBUTION=debian
else
    DISTRIBUTION=$(cat /etc/*{version,release} 2>/dev/null \
        | perl -0777 -ne 'print lc $1 if /(debian|suse|redhat)/igm')
fi

export DISTRIBUTION
if [[ $DISTRIBUTION = "suse" ]] ; then
    unalias crontab
fi

### fatpacked app docopt-convert ###############################################

#!/usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';

use Docopt;
use JSON;
use autobox::Core;
use Path::Tiny;

my $options  = docopt();
my $app_argv = $options->{"<argv>"};

my $doc_file = path($options->{"<file.docopt>"});
my $doc      = $doc_file->slurp;

my $docopt_ran = 0;

if ($doc =~ /^### docopt #*(.+)/sm) {
    $doc = $1;
}

my $basename = $doc_file->basename;

$doc =~ s/\$0/$basename/gm;

parse_external_doc($doc, $app_argv);

sub parse_external_doc {
    my ($doc, $argv) = @_;

    my $app_options = docopt(doc => $doc, argv => $argv);

    $docopt_ran = 1;

    convert_booleans($app_options);

    my $json =
        JSON->new->pretty($options->{'--pretty'})->encode($app_options);

    $json =~ s/"boolean:(true|false)"/$1/gm;

    print $json;
}

sub convert_booleans {
    my ($twig) = @_;

    if (!ref $twig eq 'HASH') {
        return;
    }

    $twig->each(
        sub {
            my ($key, $value) = @_;
            convert_booleans($value) if ref($value) eq 'HASH';
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
    --shell       Print bash parsable result - TODO
    --p --pretty  Pretty print JSON


### fatpacked app dos2unix #####################################################

#!/bin/bash

# Convert line endings from dos to unix

perl -i -pe 's/\r//g' "$@"

### fatpacked app env-grep #####################################################

# Grep environment

env | grep -i "$@"

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

ubuntu_version=$(cat /etc/issue | perl -ne 'print $1 if /ubuntu (\d+\.\d+)/i')

if [[ $ubuntu_version ]] ; then
    release=$(note ubuntu | perl -ne 'print $_ if /^\s+'$ubuntu_version'\s+(.+?)\s+\d+/')
    SHOW Ubuntu $release
else
    SHOW Linux $(cat /etc/issue.net)
fi

### fatpacked app file-template-filler #########################################

#!/usr/bin/env perl

# Create a file from a template

use strict;
use warnings;
use Data::Dumper;

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

### fatpacked app find-and #####################################################

#!/bin/bash 

# Find files excluding dotfiles optional matching several strings

find . -mount \
    | perl -ne 'print if ! m#/\.#' \
    | grep-and -e $@

### fatpacked app find-from-date ###############################################

# Find files newer than date

find -maxdepth 1 -type f -printf "%CF %CH:%CM %h/%f\n" \
    | perl -ne 'print substr($_, 17) if m#^\Q'$@'\E#'

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

### fatpacked app find-or-grep #################################################

#!/bin/bash

# Find a file or grep stdin

if [[ -t 0 ]] ; then
    find-and | while read i; do grep-and -epf "$i" "$@" ; done
else
    grep-and -e $@
fi

### fatpacked app git-env-validate #############################################

#!/bin/bash

# Ensure git-scm is configured appropriately

set -e

source bash-helpers

git config --global --get user.name  > /dev/null && DIE 'Global user name set!'
git config --global --get user.email > /dev/null && DIE 'Global user email set!'

exit 0

### fatpacked app git-reset-head ###############################################

#!/bin/bash

# Discard commits dating back to specified commit

set -e

source bash-helpers

commit_id=${1?Specify commit id}

git reset --hard $commit_id

INFO "Push now with: git push origin HEAD --force"

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

=item - copy script to ~/.gnome2/nautilus-scripts

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

my $use_thunderbird = 0;

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

### fatpacked app grep-and #####################################################

#!/usr/bin/env perl

# Search for lines matching one or more perl regex patterns

use strict;
use warnings;
use Data::Dumper;

use Getopt::Long;
Getopt::Long::Configure("bundling");

my $red      = "\x1b[38;5;124m";
my $no_color = "\x1b[33;0m";

my $opts = {
    "f|file=s"           => \my $file,
    "p|prefix-file-name" => \my $prefix,
    "e|allow-empty"      => \my $allow_empty,
    "no-color"           => \my $show_no_color,
};
GetOptions(%$opts) or die "Usage:\n$0 " . join("\n", sort keys %$opts) . "\n";

if (!-t STDOUT || $show_no_color) {
    $red = $no_color = "";
}

my @patterns = @ARGV;

if (!$allow_empty) {
    @patterns || die "Specify patterns to search for.";
}

my $h = *STDIN;
if ($file) {
    open($h, $file) || die $!;
}

LINE: while (<$h>) {

    if (!@patterns && $allow_empty) {
        print;
        next;
    }

    foreach my $pattern (@patterns) {
        if (!s/(\Q$pattern\E)/$red$1$no_color/gi) {
            next LINE;
        }
    }

    if ($prefix) {
        printf("%s:%5s: %s", $file, $., $_);
    }
    else {
        print;
    }
}

### fatpacked app grep-before ##################################################

#!/usr/bin/env perl

# Print file contens before a specified regex first matches

while (<STDIN>) {
    print;
    exit 0 if /@ARGV/i;
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
while ( my $line = <STDIN> ) {
    foreach my $regex (@ARGV) {
        next if $line !~ /$regex/i;
        $matches++;
        print $line;
        last;
    }
}

exit 1 if ! $matches;

### fatpacked app java-decompile-jar ###########################################

#!/bin/bash

# Recursively decompile a jar including contained jars

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


### fatpacked app keyboard-disable-caps-lock-console ###########################

#!/bin/bash

# Map caps lock to escape for consoles

(
    echo `dumpkeys | grep -i keymaps` ; \
    echo keycode 58 = Escape \
) | sudo loadkeys -

### fatpacked app keyboard-disable-caps-lock-xwindows ##########################

#!/bin/bash

# Map caps lock to escape for X

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

### fatpacked app man-explain-options ##########################################

#!/usr/bin/env perl

# Display man page infos about command line options

use strict;
use warnings;
no warnings 'uninitialized';
use Data::Dumper;

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

    my ($desc) = $man =~ /^(?:(?:-{1,2}\w+, )*|\s+)($option\W.+?)^\s+-/ms;

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

function _printifok() {
    local msg=$1 ; shift
    local cmd="$*"

    local out=$(MANWIDTH=80 MAN_KEEP_FORMATTING=1 $cmd 2>/dev/null)
    [[ ${out[@]} ]] || return 1
    line $msg
    echo "${out[@]}"
    echo
}

cmd=$1 ; shift

if [[ $cmd = git ]] ; then
    cmd=$cmd-$1
    shift
fi

arg="$1"

if [[ $arg =~ ^-- ]] ; then
   arg="+/$arg"
elif [[ $arg =~ ^- ]] ; then
   arg="+/^\\s+$arg"
elif [[ $arg ]] ; then
   arg="+/$arg"
else
   arg="+/^--- "
fi

(
    _printifok options man-explain-options $cmd "$@"
    _printifok help help -m $cmd
    _printifok man man -a $cmd
    _printifok perldoc perldoc -f $cmd
    _printifok "apt show" apt-cache show $cmd
    _printifok "apt search" apt-cache search $cmd
    _printifok related man -k $cmd

) | LESS="-j.5 -inRg" less $arg

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

### fatpacked app mysql ########################################################

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
    MYSQL_HISTFILE=$history_file alternative-run $0 \
        --default-character-set=utf8 \
        --show-warnings --pager="less -FX" "$@"

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

### fatpacked app net-open-ports ###############################################

# List all open ports

netstat -tapnu | less -S

### fatpacked app note #########################################################

#!/bin/bash

# File of notes and a way to query them

search=$1

if [[ ! $search ]] ; then
    perl -ne 'print " * $1\n" if /^# NOTES ON (.*)/' \
        $0| sort
    exit
fi

perl -0777 -ne \
  'foreach(/^(# NOTES ON '$search'.+?\n\n)/imsg){ s/# //g; print "\n$_" }' \
    $0

# NOTES ON ssh
# * prevent timeouts: /etc/ssh/ssh_config + ServerAliveInterval 5
# * tunnel (reverse/port forwarding):
#     * forward: ssh -v -L 3333:localhost:443 host
#     * reverse:  ssh -nNT [via host] -R [local src port]:[dst host]:[dst port]
#     * socks proxy: ssh -D 1080 host -p port / tsocks program
#     * keep tunnel alive: autossh
# * mount using ssh: sshfs / shfs
# * cssh = clusterssh

# NOTES ON perl
# * call graph: perl -d:DProf <SCRIPTNAME> && dprofpp -T tmon.out (or B::Xref)
# * Print out each line before it is executed: perl -d:Trace <SCRIPTNAME>
# * DBI->trace(2 => "/tmp/dbi.trace");
# * ignore broken system locales in perl programs: PERL_BADLANG=0
# * corelist - perl core modules

# NOTES ON apt
# * apt-cache depends -i 

# NOTES ON bash
# * zenity for dialogs?
# * Advanced Bash-Scripting Guide:
#    http://tldp.org/LDP/abs/html/index.html
# * expand only if files exist: shopt -s nullglob / for x in *.ext ; ...
# * generate unique ID: uuidgen (not thread safe?)
# * unaliased version of a program: prefix with slash i.e.: \ls file

# NOTES ON cron
# * make cron scripts use bashrc (now path can use ~ too)
#    SHELL=/bin/bash
#    BASH_ENV=~/.bashrc
#    PATH=~/bin:/usr/bin/:/bin

# NOTES ON bios
# * infos of system: getSystemId

# NOTES on chroot
# * chroot to fix broken system using live-cd
#   cd /
#   mount -t ext4 /dev/sda1 /mnt
#   mount -t proc proc /mnt/proc
#   mount -t sysfs sys /mnt/sys
#   mount -o bind /dev /mnt/dev
#   cp -L /etc/resolv.conf /mnt/etc/resolv.conf
#   chroot /mnt /bin/bash
#   ...
#   exit
#   umount /mnt/{proc,sys,dev}
#   umount /mnt

# NOTES ON compiling
# * basic steps
#    apt-get install build-essential
#    sudo apt-get build-dep Paketname
#    ./configure
#    sudo checkinstall -D

# NOTES ON console
# * switch console: chvty
# * turn off console-blanking: echo -ne "\033[9;0]" > /dev/tty0
# * lock: ctrl+s / unlock: ctrl+q

# NOTES ON encoding
# * recode UTF-8..ISO-8859-1 file_name
# * convmv: filename encoding conversion tool
# * luit - Locale and ISO 2022 support for Unicode terminals
#      luit -encoding 'ISO 8859-15' ssh legacy_machine

# NOTES ON man and the like
# * apropos - search the manual page names and descriptions

# NOTES ON processes
# * to kill a long running job
#    ps -eafl |\
#       grep -i "dot \-Tsvg" |\ 
#       perl -ane '($h,$m,$s) = split /:/,$F[13];
#          if ($m > 30) { print "killing: " . $_; kill(9, $F[3]) };'
# * disown, (cmd &) - keep jobs running after closing shell
# * continue a stoped disowned job: sudo kill -SIGCONT $PID

# NOTES ON networking
# * fuser
# * lsof -i -n

# NOTES ON recovery
# * recover removed but still open file
#   lsof | grep -i "$file"
#   cp /proc/$pid/fd/$fd $new_file
#   (fd = file descriptor)
# * recover partition: ddrescue
# * recover deleted files: foremost jpg -o out_dir -i image_file

# NOTES ON text csv and other files
# * sort by numeric column: sort -u -t, -k 1 -n file.csv > sort
# * comm - compare two sorted files line by line with 3 column output
# * join files horizontally: paste
# * truncate a file without removing its inode: > file
# * join csv files: join
# * edit shell commands in vi with Ctrl-x Ctrl-e

# NOTES ON sql / mysql
# * INSERT
#    * REPLACE INTO x ( f1, f2 ) SELECT ... - replaces on duplicate key
#    * INSERT IGNORE INTO ... - skips insert on duplicate key
# * default-storage-engine = innodb
# * mysql full join: left join union right join
# * split: SUBSTRING_INDEX(realaccount,'@',-1)
# * convert string to date: STR_TO_DATE(created, "%d.%m.%y")
# * NULL does no match regex use: (f IS NULL OR f NOT REGEXP '^regex$')

# NOTES ON sftp
# * use specifc key file
#     sftp -o IdentityFile=~/.ssh/$keyfile $user@$host
# * use password
#     ltp -u login,pass sftp://host

# NOTES ON user management
# * newgrp - log in to a new group
# * sg - execute command as different group ID

# NOTES ON ubuntu
# 
# * Releases:
#                                                  Supported until
#                                                Desktop      Server
#      4.10       Warty Warthog     2004-10-20   2006-04-30
#      5.04       Hoary Hedgehog    2005-04-08   2006-10-31
#      5.10       Breezy Badger     2005-10-13   2007-04-13
#      6.06 LTS   Dapper Drake      2006-06-01   2009-07-14   2011-06
#      6.10       Edgy Eft          2006-10-26   2008-04-25
#      7.04       Feisty Fawn       2007-04-19   2008-10-19
#      7.10       Gutsy Gibbon      2007-10-18   2009-04-18
#      8.04 LTS   Hardy Heron       2008-04-24   2011-04      2013-04
#      8.10       Intrepid Ibex     2008-10-30   2010-04-30
#      9.04       Jaunty Jackalope  2009-04-23   2010-10-23
#      9.10       Karmic Koala      2009-10-29   2011-04
#     10.04 LTS   Lucid Lynx        2010-04-29   2013-04      2015-04
#     10.10       Maverick Meerkat  2010-10-10   2012-04
#     11.04       Natty Narwhal     2011-04-28   2012-10
#     11.10       Oneiric Ocelot    2011-10-13   2013-04
#     12.04 LTS   Precise Pangolin  2012-04-26   2017-04
#     12.10       Quantal Quetzal   2012-10-18   2014-04
#     13.04       Raring Ringtail   2013-04-25   2014-01
#     13.10       Saucy Salamander  2013-10-17   2014-07
#     14.04 LTS   Trusty Tahr       2014-04-17   2019-04

# NOTES ON vim
# * :help quickref
# * :help quickfix

# NOTES ON x
# * ssh -X host x2x -west -to :4.0

# NOTES ON init
# * sudo update-rc.d vncserver defaults 
# * sudo update-rc.d -f vncserver remove

# NOTES ON encryption
# * fsck encrypted volume
#    - sudo cryptsetup luksOpen /dev/hda5 mydisk
#    - fsck /dev/mapper/mydisk

### fatpacked app path-grep ####################################################

#!/bin/bash

# Find an executable in path
compgen -c | grep -i "$@"

### fatpacked app perl-install-deps-for-module #################################

#!/bin/bash

# Install all CPAN dependencies for a module

perl-install-module lib::xi
perl -c -Mlib::xi=-nq "$@"

### fatpacked app perl-install-latest-stable-perl ##############################

#!/bin/bash

# Install latest stable perl via perlbrew

perlbrew install stable --notest --switch

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

perlbrew list-modules | perlbrew exec --with $version cpanm

### fatpacked app perl-install-perlbrew ########################################

#!/bin/bash

# Install perlbrew

set -e
wcat http://install.perlbrew.pl | bash > /dev/null
source ~/perl5/perlbrew/etc/bashrc
perlbrew init > /dev/null
perlbrew install-cpanm > /dev/null

INFO "You have to re-login now for changes to take effect."

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

### fatpacked app perl-named-process ###########################################

#!/bin/bash

# Set process name of perl process to script name. Usefull when run via /usr/bin/env

# This only works for some tools like pidof because it only changes argv[0] and does
# not call prctl.

set -e

perl=$(alternative $0)

file=$1

if [[ $file ]] ; then
    if [[ -f $file ]] ; then
        file="-a "$(basename $file)
    else
        unset file
    fi
fi

exec $file $perl "$@"

### fatpacked app perl-profile #################################################

#!/bin/bash

# Profile a perl app and display the html results

set -e

perl-install-module Devel::NYTProf

set -x

local script=$(basename $1)
local dir=/tmp/nytprof.$script.$(date +%F_%H%M%S)
mkdir $dir
local file=$dir/nytprof.out

NYTPROF=file=$file perl -d:NYTProf "$@"

nytprofhtml --file $file --out $dir

if [ -e nytprof.out ] ; then
    rm nytprof.out
fi

see $dir/index.html

### fatpacked app perl-setup-local-lib #########################################

#!/bin/bash

# Setup user dir for cpan perl libs using local::lib and cpanm

set -e

if [[ ! $REMOTE_HOME ]] ; then
    REMOTE_HOME=$HOME
fi

dst=$REMOTE_HOME/perl5
bashrc=$REMOTE_HOME/.bashrc

tmp=$(mktemp -d)
cd $tmp

echo
echo "Setting up local::lib..."
echo

wget -q http://cpan.metacpan.org/authors/id/H/HA/HAARG/local-lib-2.000008.tar.gz
tar xfz local-lib*tar.gz
rm *tar.gz

cd local*
perl Makefile.PL --bootstrap=$dst
make install

echo
echo "Setting up cpanm..."
echo

mkdir -p $REMOTE_HOME/bin
cd $REMOTE_HOME/bin
wget -q http://xrl.us/cpanm
chmod +x cpanm

echo
echo "Updating bashrc..."
echo

echo 'eval "$(perl -I'$dst'/lib/perl5 -Mlocal::lib='$dst')"' > bashrc
echo 'alias cpan="(echo use cpanm >&2 ; exit 1)"' >> bashrc
echo 'alias cpanm="cpanm -nq"' >> bashrc
cat $bashrc >> bashrc
cp bashrc $bashrc

echo "done."

### fatpacked app perl-upgrade-outdated-modules ################################

#!/bin/bash

# Upgrade installed perl modules if a new version is available

perlbrew list-modules | cpanm

### fatpacked app prompt-dir ###################################################

# Prompt containing only the prettified current directory

dir-name-prettifier $PWD
echo -n "> "

### fatpacked app prompt-dir-full ##############################################

# Prompt containing the current directory ony

echo -n "$PWD> "

### fatpacked app prompt-helper-git ############################################

#!/usr/bin/env perl
# Add git status information to prompt

# The status is represented in the form of the word git followed by a + or -.
#
# Of the word git+/- the red characters represent:
# g = untracked files
# i = unstaged files
# t = staged files
# + = branch is ahead of master = unpushed changes
# - = branch is behind master

use strict;
use warnings;
no warnings 'uninitialized';

my $red      = '\[\e[38;5;9m\]';
my $gray     = '\[\e[38;5;243m\]';
my $no_color = '\[\e[33;0;m\]';

# test data
my $git = <<'git';
# On branch masterx
# Your branch is ahead of 'origin/master' by 1 commit.
# Untracked files
# Changes not staged for commit
# Changes to be committed
# Your branch and 'origin/master' have diverged,
git

$git = `git status 2>/dev/null` || exit;

$git =~ s/^# //gm;

my ($branch)   = $git =~ /^On branch (.+)$/gm;
my ($revision) = $git =~ /^HEAD detached at (.+)$/gm;
$branch ||= "?" . $revision;

if ($branch eq "master") {
    $branch = "";
}
else {
    $branch = $gray . "@" . $red . $branch . $no_color;
}

my ($branch_status) = $git =~ /^Your branch is (\w+) of/gm;

if ($branch_status eq "ahead") {
    my ($commit_count) =
        $git =~ /^Your branch is ahead of .* by (\d+) commit/gm;
    $branch_status = "+". $commit_count;
}
elsif ($branch_status) {
    $branch_status = "-";
}

if ($branch_status) {
    $branch_status = $gray . $red . $branch_status . $no_color;
}

my $untracked = $gray;
my $unstaged  = $gray;
my $staged    = $gray;
my $conflicts = $gray;

$untracked = $red if $git =~ /^Untracked files/m;
$unstaged  = $red if $git =~ /^Changes not staged for commit/m;
$staged    = $red if $git =~ /^Changes to be committed/m;
$conflicts = $red . "!" if $git =~ /^Your branch .*have diverged/m;

print " "
    . $untracked . "g"
    . $unstaged . "i"
    . $staged . "t"
    . $branch_status
    . $conflicts
    . $no_color
    . $branch;

### fatpacked app prompt-host ##################################################

# Prompt containing the current hostname

source bash-helpers

time-humanize-seconds $elapsed
eval $BASHRC_PROMPT_HELPERS
echo -n " "
bashrc-helper-login-name
echo -n "@"
bashrc-helper-hostname
echo -n ":"
dir-name-prettifier $PWD
jobs=$jobs bash-background-jobs-count
echo -n "> "

### fatpacked app prompt-local #################################################

# Prompt for local shells - without hostname

source bash-helpers

time-humanize-seconds "$elapsed"
eval $BASHRC_PROMPT_HELPERS
prefixif $(bashrc-helper-login-name 1)
prefixif $(dir-name-prettifier $PWD)
jobs=$jobs bash-background-jobs-count
echo -n "> "

### fatpacked app prompt-plain #################################################

# Static prompt

echo -n "BASH> "

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
app-knows-switch pstree -g && switches=$switches"g"

pstree $switches \
    | perl -ne '$x = "xxSKIPme"; print if $_ !~ /[\|`]\-\{[\w-_]+},\d+$|less.+\+\/'$1'|$x/' \
    | less "+/$search"

### fatpacked app publicip #####################################################

#!/bin/bash

# Find own public ip when behind proxy

wcat http://checkip.dyndns.org \
    | perl -ne '/Address\: (.+?)</i || die; print $1'

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
use Data::Dumper;
use Getopt::Long;

my $red = "\x1b[38;5;124m";
my $dry = 1;

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
    . ( $dry ? "$red - dry run." : "" ) . "\n";

### fatpacked app shell-color-test #############################################

#!/usr/bin/perl

# most color mappings taken from xterm-colortest
# at http://www.frexx.de/xterm-256-notes/data/xterm-colortest

use strict;
use warnings;

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

### fatpacked app shell-open-access-on-freeport ################################

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

### fatpacked app ssh-agent-env-clear ##########################################

#!/bin/bash

# Remove connection to ssh-agent

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

### fatpacked app ssh-no-check #################################################

#!/bin/bash

# SSH without host key checks

ssh -A \
    -q \
    -o CheckHostIP=no \
    -o UserKnownHostsFile=/dev/null \
    -o StrictHostKeyChecking=no

### fatpacked app ssh-persistent-reverse-tunnel-setup ##########################

#!/bin/bash

# Setup a persistent reverse tunnel

source bash-helpers

set -e

local ssh_key_file=~/.ssh/reverse-tunnel

if [[ -e $ssh_key_file ]] ; then
    DIE "$ssh_key_file already exists"
fi

local server=${1?Server?}
local port=${2?Port?}

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

### fatpacked app ssh-with-reverse-proxy #######################################

#!/bin/bash

# Proxy traffic of a remote host through localhost
# i.e. if the remote host has no access to the cpan or
# other parts of the internet

set -e

host=${1?specify host}
port=${2:-59347}

proxyserver $port

ssh -A -t $host -R $port:localhost:$port \
    http_proxy=http://localhost:$port \
    https_proxy=https://localhost:$port \
    ftp_proxy=ftp://localhost:$port \
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

### fatpacked app text-quote ###################################################

# Quote text

fmt -s | perl -pe 's/^/> /g' -

### fatpacked app text-remove-comments #########################################

# Remove comment from text

perl -ne 'print if ! /^#/ && ! /^$/' -

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

### fatpacked app tmux-reattach ################################################

#!/bin/bash

# Reattach to a screen or tmux session

session=$1

if [[ ! $session ]] ; then
    session=main
fi

ssh-agent-env-grab

(
    xtitle tmux@$HOSTNAME
    if tmux has-session -t $session ; then
        tmux -2 att -d -t $session
        exit 0
    fi


    if tmux has-session ; then
        tmux -2 att -d
        exit 0
    fi

    xtitle screen@$HOSTNAME
    screen -rd $session && exit
    screen -rd && exit

    xtitle "Terminal"

    exit 1

) && clear

### fatpacked app tree #########################################################

#!/usr/bin/env perl

# List a directory as a tree

use strict;
use warnings;
no warnings 'uninitialized';

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

use File::stat;

binmode STDOUT, ":utf8";
use File::Basename;
use Cwd qw(abs_path getcwd);
use File::Spec;

use Getopt::Long;
Getopt::Long::Configure("bundling");
my %o                  = ();
my @option_definitions = (
    "directories-only|d", "summary",   "all|a",            "colors!",
    "ascii",              "eval|e=s",  "exec|execute|x=s", "include=s",
    "grep|g=s",           "exclude=s", "empty!",           "v|verbose",
    "info|i",             "warnings!", "mounted!",         "stats",
    "age",                "size|s",    "entry-count",      "html",
    "abs",
);

GetOptions( \%o, @option_definitions )
    or die "Usage:\n" . join( "\n", sort @option_definitions ) . "\n";

$o{empty}    = 1 if !defined $o{empty};
$o{warnings} = 1 if !defined $o{warnings};
$o{mounted}  = 0 if !defined $o{mounted};
$o{colors}   = 1 if !defined $o{colors};

if ( $ENV{LANG} !~ /utf/i ) {
    $o{ascii} = 1;
}

if ( $o{info} ) {
    $o{age}           = 1;
    $o{size}          = 1;
    $o{'entry-count'} = 1;
}

if ( $o{grep} ) {
    $o{include} = ".*" . $o{grep} . ".*";
    $o{empty}   = 0;
}
if ( $o{include} ) {
    $o{all} = 1;
}

$ARGV[0] ||= getcwd;

my $root_dev;

foreach my $root_dir (@ARGV) {

    $root_dir = File::Spec->rel2abs($root_dir);
    $root_dev = stat($root_dir)->dev;
    $root_dir =~ s/\/$//g;

    if ( $o{v} ) {
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

my ( $blue, $green, $red, $gray, $no_color );
my ( $graph_vertical, $graph_t, $graph_l, $graph_line );
my %warnings;
my %stats;

sub init {
    if ( $o{colors} ) {
        $blue     = "\x1b[34;5;250m";
        $green    = "\x1b[32;5;250m";
        $red      = "\x1b[31;5;250m";
        $gray     = "\x1b[38;5;243m";
        $no_color = "\x1b[33;0m";
    }

    if ( $o{html} ) {
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

    if ( $o{ascii} ) {
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

    if ( $o{html} ) {
        print "<pre>\n";
    }

    $self->_print;
    $self->print_warnings;
    $self->print_stats;

    if ( $o{html} ) {
        print "</pre>\n";
        print "<hr noshade>\n" if $self->multiple;
    }
}

sub _print {
    my ( $self, $parent, $is_parent_last_entry, $prefix ) = @_;

    $self->prefix($prefix);

    my $name = $self->name;
    $name = $self->abs if $o{abs} && $self->is_root;

    print $self->prefix
        . $self->dir_prefix($is_parent_last_entry)
        . $self->color
        . $name
        . $self->link_info
        . $no_color
        . ( $o{warnings} ? $self->warnings : "" )
        . $self->info . "\n";

    my $next_prefix = $is_parent_last_entry ? "  " : $graph_vertical . " ";
    $next_prefix = $self->prefix . $next_prefix;
    $next_prefix = "" if $self->is_root;

    my $entry_count         = keys %{ $self->entries };
    my $current_entry_count = 0;
    foreach my $path_name ( sort keys %{ $self->entries } ) {

        $current_entry_count++;
        my $is_last_entry = $current_entry_count == $entry_count;

        my $path = $self->entries->{$path_name};

        if ( $path->is_dir ) {
            $path->_print( $self, $is_last_entry, $next_prefix );
            next;
        }

        my $name = $path->name;
        if ( $path->count > 1 ) {
            $name
                = $red
                . $path->count . "x "
                . $green
                . $path->normalized_marking
                . $no_color;
        }

        print $self->prefix
            . $self->file_prefix( $is_parent_last_entry, $is_last_entry )
            . $path->color
            . $name
            . $path->link_info
            . ( $o{warnings} ? $path->warnings : "" )
            . $path->info
            . $no_color . "\n";
    }
}

sub link_info {
    my ($self) = @_;
    return if !$self->is_link;
    return "$red -> " . readlink( $self->abs ) . $no_color;
}

sub print_warnings {

    return if !%warnings;
    return if !$o{warnings};

    print "\n${red}Warnings:${no_color}\n", dumps( \%warnings, $red ), "\n";
}

sub print_stats {

    return if !%stats;
    return if !$o{stats};

    print "\nStats:\n", dumps( \%stats ), "\n";
}

sub dumps {
    my ( $ref, $color ) = @_;

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

    if ( $secs >= $y ) {
        $human = sprintf( "%.1fy", $secs / $y );
    }
    elsif ( $secs >= $d99 ) {
        $human = sprintf( "%0dw", $secs / $w );
    }
    elsif ( $secs >= $h99 ) {
        $human = sprintf( "%0dd", $secs / $d );
    }
    elsif ( $secs >= $m99 ) {
        $human = sprintf( "%0dh", $secs / $h );
    }
    elsif ( $secs >= $m ) {
        $human = sprintf( "%0dm", $secs / $m );
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

    if ( $bytes >= $t ) {
        $human = sprintf( "%.1fT", $bytes / $t );
    }
    elsif ( $bytes >= $g ) {
        $human = sprintf( "%.1fG", $bytes / $g );
    }
    elsif ( $bytes >= $m ) {
        $human = sprintf( "%.1fM", $bytes / $m );
    }
    elsif ( $bytes >= $k ) {
        $human = sprintf( "%.1fK", $bytes / $k );
    }
    elsif ( $bytes == 0 ) {
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
        . join( "$no_color, $red", @{ $self->{warnings} } )
        . $no_color;
}

sub info {
    my ($self) = @_;

    my @info;

    if ( $o{'entry-count'} ) {
        push( @info, "Entries: " . ( keys %{ $self->entries } || 0 ) )
            if $self->is_dir;
    }

    if ( $o{age} ) {
        push( @info, $self->age );
    }

    if ( $o{size} ) {
        push( @info, $self->size );
    }

    if ( $o{eval} ) {
        $_ = $self->abs;
        my $eval = eval $o{eval};
        die $@ if $@;
        push( @info, $eval );
    }

    if ( $o{exec} ) {
        my $exec = $o{exec};
        my $abs  = $self->abs;
        $exec =~ s/\{\}/'$abs'/g;
        print STDERR "Executing in the shell: $exec\n" if $o{v};
        $exec = `$exec`;
        $exec =~ s/\n+$//g;
        $exec =~ s/\n/ | /g;
        $exec =~ s/^ +//g;
        push( @info, $exec );
    }

    return if !@info;
    return " " . $gray . join( ", ", @info ) . $no_color;
}

sub file_prefix {
    my ( $self, $is_last_dir_entry, $is_last_entry ) = @_;

    my $fork     = $is_last_entry     ? $graph_l : $graph_t;
    my $dir_fork = $is_last_dir_entry ? " "      : $graph_vertical;
    if ( $self->is_root ) {
        $dir_fork = "";
    }
    else {
        $dir_fork .= " ";
    }

    return $dir_fork . $fork . $graph_line;
}

sub dir_prefix {
    my ( $self, $is_last_entry ) = @_;

    return if $self->is_root;

    my $fork = $is_last_entry ? $graph_l : $graph_t;

    return $fork . $graph_line;
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

    my $dev = stat( $self->abs )->dev;

    if ( $dev != $root_dev ) {
        return 1;
    }

    return 0;
}

sub add {
    my ( $self, $path ) = @_;

    if ( !$path->is_dir && $o{include} ) {
        return 0 if $path->abs !~ /$o{include}/i;
    }

    if ( !$path->is_dir && $o{exclude} ) {
        return 0 if $path->abs =~ /$o{exclude}/i;
    }

    $path->add_warnings;

    if ( $path->is_dir ) {

        $path->color($blue);
        $stats{Directories}++;

        if ( $path->name =~ /^\.(git|svn)/ ) {
        }
        elsif ( !stat( $path->abs ) ) {
        }
        elsif ( $path->is_mounted ) {
        }
        elsif ( !$path->is_link ) {
            $path->add_children;
        }

        $path->add_to_global_warnings;

        if ( $path->name =~ /^\./ ) {
            return if !$o{all};
        }

        if ( !$path->has_entries && !$o{empty} ) {
            return;
        }

        $self->entries->{ $path->name } = $path;
        return;
    }

    if ( $o{'directories-only'} ) {
        return;
    }

    $path->color($green);

    $path->add_to_global_warnings;

    if ( $path->name =~ /^\./ ) {
        return if !$o{all};
    }

    my ($extension) = $path->name =~ /\.([^\.]+)$/;
    $extension = "" if $path->name !~ /\./;
    $extension = "" if $extension =~ /^\d+$/;

    $stats{Files}++;
    $stats{'File extensions'}{$extension}++;

    my $path_key = $path->name;

    if ( $o{summary} ) {
        $path_key = $path->normalized;
        $path->count(1);
    }

    if ( exists $self->entries->{$path_key} ) {
        $self->entries->{$path_key}{count}++;
    }
    else {
        $self->entries->{$path_key} = $path;
    }
}

sub add_warning {
    my ( $self, $warning ) = @_;
    push( @{ $self->{warnings} }, $warning );
}

sub add_warnings {
    my ($self) = @_;

    if ( $self->name =~ /^\./ ) {
        $self->add_warning('DOTFILE');
    }

    $self->add_warning("PRECEDING SPACE") if $self->name =~ /^\ /;
    $self->add_warning("TRAILING SPACE")  if $self->name =~ /\ $/;

    if ( $self->name =~ /^\.(git|svn)/ ) {
        $self->add_warning("SCM DIR");
    }

    if ( !stat $self->abs ) {
        $self->add_warning("READ ERROR");
    }
    else {

        if ( $self->is_mounted ) {
            $self->add_warning("MOUNTED");
        }

        if ( $self->is_link ) {
            $self->add_warning("LINK");
        }
    }

}

sub add_to_global_warnings {
    my ($self) = @_;

    foreach my $warning ( @{ $self->{warnings} } ) {
        $warnings{$warning}++;
    }
}

sub add_children {
    my ($self) = @_;

    my $dirh;
    if ( !opendir( $dirh, $self->abs ) ) {
        $self->add_warning( "ERROR: " . $! );
        return;
    }

    while ( my $entry = readdir($dirh) ) {

        next if $entry =~ /^\.{1,2}$/;

        my $path = Path->new( parent_name => $self->abs, name => $entry, );

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

    # return $self->normalized;

    my $normalized = $self->name;
    $normalized =~ s/([0-9a-f\-]{2,}|[\W\d\s_]{2,})/${red}$^N$no_color/gi;
    return $normalized;
}

sub age {
    my ($self) = @_;

    my $stat = stat( $self->abs ) || return;

    my $age   = time - $stat->mtime;
    my $h_age = humanize_secs($age);
    $h_age = $red . $h_age . $no_color if $h_age =~ /[sm]/;
    return "Changed: $h_age";
}

sub size {
    my ($self) = @_;

    return if $self->is_dir;

    my $stat = stat( $self->abs ) || return;

    my $size       = $stat->size;
    my $blocks     = $stat->blocks;
    my $block_size = $stat->blksize;

    my $alloc = $blocks * 512;
    my $done  = 100;
    $done = $alloc / ( $size / 100 ) if $size != 0;
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

my $rel = qx{rel "@ARGV"};
$rel =~ s/\n$//g;
$rel = "\"$rel\"" if $rel =~ /\s|;/;
print "$ENV{USER}\@$ENV{HOSTNAME}:$rel\n"

### fatpacked app vi-choose-file-from-list #####################################

# Edit a file from a list on STDIN

set -e

line=$1

if [[ ! $line ]] ; then
    cat | nl
    exit 0
fi

file=$(cat | perl -ne 'print if $. == '$line)

# close STDIN by connecting it back to the terminal
exec < $BASHRC_TTY

command eval $EDITOR $file

### fatpacked app vi-from-find #################################################

# Recursively search for a file and open it in vim - TODO

search=$(perl -e '$_ = "'"$@"'" ; s#\:\:#/#g; print')

entry=$(find-and "$search" | head -1)

if [[ ! "$entry" ]] ; then
    exit 1
fi

command eval $EDITOR "$entry"

### fatpacked app vi-from-history ##############################################

# Search eternal history for an existing file an open it in vi

set -e
file=$(bash-eternal-history-search --file -c 1 "$@")
command eval $EDITOR "$file"

### fatpacked app vi-from-path #################################################

#!/bin/bash

# Find an executable in the path and edit it

set -e

file=$(type -p $@)

command eval $EDITOR "$file"

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

### fatpacked app webserver-serve-current-directory ############################

#!/bin/bash

# Serve current directory files via http

perl-install-module App::HTTPThis
http_this

### fatpacked app wikipedia-via-dns ############################################

#!/bin/bash

# Query wikipedia via DNS

dig +short txt "$@".wp.dg.cx | perl -0777 -pe 'exit 1 if ! $_ ; s/\\//g'

### fatpacked app xmv ##########################################################

#!/usr/bin/env perl

# Rename files by perl expression
# Protects against duplicate resulting file names.

use strict;
use warnings;
no warnings 'uninitialized';
use Data::Dumper;

use File::Basename;
use File::Copy qw(mv);
use File::stat;

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

my %will  = ();
my %was   = ();
my $abort = 0;
my $COUNT = 0;

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
    mv( $was, $will ) || die $!;
    utime( $stat->atime, $stat->mtime, $will ) || die $!;
}

sub normalize {
    my ($abs) = @_;

    my $file = basename($abs);
    my $ext  = "";

    if ( !-d $abs && $file =~ /^(.+)(\..+?)$/ ) {
        ( $file, $ext ) = ( $1, $2 );
    }

    $_ = $file;

    s/www\.[^\.]+\.[[:alnum:]]+//g;
    s/&/and/g;
    s/['`´]+//g;
    s/[^\w\.]+/_/g;
    s/[\._]+/_/g;
    s/^[\._]+//g;
    s/[\._]+$//g;

    $_ ||= "_empty_file_name";

    return $_ . lc($ext);
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

### END fatpacked apps #########################################################
