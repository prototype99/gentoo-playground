gentoo-playground
=================
This repository contains ebuilds which fall into the following categories:

* ebuilds modified from those in portage for supporting
  additional features (usually with new USE flags)

* version bumped higher than those yet in the portage tree

* fixed ebuilds for updated dependencies or where there is
  bug in the portage version which hasn't yet been fixed

* all new packages not currently in portage

WARNING! Some ebuilds in this repo supercede those in Portage and have
KEYWORDS copied from their Portage counterparts.  Until I rectify this
or alternatively provide a local mask in this repo, I recommend adding
a local mask for */*::gentoo-playground, then unmasking specific packages
as needed.

I would accept pull requests to rectify this situation.
