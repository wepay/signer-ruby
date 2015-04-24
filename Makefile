all:
	cat Makefile | grep : | grep -v PHONY

#-------------------------------------------------------------------------------

.PHONY: install
install:
	bundle install

.PHONY: test
test: install
	ruby ./test_helper.rb

.PHONY: docs
docs: install
	yard
	rm -Rf /tmp/gh-pages
	git clone git@github.com:wepay/signer-ruby.git --branch gh-pages --single-branch /tmp/gh-pages
	cp -Rf ./doc/ /tmp/gh-pages/
	cd /tmp/gh-pages/
	git add .
	git commit -a -m "Automated commit at $(date)"
	git push origin gh-pages
