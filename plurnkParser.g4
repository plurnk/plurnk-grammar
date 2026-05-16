parser grammar plurnkParser;

options { tokenVocab = plurnkLexer; }

document
    : (statement | TEXT)* EOF
    ;

statement
    : findStatement
    | readStatement
    | editStatement
    | copyStatement
    | moveStatement
    | showStatement
    | hideStatement
    | sendStatement
    | execStatement
    ;

// 6 tag-CSV ops share the same modifier permutation: tagSignal, path, lineMarker
// in any order, each appearing at most once. HIDE is split out because its
// signal slot accepts either a tag filter or an integer status code (the
// latter being the model's explicit subscription-cancel intent, e.g.
// `<<HIDE[499](sse://feed)::HIDE`).
findStatement : OPEN_FIND tagOpModifiers? COLON body? CLOSE_TAG ;
readStatement : OPEN_READ tagOpModifiers? COLON body? CLOSE_TAG ;
editStatement : OPEN_EDIT tagOpModifiers? COLON body? CLOSE_TAG ;
copyStatement : OPEN_COPY tagOpModifiers? COLON body? CLOSE_TAG ;
moveStatement : OPEN_MOVE tagOpModifiers? COLON body? CLOSE_TAG ;
showStatement : OPEN_SHOW tagOpModifiers? COLON body? CLOSE_TAG ;
hideStatement : OPEN_HIDE hideOpModifiers? COLON body? CLOSE_TAG ;

// SEND/EXEC have no `<L>` slot. Signal and path may appear in either order.
sendStatement : OPEN_SEND sendModifiers? COLON body? CLOSE_TAG ;
execStatement : OPEN_EXEC execModifiers? COLON body? CLOSE_TAG ;

// Modifier slot permutations. Each leaf rule appears at most once in any
// path through the alternatives, so duplicate slots fail at parse time.
tagOpModifiers
    : tagSignal (path lineMarker? | lineMarker path?)?
    | path (tagSignal lineMarker? | lineMarker tagSignal?)?
    | lineMarker (tagSignal path? | path tagSignal?)?
    ;

hideOpModifiers
    : hideSignal (path lineMarker? | lineMarker path?)?
    | path (hideSignal lineMarker? | lineMarker hideSignal?)?
    | lineMarker (hideSignal path? | path hideSignal?)?
    ;

sendModifiers
    : intSignal path?
    | path intSignal?
    ;

execModifiers
    : identSignal path?
    | path identSignal?
    ;

// Signal productions — permissive where the interpretation is deterministic.
// hideSignal is dispatched in the lexer's SIGNAL_HIDE mode, which emits
// either INT or TAG tokens; the parser picks the matching alternative.
tagSignal   : LBRACKET (TAG | COMMA)* RBRACKET ;
intSignal   : LBRACKET INT? RBRACKET ;
identSignal : LBRACKET IDENT? RBRACKET ;
hideSignal  : intSignal | tagSignal ;

path        : LPAREN PATH_TEXT? RPAREN ;
lineMarker  : L_MARKER ;
body        : BODY_TEXT+ ;
