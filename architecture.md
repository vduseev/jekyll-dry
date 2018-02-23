# Architecture of jekyll-dry plugin

The plugin consists of three new Liquid tags: `frag`, `endfrag`, and `>`.

## Fragment's beginning tag: `frag`

Whenever `frag` tag is detected it searches for the `endfrag` tag with the same id that was used for `frag` tag itself. That means that the tag's class method must perform a text search on the page using regex expression with the starting position of the search equal to the position of the first character after the current `frag` tag.

If a corresponding `endfrag` tag is not found, then the `render()` method of the tag does not return anything.

However, if matching `endfrag` tag is found, then the whole text between the pair of `frag` and `endfrag` tags is captured and saved to a variable.

Any other `frag` and `endfrag` tags trapped in the captured text are removed.

After that, the text is saved to the file in the output directory. The saving path must be `output_directory_path/_fragments/`. And the name of the file must be equal to the unique id (*or variable as it is called in the source code of `include` tag*) provided with the tag.

If the file with the same name already exists in the `_fragments` directory, then an exception must be thrown from the plugin, saying:
```
The fragment with such name already exists: <fragment's name here>
```

## Fragment's end tag: `endfrag`

`endfrag` tag is only required for the correct work of the `frag` tag. It is replaced with empty string, or simply, not rendered at all when processed.

## Fragment's embedding tag: `>`

`>` embedding tag must have a lower priority than `frag` tag. This is required because all fragment files must be generated before `>` tag gets parsed and processed by Jekyll.

Embedding tag looks for the file specified in the variable to the tag in the `output_directory_path/_fragments/` directory.

If file is not found then nothing is rendered.

If, however, the file is found, the embedding tag reads it and resolves all internal inclusions completely (see a [note on recursive fragment embedding](#recursion)), regenerating the initial requested fragment while doing so.

If no regeneration is required and the fragment already has a final form, then the `>` tag embeds the contents of the file in place of itself on the page.

## <a name="recursion">Note on recursive fragment embedding and loops</a>

A fragment might contain an inclusion of another fragment inside itself. For example:
```
{% frag example_of_loop %}
This text illustrates that the fragment can contain another fragment
inside itself. {% > totally_different_fragment %} Such inclusion is
correctly resolved during generation process.
{% endfrag example_of_loop %}
```

In order to resolve this the `frag` tag first generates all fragment files, including `>` tag inside them leaved intact.

The example above will result in a following fragment generated.

`output_directory_path/_fragments/example_of_loop`:
```
This text illustrates that the fragment can contain another fragment
inside itself. {% > totally_different_fragment %} Such inclusion is
correctly resolved during generation process.
```

Later, when `>` tag is being processed, the first time it encounters the usage of the `example_of_loop` fragment in a page, it detects an internal inclusion of another fragment, in this case a fragment called `totally_different_fragment`. So, it goes and pulls up that fragment's file and replaces the `{% > totally_different_fragment %}` string in `example_of_loop` file with the actual content of `totally_different_fragment` file. Hence, it regenerates the `example_of_loop` file leaving it ready-to-use for all other cases, where this fragment will be included whether it's the same page or a different one. This action must be performed in a recursive fashion, or using a stack, until the fragment embedded in another fragment is static and has a determined content. In other words, when embedded fragment has no inclusions in it. As soon as this condition is satisfied the loop, or recursion, has to be stopped.

A special validity check must be included into the logic to make sure that under no circumstances a fragment contains an inclusion of itself. Or, in other words, that there is no loop in fragment embedding. Whenever this is detected, an exception must be thrown, saying:
```
A loop in fragment inclusion is detected: <looped fragment's name here>
```