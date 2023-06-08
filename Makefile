.PHONY: doc json ready

ready:
	dart analyze
	dart test

doc:
	dart doc .

deps:
	dart pub install

js:
	dart compile js lib/src/js.dart -o html/out.js

json:
	dart run build_runner build --delete-conflicting-outputs

play:
	dart run bin/play.dart
