# Frontend

This is the frontend part of the application, which uses the [Elm](https://elm-lang.org) programming language, with [TailwindCSS](https://tailwindcss.com) for styling, and [Snowpack](https://www.snowpack.dev/) for bundling. For more information on the technologies used, head to [About the technology](<##About\ the\ technology>).

The initial project was created following [this article](https://dev.to/mickeyvip/creating-an-elm-project-with-snowpack-1c1b).

## Getting Started

This project uses [npm](https://www.npmjs.com/) to handle packages and dependencies, so upon cloning the project, you'll need to run `npm install` to fetch all of the dependencies we need.

After having installed all the dependencies, you can run `npm start` to start a development server, running at [localhost:8080](localhost:8080) (you can access that and see the project). This will start Snowpack, which will watch for file changes and automatically recompile and show the changes in the browser.

## About the technology

### Elm

Elm is a pure [functional programming](https://en.wikipedia.org/wiki/Functional_programming) language, heavily inspired by the [ML](<https://en.wikipedia.org/wiki/ML_(programming_language)>) family of languages, especially [Haskell](https://www.haskell.org/).

Elm is **not** a general-purpose language - it does frontend web development, and does it very well. Because it's focused on web frontend, it transpiles to JavaScript, the language interpreted by browsers. And because JavaScript can be run on, for example, the server side, there are some initiatives that try to use Elm on other domains.

Elm is statically and strongly typed - an `Int` is an `Int`, and there is no implicit conversion to any other type. If a function accepts a `Float`, you can't ever give it an `Int`. This might seem bad for some people initially, but this guarantees there is little to no runtime errors! An entire type of error is just non-existent because of this, and it also means the compiler, which is usually seen as an "enemy", can be your BFF, pointing out what's wrong and even how to fix it.

In Elm, everything is immutable - there is no in-place operations. Every "change" means creating a new instance of the "changed" data. For example, it would be the same as using `const` for everything instead of `let` or `var` in JavaScript.

### TailwindCSS

TailwindCSS is a CSS utility-first framework, which means it's very different from frameworks like [Bootstrap](https://getbootstrap.com/). Instead of providing entire components, such as a `btn` (an already styled button), it provides utilities, such as `rounded-sm`, `px-4`, `py-2`, `bg-purple-800`, `text-white`. It may be strange at first, but once you become familiar with the available classes/utilities, it becomes really nice to work with it (also, their documentation has a really good search engine).

### Snowpack

Snowpack is a relatively new tool in the space of frontend web bundlers. It describes itself as "a lightning-fast frontend build tool, designed for the modern web.", and is an alternative to other tools such as [Webpack](https://webpack.js.org/) and [Parcel](https://parceljs.org/).
