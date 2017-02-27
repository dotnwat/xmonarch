#include <string>
#include <iostream>
#include <cassert>
#include <string.h>
#include "base64.h"
#include "keccak.h"
#include "jh.h"
#include "blake.h"
#include "skein.h"
#include "groestl.h"

int main(int argc, char **argv)
{
  assert(argc == 2);

  // read base64 encoded input string
  std::string input((std::istreambuf_iterator<char>(std::cin)),
      (std::istreambuf_iterator<char>()));

  // decode into binary blob
  std::string blob;
  Base64::Decode(input, &blob);

  // hash
  unsigned char buf[200];
  memset(buf, 0, sizeof(buf));

  if (strcmp(argv[1], "keccak") == 0) {
    keccak((unsigned char *)blob.c_str(), blob.size(),
        buf, sizeof(buf));
  } else if (strcmp(argv[1], "jh") == 0) {
    jh(256, (unsigned char *)blob.c_str(), blob.size() * 8, buf);
  } else if (strcmp(argv[1], "blake") == 0) {
    blake((unsigned char *)blob.c_str(), blob.size(), buf);
  } else if (strcmp(argv[1], "skein") == 0) {
    skein(256, (unsigned char *)blob.c_str(), blob.size() * 8, buf);
  } else if (strcmp(argv[1], "groestl") == 0) {
    groestl((unsigned char *)blob.c_str(), blob.size() * 8, buf);
  } else {
    std::cerr << "unknown function: " << argv[1] << std::endl;
    assert(0);
  }

  // encode output as base64 and print
  std::string tmp((char*)buf, sizeof(buf));
  std::string output;
  Base64::Encode(tmp, &output);

  std::cout << output << std::endl;

  return 0;
}
