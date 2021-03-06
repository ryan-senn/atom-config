module ASTParsing.Expressions.ListExpression exposing (canParseFromList)

import Dict
import ElmFile
import Expect
import Set
import Test exposing (Test, describe, test)
import Types.Expression
import Types.Reference exposing (Reference)


canParseFromList : Test
canParseFromList =
    describe "References in List Expression" <|
        let
            fileName =
                "ListExpression.elm"

            file =
                ElmFile.makeAst fileName elmFileText

            elmFile =
                ElmFile.createBase fileName file
                    |> ElmFile.parseCore fileName file
                    |> ElmFile.parseReferences fileName file Dict.empty
        in
        [ test "has expected module name" <|
            \_ ->
                Expect.equal elmFile.moduleName [ "Simple" ]
        , test "has expected imports" <|
            \_ ->
                Expect.equal elmFile.imports
                    { direct = Dict.empty
                    , aliases = Dict.empty
                    , unqualified = Set.empty
                    }
        , test "has expected top level expressions" <|
            \_ ->
                Expect.equal elmFile.topLevelExpressions
                    { functions =
                        Dict.empty
                            |> Dict.insert "reference1" (Types.Expression.standardExpression 2)
                            |> Dict.insert "reference2" (Types.Expression.standardExpression 6)
                            |> Dict.insert "listExpression" (Types.Expression.standardExpression 10)
                    , types = Dict.empty
                    , typeAliases = Dict.empty
                    }
        , test "has expected exposings" <|
            \_ ->
                Expect.equal elmFile.exposings
                    { functions =
                        Set.empty
                            |> Set.insert "listExpression"
                    , types = Set.empty
                    }
        , test "has expected references" <|
            \_ ->
                Expect.equal elmFile.references
                    { internal =
                        Dict.empty
                            |> Dict.insert "Int" [ Types.Reference.make "Int" 10 17 10 20 "ListExpression.elm" ]
                            |> Dict.insert "String" [ Types.Reference.make "String" 6 13 6 19 "ListExpression.elm", Types.Reference.make "String" 2 13 2 19 "ListExpression.elm" ]
                            |> Dict.insert "reference2" [ Types.Reference.make "reference2" 12 18 12 28 "ListExpression.elm" ]
                            |> Dict.insert "reference1" [ Types.Reference.make "reference1" 12 6 12 16 "ListExpression.elm" ]
                    , external = Dict.empty
                    }
        ]


elmFileText : String
elmFileText =
    """module Simple exposing (listExpression)

reference1 : String
reference1 =
    "a"

reference2 : String
reference2 =
    "b"

listExpression : Int
listExpression =
    [ reference1, reference2 ]

"""
