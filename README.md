This is a generic space shooter game using coffeescript for the logic and HTML5 canvas for the rendering.

Overview
========

See the TODO for things that we are interested in working on in the future.

To develop
==========

Install node.js and npm, and npm install [coffee-toaster](https://github.com/serpentem/coffee-toaster)

    $ npm install -g coffee-toaster

coffee-toaster is currently used to be able to split up all of our project files and automatically recompile and merge on changes. To run it, invoke:

    $ toaster -w

To work with the stylesheets:

    $ gem install sass

and run ./scripts/sass-watcher
