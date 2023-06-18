.PHONY: doc json ready test runtrainingserver

ready:
	dart analyze
	dart test

test:
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

runtrainingserver:
	dart run bin/trainingserver.dart
