#!/bin/sh

APP=microsoft-edge

# TEMPORARY DIRECTORY
mkdir -p tmp
cd ./tmp || exit 1

# DOWNLOAD APPIMAGETOOL
if ! test -f ./appimagetool; then
	wget -q "$(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | sed 's/"/ /g; s/ /\n/g' | grep -o 'https.*continuous.*tool.*86_64.*mage$')" -O appimagetool
	chmod a+x ./appimagetool
fi

# CREATE CHROME BROWSER APPIMAGES

_create_edge_appimage(){
	if wget --version | head -1 | grep -q ' 1.'; then
		wget -q --no-verbose --show-progress --progress=bar "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-$CHANNEL/$(curl -Ls https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-"$CHANNEL"/ | grep -Po '(?<=href=")[^"]*' | sort --version-sort | tail -1)"
	else
		wget "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-$CHANNEL/$(curl -Ls https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-"$CHANNEL"/ | grep -Po '(?<=href=")[^"]*' | sort --version-sort | tail -1)"
	fi
	ar x ./*.deb
	tar xf ./data.tar.xz
	mkdir "$APP".AppDir
	mv ./opt/microsoft/msed*/* ./"$APP".AppDir/
	mv ./usr/share/applications/*.desktop ./"$APP".AppDir/
	if [ "$CHANNEL" = "stable" ]; then
		cp ./"$APP".AppDir/"$APP" ./"$APP".AppDir/AppRun
		cp ./"$APP".AppDir/*128.png ./"$APP".AppDir/"$APP".png
	else
		cp ./"$APP".AppDir/"$APP"-"$CHANNEL" ./"$APP".AppDir/AppRun
		cp ./"$APP".AppDir/*128*png ./"$APP".AppDir/"$APP"-"$CHANNEL".png
	fi
	tar xf ./control.tar.xz
	VERSION=$(cat control | grep Version | cut -c 10-)
	ARCH=x86_64 VERSION=$(./appimagetool -v | grep -o '[[:digit:]]*') ./appimagetool -u "gh-releases-zsync|lavilao|MS-Edge-appimage|continuous|Microsoft-Edge-$CHANNEL-*-x86_64.AppImage.zsync" -s ./"$APP".AppDir
	OUTPUT_NAME="Microsoft-Edge-$CHANNEL-$VERSION-x86_64.AppImage"
mv ./*-x86_64.AppImage "./$OUTPUT_NAME" || exit 1
mv ./*-x86_64.AppImage.zsync "./$OUTPUT_NAME.zsync" || exit 1
}

CHANNEL="stable"
mkdir -p "$CHANNEL" && cp ./appimagetool ./"$CHANNEL"/appimagetool && cd "$CHANNEL" || exit 1
_create_edge_appimage
cd ..
mv ./"$CHANNEL"/*.AppImage ./

CHANNEL="beta"
mkdir -p "$CHANNEL" && cp ./appimagetool ./"$CHANNEL"/appimagetool && cd "$CHANNEL" || exit 1
_create_edge_appimage
cd ..
mv ./"$CHANNEL"/*.AppImage ./

CHANNEL="dev"
mkdir -p "$CHANNEL" && cp ./appimagetool ./"$CHANNEL"/appimagetool && cd "$CHANNEL" || exit 1
_create_edge_appimage
cd ..
mv ./"$CHANNEL"/*.AppImage ./

cd ..
mv ./tmp/*.AppImage ./
