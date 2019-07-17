
/*
 * This binary opens given set of binaries
 */



#include <iostream>
#include <chrono>

#include <unistd.h>
#include <sys/wait.h>

using namespace std;
using namespace chrono;

int main(int argc, char** argv) {

  if (argc != 3) {
    cerr << "error params" << endl;
    return 1;
  }

  long xtimes = stol(argv[1]);
  string bin(argv[2]);


  for (long i = 0 ; i < xtimes ; i++) {
    int pid, status;

    if (pid = fork()) {
      waitpid(pid, &status, 0);
    } else {
      std::string s = bin;
      s.append(std::to_string(i));
      execve(s.c_str(), nullptr, nullptr);
    }
  }
  return 0;
}
