.PHONY: doc json ready

ready:
	dart analyze
	dart test

doc:
	dart doc .

deps:
	dart pub install

json:
	dart run build_runner build --delete-conflicting-outputs

play:
	dart run bin/play.dart
