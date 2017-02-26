#include <string>
#include <iostream>
#include "base64.h"
#include "keccak.h"

int main(int argc, char **argv)
{
  // read base64 encoded input string
  std::string input((std::istreambuf_iterator<char>(std::cin)),
      (std::istreambuf_iterator<char>()));

  // decode into binary blob
  std::string blob;
  Base64::Decode(input, &blob);

  // hash
  unsigned char buf[200];
  keccak((unsigned char *)blob.c_str(), blob.size(),
      buf, sizeof(buf));

  // encode output as base64 and print
  std::string tmp((char*)buf, sizeof(buf));
  std::string output;
  Base64::Encode(tmp, &output);

  std::cout << output << std::endl;

  return 0;
}
