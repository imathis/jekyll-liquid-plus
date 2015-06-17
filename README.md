# Jekyll Liquid Plus

[![Gem Version](https://badge.fury.io/rb/jekyll-liquid-plus.svg)](http://badge.fury.io/rb/jekyll-liquid-plus) [![Build Status](https://travis-ci.org/imathis/jekyll-liquid-plus.svg)](https://travis-ci.org/imathis/jekyll-liquid-plus)

Super powered Liquid tags for smarter Jekyll templating.

Redesigned, but backwards compatible: include, assign, capture.
All new: render, wrap, wrap_include, return.

## Installation

Add this line to your application's Gemfile:

    gem 'jekyll-liquid-plus'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-liquid-plus

Next create a plugin in your Jekyll plugins directory called something like "liquid-plus.rb" (the name doesn't matter). Then add the following line to the top.

```ruby
require 'jekyll-liquid-plus'
```

## Include Tag

The new include tag accepts multiple paths as strings or variables and searches the file system, including the first file found. It allows you to write ternary expressions and post conditions to control what file to include and whether to include a file at all. It can even fail gracefully. Have a look.

First, here's the standard `include` in action. It can embed a file from Jekyll's `_includes` directory, and optionally create local variables.

```
{% include article.html %}
{% include article.html type='linkpost' %} # in article.html {{ include.type }} outputs 'linkpost'
```

#### Include syntax

The new syntax may seem a bit crazy out of context of use, but the examples below are nice.

```
           Cascade and/or ternary exp    post condition      local vars
{% include [file1.md || file2.md || var] [unless 2 + 2 == 6] [var=value] %}
```

#### Cascading paths

Now include can cascade file paths, embedding the first file which exists.

```
{% include custom/article.html || theme/article.html %}
```

Cascading makes it possible for theme and plugin creators to easily allow users to override template components, customizing a template without editing the original source.

Passing `none` will tell include to fail gracefully, rather than outputting an error if no file path exists.

```
{% include custom/comments.html || none %}
```

This shows how a theme creator might make it easy to inject a script for comments at the bottom of a post.

#### Ternary paths

Sometimes this is just simpler.

```
{% include (post ? theme/post.html : theme/page.html) %}
{% include (post ? theme/post.html : theme/page.html) || none %}
```

The second example will fail gracefully and shows how you might use a ternary expression and cascading paths together.

#### Conditional includes

Conditional includes make it easy to pick the right partial without a nest of `{% if %}` blocks.

```
{% include theme/post/date.html if post.date or page.date %}
{% include custom/comments.html unless post.comments == false %}
```

#### Include accepts variables

Include even allows variables to be passed instead of string paths.

For this example, we'll assuse a user has set a default sidebar path in their Jekyll config file like this:

```yaml
sidebar:
  default: sidebar.html
```

Then on a per page basis they could override their default sidebar in the page's YAML front-matter.

```yaml
sidebar: page_sidebar.html
```

Now we can include the correct sidebar by cascading them. Using a post condition, we can even allow users to disable the sidebar by setting `sidebar: false` in their YAML front matter.

```
{% include page.sidebar || site.sidebar.default || none  unless page.sidebar == false %}
```

Of course you can combine cascades, ternary expressions, post conditions and local variable passing, but you probably shouldn't.

#### Error reporting

Finally, the new `include` has better error reporting. When attempting to include a file which doesn't exist, an error message will be written to the file and output to the terminal. Here's an example.

```
From theme/article.html: File 'not_there.html' not found in '_includes/' directory
```

## Render Tag

Everything you can do with `include`, you can also do with `render`, However there are a few differences. If you haven't read about include, [do it](#include-tag).

#### Render syntax

```
                Cascade and/or ternary exp    post condition      local vars
{% render [raw] [file1.md || file2.md || var] [unless 2 + 2 == 6] [var=value] %}
```

#### Differences from include

1. Paths are relative to Jekyll's source directory, not the `_includes` directory.
2. Embed adjacent files by adding `./` to the beginning of a path.
3. When passing local template variables, they are accessed as `{{ render.var }}` instead of `{{ include.var }}`
5. YAML front-matter is stripped from partials, but local page variables are rendered.

This is the standard include example from above, but when using render it searches for files starting at Jekyll's source directory (./ by default). 

```
{% render _article.html %} # embeds _article.html from the source directory
{% render _article.html type='linkpost' %} # in _article.html {{ render.type }} outputs 'linkpost'
```
Note I'm using underscores in the file names to tell Jekyll to ignore them as partials, however you can embed any other file, including full Jekyll posts and pages.

This great for when you are writing a bunch of pages and would like to break things up into partials without have to keep everything in the _includes directory.

#### Rendering raw unprocessed files

To embed a file without parsing it through Liquid and (if appropriate, markdown or textile) add `raw` to the beginning of your render tag. 

```
{% render raw _test.md %} # outputs bare markdown and unprocessed liquid tags
```

## Wrap Include Tag

This tag is also like include, but it allows you to wrap the contents of an included file in a block.

#### Wrap include syntax

Use the `{= yield }` tag to indicate where the partial's content will be rendered.

```
                Cascade and/or ternary exp    post condition      local vars
{% wrap_include [file1.md || file2.md || var] [unless 2 + 2 == 6] [var=value] %}
  <div>{= yield }</div>
{% endwrap_include %}
```

Here's an example.

```
{% wrap_include date.html %}
<p class='post-date'>{= yield }</p>
{% endwrap_include %}
```

Here's another useful example.

{% wrap_include custom/comments.html || theme/comments.html unless page.comments == false %}
<div id='comments'>{= yield }</div>
{% endwrap_include %}

As above, all the cool stuff you can do with include applies here.

## Wrap Tag

Wrap is just like wrap_include except it uses the render tag instead of the include tag. This means paths start at Jekyll's source directory and you can do everything listed under render.

#### Wrap syntax

Use the `{= yield }` tag to indicate where the partial's content will be rendered.

```
              Cascade and/or ternary exp    post condition      local vars
{% wrap [raw] [file1.md || file2.md || var] [unless 2 + 2 == 6] [var=value] %}
  <div>{= yield }</div>
{% endwrap_include %}
```

Here's an example.

```
{% wrap _nav.html %}
<nav role='navigation'>{= yield }</nav>
{% endwrap %}
```

As above, all the cool stuff you can do with render applies here.

## Assign Tag

The new assign tag can accept the `+=` and `||=` operators and allows cascading variable assignment and post conditions.

#### Assign syntax

```
                cascade or ternary  filters    post condition 
{% assign var = [some_var or 'bar'] [| upcase] [unless 2 + 2 == 6] %}
```

Operators work as you'd expect.

```
{% assign var = 'hi' %}      # {{ var }} yields 'hi'
{% assign var ||= 'yo' %}    # {{ var }} yields 'hi'
{% assign var += ', man.' %} # {{ var }} yields 'hi, man.'
```

You can do cascading assignment like this.

```
{% assign date = post.date or page.date or nil %}
```

And ternary assignment too.

```
{% assign url = (post ? post.url : page.url) %}
```

Post conditions work like this.

```
{% assign date = post.date or page.date or nil %}
{% assign date = date | datetime | date_to_xmlschema if date != nil %}
```

## Capture Tag

The new capture tag allows `+=`, `||=` assignment and evaluates post conditions.

#### Capture syntax

```
                    post condition 
{% capture var [+=] [unless 2 + 2 == 6] %}
[value]
{% endcapture %}
```

It's pretty straightforward, but here are some examples.

```
{% assign var = 'hi' %}
{% capture var ||= %} yo {% endcapture %}  # {{ var }} yields 'hi'
{% capture var += %}, man.{% endcapture %} # {{ var }} yields 'hi, man.'
```

Here's an example of how you might generate a semantic `<time>` tag.

```
{% assign date = page.date or post.date or nil %}

{% capture date if date %}
<time datetime="{{ date | datetime | date_to_xmlschema }}" pubdate>{{ date | format_date }}</time>
{% endcapture %}
```

## Return Tag

Return is useful when you want to conditionally output a variable without having to write an `{% if %}` block. Yes its utility is pretty limited, but in Liquid, anything that helps you use fewer conditional blocks, makes code easier to read. 

#### Return syntax

```
          Cascade and/or ternary exp    filters    post condition 
{% return [file1.md || file2.md || var] [| upcase] [unless 2 + 2 == 6] %}
```

Below each example shows how return can be used, followed by something that works the same, but with only standard liquid tags.

```
new: {% return (post ? post.content : page.content) %}
old: {% if post %}{{ post.content }}{% else %}{{ page.content }}{% endif %}
```
```
new: <a href="{% return post.external-url || post.url %}">{{ post.title }}</a>
old: <a href="{% if post.external-url %}{{ post.external-url }}{% else %}{{ post.url }}{% endif %}">{{ post.title }}</a>
```
```
new: <div class="post {% return 'linklog' if post.external-url %}">...
old: <div class="post {% if post.external-url %} linklog {% endif %}">
```
```
new: {% return post.date or page.date | datetime | date_to_xmlschema if post.date or page.date %}
old: {% capture date %}{{ post.date }}{{ page.date }}{% endcapture %}
     {% if date != '' %}{{ date | datetime | date_to_xmlschema }}{% endif %}
```

It's not amazing, but it may come in handy.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright (c) 2013 Brandon Mathis

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

