module Main exposing (main)

import Browser
import Browser.Events
import Html exposing (Html, button, div, input, span, text)
import Html.Attributes exposing (class, classList, disabled, type_, value)
import Html.Events exposing (onClick)
import Http
import Json.Decode
import Json.Encode
import List.Extra as LE
import Svg exposing (rect, svg)
import Svg.Attributes
    exposing
        ( d
        , fill
        , height
        , stroke
        , strokeLinecap
        , strokeLinejoin
        , strokeWidth
        , style
        , viewBox
        , width
        , y
        )



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = \_ -> subscriptions
        }



-- MODEL


type alias Model =
    { inputValue : String
    , firstNumber : Maybe Float
    , operator : Maybe Operator
    }


init : ( Model, Cmd msg )
init =
    ( initModel, Cmd.none )


initModel : Model
initModel =
    { inputValue = ""
    , firstNumber = Nothing
    , operator = Nothing
    }



-- TYPES


type Operator
    = Add
    | Subtract
    | Multiply
    | Divide


listOperators : List Operator
listOperators =
    [ Add, Subtract, Multiply, Divide ]


type alias Expression =
    { firstNumber : Float
    , operator : Operator
    , secondNumber : Float
    }


type Style
    = Primary
    | Secondary


mapMaybeWith : (a -> b) -> b -> Maybe a -> b
mapMaybeWith fn default maybe =
    Maybe.map fn maybe
        |> Maybe.withDefault default



-- MSG


type Msg
    = Ignored
    | ClickedNumber Int
    | ClickedClear
    | ClickedToggleSign
    | ClickedBackspace
    | ClickedOperator Operator
    | ClickedPeriod
    | ClickedEnter
    | GotResult (Result Http.Error (Result String Float))



-- SUBSCRIPTION


subscriptions : Sub Msg
subscriptions =
    Browser.Events.onKeyPress
        (Json.Decode.field "key" Json.Decode.string
            |> Json.Decode.map handleKey
        )


handleKey : String -> Msg
handleKey keyValue =
    case keyValue of
        "Clear" ->
            ClickedClear

        "Backspace" ->
            ClickedBackspace

        "Delete" ->
            ClickedBackspace

        "+" ->
            ClickedOperator Add

        "-" ->
            ClickedOperator Subtract

        "*" ->
            ClickedOperator Multiply

        "/" ->
            ClickedOperator Divide

        "." ->
            ClickedPeriod

        "Enter" ->
            ClickedEnter

        "=" ->
            ClickedEnter

        _ ->
            case String.toInt keyValue of
                Just number ->
                    ClickedNumber number

                Nothing ->
                    Ignored



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Ignored ->
            ( model, Cmd.none )

        ClickedNumber n ->
            -- Elm limits floats to be this long, apparently
            if String.length model.inputValue >= 18 then
                ( model, Cmd.none )

            else
                case String.toFloat model.inputValue of
                    Nothing ->
                        ( { model | inputValue = String.fromInt n }, Cmd.none )

                    Just _ ->
                        ( { model | inputValue = model.inputValue ++ String.fromInt n }, Cmd.none )

        ClickedClear ->
            ( initModel, Cmd.none )

        ClickedToggleSign ->
            case String.toList model.inputValue of
                '-' :: rest ->
                    ( { model | inputValue = String.fromList rest }, Cmd.none )

                _ ->
                    ( { model | inputValue = "-" ++ model.inputValue }, Cmd.none )

        ClickedBackspace ->
            ( { model | inputValue = String.dropRight 1 model.inputValue }, Cmd.none )

        ClickedOperator operator ->
            case ( String.toFloat model.inputValue, model.firstNumber ) of
                ( Just firstNumber, Nothing ) ->
                    ( { model
                        | firstNumber = Just firstNumber
                        , operator = Just operator
                        , inputValue = ""
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        ClickedPeriod ->
            if String.isEmpty model.inputValue then
                ( { model | inputValue = "0." }, Cmd.none )

            else if String.any ((==) '.') model.inputValue then
                ( model, Cmd.none )

            else
                ( { model | inputValue = model.inputValue ++ "." }, Cmd.none )

        ClickedEnter ->
            let
                secondNumber =
                    String.toFloat model.inputValue
            in
            case Maybe.map3 Expression model.firstNumber model.operator secondNumber of
                Nothing ->
                    ( model, Cmd.none )

                Just expression ->
                    ( model
                    , Http.post
                        { url = expressionUrl expression "http://localhost:4000"
                        , body = Http.jsonBody (encodeExpression expression)
                        , expect =
                            Http.expectJson GotResult
                                (Json.Decode.field "operationResult"
                                    (Json.Decode.oneOf
                                        [ Json.Decode.map Ok Json.Decode.float
                                        , Json.Decode.map Err Json.Decode.string
                                        ]
                                    )
                                )
                        }
                    )

        GotResult (Ok (Ok result)) ->
            ( { model
                | firstNumber = Nothing
                , operator = Nothing
                , inputValue = String.fromFloat result
              }
            , Cmd.none
            )

        GotResult (Ok (Err error)) ->
            ( { model
                | firstNumber = Nothing
                , operator = Nothing
                , inputValue = error
              }
            , Cmd.none
            )

        GotResult (Err err) ->
            ( { model | inputValue = "Something went wrong" }, Cmd.none )


expressionUrl : Expression -> String -> String
expressionUrl { operator } baseUrl =
    let
        operatorUrl =
            case operator of
                Add ->
                    "sum"

                Subtract ->
                    "subtract"

                Multiply ->
                    "multiply"

                Divide ->
                    "divide"
    in
    String.join "/" [ baseUrl, operatorUrl ]


encodeExpression : Expression -> Json.Encode.Value
encodeExpression { firstNumber, secondNumber } =
    Json.Encode.object
        [ ( "firstOperand", Json.Encode.float firstNumber )
        , ( "secondOperand", Json.Encode.float secondNumber )
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "w-screen h-screen flex items-center justify-center" ]
        [ div [ class "shadow-lg" ]
            [ viewInput model
            , div [ class "flex" ]
                [ div [ class "flex flex-col flex-grow" ]
                    [ viewTopRow
                    , viewNumbers
                    ]
                , viewOperationsColumn
                ]
            , viewBottomRow
            ]
        ]


viewInput : Model -> Html Msg
viewInput model =
    div [ class "bg-purple-700 py-4 px-2 rounded-tl-lg w-full flex flex-col" ]
        [ span
            [ class "text-white text-right w-full pr-2"
            , classList
                [ ( "opacity-0"
                  , mapMaybeWith (\_ -> False) True model.firstNumber
                  )
                ]
            ]
            [ text
                (mapMaybeWith String.fromFloat "0" model.firstNumber)
            ]
        , input
            [ class "bg-purple-700 py-6 px-4 text-right text-white text-xl sm:text-2xl w-full"
            , type_ "text"
            , disabled True
            , value model.inputValue
            ]
            []
        ]


viewTopRow : Html Msg
viewTopRow =
    div [ class "w-100 flex" ]
        [ viewButton
            { label = text "AC"
            , onClick = ClickedClear
            , isLarge = False
            , style = Secondary
            }
        , viewButton
            { label = text "+/-"
            , onClick = ClickedToggleSign
            , isLarge = False
            , style = Primary
            }
        , viewButton
            { label = iconBackspace
            , onClick = ClickedBackspace
            , isLarge = False
            , style = Primary
            }
        ]


viewBottomRow : Html Msg
viewBottomRow =
    div [ class "flex" ]
        [ viewButton
            { label = text "0"
            , onClick = ClickedNumber 0
            , isLarge = True
            , style = Primary
            }
        , viewButton
            { label = text "."
            , onClick = ClickedPeriod
            , isLarge = True
            , style = Primary
            }
        , viewButton
            { label = span [ class "text-4xl font-medium" ] [ text "=" ]
            , onClick = ClickedEnter
            , isLarge = False
            , style = Secondary
            }
        ]


viewOperationsColumn : Html Msg
viewOperationsColumn =
    listOperators
        |> List.map
            (\operator ->
                viewButton
                    { label = viewOperator operator
                    , onClick = ClickedOperator operator
                    , isLarge = False
                    , style = Secondary
                    }
            )
        |> div [ class "flex flex-col" ]


viewOperator : Operator -> Html msg
viewOperator operator =
    case operator of
        Add ->
            iconAdd

        Subtract ->
            iconSubtract

        Multiply ->
            iconMultiply

        Divide ->
            iconDivide


viewNumbers : Html Msg
viewNumbers =
    div [ class "w-full" ]
        (List.range 1 9
            |> List.reverse
            |> LE.greedyGroupsOf 3
            |> List.map
                (List.reverse
                    >> List.map
                        (\i ->
                            viewButton
                                { label = String.fromInt i |> text
                                , onClick = ClickedNumber i
                                , isLarge = False
                                , style = Primary
                                }
                        )
                    >> div [ class "flex w-full" ]
                )
        )


viewButton :
    { label : Html msg
    , onClick : msg
    , isLarge : Bool
    , style : Style
    }
    -> Html msg
viewButton ({ label, isLarge, style } as options) =
    let
        color =
            case style of
                Primary ->
                    "text-black"

                Secondary ->
                    "text-white"

        background =
            case style of
                Primary ->
                    "bg-white hover:bg-gray-100"

                Secondary ->
                    "bg-purple-700 hover:bg-purple-600"

        size =
            if isLarge then
                "w-full"

            else
                "flex-grow"
    in
    button
        [ onClick options.onClick
        , class
            (String.join " "
                [ "min-w-16 min-h-16 min-h-max flex items-center justify-center font-bold focus:outline-none"
                , color
                , background
                , size
                ]
            )
        ]
        [ label ]



-- ICONS


iconBackspace : Html msg
iconBackspace =
    svg [ fill "none", width "24", height "24", viewBox "0 0 24 24", stroke "currentColor" ] [ Svg.path [ strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", d "M12 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2M3 12l6.414 6.414a2 2 0 001.414.586H19a2 2 0 002-2V7a2 2 0 00-2-2h-8.172a2 2 0 00-1.414.586L3 12z" ] [] ]


iconAdd : Html msg
iconAdd =
    svg [ fill "none", width "24", height "24", viewBox "0 0 24 24", stroke "currentColor" ] [ Svg.path [ strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", d "M12 6v6m0 0v6m0-6h6m-6 0H6" ] [] ]


iconSubtract : Html msg
iconSubtract =
    svg [ fill "none", width "24", height "24", viewBox "0 0 24 24", stroke "currentColor" ] [ Svg.path [ strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", d "M20 12H4" ] [] ]


iconMultiply : Html msg
iconMultiply =
    svg [ fill "none", width "24", height "24", viewBox "0 0 24 24", stroke "currentColor" ] [ Svg.path [ strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", d "M6 18L18 6M6 6l12 12" ] [] ]


iconDivide : Html msg
iconDivide =
    svg [ width "24", height "24", viewBox "0 0 42 42", fill "currentColor" ] [ rect [ y "19", width "42", height "4" ] [], Svg.path [ d "M21,13c2.757,0,5-2.243,5-5s-2.243-5-5-5s-5,2.243-5,5S18.243,13,21,13z" ] [], Svg.path [ d "M21,29c-2.757,0-5,2.243-5,5s2.243,5,5,5s5-2.243,5-5S23.757,29,21,29z" ] [] ]
