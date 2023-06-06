.PHONY: doc json ready

ready:
	dart analyze
	dart test

doc:
	dart doc .

json:
	dart run build_runner build --delete-conflicting-outputs
