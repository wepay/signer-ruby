all:
	@cat Makefile | grep : | grep -v PHONY | grep -v 'git@github.com' | sed 's/:/ /' | awk '{print $$1}'

#-------------------------------------------------------------------------------

.PHONY: install
install:
	bundle install

.PHONY: test
test: install
	ruby ./test_helper.rb

#-------------------------------------------------------------------------------

.PHONY: docs
docs: install
	yard

.PHONY: pushdocs
pushdocs: docs
	rm -Rf /tmp/gh-pages
	git clone git@github.com:wepay/signer-ruby.git --branch gh-pages --single-branch /tmp/gh-pages
	cp -Rf ./doc/ /tmp/gh-pages/
	cd /tmp/gh-pages/ && git add . && git commit -a -m "Automated commit on $$(date)" && git push origin gh-pages

#-------------------------------------------------------------------------------

.PHONY: gem
gem: version
	@sed "s/@@version@@/$$(cat .\/VERSION)/" < ./wepay-signer.gemtmpl > ./wepay-signer.gemspec
	gem build wepay-signer.gemspec

.PHONY: pushgem
pushgem: gem
	gem push wepay-signer-$$(cat ./VERSION).gem

#-------------------------------------------------------------------------------

.PHONY: tag
tag:
	@echo "This release will be tagged as: $$(cat ./VERSION)"
	@echo "This version should match your gem. If it doesn't, re-run 'make gem'."
	@echo "---------------------------------------------------------------------"
	@read -p "Press any key to continue, or press Control+C to cancel. " x;

#-------------------------------------------------------------------------------

.PHONY: version
version:
	@echo "Current version: $$(cat ./VERSION)"
	@read -p "Enter new version number: " nv; \
	printf "$$nv" > ./VERSION
