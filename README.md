heroku-buildpack-libvips
=====================

Heroku buildpack with [libvips](https://libvips.github.io/libvips/) installed.

You can even use the [ruby-vips](https://github.com/libvips/ruby-vips) gem 😉

## Requirements

Important notes:

In order to use this buildpack, you must install `glib-2.0` packages in your heroku application.

The easiest way to do this is using the [heroku apt buildpack](https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-apt).
#### Command-line

```
heroku buildpacks:add --index 1 heroku-community/apt
```
#### Aptfile

Create a new file named `Aptfile` in your app root directory and append the following packages:

```
libglib2.0-0
libglib2.0-dev
```

You can add [extra packages](https://libvips.github.io/libvips/install.html#optional-dependencies) like `libjpeg` `libpng` `libtiff` `giflib` `libwebp` `libpoppler` and more.
Get any [packages you may have missing](https://github.com/libvips/libvips/wiki/Build-for-Ubuntu#building-from-source).

## Usage

1. Make sure the required `glib-2.0` [dependency for libvips](https://libvips.github.io/libvips/install.html#dependencies) is fulfilled.
2. Add this buildpack to your app:
#### Command-line

To use the latest stable version:

```
heroku buildpacks:add --index 2 zoras/heroku-buildpack-libvips
```

To use the edge version (i.e. the code in this repo):

```
heroku buildpacks:add -i 2 https://github.com/zoras/heroku-buildpack-libvips
```

## Build script

[This](./build.sh) is the script used to build libvips.
