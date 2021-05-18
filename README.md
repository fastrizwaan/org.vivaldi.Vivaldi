# Vivaldi Browser Flatpak
This is a testing repository for trying to build the Vivaldi Browser into a Flatpak.

## Building
* clone repository
* cd into the repository folder
* run this command to build `flatpak-builder build-dir org.vivaldi.Vivaldi.json --install --user`

## Assumptions

* Browswer requires similar dependencies to other browsers (Edge, FireFox, Chromium)

* Widevine and ffmpeg need to work properly for the browser to be successful

* LD_Preload is going to be a problem as it is required for both zypak and Vivaldi
