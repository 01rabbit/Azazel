.PHONY: lint test package
lint:
	python -m json.tool < configs/azazel.schema.json > /dev/null
	shellcheck scripts/*.sh
	test -f scripts/bootstrap_mvp.sh
	test -f scripts/nft_apply.sh
	test -f scripts/rollback.sh
	test -f scripts/sanity_check.sh
	test -f scripts/tc_reset.sh
test:
	pytest tests/unit -q
package:
	mkdir -p dist/azazel-installer && \
	cp -r scripts systemd configs azazel_core azctl docs Makefile dist/azazel-installer/ && \
	tar -C dist -czf dist/azazel-installer.tar.gz azazel-installer
