#!/bin/sh

#-----------------------------------------------------------------------------

waveform_viewer="gtkwave"
# waveform_viewer="surfer"

#-----------------------------------------------------------------------------
# Utility functions
#-----------------------------------------------------------------------------

find_path()
{
    search_path=$1
    i=0

    while [ "$i" -lt 3 ]
    do
        [ -d "$search_path" ] && break
        search_path=../$search_path
        i=$((i + 1))
    done

    if [ -d "$search_path" ]
    then
        echo "$search_path"
    else
        echo "none"
    fi
}

#-----------------------------------------------------------------------------

run_icarus()
{
    extra_args=$1

    # $extra_args has to be unquoted here, otherwise it would pass as a single argument
    # shellcheck disable=SC2086
    iverilog -g2012                  \
             -o sim.out              \
             $extra_args 2>&1        \
             | tee log.txt           \
             && vvp sim.out          \
             >> log.txt 2>&1
}

#-----------------------------------------------------------------------------

run_verilator()
{
    extra_args=$1

    # $extra_args has to be unquoted here, otherwise it would pass as a single argument
    # shellcheck disable=SC2086
    verilator --lint-only      \
              -Wall            \
              --timing         \
              $lint_rules_path \
              $extra_args      \
              >> lint.txt 2>&1

}


#-----------------------------------------------------------------------------

check_iverilog_executable()
{
    if ! command -v iverilog > /dev/null 2>&1
    then
        printf "%s\n"                                                \
               "ERROR: Icarus Verilog (iverilog) is not in the path" \
               "or cannot be run."                                   \
               "See README.md file in the package directory"         \
               "for the instructions how to install Icarus."         \
               "Press enter"

        read -r enter
        exit 1
    fi
}

#-----------------------------------------------------------------------------

check_verilator_setup()
{
    if ! command -v verilator > /dev/null 2>&1
    then
        printf "%s\n"                                                             \
               "ERROR [-l | --lint]: Verilator is not in the path"                \
               "or cannot be run."                                                \
               "See README.md file in the package directory for the instructions" \
               "how to install Verilator."                                        \
               "Press enter"

        read -r enter
        exit 1
    fi

    lint_rules_path="../.lint_rules.vlt"
    i=0

    while [ "$i" -lt 3 ]
    do
        [ -f $lint_rules_path ] && break
        lint_rules_path=../$lint_rules_path
        i=$((i + 1))
    done

    if ! [ -f $lint_rules_path ]
    then
        printf "%s\n"                                             \
               "ERROR: Config file for Verilator cannot be found" \
               "Press enter"

        read -r enter
        exit 1
    fi
}

#-----------------------------------------------------------------------------
# Main functions
#-----------------------------------------------------------------------------

simulate_rtl()
{
    if [ ! -f $1 ]; then
        echo "Error: no program to run"
    fi

    check_iverilog_executable

    rm -f sim.out
    rm -f dump.vcd
    rm -f log.txt

    inst_rom=$1
    inst_template=$1.in.sv
    sed -e 's#TEST_PROGRAM#"'$1'"#' $TEST_DIR/instruction_rom.in > $inst_template

    extra_args="-I src/ src/*.sv tests/tb.sv $inst_template"
    choice=0

    run_icarus "$extra_args"

    # Don't print iverilog warning about not supporting constant selects
    sed -i -e '/sorry: constant selects/d' log.txt
    # Don't print $finish calls to make log cleaner
    sed -i -e '/finish called/d' log.txt
}

#-----------------------------------------------------------------------------

lint_code()
{
    common_path=$(find_path "../common")
    check_verilator_setup

    rm -f lint.txt

    extra_args="-I$common_path"

    if [ -f tb.sv ]
    then
        extra_args="$extra_args
                    *.sv
                    -top tb"

        run_verilator "$extra_args"
    elif [ -d testbenches ]
    then
        extra_args="$extra_args
                    -I$common_path/isqrt
                    -Itestbenches
                    testbenches/*.sv
                    *.sv
                    -top tb"

        run_verilator "$extra_args"
    else
        for d in */
        do
            extra_args="-I$common_path"

            {
                printf "==============================================================\n"
                printf "Task: %s\n" "$d"
                printf "==============================================================\n\n"
            } >> lint.txt

            if [ -d "$d"testbenches ]
            then
                extra_args="$extra_args
                            -I$common_path/isqrt
                            -I${d}testbenches
                            -I${d}
                            ${d}testbenches/*.sv
                            ${d}*.sv
                            -top tb"
            else
                if [ -f "$d"testbench.sv ] && grep -q "realtobits" "$d"testbench.sv;
                then
                    import_path=$(find_path "../import/preprocessed/cvw")

                    if [ "$import_path" = "none" ]
                    then
                        continue
                    fi

                    if [ -d "$d"solution_submodules ]
                    then
                        extra_args="$extra_args
                                    -I  ${d}solution_submodules
                                    ${d}solution_submodules/*.sv"
                    fi

                    extra_args="$extra_args
                                -I$import_path
                                $import_path/config.vh
                                -y $common_path/wally_fpu/*.sv
                                -y $import_path/wally_fpu"
                fi

                extra_args="$extra_args
                            ${d}*.sv
                            -top testbench"
            fi

            run_verilator "$extra_args"
        done
    fi

    sed -i -e '/- Verilator:/d' lint.txt
    sed -i -e '/- V e r i l a t i o n/d' lint.txt
}

#-----------------------------------------------------------------------------

# $1 - test source
# $2 - output file
run_assembly()
{
    rars_jar=rars1_6.jar

    #  nc                              - Copyright notice will not be displayed
    #  a                               - assembly only, do not simulate
    #  ae<n>                           - terminate RARS with integer exit code if an assemble error occurs
    #  dump .text HexText program.hex  - dump segment .text to program.hex file in HexText format

    rars_args="nc a ae1 dump .text HexText $2"

    if command -v rars > /dev/null 2>&1
    then
        rars_cmd=rars
    else
        if ! command -v java > /dev/null 2>&1
        then
            printf "%s\n"                                             \
                   "ERROR: java is not in the path or cannot be run." \
                   "java is needed to run RARS,"                      \
                   "a RISC-V instruction set simulator."              \
                   "You can install it using"                         \
                   "'sudo apt-get install default-jre'"               \
                   "Press enter"

            read -r enter
            exit 1
        fi

        rars_cmd="java -jar ../bin/$rars_jar"
    fi

    # $rars_args has to be unquoted in order to pass as multiple arguments
    # shellcheck disable=SC2086

    if ! $rars_cmd $rars_args $1 >> log.txt 2>&1
    then
        printf "ERROR: assembly failed. See log.txt.\n"
        grep Error log.txt
        printf "Press enter\n"
        read -r enter
        exit 1
    fi
}

#-----------------------------------------------------------------------------

open_waveform()
{
    if [ -f dump.vcd ]
    then

        if [ "$waveform_viewer" = "gtkwave" ]
        then
            if [ -f gtkwave.tcl ]
            then
                gtkwave dump.vcd --script gtkwave.tcl &
            else
                gtkwave dump.vcd &
            fi
        elif [ "$waveform_viewer" = "surfer" ]
        then
            if [ -f state.ron ]
            then
                surfer dump.vcd --state-file state.ron &
            else
                surfer dump.vcd &
            fi
        fi

    else
        printf "No dump.vcd file found\n"
        printf "Check that it's generated in testbench for this exercise\n\n"
    fi
}

#-----------------------------------------------------------------------------
# Main logic
#-----------------------------------------------------------------------------
TEST_DIR=tests/

rm $TEST_DIR/*.hex
for test in $TEST_DIR/*.s; do
    prog=${test}.hex

    echo "Runnig test $test"
    run_assembly $test $prog
    simulate_rtl $prog
    echo "End of test $test"
done


while getopts ":lw-:" opt
do
    case $opt in
        -)
            case $OPTARG in
                lint)
                    lint_code;;
                wave)
                    open_waveform;;
                *)
                    printf "ERROR: Unknown option\n"
                    printf "Press enter\n"
                    read -r enter
                    exit 1
            esac;;
        l)
            lint_code;;
        w)
            open_waveform;;
        ?)
            printf "ERROR: Unknown option\n"
            printf "Press enter\n"
            # shellcheck disable=SC2034
            read -r enter
            exit 1;;
    esac
done

grep -e PASS -e FAIL -e ERROR -e Error -e error -e Timeout -e ++ log.txt \
    | sed -e 's/PASS/\x1b[0;32m&\x1b[0m/g' -e 's/FAIL/\x1b[0;31m&\x1b[0m/g'
