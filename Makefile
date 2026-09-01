PACKAGE_DIRS = \
	lib/domain/model \
	lib/domain/usecase \
	lib/gateway/flutter_haptic_gateway \
	lib/gateway/system_clock_gateway \
	lib/gateway/wakelock_screen_awake_gateway \
	lib/gateway/url_launcher_external_map_gateway \
	lib/gateway/native_geocoding_service \
	lib/gateway/geolocator_location_service \
	lib/gateway/shared_preferences_onboarding_gateway \
	lib/gateway/native_overlay_service \
	lib/gateway/method_channel_storage

TEST_PACKAGE_DIRS = \
	lib/domain/model \
	lib/domain/usecase

FLUTTER_TEST_PACKAGE_DIRS = \
	lib/gateway/geolocator_location_service \
	lib/gateway/shared_preferences_onboarding_gateway

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
	fvm dart format lib test integration_test

analyze:
	@for package_dir in $(PACKAGE_DIRS); do \
		(cd $$package_dir && fvm dart analyze) || exit 1; \
	done
	fvm flutter analyze

test:
	@for package_dir in $(TEST_PACKAGE_DIRS); do \
		(cd $$package_dir && fvm dart test) || exit 1; \
	done
	@for package_dir in $(FLUTTER_TEST_PACKAGE_DIRS); do \
		(cd $$package_dir && fvm flutter test) || exit 1; \
	done
	fvm flutter test
