#
# Create Universal Static Library for ReSwift
#

# Set bash script to exit immediately if any commands fail.
set -e
 
# If remnants from a previous build exist, delete them.
if [ -d "build" ]; then
rm -rf "build"
fi
 
# Build the framework for device and for simulator (using all needed architectures).
xcodebuild -target ReSwift-iOS -configuration Release -arch arm64 -arch armv7 -arch armv7s only_active_arch=no defines_module=yes -sdk "iphoneos"
xcodebuild -target ReSwift-iOS -configuration Release -arch x86_64 -arch i386 only_active_arch=no defines_module=yes -sdk "iphonesimulator"
 
# Copy the device and simulator version of framework to new universal framework.
mkdir "build/Release-iphoneuniversal"
cp -r "build/Release-iphoneos/ReSwift.framework" "build/Release-iphoneuniversal/ReSwift.framework"

# Merge the binaries of the two frameworks.
lipo -create build/Release-iphoneos/ReSwift.framework/ReSwift build/Release-iphonesimulator/ReSwift.framework/ReSwift -output build/Release-iphoneuniversal/ReSwift.framework/ReSwift

# Fix the Info.plist for the new combined framework. 
plutil -replace CFBundleSupportedPlatforms -json '[ "iPhoneSimulator", "iPhoneOS" ]' build/Release-iphoneuniversal/ReSwift.framework/Info.plist 

# Add Swift module mappings from simulator framework to the new combined framework.
cp "build/Release-iphonesimulator/ReSwift.framework/Modules/ReSwift.swiftmodule/x86_64.swiftdoc" "build/Release-iphoneuniversal/ReSwift.framework/Modules/ReSwift.swiftmodule/"
cp "build/Release-iphonesimulator/ReSwift.framework/Modules/ReSwift.swiftmodule/x86_64.swiftmodule" "build/Release-iphoneuniversal/ReSwift.framework/Modules/ReSwift.swiftmodule/"
