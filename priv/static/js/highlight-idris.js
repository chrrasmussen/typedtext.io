/*
Language: Idris
Author: Christian Rasmussen <christian.rasmussen@me.com>
Derived from haskell.js by: Jeremy Hull <sourdrums@gmail.com>, Zena Treep <zena.treep@gmail.com>
Website: https://www.idris-lang.org
Category: functional
*/

var hljsDefineIdris = function(hljs) {
  var COMMENT = {
    variants: [
      hljs.COMMENT('--', '$'),
      hljs.COMMENT(
        '{-',
        '-}',
        {
          contains: ['self']
        }
      )
    ]
  };

  var PRAGMA = {
    className: 'meta',
    begin: '%', end: '$'
  };
  
  var PREPROCESSOR = {
    className: 'meta',
    begin: '^#', end: '$'
  };

  var CONSTRUCTOR = {
    className: 'type',
    begin: '\\b[A-Z][\\w\']*', // TODO: other constructors (build-in, infix).
    relevance: 0
  };

  var LIST = {
    begin: '\\(', end: '\\)',
    illegal: '"',
    contains: [
      PRAGMA,
      PREPROCESSOR,
      {className: 'type', begin: '\\b[A-Z][\\w]*(\\((\\.\\.|,|\\w+)\\))?'},
      hljs.inherit(hljs.TITLE_MODE, {begin: '[_a-z][\\w\']*'}),
      COMMENT
    ]
  };
  
  var IDRIS_KEYWORDS = [
    'data', 'module', 'where', 'let', 'in', 'do', 'record',
    'auto', 'default', 'implicit', 'mutual', 'namespace',
    'parameters', 'with', 'impossible', 'case', 'of',
    'if', 'then', 'else', 'forall', 'rewrite',
    'using', 'interface', 'implementation', 'open', 'import',
    'public', 'export', 'private',
    'infixl', 'infixr', 'infix', 'prefix',
    'total', 'partial', 'covering',
    'constructor'
  ].join(' ');

  return {
    name: 'Idris',
    aliases: ['idr'],
    keywords: IDRIS_KEYWORDS,
    contains: [
      // Top-level constructs

      {
        beginKeywords: 'module', end: '$',
        keywords: 'module',
        contains: [LIST, COMMENT],
        illegal: '\\W\\.|;'
      },
      {
        begin: 'import', end: '$',
        keywords: 'import as',
        contains: [LIST, COMMENT],
        illegal: '\\W\\.|;'
      },

      {
        beginKeywords: 'interface implementation', end: 'where',
        keywords: 'interface implementation where',
        contains: [CONSTRUCTOR, LIST, COMMENT]
      },
      {
        beginKeywords: 'data', end: 'where|$',
        keywords: 'data where',
        contains: [PRAGMA, CONSTRUCTOR, LIST, COMMENT]
      },
      {
        beginKeywords: 'infix infixl infixr', end: '$',
        contains: [hljs.C_NUMBER_MODE, COMMENT]
      },
      {
        beginKeywords: 'public export private'
      },
      {
        beginKeywords: 'partial'
      },
      {
        beginKeywords: 'record', end: 'where',
        keywords: 'record where'
      },
      {
        beginKeywords: 'namespace', end: '$'
      },

      PRAGMA,
      PREPROCESSOR,

      // TODO: Character literals
      hljs.QUOTE_STRING_MODE,
      hljs.C_NUMBER_MODE,
      CONSTRUCTOR,
      hljs.inherit(hljs.TITLE_MODE, {begin: '^[_a-z][\\w\']*'}),

      COMMENT
    ]
  };
}
