#!/bin/bash
sed --in-place $HOME/.config/gtk-3.0/gtk.css -e 's/background-image.*;/;/g'

