# Comparison and verification code from https://gist.github.com/z2s8/edee650329de288a4da4

require "openssl"
require "openssl/hmac"

# constant time string comparison between fixed length strings
# forked from github.com/rack/rack, modified to work with crystal
def secure_compare(a, b)
  return false unless a.bytesize == b.bytesize

  l = a.bytes

  r, i = 0, -1
  b.each_byte { |v| r |= v ^ l[i += 1] }
  r == 0
end

def verify_signature(payload_body, hub_signature, secret_token)
  signature = "sha1=" + OpenSSL::HMAC.hexdigest(:sha1, secret_token, payload_body)
  secure_compare(signature, hub_signature)
end
