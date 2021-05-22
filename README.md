# Vivaldi Browser Flatpak
This is a testing repository for trying to build the Vivaldi Browser into a Flatpak.

## Building
* clone repository
* cd into the repository folder
* run this command to build `flatpak-builder build-dir org.vivaldi.Vivaldi.json --install --user`
* run this command to execute the package in testing `flatpak run org.vivaldi.Vivaldi`

## Assumptions

* Browswer requires similar dependencies to other browsers (Edge, FireFox, Chromium)

~~* Widevine and ffmpeg need to work properly for the browser to be successful~~
* Widewine and ffmpeg works!

* LD_Preload is going to be a problem as it is required for both zypak and Vivaldi

### Install and Create Flatpak
```
 flatpak-builder --force-clean --install --user build-dir org.vivaldi.Vivaldi.json 
 flatpak-builder --repo="repo" --force-clean build-dir/ org.vivaldi.Vivaldi.json 
 flatpak build-bundle "repo" org.vivaldi.Vivaldi.flatpak org.vivaldi.Vivaldi 
 
```
### Install Vivaldi flatpak
```
 flatpak --user install org.vivaldi.Vivaldi.flatpak
```
