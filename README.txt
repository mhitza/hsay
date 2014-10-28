About
=====

(ab)Use Google Translate as a speech synthesiser. Perfect for reading books,
source code or long-winded licence texts!


Install
=======

hsay is installed using cabal:
  $ cabal install

It works well in a sandbox too:
  $ cabal sandbox init && cabal install

Note that hsay requires mgp123 installed on your system to work!


Run
===

If your cabal binaries are in $PATH after installing, invoke hsay like any
other program:
  $ hsay

It can also be ran via cabal (inside a sandbox or not):
  $ cabal run


Usage
=====
hsay hsays its arguments. It uses Google Translate to obtain an mp3 of what to
say, and plays it with mpg123. To choose a language, pass
-[lowercase-letters-code] to it as the first argument:
  $ hsay -no omggg

If no language is passed, English is assumed. If an unrecognised language is
passed, 404 is returned from Google.

Running hsay without arguments starts a read-evaluate-say-loop (RESL). Type
what you want read, and use ^J to say it. Close the loop with ^D. This mode
works very well with GNU readline wrapper!

Running hsay with *only* a language argument, starts the RESL with that
language.

You may change the language of a running RESL with the #LANG command.
>#LANG -ru

hsay also works well with pipes.


Examples
========
  $ hsay                                    # start RESL
  $ rlwrap hsay                             # rlwrap RESL -- super useful!
  $ resl hsay -en-au                        # start RESL in Australian English
  $ hsay -sv jeans                          # hsay "jeans" in Swedish
  $ echo hallo world | hsay                 # hsay STDIN in Default
  $ echo bøff bøff | hsay -fr               # hsay STDIN in French
  $ cat txt/tolkien/lotr/f1.txt | hsay -ja  # hsay STDIN in Japanese


Flip
====
Thanks to David Bain for his magnificent page-flip recording, licensed as CC0.
