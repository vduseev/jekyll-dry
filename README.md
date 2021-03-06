# jekyll-dry

[![Build Status](https://travis-ci.org/vduseev/jekyll-dry.svg?branch=master)](https://travis-ci.org/vduseev/jekyll-dry)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/f261f89a633e47e3964ecc37bb826d4f)](https://www.codacy.com/manual/vduseev/jekyll-dry?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=vduseev/jekyll-dry&amp;utm_campaign=Badge_Grade)

Jekyll plugin that helps you to implement the DRY (Don't Repeat Yourself) principle while writing documentation using Jekyll.
The plugin allows you to reuse any fragments of markdown multiple times across a single Jekyll website. The fragments can include Liquid syntax and tags.

## Table of contents

* User Guide:
  * [Usage](#usage)
  * [Installation](#installation)
  * [Incompatibility with GitHub Pages](#incompatibility-with-github-pages)
* Implementation:
  * [Plugin's architecture](architecture.md)
  * [Detailed Design](detailed_design.md)

## Usage

### Fragment's beginning tag: `{% frag ... %}`

`frag` tag marks the beginning of a reusable fragment and assigns a unique id to it. Everything between `frag` and `endfrag` tags with unique id is considered a unique reusable fragment that can be included to any page.

<a name="example-of-frag-usage">Example of usage</a>:
```
It was decided that the amount of dependencies of the executable will
be kept at minimum. For that reason {% frag dependencies %}the only
dependency is Python's `argparse` library{% endfrag dependencies %}.
```

As a result of the above markup the `dependencies` file will be generated and will contain following text:
```
the only dependency is Python's `argparse` library
```

The generated file is now available for inclusion at any page, including the page where it was initially declared. During generation process `frag` tag is replaced in page with an empty string.

### Fragment's end tag: `{% endfrag ... %}`

`endfrag` tag only marks the end of the fragment declared by `frag` tag and is only used by it. After Jekyll processes the page `endfrag` disappears.

If no matching `endfrag` is found for a given `frag`, then that `frag` will not be counted as a valid fragment and will not produce an include file.

<a name="example-of-endfrag-usage">Example of usage</a>: [see above](#example-of-frag-usage).

During generation process `endfrag` tag is replaced in page with an empty string.

### Fragment embedding tag: `{% > ... %}`

`>` inclusion tag that searches for an include file with a given unique id generated by `frag` tag. Works in exactly same way as traditional `include` tag, but does not use parameters.

<a name="example-of-inclusion-usage">Example of usage:</a>
```
Testing will require a test suite that covers a set of test cases
derived from initial use cases. However, since {% > dependencies %},
the testing will be entirely implemented using just the `py.test`
library.
```

Which will produce the following result:

Testing will require a test suite that covers a set of test cases derived from initial use cases. However, since the only
dependency is Python's `argparse` library, the testing will be entirely implemented using just the `py.test` library.

## Installation

Drop the `jekyll-dry.rb` file into the `_plugins` directory of the website as described in the first option of enabling a plugin in [Jekyll documentation](https://jekyllrb.com/docs/plugins/#installing-a-plugin):
```
In your site source root, make a _plugins directory. Place your plugins
here. Any file ending in *.rb inside this directory will be loaded
before Jekyll generates your site.
```

## Incompatibility with GitHub Pages

Since this is a custom plugin which is not included in the code set of GitHub pages plugins it will not work with GitHub's automatic website generation.

You will have to generate the website locally and then push the contents of the `_site` folder to GitHub in order to publish your website.
