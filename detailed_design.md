# Detailed design of jekyll-dry plugin

## Fragment's beginning tag: `frag`

### Hierarchy note

Must be in module `Jekyll`. Must be in module `Tags`.

### Class `FragTag`

Class `FragTag` must be inherited from `Liquid::Tag`.

#### Methods of `FragTag`

##### `initialize` method

###### Arguments:

* tag_name
* markup
* tokens

###### Logic:
1. The `initialize method` should first make a call to the `super` method.
1. Then it should verify that markup string matches the predefined markup pattern similar to the one in the source code of the `include` tag. The regex below matches following example of markup:
   ```
   file_path.ext param1="value1" param2='value2'
   ```
   The regex that matches that string is:
   ```
   # Capture group "fragment_id":
   #  - Starts with any amount of any symbols other than "{"
   #  - One or more untitled capture group:
   #    - Starts with "{{"
   #    - Followed by any number of whitespace characters
   #    - One or more: word, "-", or "."
   #    - Followed by any number of whitespace characters
   #    - Maybe one "|" followed by any amount of any symbols
   #    - Ends with "}}"
   #    - And any amount of symbols other than "\s", "{", or "}"
   #
   # Capture group "params":
   #    - Everything not captured by "fragment_id" group

   (?<fragment_id>[^{]*(\{\{\s*[\w\-\.]+\s*(\|.*)?\}\}[^\s{}]*)+)
   (?<params>.*)
   ```
   1. If markup matched this regex, then a capture group named `fragment_id` must be extracted