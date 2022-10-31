# Great-Dictator-iOS
iOS demo app for GraalVM Native Image shared library

Please create `development.xcconfig` file under project root directory by following this sample format:

```
USER_HOME=<your user home dir>
GREAT_DICTATOR_INTERFACE=$(USER_HOME)/src/dictator_graal/graal_interface

// used in build settings
NATIVE_COMPILE=$(GREAT_DICTATOR_INTERFACE)/build/native/nativeCompile
APP_HEADERS=$(GREAT_DICTATOR_INTERFACE)/src/main/resources/headers
JAVA_INCLUDE=$(USER_HOME)/.sdkman/candidates/java/current/include
JAVA_INCLUDE_DARWIN=$(JAVA_INCLUDE)/darwin
JAVA_STATIC_LIBS=$(USER_HOME)/.gluon/substrate/javaStaticSdk/18-ea+prep18-8/ios-x86_64/staticjdk/lib/static
```

You'll need to make sure `dictator_graal` [project](https://github.com/philip-han/dictator_graal) is built before building this app.

In this first iteration, only iOS simulator is tested. Some tweaks are necessary for actual device, .e.g. ios-aarch64 libs.

## Using the app

On iOS version, tap the **Dictate** button and start speaking, then tap **Dictate** button again to stop it. On Android, it will stop automatically when silence is detected after speaking.

Of course, NLP server should be running for it to work properly. If the server is down, the app will display an error message.
