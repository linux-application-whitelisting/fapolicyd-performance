
add_executable (one-binary one-binary.cpp)
add_executable (multiple-binary multiple-binary.cpp)

install (
  PROGRAMS
  benchmark.sh
  DESTINATION
  bin
  RENAME
  benchmark
  )

install (
  PROGRAMS
  benchmark-single-exec.sh
  DESTINATION
  bin
  RENAME
  benchmark-single-exec
  )
