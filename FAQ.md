# Frequently asked questions

## Why use this and how?

So how does one use it to enter letters like ä or ß?

- `ä` = `AltGr` + `q`
- `ö` = `AltGr` + `p`
- `ü` = `AltGr` + `y`
- `ä` = `"` + `a`
- `ß` = `AltGr` + `s`
- `¡` = `AltGr` + `!`

You are probably that thinking `AltGr` + `q`, `AltGr` + `p` and `AltGr` + `y`
don't look very intuitive, so what's up with that? Look at your keyboard and you
notice that q is close to a, y is close to u and p is close to o.   The
reasoning is that many of the non-standard letters you want to type will be
close to their base letter so that you don't have to look them up, you can
explore and leverage your muscle memory instead.

- A longer [explanation][8] which made me use his layout.
- Here is [another][9] blogpost about this layout used in the original readme
  for this repository

There is one downside, at least for me, I unintentionally press ® and other
funny letters at times when writing in German.


## Where did this originate from?

The layout was created by [xv0x7c0][1].  I had to change my wording a bit to
find it and started with a mix of [WillerWasTaken][2] and macOS's "U.S.
International – PC" layout, then trying to port the Linux layout with
[Ukelele][3] to macOS.  xv0x7c0 is cleaner to read and complete.



## Is there a difference to xv0x7c0's osx-us-altgr-intl or is this just a repackaged version?

It contains a few changes to bring it closer to the Linux layout which it was
derieved from.  If I had the time I would design my optimal layout for all
platforms, but until then I'm fine with what I have on Linux, Chrome Os and
Windows and prefer consistency.

You can view the differences in a diff viewer like vimdiff or Meld.


## How can I customize this?

You can use [Ukelele][3] on a Mac or a text editor.

In scope patches and improvements are welcome. At the moment I'm not accepting
maintainership for all and everything keyboard related that Apple does not
provide out of the box. Sorry.


## Where and how does one find the Linux files that define this layout?

If you have Gnome on Ubuntu you can follow through with the following: from the
*Settings* app select *Keyboard* > *Input Sources* .  This layout is called
`English (US, intl., with dead keys)`.

So we are going to seach for that:

```
$ grep -r 'English (US, intl., with dead keys)' "/usr/share/"
/usr/share/console-setup/KeyboardNames.pl:	'English (US, intl., with dead keys)' => 'intl',
/usr/share/X11/xkb/rules/evdev.lst:  intl            us: English (US, intl., with dead keys)
/usr/share/X11/xkb/rules/base.lst:  intl            us: English (US, intl., with dead keys)
/usr/share/X11/xkb/rules/base.xml:            <description>English (US, intl., with dead keys)</description>
/usr/share/X11/xkb/rules/evdev.xml:            <description>English (US, intl., with dead keys)</description>
/usr/share/X11/xkb/symbols/us:    name[Group1]= "English (US, intl., with dead keys)";
/usr/share/ibus/component/simple.xml:            <longname>English (US, intl., with dead keys)</longname>
/usr/share/ibus/component/simple.xml:            <description>English (US, intl., with dead keys)</description>
```

`/usr/share/X11/xkb/symbols/us` looks good, lets use that.

We need to have `apt-file` installed for the next step and its [database
initialized][4]

```bash
$ apt-file search /usr/share/X11/xkb/symbols/us
xkb-data: /usr/share/X11/xkb/symbols/us
```

Okay, that's enough terminal for now, so the package name which this file
belongs to is `xkb-data` and after a few links ([1][5], [2][6]) we arrive
[upstream][7].


## Where is the icon from?

It would probably have taken too long for me to find the right search terms, so
I made an SVG myself in Inkscape to somewhat match the shape of the black icon
which already existed in Ukelele.  It looks like I got the color or opacity
wrong.  It's good enough for now.


## Do you prefer any coding styles?

- [Google's Shell Style Guide][10]
- For Markdown in vim use `set ts=4 sw=4 et ai cc=81 tw=80 fo=cq` and wrap
  paragraphs with `vip` and `gq` where appropriate


[1]: https://github.com/xv0x7c0/osx-us-altgr-intl/
[2]: https://github.com/WillerWasTaken/mac-us-int-no-dead-key
[3]: https://software.sil.org/ukelele/
[4]: https://wiki.debian.org/apt-file
[5]: https://packages.ubuntu.com/jammy/xkb-data
[6]: https://www.freedesktop.org/wiki/Software/XKeyboardConfig/
[7]: https://gitlab.freedesktop.org/xkeyboard-config/xkeyboard-config/-/blob/067b28d703c8969782e7078b0747ce56e74841b0/symbols/us#L86
[8]: https://german.stackexchange.com/a/24924/5429
[9]: https://zuttobenkyou.wordpress.com/2011/08/24/xorg-using-the-us-international-altgr-intl-variant-keyboard-layout/
[10]: https://google.github.io/styleguide/shellguide.html
