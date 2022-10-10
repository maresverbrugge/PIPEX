WHOOOOOP 

➖
Piiiiipe 
🥖


NOTES:

PIPE:
communicating between processes: pipe.
a file that has a buffer saved in memory.
you can write to and read from that buffer.
pipe() takes array of 2 integers = file descriptors = key to access a file.
pipe() saves fd's that it uses when it opens a pipe.
fd[0] - read
fd[1] - write
read() waits until there's something to be read from the pipe.
write() waits until there's space in the pipe's buffer.
size of read and write don't have to match:
you can write more than 1 byte, you can only read 1 byte at the time.
first pipe() than fork() so fd's are copied and inherited to other process.
bash/terminal commands: using pipe to make output of one process the input of another process.
stdout(put) of first process is written to the pipe = dup2(fd[1], STDOUT);
stdin(put) of second process is coming from the pipe = dup2(fd[0], STDIN);

FORK:
child process (fork returns 0, this = NOT process id).
parent/main process (fork returns process id of child process).
memory and variables get copied when fork gets called.
wait(NULL); returns -1 if there is nothing to wait for.
2^n processes when you call fork n x times.

OPEN:
opening only the read or write end of a pipe
BLOCKS until the other end is also opened by other process or thread!!!

INFILE:
int file = open("infile.txt", O_WRONLY, 0644);
if (file == -1) --> print error message + return error value.

DUP2:
OUTPUT IN OUTFILE:
use fd as id to handle correct files!
fd 0 = standard input (scanf).
fd 1 = standard output (terminal).
fd 2 = standard error (terminal in red).
fd > 2 = for files you open or create in code. 
dup() takes fd = dup(file) and duplicates so two different fd's point to one file.
dup2() takes fd and value (fd) to duplicate it to! 
dup2(file, 1) will change fd 1 from terminal to <file>.
printf("test"); will then print "test" to <file>!
don't forget to close fd you're NOT using anymore, with close(file).

WAITPID:

COMMANDS:
MAKE PARSE FUNCTION
look for the executable in all the folders found in the PATH environment variable.
commands are stored in a directory, found with PATH=local/bin/usr: etc
int argc, char* argv[], char *envp[]
get envp = PATH (make string PATH and search for that in envp[n])
if PATH found, strip PATH= part and use split on : to get subdirectories
try to find command with access
execve to execute, make sure to throw error after!
to find commands: whereis <cmd> in terminal -> DONT use in code (= forbidden?)!
re-create the whereis command into function?

char **envp contains list of all environment parameters, also:
PATH !!!

EXECVE:
exec function replaces everything after with own memory 
= taking over all other processes.
solve with fork: exec only in child process!
exec not in parent process (because child becomes zombie process).
path to program, path to program, actual argument for program, NULL pointer.
execve(int argc, char *argv[], char *envp[])

does not change process id and fd's that are already opened!

MULTIPLE PIPES:
So the number of pipes will be 2n^2
Which means we will close them 2n^2 times.
There should be 2 open in each child. 
For child n it will be read of child (n-1) and write of child (n)
The main process will be write of 0 (which is the value of n for the parent process) 
and the read will be of (0-1) which is the max value of (n). When implementing the code 
think about the number of children is (n) and the parent is the last process. 
Following this logic will make what i wrote above work without subtracting an extra one or so.

For example, in the video above we had 2 children and 1 parent so we had a total of 3 processes
(but think of n here to be 2, but when declaring the array declare it to n+1), 
child1(n-1) will be child1(0) [for reading]
And child1(n) will be child1(1) [for writing]
And child2(n-1) will be child2(1)....etc.
The same logic applies to the parent as in writing he will be fd[0] and in reading he will be fd[n] or in this case fd[2]

Use dup2 to properly link stdout and stdin of the new processes then call execve. 
If done correctly each process launched should read from the previous' stdout and write to the next stdin.

WIFEXITED = macro, if it returns TRUE (something else than 0) -->
program finished properly, normal termination.
you can take the status code
if status_code == 0 --> success, else --> error/failure

int status_code;
waitpid(pid1, &status_code, 0);

if (WIFEXITED(status_code))
{
    int code = WEXITSTATUS(status);
    printf("status_code = %d\n", code);
    return (code);
}

//////// TESTS ////////
tests in Makefile

Pipexamintor by mdaan:
cd pipexaminator
bash all_tests.sh

run_tests.sh by hyilmaz
bash run_tests.sh 




PRACTICE:
take number in child process
give to parents process
parent process calculates with and prints number
CODE:
int main(int argc, char *argv[])
{
    int fd[2];
    if (pipe(fd) == -1)
    {
        printf("An error ocurred with opening the pipe\n");
        return 1;
    }
    int id = fork();
    if (id == -1)
    {
        printf("An error ocurred with fork\n");
        return 4;
    }
    if (id == 0) // we're in child process
    {
        close(fd[0]); // close read end of pipe
        int x;
        printf("Input a number: ");
        scanf("%d", &x);
        // send x from child process to parents process:
        write(fd[1], &x, sizeof(int));
        if (write(fd[1], &x, sizeof(int) == -1))
        {
            printf("An error ocurred with writing to the pipe\n");
            return 2;
        }
        close(fd[1]); // close write end of pipe
    }
    else // we're in parent process
    {
        close(fd[1]); // close write end of pipe
        int y;
        read(fd[0], &y, sizeof(int));
        if (read(fd[0], &y, sizeof(int) == -1)) // read from read end of pipe = fd[0]
        {
            printf("An error ocurred with reading from the pipe\n");
            return 3;
        }
        y = 10 * y;
        wait(NULL);
        printf("Got from child process nbr: %d\n", y);
        close(fd[0]); // close read end of pipe
    }
    return 0;
}
