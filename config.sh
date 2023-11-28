export pathToRepo="/Users/username/Documents/myrepo/"
export pathToDb="/Users/username/Documents/Data/myProject/"
export stataCmd="StataMP"
export pythonCmd="python3"

# Section taken from previous lib_run_programs.sh
#!/bin/bash   

# separates "./path/to/program.do" into
#   (1) file = program.do
#   (2) extension = do
#   (3) path_to_file = ./path/to/
#   (4) filename = program
unset parse_fp 
parse_fp() {

    # get arguments
    fp="$1"
    opt="$2"
    
    file="${fp##*/}"

    case $opt in
        1)  output="${file}"
            ;;
        2)  output="${file##*.}"
            ;;
        3)  output="${fp%"${file}"}"
            ;;
        4)  output="${file%.*}"
            ;;
        *)  output="ERROR in parse_fp: unmatched option"
            ;;
    esac

    echo "${output}"

}

unset get_abs_filename
get_abs_filename() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")"
}

# usage: run_stata "${stataCmd}" "${prog}" "${LOGFILE}"
unset run_stata
run_stata() {

    if [[ $# -eq 3 ]]
    then 
        # get arguments
        stata_cmd="$1"
        program="$2"
        logfile="$3"

        # get path to file and file name
        local path_to_file=$(parse_fp "${program}" 3)
        local filename=$(parse_fp "${program}" 4)

        # run program
        (${stata_cmd} -e do code/${program})

        # add default log to log file
        cat "${filename}.log" >> "${logfile}"
        # delete default log
        rm "${filename}.log"

    elif [[ $# -eq 2 ]]
    then
        # get arguments
        stata_cmd="$1"
        program="$2"

        # run stata (log file handled elsewhere)
        (${stata_cmd} -e do ${program})

    else 
        echo "ERROR IN RUN STATA: INVALID NUMBER OF ARGS"
    fi

}

# usage: run_shell "${prog}" "${LOGFILE}"
unset run_shell
run_shell() {

    # get arguments
    program="$1"
    logfile="$2"

    # run program, add output to logfile
    (${SHELL} code/${program} >> "${logfile}")

}

# usage: run_python "${prog}" "${LOGFILE}"
unset run_python
run_python () {

    # get arguments
    program="$1"
    logfile="$2"

    # set python command if unset
    if [ -z "$pythonCmd" ]; then
        echo "No python command set. Using default: python"
        pythonCmd="python"
    fi

    # run program, add output to logfile
    echo "Executing: ${pythonCmd} code/${program} >> \"${logfile}\""
    (${pythonCmd} code/${program} >> "${logfile}")
}

# usage: run_R "${prog}" "${LOGFILE}"
unset run_R
run_R () {

    # get arguments
    program="$1"
    logfile="$2"

    # run program, add output to logfile
    (Rscript code/${program} >> "${logfile}")
}

# usage: run_latex "${programname}" "${LOGFILE}"
unset run_latex
run_latex() {

    # get arguments
    programname="$1"
    logfile="$2"

    abslogfile=$(get_abs_filename "${logfile}")

    # run program, add output to logfile
    rm -f code/${programname}.toc
	rm -f code/${programname}.apt
	rm -f code/${programname}.aux
	rm -f code/${programname}.lof
	rm -f code/${programname}.lot
	rm -f code/${programname}.log
	rm -f code/${programname}.out
    rm -f code/${programname}.bbl
    rm -f code/${programname}.blg
	rm -f code/${programname}.pdf
	rm -f code/missfont.log

    echo "Executing: pdflatex ${programname}.tex >> \"${logfile}\""
    (cd code && pwd && pdflatex ${programname}.tex >> "${abslogfile}")
	for i in {1..10}; do echo >> "${abslogfile}"; done
    
    echo "Executing: bibtex ${programname}.aux >> \"${logfile}\""
    if (cd code && bibtex ${programname}.aux >> "${abslogfile}"); then
        echo "Successfully ran bibtex"
    else
        # print error message
        echo "Error: bibtex failed. See ${logfile} for details."
    fi
	for i in {1..10}; do echo >> "${abslogfile}"; done
    
    echo "Sleeping 1 second..."
    sleep 1
    
    echo "Executing: pdflatex ${programname}.tex >> \"${logfile}\""
	(cd code && pdflatex ${programname}.tex >> "${abslogfile}")
    for i in {1..10}; do echo >> "${abslogfile}"; done

    echo "Executing: pdflatex ${programname}.tex >> \"${logfile}\""
	(cd code && pdflatex ${programname}.tex >> "${abslogfile}")
	for i in {1..10}; do echo >> "${abslogfile}"; done

    # remove program artifacts
    rm -f code/${programname}.toc
	rm -f code/${programname}.apt
	rm -f code/${programname}.aux
	rm -f code/${programname}.lof
	rm -f code/${programname}.lot
	rm -f code/${programname}.log
	rm -f code/${programname}.out
    rm -f code/${programname}.bbl
    rm -f code/${programname}.blg

}

# relies on globals:
#   stataCmd
#   LOGFILE
unset run_programs_in_order
run_programs_in_order() {

    # read a line
    while read prog; do
        # ensure its not just whitespace: 
        # https://unix.stackexchange.com/questions/146942/how-can-i-test-if-a-variable-is-empty-or-contains-only-spaces
        # and doesn't start with #
        # https://www.cyberciti.biz/faq/bash-check-if-string-starts-with-character-such-as/
        if ! [[ -z "${prog// }" || $prog = \#* ]];
        then 
            # parse program for extension
            local programname=$(parse_fp "${prog}" 4)
            local extension=$(parse_fp "${prog}" 2)
            case "${extension}" in
                "do")   echo "\nRunning: ${prog}"
                        run_stata "${stataCmd}" "${prog}" "${LOGFILE}"
                        ;;
                "py")   echo "\nRunning: ${prog}"
                        run_python "${prog}" "${LOGFILE}"
                        ;;
                "R")   echo "\nRunning: ${prog}"
                        run_R "${prog}" "${LOGFILE}"
                        ;;                        
                "tex")  echo "\nRunning: ${prog}"
                        run_latex "${programname}" "${LOGFILE}"
                        ;;
                "sh")   echo "\nRunning: ${prog}"
                        run_shell "${prog}" "${LOGFILE}"
                        ;;
                *)      echo "SKIPPED: ${prog}"
                        echo "No executable for files of type: ${extension}"
                        ;;
            esac 
        fi
    done
}

# Section taken from previous lib_venv.sh
#!/bin/bash

# accepts an optional argument for the environment directory name
unset create_activate_venv
create_activate_venv() {

    # Define the environment directory
    if [ -z "$1" ]; then
        ENV_DIR="${PATH_TO_ROOT}/venv"
    else
        ENV_DIR="${PATH_TO_ROOT}/$1"
    fi

    # Create the virtual environment if it doesn't exist
    echo "Creating virtual environment: ${ENV_DIR}"
    if [ ! -d "$ENV_DIR" ]; then
        python3 -m venv $ENV_DIR
    fi

    # Activate the virtual environment
    echo "Activating virtual environment: ${ENV_DIR}"
    source $ENV_DIR/bin/activate

    # Install dependencies
    echo "Installing venv dependencies from setup/requirements.txt ..."
    pip install -r "${PATH_TO_ROOT}/setup/requirements.txt"

}

# accepts an optional argument for the environment directory name
unset activate_venv
activate_venv() {

    # Define the environment directory
    if [ -z "$1" ]; then
        ENV_DIR="${PATH_TO_ROOT}/venv"
    else
        ENV_DIR="${PATH_TO_ROOT}/$1"
    fi

    # Activate the virtual environment
    echo "Activating virtual environment: ${ENV_DIR}"
    source $ENV_DIR/bin/activate

}
