#!/usr/bin/env bash
#
# This script...
#
# Style guide: https://google.github.io/styleguide/shellguide.html

### CONFIGURATION

set -e  # Exit on first failure
set -u  # Fail on referencing undefined variable
# set -x  # Output all commands to terminal
set -o pipefail  # Return code is the same return code as the last command


### CONSTANTS

readonly CONSTANT=""

# declare -ra ARRAY=(
#   "VALUE"  
# )

# declare -rA MAP=(
#   [KEY]="VALUE"
# )


### INPUT FLAGS
INPUT_A=false
INPUT_B=""


### STRING FORMATTERS
if [[ -t 1 ]] then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_underline="$(tty_escape "4;39")"
tty_mkbold() { tty_escape "1;$1"; }
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"


### TITLER

# Prints a title.
#
# Arguments:
#   1) Words to print in the title 
function titler::print_title() {
  echo
  echo "------------- ${1} -------------"
  echo
}


### COMMAND EXECUTOR
declare -a COMMANDS_RUN

function executor::print_commands_run() {
  titler::print_title "Execution Summary"
  echo "Commands executed:"
  printf '  %s\n' "${COMMANDS_RUN[@]}"
  echo
}

# Runs a command and displays error/success messages
# for tracking script progress.
function executor::run_command() {
  COMMAND=$1
  COMMANDS_RUN+=("$COMMAND")
  eval $COMMAND
}


### FUNCTIONS

# Output the help instructions and quit.
function help() {
  echo "Usage: template.bash [OPTION]"
  echo "  -a         Sets value A to true."
  echo "  -b NAME    Sets value B to NAME."
  exit 1
}

# Output the argument to stderr (file descriptor 2) and exit.
function abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

# Use the shell's audible bell.
function ring_bell() {
  if [[ -t 1 ]] then
    printf "\a"
  fi
}

# Wait for user input to confirm continuation of process.
function wait_for_user() {
  local c
  echo
  echo "Press ${tty_bold}RETURN${tty_reset}/${tty_bold}ENTER${tty_reset} to continue or any other key to abort: "
  getc c
  # Test for \r and \n because some OSes use \r instead
  if ! [[ "${c}" == $'\r' || "${c}" == $'\n' ]] then
    exit 1
  fi
}

# Parse all input flags.
#
# Arguments:
#   $@ (i.e. the arguments from invoking this script)
function parse_flags() {
  # Flags with a trailing colon must include a value
  local option_flags=": h a b:"
  
  while getopts option_flags FLAG; do
    case "$FLAG" in
      h)
        help
        ;;
      a)
        INPUT_A=true
        echo "A: true"
        ;;
      b)
        INPUT_B="${OPTARG,,}"  # Convert to lowercase
        echo "B: $INPUT_B"
        ;;
      \?)
        echo "Invalid option: -${OPTARG}"
        echo
        help
        ;;
      :)
        echo "Invalid option: -${OPTARG} requires an argument."
        echo
        help
    esac
  done

  shift $((OPTIND -1))  # Reset the getops iterator
  echo
}

### MAIN
# The code is wrapped in a main function which gets called at the end of the file
# so a truncated partial download will not execute a partial script.
function main() {
  parse_flags $@
  local start_time=$(date +%s)

  titler::print_title "Starting Execution"

  # Do something
  executor::run_command "echo \"Hello world!\""

  executor::print_commands_run
  echo "Total execution time: $((($(date +%s) - start_time) / 60)) minutes."
  echo
  echo "Exiting."
}

main "$@"
