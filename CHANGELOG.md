# CHANGELOG

## 1.1.1 - 2016-08-12

* GitHub has made some general service changes (e.g., adding signing support), so we have adapted the docs and Makefile appropriately.
* Cleaned-up and improved the code samples in the documentation.
* Explicitly removes the `client_secret` in case the customer accidentally provides it.

## 1.1.0 - 2015-04-23

* Removed the `Rakefile`.
* Added a `Makefile` to help simplify deployment tasks.
* Added documentation to the README about deployment tasks.
* Renamed `lib/signer.rb` → `lib/wepay-signer.rb`.
* Ensure that all values passed to the `Signer` class are strings.

## 1.0.0 - 2015-04-17

* Initial release.
