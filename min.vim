" Vim syntax file
" Language: min
" Maintainer: Fabio Cevasco
" Last Change: 05 Jan 2021
" Version: 0.28.0

if exists("b:current_syntax")
  finish
endif

setl iskeyword=@,36-39,+,-,*,.,/,:,~,!,48-57,60-65,94-95,192-255 
setl iskeyword+=^

syntax keyword          minDefaultSymbol ! !! != # $ % & && ' * + - -- -> -inf . .. / : :: < <= = =% =-= == ==> => =~ > >< >= >> @ ROOT ^ _demo _dev _github _min _one _shell accept acos aes all? and any? append apply apply-interpolate args asin ask atan atime bind bool boolean? call capitalize case cd ceil chmod choose chr clear clear-stack cleave close cmd column-print compiled? concat confirm connect cons cos cosh cp cpu crypto ctime d2r datetime ddel ddup debug debug! decode decode-url define define-sigil defined-sigil? defined? delete delete-sigil dequote dequote-and dequote-or devconfig dget dhas? dict dictionary? difference dip dir? dirname div dkeys download dpairs dpick drop dsdelete dset dsget dshas? dsinit dspost dsput dsquery dsread dstore dswrite dtype dup dvalues e encode encode-url env? error error! escape eval even? exists? exit expect expect-all expect-any expect-empty-stack fappend fatal fatal! file? filename filter find first flatten float float? floor foreach format-error fperms fread from-json from-semver from-yaml fs fsize fstats ftype fwrite get get-content get-env get-stack getchr gets hardlink harvest hidden? http id if import in? indent indexof inf infix-dequote info info! insert int integer? interpolate intersection invoke io join keep last length linrec listen lite? ln load load-symbol log10 log2 logic loglevel loglevel? lowercase ls ls-r map map-reduce mapkey match math md5 min_symbols mini? minrc mkdir mod module mtime mv nan net netstart netstop newline nip not notice notice! now null? num number? odd? one? operator opts or ord os over parse parse-url partition password pi pick pop pow pred prefix prefix-dequote prepend print print! prompt publish put-env putchr puts puts! quit quotation? quote quote-bind quote-define quote-map r2g raise random randomize raw-args read rebuild recv recv-line reduce regex reject remove remove-symbol repeat replace request require rest restart return reverse reverse-expect-dequote rm rmdir rolldown rollup round run save-symbol saved-symbols scope scope-sigils scope-symbols seal seal-sigil search semver-inc-major semver-inc-minor semver-inc-patch semver? send seq set set-stack set-type sha1 shorten sigils sin sinh sip size sleep slice socket sort source split spread sqrt stack start-server startshell stop-server stopshell str string string? strip substr succ suffix sum swap swons symbols symdir symlink symlink? symmetric-difference sys system system! take tan tanh tap tap! tau tformat time timeinfo times timestamp titleize to-json to-semver to-timestamp to-yaml tobin trunc try type type? union unless unmapkey unseal unseal-sigil unzip uppercase version vscode warn warn! when which while with xor zip ||

syntax match            minDefaultSigil       ;\<[/:@'~!?$%&=<>#^*#+]; contained
syntax match            minQuote              ;\<['];
syntax match            minQuotedBinding      ;#;
syntax match            minBinding            ;@;

syntax keyword          minCommentTodo        TODO FIXME XXX TBD contained
syntax match            minComment            /;.*$/ contains=minCommentTodo

syntax match            minNumber             ;[-+]\=\d\+\(\.\d*\)\=;
syntax keyword          minBoolean            true false
syntax region           minString             start=+"+ skip=+\\\\\|\\$"+  end=+"+  

syntax region           minSigilSymbol        start=;\<[/:@'~!?$%&=<>^*#+]; end=;\>; contains=minDefaultSigil  
syntax region           minQuotedSymbol       start=;\<[']; end=;\>; contains=minQuote
syntax region           minBoundSymbol        start=;@; end=;\>; contains=minBinding
syntax region           minQuotedBoundSymbol  start=;#; end=;\>; contains=minQuotedBinding
syntax match            minSymbol             ;[a-zA-Z._][a-zA-Z0-9/!?+*._-]*;

syntax match            minParen              ;(\|)\|{\|}; 

syntax match            minSharpBang          /\%^#!.*/


" Highlighting
hi default link         minComment            Comment
hi default link         minCommentTodo        Todo
hi default link         minString             String
hi default link         minSigilSymbol        String
hi default link         minNumber             Number
hi default link         minBoolean            Boolean
hi default link         minDefaultSymbol      Statement
hi default link         minQuote              Delimiter
hi default link         minBinding            Delimiter
hi default link         minQuotedBinding      Delimiter
hi default link         minDefaultSigil       Delimiter
hi default link         minSymbol             Identifier
hi default link         minQuotedSymbol       Special
hi default link         minBoundSymbol        Special
hi default link         minQuotedBoundSymbol  Special
hi default link         minParen              Special
hi default link         minSharpBang          Preproc

let b:current_syntax = "min"
