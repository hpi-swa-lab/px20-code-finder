# Automatic Code Reuse

## Install
1. Install [GraalVM](https://github.com/graalvm/graalvm-ce-builds/releases/tag/vm-19.3.0) (tested with graalvm-ce-java8-19.3.0 64bit on OSX and Linux)
2. Install the GraalVM build tool [mx](https://github.com/graalvm/mx)
3. Run the `setup.sh` script to compile the languages with no native multi-threading support
    - `./setup.sh --mx /path/to/mx_dir --graal /path/to/graalvm/bin/gu`
2. Install TruffleRuby and GraalSqueak with the [GraalVM Updater](https://www.graalvm.org/docs/reference-manual/graal-updater/)
    ```bash
    gu install ruby
    # Change the link according to your os: https://github.com/hpi-swa/graalsqueak/releases/tag/1.0.0-rc7
    gu install -u https://github.com/hpi-swa/graalsqueak/releases/download/1.0.0-rc7/graalsqueak-installable-linux-amd64-1.0.0-rc7-for-GraalVM-19.3.0.jar
    ```
    - **Don't forget to execute the ruby post-install hook script.**
3. Clone the following repositories:
	  - https://github.com/hpi-swa-lab/pp19-5-automatic-code-reuse
	  - https://github.com/hpi-swa-lab/pp19-6-code-editor
4. Download [a recent Squeak version](https://squeak.org/downloads/) (tested with Squeak5.2-18229-64bit on OSX and Linux)
5. Exchange the image of this Squeak with the [GraalSqueak image](https://www.hpi.uni-potsdam.de/hirschfeld/artefacts/graalsqueak/graalsqueak-0.8.4.zip)
    - MacOS
        1. Copy the downloaded files to `path/to/squeak/Contents/Resources`
        2. Change the key `SqueakImageName` in `path/to/squeak/Contents/Info.plist` to `graalsqueak-1.0.0-rc7.image`
    - Windows/Linux
       1. Copy downloaded files to Squeak folder (and in Linux to `Squeak/shared`)
       2. Start Squeak via `Squeak.exe graalsqueak-1.0.0-rc7.image` or `squeak.sh shared/graalsqueak-1.0.0-rc7.image`
6. Open this Squeak
    1. Install the Squeak Git Browser via Tools -> Git Browser
    2. Add the cloned repositories to the Git browser and checkout the objects (tested with Code-Editor commit 2f37546c5cded4ec539958d32a35e05ba78eac58)
    3. Open the preference browser and set the value `Polyglot>Automatic Code Reuse Project Path` to the root directory of the cloned repository (of this repository)
    4. Optional changes:
        - Go to `MorphicToolBuilder>>buildPluggableCheckbox` and add the following below `widget installButton.`.
        ```
        spec color isColor
            ifTrue: [widget color: spec color].
        ```
        - Go to `PolyglotTextStyler>>style:language:` and add to the top as first line: `false ifFalse: [ ^ aText ].`
7. Install the dependencies from the `code_importer` directory inside the cloned repository
    `bundle install`
      - Refer to [Nokogiri install instructions](https://nokogiri.org/tutorials/installing_nokogiri.html) before you run `bundle install`:
        1. Install system libraries
        	- macOS: `brew install libxml2`
        	- Ubuntu: `sudo apt install build-essential patch zlib1g-dev liblzma-dev`
        3. On macOS run `xcode-select --install` ([or install system headers via .pkg file](https://silvae86.github.io/sysadmin/mac/osx/mojave/beta/libxml2/2018/07/05/fixing-missing-headers-for-homebrew-in-mac-osx-mojave/))
8. Open GraalSqueak with the `graalsqueak-1.0.0-rc7.image`:
     - `graalsqueak --jvm --experimental-options --ruby.single-threaded=false  /path/to/graalsqueak-1.0.0-rc7.image`
