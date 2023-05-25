.PHONY: doc json

doc:
	dart doc .

json:
	dart run build_runner build --delete-conflicting-outputs
