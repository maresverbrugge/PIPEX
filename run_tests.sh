#!/bin/bash

# This is a simple tester for pipex.

# Colours
RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

# Program input
if [[ "$1" == "bonus" ]]; then
	bonus="1"
else
	bonus="0"
fi

# Exit variables
exit_status_bash="0"
exit_status_yours="0"

# Check for pipex executable
if [[ -f pipex_debug ]]; then
	pipex="./pipex_debug"
elif [[ -f pipex ]]; then
	pipex="./pipex"
else
	echo "No pipex executable found."
	exit 1
fi

echo "Running $pipex"

# Input file name
file_in="/tmp/file_in"

# Create input file
cat << EOF > $file_in
codamcodingcollege
codam
ahhaha
codamamsterdam
codanmgotcha
EOF

# $1: input file
# $2: cmd1
# $3: cmd2
# $4: output file
run_pipex()
{
	"$pipex" "$1" "$2" "$3" "$4"
	exit_status_yours="$?"
}

# $1 whole command to execute
run_bash()
{
	if [[ "$(uname)" == "Linux" ]]; then
		bash -c "$1"
	else
		zsh -c "$1"
	fi

	exit_status_bash="$?"
}

# $1: exit_status_bash
# $2: exit_status_yours 
# $3: file_out_bash
# $4: file_out_yours
compare_outputs()
{
	# Compare exit status
	if [[ ("$1" == "0" && "$2" == "0") || ("$1" != "0" && "$2" != "0") ]]; then
		echo -e "${GREEN}SUCCES${NC}: Exit codes correct (yours="$2" | bash="$1")"
	else
		echo -e "${RED}ERROR${NC}: Exit codes differ (yours="$2" | bash="$1")"
	fi

	# Compare output files
	diff "$3" "$4" > /dev/null 2>&1
	if [[ "$?" == "0" ]]; then
		echo -e "${GREEN}SUCCES${NC}: Output files the same."
	else
		echo -e "${RED}ERROR${NC}: Output files differ."
	fi

	# Delete created files
	if [[ -f "$3" && -f "$4" ]]; then
		rm -f "$3" "$4"
	fi

	echo ""
}

# Test 1: Normal test
echo "Test 1: Normal test"
run_bash "< $file_in grep contents | wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "grep contents" "wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 2: Test with correct absolute path to first command.
echo "Test 2: Correct absolute path to first command."
run_bash "< $file_in /usr/bin/grep codam | wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "/usr/bin/grep codam" "wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 3: Test with incorrect absolute path to first command.
echo "Test 3: Incorrect absolute path to first command."
run_bash "< $file_in /bin/grep codam | wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "/bin/grep codam" "wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 4: Test with correct absolute path to second command.
echo "Test 4: Correct absolute path to second command."
run_bash "< $file_in grep codam | /usr/bin/wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "grep codam" "/usr/bin/wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 5: Test with incorrect absolute path to second command.
echo "Test 5: Incorrect absolute path to second command."
run_bash "< $file_in grep codam | /bin/wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "grep codam" "/bin/wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 6: Test with correct absolute path to first and second command.
echo "Test 6: Correct absolute path to first and second command."
run_bash "< $file_in /usr/bin/grep codam | /usr/bin/wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "/usr/bin/grep codam" "/usr/bin/wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 7: Test with incorrect absolute path to first and second command.
echo "Test 7: Incorrect absolute path to first and second command."
run_bash "< $file_in /bin/grep codam | /bin/wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "/bin/grep codam" "/bin/wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 8: Test with other command than Test 1.
echo "Test 8: Other command than Test 1."
run_bash "< $file_in ls -la | wc -w > /tmp/file_out_bash"
run_pipex "$file_in" "ls -la" "wc -w" /tmp/file_out_yours
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 9: Input file doesn't exist.
echo "Test 9: Input file doesn't exist."
run_bash "< ewa_broer grep contents | wc -l > /tmp/file_out_bash"
run_pipex ewa_broer "grep contents" "wc -l" /tmp/file_out_yours
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 10: command 1 doesn't exist.
echo "Test 10: Command 1 doesn't exist."
run_bash "< $file_in grep12 contents | wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "grep12 contents" "wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 11: command 2 doesn't exist.
echo "Test 11: Command 2 doesn't exist."
run_bash "< $file_in grep contents | wc12 -l > /tmp/file_out_bash"
run_pipex "$file_in" "grep contents" "wc12 -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 12: command 1 invalid options.
echo "Test 12: Command 1 invalid options."
run_bash "< $file_in grep -Q codam | wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "grep -Q codam" "wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 13: command 2 invalid option.
echo "Test 13: Command 2 invalid option."
run_bash "< $file_in grep contents | wc -x > /tmp/file_out_bash"
run_pipex "$file_in" "grep contents" "wc -x" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 14: Outputfile without write permission.
echo "Test 14: Outputfile without write permission."
touch /tmp/no_permissions_bash /tmp/no_permissions_yours
chmod 444 /tmp/no_permissions_bash 
chmod 444 /tmp/no_permissions_yours
run_bash "< $file_in grep contents | wc -l > /tmp/no_permissions_bash"
run_pipex $file_in "grep contents" "wc -l" "/tmp/no_permissions_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/no_permissions_bash" "/tmp/no_permissions_yours"

# Test 15: Input file without read permission.
echo "Test 15: Input file without read permission."
touch /tmp/no_read_permissions
chmod 333 /tmp/no_read_permissions
run_bash "< /tmp/no_read_permissions grep contents | wc -l > /tmp/file_out_bash"
run_pipex "/tmp/no_read_permissions" "grep contents" "wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"
rm -f /tmp/no_read_permissions

# Test 16: Executable no execute permission
echo "Test 16: Executable no execute permission."
cp "pipex" "/Users/hyilmaz/.brew/bin/"
chmod 444 "/Users/hyilmaz/.brew/bin/pipex" 
run_bash "< $file_in grep codam | /Users/hyilmaz/.brew/bin/pipex > /tmp/file_out_bash"
run_pipex "$file_in" "grep codam" "/Users/hyilmaz/.brew/bin/pipex" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"
rm -f "/Users/hyilmaz/.brew/bin/pipex"

# Test 17: Using pipe but not needed.
echo "Test 17: Using pipe but not needed."
run_bash "< $file_in ls -l | grep codam $file_in > /tmp/file_out_bash"
run_pipex "$file_in" "ls -l" "grep codam $file_in" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 18: Empty input command 1
echo "Test 18: Empty input command 1"
run_bash "< $file_in \"\" | wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "" "wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 19: Empty input command 2
echo "Test 19: Empty input command 2"
run_bash "< $file_in ls -la | \"\" > /tmp/file_out_bash"
run_pipex "$file_in" "ls -la" "" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 20: Empty input file 1
echo "Test 20: Empty input file 1"
run_bash "< \"\" ls -la | wc -l > /tmp/file_out_bash"
run_pipex "" "ls -la" "wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# # Test 21: Empty input file 2
# echo "Test 21: Empty input file 2 (NOTE: this test gives error comparing the output files, because both don't exist. Don't stress this is oke)"
# run_bash "< $file_in ls -la | wc -l > \"\""
# cat "" > /tmp/file_out_bash
# run_pipex "$file_in" "ls -la" "wc -l" ""
# cat "" > /tmp/file_out_yours
# compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 22: Incorrect relative path command 1
echo "Test 22: Incorrect relative path command 1"
run_bash "< $file_in ../../../../usr/bin/grep codam | wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "../../../../usr/bin/grep codam" "wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 23: Correct relative path command 1
echo "Test 23: Correct relative path command 1"
run_bash "< $file_in ../../../../../usr/bin/grep codam | wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "../../../../../usr/bin/grep codam" "wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 24: Incorrect relative path command 2
echo "Test 24: Incorrect relative path command 2"
run_bash "< $file_in grep codam | ../../../../usr/bin/wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "grep codam" "../../../../usr/bin/wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 25: Correct relative path command 2
echo "Test 25: Correct relative path command 2"
run_bash "< $file_in grep codam | ../../../../../usr/bin/wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "grep codam" "../../../../../usr/bin/wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 26: Test with spaces as commands
echo "Test 26: Test with spaces for command 1"
run_bash "< $file_in \"  \" | wc -l > /tmp/file_out_bash"
run_pipex "$file_in" "  " "wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 27: Test with spaces as commands
echo "Test 27: Test with spaces for command 2"
run_bash "< $file_in ls -la | \"  \" > /tmp/file_out_bash"
run_pipex "$file_in" "ls -la" "  " "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 28: Test with spaces as input file
echo "Test 28: Test with spaces as input file"
run_bash "< \"  \" grep codam | wc -l > /tmp/file_out_bash"
run_pipex "  " "grep codam" "wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 29: Test with spaces as output file
echo "Test 29: Test with spaces as output file"
run_bash "< $file_in grep codam | wc -l > \"  \""
cat "  " > /tmp/file_out_bash
run_pipex "$file_in" "grep codam" "wc -l" "  "
cat "  " > /tmp/file_out_yours
rm -f "  "
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 30: Input file is directory
echo "Test 30: Input file is directory"
run_bash "< \".\" grep codam | wc -l > /tmp/file_out_bash"
run_pipex "." "grep codam" "wc -l" "/tmp/file_out_yours"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

# Test 31: Output file is directory
echo "Test 31: Output file is directory"
run_bash "< $file_in grep codam | wc -l > /tmp/"
run_pipex "$file_in" "grep codam" "wc -l" "/tmp/"
compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/" "/tmp/"

# Test 32: No PATH variable
# tmp_path="$PATH"
# unset PATH
# echo "Test 32: No PATH variable. NOTE: output files are not created. So red is good."
# run_bash "< $file_in grep contents | wc -l > /tmp/file_out_bash"
# run_pipex "$file_in" "grep contents" "wc -l" "/tmp/file_out_yours"
# export PATH="$tmp_path"
# compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

if [[ "$bonus" == "1" ]]; then

	# Test 33
	echo "Test 33: Multiple commands"
	run_bash "< $file_in ls -l | grep pipex | wc -l > /tmp/file_out_bash"
	"$pipex" "$file_in" "ls -l" "grep pipex" "wc -l" "/tmp/file_out_yours"
	exit_status_yours="$?"
	compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

	# Test 34
	echo "Test 34: Multiple commands empty input middle command"
	run_bash "< $file_in ls -l | \"\" | wc -l > /tmp/file_out_bash"
	"$pipex" "$file_in" "ls -l" "" "wc -l" "/tmp/file_out_yours"
	exit_status_yours="$?"
	compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

	# Test 35
	echo "Test 35: Multiple commands empty input last command"
	run_bash "< $file_in ls -l | grep pipex | \"\" > /tmp/file_out_bash"
	"$pipex" "$file_in" "ls -l" "grep pipex" "" "/tmp/file_out_yours"
	exit_status_yours="$?"
	compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

	# Test 36
	echo "Test 36: Multiple commands, no process communication"
	run_bash "< $file_in ls -l | ping -c 3 google.com | cat $file_in > /tmp/file_out_bash"
	"$pipex" "$file_in" "ls -l" "ping -c 3 google.com" "cat $file_in" "/tmp/file_out_yours"
	exit_status_yours="$?"
	compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

	# Test 37
	echo "Test 37: Multiple commands extreme, no process communication"
	run_bash "< $file_in ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -l | ls -la | wc -l > /tmp/file_out_bash"
	"$pipex" "$file_in" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -l" "ls -la" "wc -l" "/tmp/file_out_yours"
	exit_status_yours="$?"
	compare_outputs "$exit_status_bash" "$exit_status_yours" "/tmp/file_out_bash" "/tmp/file_out_yours"

fi