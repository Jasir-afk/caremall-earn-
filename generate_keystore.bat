@echo off
echo Deleting old keystore if exists...
del /f /q android\app\upload-keystore.jks
echo Generating new keystore with password 'caremall'...
keytool -genkey -v -keystore android\app\upload-keystore.jks -storepass caremall -keypass caremall -alias upload -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=CareMall, OU=Development, O=CareMall, L=City, S=State, C=US"
echo Keystore generation complete!
pause
