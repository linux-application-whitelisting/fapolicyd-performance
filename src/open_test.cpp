
/*
 * This binary opens given set of binaries
 */



#include <iostream>
#include <chrono>

#include <vector>

#include <unistd.h>
#include <sys/wait.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


int main(int argc, char** argv) {

  if (argc != 3) {
    std::cerr << "error params" << std::endl;
    return 1;
  }

  std::string bin(argv[1]);
  long xtimes = std::stol(argv[2]);
  std::vector<std::string> v;

  long long counter = 0;
  for (long i = 0 ; i < xtimes; i++) {
    v.push_back(bin + std::to_string(i));
  }

  //  std::cout << "Start" << std::endl;

  auto start = std::chrono::system_clock::now();
  auto end = start;
  std::chrono::duration<double> elapsed_seconds;

  while(1) {
    for (long i = 1 ; i <= xtimes; i++) {
      int fd = open(v[i].c_str(), O_RDONLY);
      if (fd < 0) {
        continue;
      }
      counter++;
      close(fd);
    }

    end = std::chrono::system_clock::now();
    elapsed_seconds = end-start;
    if (elapsed_seconds.count() > 60.0)
      break;
  }

  std::cout << counter << std::endl;
  std::cout << elapsed_seconds.count() << std::endl;
  //std::cout << "End" << std::endl;

  return 0;
}
