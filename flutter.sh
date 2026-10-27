sudo apt update
sudo apt install openjdk-17-jdk -y

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/build-tools

flutter config --android-sdk ~/Android/Sdk

sdkmanager "system-images;android-34;google_apis;x86_64"
avdmanager create avd -n flutter_emulator -k "system-images;android-34;google_apis;x86_64"
emulator -avd flutter_emulator

adb kill-server
adb start-server

~/Android/Sdk/emulator/emulator -avd flutter_emulator -gpu swiftshader_indirect -no-snapshot

