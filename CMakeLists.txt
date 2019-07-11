cmake_minimum_required (VERSION 2.6)
project (aw_bench)

add_custom_target (
  run
  ./src/same_bin
  all
  )

add_subdirectory (src)
