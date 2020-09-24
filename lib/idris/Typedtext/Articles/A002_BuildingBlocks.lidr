<!--
AUTHOR_NAME: Christian Rasmussen
AUTHOR_EMAIL: christian.rasmussen@me.com
PUBLISH_DATE: 2020-09-21
TAGS: meta, idris2, erlang, elixir, phoenixframework, codegen, ffi
-->

# How was this website built?

Ever since I started working on the [Erlang code generator for Idris 2](https://github.com/chrrasmussen/Idris2-Erlang), my goal has been to be able to build websites and web services written in [Idris 2](https://github.com/idris-lang/Idris2). This website is an attempt at doing just that.

By using the Erlang code generator I am able to access functionality from the [Erlang](https://www.erlang.org) ecosystem. This is important, as I would not be able to write all the building blocks (like a web server) that are necessary to make even a simple website.

<!-- FOLD -->


## Goals

When building this website I had a few goals in mind:

- Write blog posts as [Literate Idris](https://idris2.readthedocs.io/en/latest/reference/literate.html)
  - I want all the Idris 2 code snippets to be type-checked (hence the name of this blog)
- Support Markdown
- Support syntax highlighting of code snippets
- Write the bulk of the code in Idris 2
  - And get more experience using the Erlang code generator


## Building blocks

In addition to the Erlang code generator, I have created a Mix compiler to ease the integration of Idris 2 in [Elixir](https://elixir-lang.org) projects: [mix_idris2](https://github.com/chrrasmussen/mix_idris2). This tool automatically recompiles changed Idris 2 modules.

Libraries/frameworks used:

- [Phoenix Framework](https://www.phoenixframework.org) — Web framework [Elixir]
- [Earmark](https://github.com/pragdave/earmark) — Markdown [Elixir]
- [highlight.js](https://highlightjs.org) — Syntax highlighting [JavaScript]

Some parts were written in plain Idris 2:

- Parsing of metadata in blog posts
- HTML builder


## Integration into Phoenix Framework

This website is built on top of [Phoenix Framework](https://www.phoenixframework.org). Phoenix Framework includes a bunch of middleware modules (called [Plug](https://github.com/elixir-plug/plug)), such as a web server ([Cowboy](https://github.com/ninenines/cowboy)), parsers, static files handling, routing and code reloading.

In order to integrate the Idris 2 code into Phoenix Framework, I created a wrapper around [Plug.Conn](https://github.com/chrrasmussen/typedtext.io/blob/e8c10f85626629265118aa4b29dde957baa81844/lib/idris/Elixir/Plug/Conn.idr). This is possible because the Erlang code generator supports calling functions in Erlang as well as exporting named functions that can be called from Erlang. Using the `Plug.Conn` wrapper I wrote a very basic [router](https://github.com/chrrasmussen/typedtext.io/blob/e8c10f85626629265118aa4b29dde957baa81844/lib/idris/Typedtext/Router.idr) in Idris 2, replacing the existing Elixir router.

The router forwards requests to the approproriate [handler](https://github.com/chrrasmussen/typedtext.io/blob/e8c10f85626629265118aa4b29dde957baa81844/lib/idris/Typedtext/Blog.idr). The handlers have access to the `Plug.Conn.Conn` value, which can be used to retrieve request parameters, set response headers, send a response etc.


## Markdown

To generate HTML from Markdown, I opted for an Elixir library called [Earmark](https://github.com/pragdave/earmark). This library was easy to integrate, needing just a call to `Earmark.as_html/1`. Or at least, that's what I thought. I soon realized that Markdown interprets lines starting with the `>` character as `<blockquote>` tags, while Literate Idris see them as Idris 2 code ([Bird style](https://idris2.readthedocs.io/en/latest/reference/literate.html#bird-style-literate-files)).

Luckily, I discovered that Earmark supports generating an AST (Abstract Syntax Tree) from the Markdown. Using this AST, I was able to transform the generated `<blockquote>` tags into `<pre>`/`<code>` tags. Earmark could then generate HTML from the transformed AST. The [transformation](https://github.com/chrrasmussen/typedtext.io/blob/e8c10f85626629265118aa4b29dde957baa81844/lib/idris/Elixir/Markdown.idr) was all done in Idris 2. Below you can see how the `markdownToHtml` function interoperates with Erlang (Calling the Elixir library):

```idris
markdownToHtml : String -> Maybe String
markdownToHtml contents = do
  let astResult = erlUnsafeCall ErlTerm "Elixir.Earmark" "as_ast" [contents]
  ast <- erlDecodeMay ((\(MkTuple3 _ ast _) => ast) <$> tuple3 (exact (MkAtom "ok")) any any) astResult
  Just $ erlUnsafeCall String "Elixir.Earmark.Transform" "transform" [transformLiterateIdris ast]
```


## Syntax highlighting

The syntax highlighting is provided by [highlight.js](https://highlightjs.org). This library looks for a `<pre>`/`<code>` tag combination that include a class name for a given language. The following code snippet will get syntax highlighting for JavaScript: `<pre><code class="javascript">var answer = 42;</code></pre>`

Unfortunately, highlight.js does not have a language definition for Idris. To fix this I adapted the language definition for Haskell, to make it work for Idris. The [language definition for Idris](https://github.com/chrrasmussen/typedtext.io/blob/e8c10f85626629265118aa4b29dde957baa81844/priv/static/js/highlight-idris.js) is surely incomplete (it does not support namespaces for example), but it is better than nothing.


## Parsing of metadata in blog posts

As mentioned above, blog posts are written as Literate Idris files. To retrieve information about the author, publish date and similar, each blog post include an HTML comment at the top. As an example, this blog post has the following metadata:

```html
<!--
AUTHOR_NAME: Christian Rasmussen
AUTHOR_EMAIL: christian.rasmussen@me.com
PUBLISH_DATE: 2020-09-21
TAGS: meta, idris2, erlang, elixir, phoenixframework, codegen, ffi
-->
```

These fields (+ title, introduction and body) are [parsed](https://github.com/chrrasmussen/typedtext.io/blob/e8c10f85626629265118aa4b29dde957baa81844/lib/idris/Typedtext/Article.idr) into an `Article` record. The parser is based on [Data.String.Parser](https://github.com/idris-lang/Idris2/blob/c4abdb4480912e2227c0ff380c83b8a1842ba739/libs/contrib/Data/String/Parser.idr) from the `contrib` package.


## HTML builder

Each page is rendered by the server as HTML. The HTML is constructed using a very basic [HTML builder](https://github.com/chrrasmussen/typedtext.io/blob/e8c10f85626629265118aa4b29dde957baa81844/lib/idris/Html.idr). At this point, it does not even handle escaping of characters in attributes or protection from any dangerous tags.

The HTML builder is inspired by [Elm's Html library](https://github.com/elm/html), except it does not support any form of interactivity. I am using meta-programming (called elaborator reflection in Idris) to generate a function per HTML tag/attribute.

Even if the view code is written in Idris 2, it is merely a DSL to generate the corresponding HTML, which means that you still need to know HTML/CSS/JavaScript in order to use it. In the future, I want to explore other ways to build user interfaces. I think [Elm UI](https://github.com/mdgriffith/elm-ui) and [SwiftUI](https://developer.apple.com/documentation/swiftui) have some interesting ideas in this regard.


## Future plans for this website

Besides writing more blog posts, I will consider adding the following functionality, mostly for fun because the low post count does not really call for any of these features:

- Add RSS feed
- Add pagination
- Add search functionality
- Add an archive page that lists all titles, grouped by a given period
- Improve layout on mobile

Further down the road, I am hopeful that Idris 2 will add [type provider](http://docs.idris-lang.org/en/latest/guides/type-providers-ffi.html) functionality, like Idris 1 had. A bit simplified: A type provider is able to run `IO` operations at compile-time. Some ideas of what a type provider can be used for:

- Validate that the metadata in the blog posts are valid
- Validate that referenced images exist on disk
- Run a spell-checker when saving changes to a blog post
- Pre-render the static HTML when saving changes to a blog post


## Conclusion

Given the stated goals, I am quite happy with the [result](https://github.com/chrrasmussen/typedtext.io). The solutions presented here may not be perfect (Far from it), but, to me, this is only the beginning. Some of the solutions are currently relying on Erlang/Elixir-specific code. My intention is to create solutions that can work for any code generator. However, that will require more work.

If this blog post made you curious about [Idris 2](https://github.com/idris-lang/Idris2) or the [Erlang code generator for Idris 2](https://github.com/chrrasmussen/Idris2-Erlang), you are welcome to join the Idris community at any of the locations listed here: https://www.idris-lang.org
