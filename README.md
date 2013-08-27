# Jekyll Liquid Plus

Super powered Liquid tags for smarter Jekyll templating. [See examples below](#usage).

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

## What's wrong with Liquid?

With standard Liquid tags, being DRY is a lot of work. If you want to create a reusable partial for something as simple as displaying a semantic date for a page or post, you
have to do something like this:

1. Determine if the current page even has a date (pages don't by default).
2. Did we find a date? Capture stores strings, so we compare `has_date` to `'0'` (ugh!).
3. Store the date wrapped in a semantic `<time>` tag.
4. Finally, output the date date in the template.

```
{% capture date %}{{ post.date }}{{ page.date }}{% endcapture %}
{% capture has_date %}{{ date | size }}{% endcapture %}

{% if has_date != '0' %}
  {% capture date %}
    <time datetime="{{ date | datetime | date_to_xmlschema }}" pubdate>{{ date | format_date, site.date_format }}</time>
  {% endcapture %}
{% endif %}

{% unless date == '' %}
  <p class='post-meta'>Published: {{ date }}</p>
{% endunless %}
```

With jekyll-liquid-plus, you can use familiar features like post conditions and `||` assignment to write templating code which is much more straight forward.

```
{% capture date if post.date or page.date %}
  {% assign date = post.date or page.date %}
  <time datetime="{{ date | datetime | date_to_xmlschema }}" pubdate>{{ date | format_date, site.date_format }}</time>
{% endcapture %}

{% if date %}
  <p class='post-meta'>Published: {{ date }}</p>
{% endif %}
```

## Usage

### Include

The new include tag accepts multiple paths as strings or variables and searches the file system, including the first file found. It allows you to write ternary expressions and post conditions to control what file to include and whether to include a file at all. It can even fail gracefully. Have a look.

First, here's the standard `include` in action. It can embed a file from Jekyll's `_includes` directory, and optionally create local variables.

```
{% include article.html %}
{% include article.html type='linkpost' %} # in article.html {{ include.type }} outputs 'linkpost'
```

Now include can cascade file paths, embedding the first one which exists. This makes it possible for theme and plugin creators to easily allow overrides for template components. 

```
{% include custom/article.html || theme/article.html %}
```

By passing `none` you can tell include to fail gracefully, rather than outputting an error if no file path exists. Here is how a theme creator might make it easy to inject a script for comments at the bottom of a post.

```
{% include custom/comments.html || none %}
```


Conditional includes make it easy to pick the right partial without a nest of `{% if %}` blocks.

```
{% include theme/post/date.html if post.date or page.date %}
{% include custom/comments.html unless post.comments == false %}
{% include (post ? theme/post.html : theme/page.html) %}
```

Include even allows variables to be passed instead of string paths. In this example, a user could set a default sidebar path in their Jekyll config file like this:

```yaml
sidebar:
  default: sidebar.html
```

Then on a per page basis they could override their default sidebar in the page's YAML front-matter.

```yaml
sidebar: page_sidebar.html
```

Now we can include the correct sidebar by cascading them. Using a post condition, we can even allow users to disable the sidebar.

```
{% include page.sidebar || site.sidebar.default || none unless page.sidebar == false %}
```

Of course you can combine cascades, ternary, post conditions and local variable passing, but you probably shouldn't.

Finally, the new `include` has better error reporting. When attempting to include a file which doesn't exist, an error message will be written to the file and output to the terminal. Here's an example.

```
From theme/article.html: File 'not_there.html' not found in '_includes/' directory
```

### Render

Everything you can do with `include`, you can also do with `render`, However there are a few differences.

1. Paths are relative to Jekyll's source directory, not the `_includes` directory.
2. Embed adjacent files by adding `./` to the beginning of a path.
3. When passing local template variables, they are accessed as `{{ render.var }}` instead of `{{ include.var }}`
5. YAML front-matter is stripped from partials, but local page variables are rendered.

This is the standard `include` example from above, but using render it searches for files starting at Jekyll's source directory (./ by default). Note I'm using underscores in the file names to tell Jekyll to ignore them as partials, however you can embed any other file,
including full Jekyll posts and pages.

```
{% render _article.html %} # embeds _article.html from the source directory
{% render _article.html type='linkpost' %} # in _article.html {{ render.type }} outputs 'linkpost'
```

This great for when you are writing a bunch of pages and would like to break things up into partials without have to keep everything in the _includes directory.

To embed a file without parsing it through Liquid and (if appropriate, markdown or textile) add `raw` to the beginning of your render tag. 

```
{% render raw _test.md %} # outputs bare markdown and unprocessed liquid tags
```

### Wrap Include

Wrap Include is like include, but it allows you to wrap the contents of an included file in a block. Here's an example.

{% wrap_include date.html %}
<p class='post-date'>{= yield }</p>
{% endwrap_include %}

Using the `{= yield }` tag, you can chose where to put the rendered content. Here's another useful example.

{% wrap_include custom/comments.html || theme/comments.html unless page.comments == false %}
<div id='comments'>{= yield }</div>
{% endwrap_include %}

As above, all the cool stuff you can do with include applies here.

### Wrap

Wrap is just like wrap_include except it uses the render tag instead of the include tag. This means paths start at Jekyll's source directory and you can do everything listed under render.

{% wrap _nav.html %}
<nav role='navigation'>{= yield }</nav>
{% endwrap %}

As above, all the cool stuff you can do with render applies here.

### Assign

Examples coming soon...

### Capture

Examples coming soon...

### Return

Return is useful when you want to conditionally output a variable without having to write an `{% if %}` block. Yes it's utlitiy is pretty limited, but in Liquid, anything that helps you use fewer conditional blocks, makes code easier to read. Here are some examples.

```
{% return (post ? post.content : page.content) %}
<a href="{% return post.external-url || post.url %}">{{ post.title }}</a>
<div class="post {% return 'linklog' if post.external-url %}">...
```

It's not amazing, but it's better than this.

```
{% if post %}{{ post.content }}{% else %}{{ page.content }}{% endif %}
<a href="{% if post.external-url %}{{ post.external-url }}{% else %}{{ post.url }}{% endif %}">{{ post.title }}</a>
<div class="post {% if post.external-url %} linklog {% endif %}">
```

Gross huh?


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

