.PHONY: check fmt lint test hooks rust-sweep clean

check:
	./scripts/check.sh

fmt:
	cargo fmt --all

lint:
	cargo clippy --all-targets -- -D warnings

test:
	cargo test

hooks:
	pre-commit install --install-hooks
	pre-commit install --hook-type commit-msg

rust-sweep:
	cargo sweep --time 7 --recursive .

clean:
	cargo clean
