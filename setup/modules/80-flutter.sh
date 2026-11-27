# desc: Flutter SDK (snap) + JDK 17; Android SDK still via Android Studio
# default: off
# check: snap list flutter
apt_install openjdk-17-jdk clang cmake ninja-build pkg-config libgtk-3-dev
snap list flutter > /dev/null 2>&1 || sudo snap install flutter --classic
flutter --version > /dev/null 2>&1 || true
ok "flutter installed; install Android Studio for the SDK, then run: flutter doctor --android-licenses"
