module GraphQL exposing (payload, request)

import Http
import Json.Encode as Encode
import Json.Decode as Decode
import Session exposing (Session)


payload : String -> Maybe Encode.Value -> Encode.Value
payload query maybeVariables =
    case maybeVariables of
        Nothing ->
            Encode.object
                [ ( "query", Encode.string query ) ]

        Just variables ->
            Encode.object
                [ ( "query", Encode.string query )
                , ( "variables", variables )
                ]


request : String -> Maybe Encode.Value -> Decode.Decoder a -> Session -> Http.Request a
request query maybeVariables decoder session =
    let
        body =
            Encode.encode 0 (payload query maybeVariables)
    in
        Http.request
            { method = "POST"
            , headers = [ Http.header "Authorization" ("Bearer " ++ session.token) ]
            , url = "/graphql"
            , body = Http.stringBody "application/json" body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }
