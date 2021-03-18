# Calculator REST Application

Student: Henrique da Cunha Buss (18102714)

[See on GitHub](https://github.com/NeoVier/RESTCalculator)

## About the project

This project consists in showing a little bit about web services, specifically REST APIs. For that, I've implemented a simple calculator API, with the frontend built using Elm, and the backend built using Typescript. For more specific information about the technology used, head to [frontend README](frontend/README.md) and [backend README](backend/README.md).

## Creating the project

The frontend is much cooler, more complex and Elm is probably new to most people, so I'll start with that.

### Frontend

Since the frontend was built using Elm, you'll need to know Elm. If you're new to it, the [official guide](https://guide.elm-lang.org/) is amazing.

To setup the initial project with Snowpack, TailwindCSS and Elm, follow [this guide](https://dev.to/mickeyvip/creating-an-elm-project-with-snowpack-1c1b).

From there, we have a barebones app, and just need to implement the styles and logic. For the styles since I actually like CSS, and started to love TailwindCSS, I've opted for TailwindCSS, but if you don't like having a bunch of classes on elements, or don't like CSS, checkout [elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/) - a new language for layout and interface - it makes styling applications in Elm much easier, and you don't have to deal with CSS.

I started by looking up calculator designs for inspiration, and started implementing the visual styles. This also makes it easier to think about how to structure your `Msg`s, and what you'll need to do. After fiddling with the styles for long enough to actually kind of like it, it's time to implement the logic! We know our calculator will only have the four basic operations: addition, subtraction, multiplication and division. So we can create an [ADT](https://en.wikipedia.org/wiki/Abstract_data_type), it's similar to an enum in other languages, but way better. So we have an operator type:

```elm
type Operator
    = Add
    | Subtract
    | Multiply
    | Divide
```

This types lists out all the operations we can have in our calculator. To store the state of the application, we need a `Model`:

```elm
type alias Model =
    { inputValue : String
    , firstNumber : Maybe Float
    , operator : Maybe Operator
    }
```

This is pretty much the equivalent of a JSON object, and here we can see another one of the great things about Elm: the `Maybe` type. Elm doesn't have `null`, `undefined`, or anything like that - it's deterministic. So a way to model some data that may or may not exist, we have `Maybe`. This is also an ADT, just like our `Operator`, but it uses some powerful concepts:

```elm
type Maybe a
    = Nothing
    | Just a
```

The `a` is what's called a type parameter: it can be any type, like `String`, `Int`, or even `Operator` (Note: some types start with a upper case letter, and some with a lower case letter. The ones that start with an upper case letter are fixed types, such as `String` and `Int`. The ones that start with a lower case letter are type parameters). What this is saying is that we can have `Nothing` (similar to `null`, but safe), or `Just` something. Why do we need this? Well, for example, we need to keep track of the `Operator` the user has chosen, but they don't choose it from the beginning! So at the start, we don't have an `Operator` - we have `Nothing`! When the user chooses an `Operator`, we'll have a `Just operator`, like `Just Subtract`. The same thing goes to the first number the user chooses. `inputValue` is just what the user is currently typing in, so we need to keep track of it as well.

Elm programs follow [The Elm Architecture](https://guide.elm-lang.org/architecture/), or TEA for short. This means we have a `Model`, a `Msg` type, and an `update` function. `Msg`s are fired either from the user, like when they press a button, or programmatically, and they are treated in the `update` function. `update` does exactly what it says: it updates the model! It receives the current state of the application, a message, and returns a new state of the application. This is very similar to a finite state machine. It then uses that new state (the new `Model`) and renders it on the screen, with the `view` function.

Since Elm is statically and strongly typed, a very _different_ thing about it is performing HTTP requests - we need to declare what we expect to get back, so for example, in our `updateFunction`, when the user `ClickedEnter` with a valid `Expression`, we do an `Http.post` request, and define the `expect` field with a JSON decoder, which means Elm will receive a JSON object, and will try to use the format specified to decode it. For that, it uses another amazing type, the `Result` type:

```elm
type Result e a
    = Err e
    | Ok a
```

This is very similar to `Maybe`, but it has some extra meaning - it tells you _why_, or _what_ (or whatever you want) went wrong, because the `Err` type has the `e` type variable - so you can say something like "This HTTP request has gone wrong - I'll give you an `Err`or with the `Http.Error` value that explains what went wrong". It also has an `Ok` case, which is used for when the operation has completed succesfully.

### Backend

The backend is much simpler than the frontend - it's just a server that takes in requests in specific URLs/endpoints, looks at the body of the request, makes a calculation and gives it back to the user. To make the "looking at the body" step easier, we use the `express.json()` middleware to automatically parse the request body (Note that in typescript we don't need to define what we `expect`, like in Elm).

We simply start up an `app`, define our middlewares, and define our routes. Routes for other endpoints look pretty much the same as `post`: you could do `app.get(...)`, etc.

The `cors()` middleware is there because of the `Cross-Origin Resource Sharing` policy, also known as CORS. CORS is a security policy adopted by the web that restricts the access to resources to specific domains. We could've restricted it to just our frontend application:

```ts
app.use(
  cors({
    origin: "http://localhost:8080",
  })
);
```

But since our API is not private, and there is no problem in sharing it with the world, we just use `cors()` to define anyone can access it (Note that we need to explicitly define this).
