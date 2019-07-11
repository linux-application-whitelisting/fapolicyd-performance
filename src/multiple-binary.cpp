/*
 * This binary opens /bin/true for x times
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

  //auto start = high_resolution_clock::now();

  long xtimes = stol(argv[1]);
  string bin(argv[2]);
  cout << "Iterations: " << xtimes << endl;
  cout << "Binary: " << bin << endl;


  for (long i = 0 ; i < xtimes ; i++) {
    int pid, status;

    if (pid = fork()) {
      waitpid(pid, &status, 0);
    } else {
      execve(bin.c_str(), nullptr, nullptr);
    }
  }


  //auto stop = high_resolution_clock::now();
  //auto duration = duration_cast<microseconds>(stop - start);
  // cout << "Duration: " << duration.count() << endl;

  return 0;
}
