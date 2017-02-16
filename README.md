# JSON-GeRBil
A script thrown together for an Image-to-[JSON-G](https://github.com/Roadcrosser/JSON-G)-to-Image converter. Though this is a **work-in-progress**, it should be able to play nicely with other converters that follow [the JSON-G spec](https://github.com/Roadcrosser/JSON-G/blob/master/spec.md).

Though you'll likely find that [Jsong](https://github.com/fwrs/Jsong) works better for you if you use only PNG, this script is guaranteed to work with anything ImageMagick is capable of reading, which means no need to waste your time converting to PNG first. :)

```
C:\Users\Michelle\Desktop\json-gerbil>ruby image-to-json-g.rb 00f.png
Converting to RGBA...
Slicing and dicing...
Determining most common color...
Converting to pixels...
Putting it all together...
Generating the JSON...
Saving your file...
Done. Took 4.790820837020874 seconds.
```

## Prerequesites.
- The [mini_magick](https://rubygems.org/gems/mini_magick) gem.
- The [json](https://rubygems.org/gems/json) gem.
- ImageMagick installed in a place where Ruby can find it (with legacy tools on windows because mini_magick is a dumb)
  - And because ruby is dumb, it doesn't check the current directory if you intend to just place the tools there. Uncomment [line 55 of image-to-json-g.rb](image-to-json-g.rb#L55) to fix this, but only if you are running the tools from the same directory.
- A fuckton of RAM if you plan to process complex images ~~because why do you give a fuck about efficiency if you're running this~~. Yes I'll **try** to lower it later.

If you feel the need to run everything within a single directory, these files from a static portable windows download worked for me for the usual PNG and JPG files:
- `convert.exe`
- `identify.exe`
- `colors.xml`
- `delegates.xml`
- `magic.xml`
- These all will need to be placed in the same directory, and [line 55 of image-to-json-g.rb](image-to-json-g.rb#L55) will need to be uncommented.

## Issues? Questions?
Feel free to [open an issue](https://github.com/LikeLakers2/JSON-GeRBil/issues/new). Please include a log of what happened when you attempted to run the script, including the exception at the end.

## TODO
- [ ] Samples to prove this works.
- [ ] Do the other way around (JSON-G to Image)
- [ ] Abstract the main method into something that can be called in an arbitrary process.
- [ ] Layer support.
- [ ] Make a common errors section in this readme.