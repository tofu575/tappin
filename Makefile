PACKAGE_DIRS = \
	lib/domain/model \
	lib/domain/usecase \
	config \
	lib/gateway/device_gateway \
	lib/gateway/api_client \
	lib/gateway/remote_image_gateway \
	lib/gateway/stub/in_memory_user_repository \
	lib/gateway/stub/in_memory_observation_repository \
	lib/gateway/stub/in_memory_discussion_repository \
	lib/gateway/stub/stub_image_metadata_reader \
	lib/presentation

.PHONY: flutter-run-device flutter-build-apk flutter-build-apk-stub flutter-build-bundle flutter-build-ios api-codegen pub-get format analyze test

DART_DEFINES_FILE ?= dart-defines.json
DART_DEFINES_OPTION = --dart-define-from-file=$(DART_DEFINES_FILE)
STUB_GATEWAY_DEFINE = --dart-define=OCHIZU_GATEWAY_MODE=stub

flutter-run-emulator:
	fvm flutter emulators --launch Pixel_5_API_33 && fvm flutter run $(DART_DEFINES_OPTION)

flutter-run-device:
	fvm flutter run $(DART_DEFINES_OPTION)

flutter-build-apk:
	fvm flutter build apk $(DART_DEFINES_OPTION)

flutter-build-apk-stub:
	fvm flutter build apk --debug $(DART_DEFINES_OPTION) $(STUB_GATEWAY_DEFINE)

flutter-build-bundle:
	fvm flutter build appbundle --release $(DART_DEFINES_OPTION)

flutter-build-ios:
	fvm flutter build ios $(DART_DEFINES_OPTION)

api-codegen:
	cd lib/gateway/api_client && ../../../.fvm/flutter_sdk/bin/dart run tool/sync_openapi.dart
	cd lib/gateway/api_client && ../../../.fvm/flutter_sdk/bin/dart run build_runner build

pub-get:
	fvm flutter pub get
	@for package_dir in $(PACKAGE_DIRS); do \
		(cd $$package_dir && fvm flutter pub get) || exit 1; \
	done

format:
	fvm dart format config/lib config/test lib test

analyze:
	cd config && fvm dart analyze
	fvm flutter analyze

test:
	cd config && fvm dart test
	fvm flutter test
