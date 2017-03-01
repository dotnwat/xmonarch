#include <string>
#include <iostream>
#include <cassert>
#include <string.h>
#include "blake.h"
#include "groestl.h"
#include "jh.h"
#include "skein.h"
#include "keccak.h"
#include "json.hpp"

using json = nlohmann::json;

static unsigned char hf_hex2bin(char c)
{
	if (c >= '0' && c <= '9')
		return c - '0';
	else if (c >= 'a' && c <= 'f')
		return c - 'a' + 0xA;
	else if (c >= 'A' && c <= 'F')
		return c - 'A' + 0xA;

	assert(0);
}

static void hex2bin(const char* in, unsigned int len, unsigned char* out)
{
	for (unsigned int i = 0; i < len; i += 2) {
		out[i / 2] = (hf_hex2bin(in[i]) << 4) | hf_hex2bin(in[i + 1]);
	}
}

#if 0
static char hf_bin2hex(unsigned char c)
{
	if (c <= 0x9)
		return '0' + c;
	else
		return 'a' - 0xA + c;
}

static void bin2hex(const unsigned char* in, unsigned int len, char* out)
{
	for (unsigned int i = 0; i < len; i++) {
		out[i * 2] = hf_bin2hex((in[i] & 0xF0) >> 4);
		out[i * 2 + 1] = hf_bin2hex(in[i] & 0x0F);
	}
}
#endif

static bool test_hash(const std::string& func,
    const std::string& message, const std::string& digest)
{
  // decode hex message into binary
  assert(message.size() % 2 == 0);
  unsigned char message_bin[message.size() / 2];
  hex2bin(message.c_str(), message.size(), message_bin);

  // hash binary message into digest_bin
  size_t digest_bin_size = 32;
  unsigned char digest_bin[200]; // maximum needed
  if (func == "blake") {
    blake(message_bin, sizeof(message_bin), digest_bin);
  } else if (func == "groestl") {
    groestl(message_bin, sizeof(message_bin) * 8, digest_bin);
  } else if (func == "jh") {
    jh(256, message_bin, sizeof(message_bin) * 8, digest_bin);
  } else if (func == "skein") {
    skein(256, message_bin, sizeof(message_bin) * 8, digest_bin);
  } else if (func == "keccak") {
    digest_bin_size = 200;
    keccak(message_bin, sizeof(message_bin), digest_bin, 200);
  } else {
    assert(0);
    return false;
  }

  // decode hex digest into binary
  assert(digest.size() % 2 == 0);
  unsigned char target_digest_bin[digest.size() / 2];
  hex2bin(digest.c_str(), digest.size(), target_digest_bin);

  if (sizeof(target_digest_bin) != digest_bin_size)
    return false;

  int res = memcmp(digest_bin, target_digest_bin, sizeof(target_digest_bin));
  return res == 0;
}

int main(int argc, char **argv)
{
  json input;

  std::cin >> input;

  assert(input.is_array());
  for (auto entry : input) {
    assert(entry.is_object());
    const std::string& func = entry["function"];
    const std::string& msg = entry["message"];
    const std::string& digest = entry["digest"];
    bool ok = test_hash(func, msg, digest);
    assert(ok);
    if (!ok)
      return 1;
  }

  return 0;
}
