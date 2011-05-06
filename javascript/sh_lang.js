/* Copyright (C) 2007 gnombat@users.sourceforge.net */
/* License: http://shjs.sourceforge.net/doc/license.html */
if (! this.sh_languages) {
  this.sh_languages = {};
}
sh_languages['tcl'] = [
  [
    {
      'next': 1,
      'regex': /#/g,
      'style': 'sh_comment'
    },
    {
      'regex': /\b[+-]?(?:(?:0x[A-Fa-f0-9]+)|(?:(?:[\d]*\.)?[\d]+(?:[eE][+-]?[\d]+)?))u?(?:(?:int(?:8|16|32|64))|L)?\b/g,
      'style': 'sh_number'
    },
    {
      'next': 2,
      'regex': /"/g,
      'style': 'sh_string'
    },
    {
      'next': 3,
      'regex': /'/g,
      'style': 'sh_string'
    },
    {
      'regex': /~|!|%|\^|\*|\(|\)|-|\+|=|\[|\]|\\|:|;|,|\.|\/|\?|&|<|>|\|/g,
      'style': 'sh_symbol'
    },
    {
      'regex': /\{|\}/g,
      'style': 'sh_cbracket'
    },
    {
      'regex': /\b(?:proc|global|upvar|if|then|else|elseif|for|foreach|break|continue|while|set|eval|case|in|switch|default|exit|error|proc|return|uplevel|loop|for_array_keys|for_recursive_glob|for_file|unwind_protect|expr|catch|namespace|rename|variable|method|itcl_class|public|protected|append|binary|format|re_syntax|regexp|regsub|scan|string|subst|concat|join|lappend|lindex|list|llength|lrange|lreplace|lsearch|lset|lsort|split|expr|incr|close|eof|fblocked|fconfigure|fcopy|file|fileevent|flush|gets|open|puts|read|seek|socket|tell|load|loadTk|package|pgk::create|pgk_mkIndex|source|bgerror|history|info|interp|memory|unknown|enconding|http|msgcat|cd|clock|exec|exit|glob|pid|pwd|time|dde|registry|resource)\b/g,
      'style': 'sh_keyword'
    },
    {
      'regex': /\$[A-Za-z0-9_]+/g,
      'style': 'sh_variable'
    }
  ],
  [
    {
      'exit': true,
      'regex': /$/g
    }
  ],
  [
    {
      'exit': true,
      'regex': /"/g,
      'style': 'sh_string'
    },
    {
      'regex': /\\./g,
      'style': 'sh_specialchar'
    }
  ],
  [
    {
      'exit': true,
      'regex': /'/g,
      'style': 'sh_string'
    },
    {
      'regex': /\\./g,
      'style': 'sh_specialchar'
    }
  ]
];
sh_languages['unix'] = [
  [
    {
      'regex': /\$ .*/g,
      'style': 'sh_comment'
    }
  ]
];
sh_languages['autosetup'] = [
  [
    {
      'next': 1,
      'regex': /#/g,
      'style': 'sh_comment'
    },
    {
      'regex': /\b[+-]?(?:(?:0x[A-Fa-f0-9]+)|(?:(?:[\d]*\.)?[\d]+(?:[eE][+-]?[\d]+)?))u?(?:(?:int(?:8|16|32|64))|L)?\b/g,
      'style': 'sh_number'
    },
    {
      'next': 2,
      'regex': /"/g,
      'style': 'sh_string'
    },
    {
      'regex': /~|!|%|\^|\*|\(|\)|-|\+|=|\[|\]|\\|:|;|,|\.|\/|\?|&|<|>|\|/g,
      'style': 'sh_symbol'
    },
    {
      'regex': /\{|\}/g,
      'style': 'sh_cbracket'
    },
    {
      'regex': /\b(?:cc-[-a-z]*|define[-a-z]*|get-define|user-error|options|use|opt-[a-z]*|msg-[-a-z]*|make-[-a-z]*|have-[-a-z]*)\s/g,
      'style': 'sh_function'
    },
    {
      'regex': /\b(?:proc|global|upvar|if|then|else|elseif|for|foreach|break|continue|while|set|eval|case|in|switch|default|exit|error|proc|return|uplevel|loop|expr|catch|namespace|rename|variable|method|public|protected|append|binary|format|re_syntax|regexp|regsub|scan|string|subst|concat|join|lappend|lindex|list|llength|lrange|lreplace|lsearch|lset|lsort|split|expr|incr|close|eof|fblocked|fconfigure|fcopy|file|fileevent|flush|gets|open|puts|read|seek|socket|tell|load|loadTk|package|pgk::create|pgk_mkIndex|source|bgerror|history|info|interp|memory|unknown|enconding|http|msgcat|cd|clock|exec|exit|glob|pid|pwd|time|dde|registry|resource)\b/g,
      'style': 'sh_keyword'
    },
    {
      'regex': /\$[A-Za-z0-9_]+/g,
      'style': 'sh_variable'
    }
  ],
  [
    {
      'exit': true,
      'regex': /$/g
    }
  ],
  [
    {
      'exit': true,
      'regex': /"/g,
      'style': 'sh_string'
    },
    {
      'regex': /\\./g,
      'style': 'sh_specialchar'
    }
  ],
];
sh_languages['makefile'] = [
  [
    {
      'regex': /^[a-zA-Z0-9_-]+[\s]*=/g,
      'style': 'sh_type'
    },
    {
      'regex': /^\.[a-zA-Z0-9_-]+[\s]*:/g,
      'style': 'sh_preproc'
    },
    {
      'regex': /@(?:.+)@/g,
      'style': 'sh_preproc'
    },
    {
      'regex': /^(?:[A-Za-z0-9_.\s-])+:/g,
      'style': 'sh_symbol'
    },
    {
      'regex': /%[a-zA-Z0-9_.-]+:%[a-zA-Z0-9_.-]+/g,
      'style': 'sh_string'
    },
    {
      'regex': /(?:[A-Za-z0-9_-]*)\.(?:[A-Za-z0-9_-]+)/g,
      'style': 'sh_normal'
    },
    {
      'regex': /\b(?:import)\b/g,
      'style': 'sh_preproc'
    },
    {
      'regex': /\b[+-]?(?:(?:0x[A-Fa-f0-9]+)|(?:(?:[\d]*\.)?[\d]+(?:[eE][+-]?[\d]+)?))u?(?:(?:int(?:8|16|32|64))|L)?\b/g,
      'style': 'sh_number'
    },
    {
      'regex': /\\"/g,
      'style': 'sh_normal'
    },
    {
      'regex': /\\'/g,
      'style': 'sh_normal'
    },
    {
      'next': 1,
      'regex': /"/g,
      'style': 'sh_string'
    },
    {
      'next': 2,
      'regex': /'/g,
      'style': 'sh_string'
    },
    {
      'regex': /function[ \t]+(?:[A-Za-z]|_)[A-Za-z0-9_]*[ \t]*(?:\(\))?/g,
      'style': 'sh_function'
    },
    {
      'regex': /(?:[A-Za-z]|_)[A-Za-z0-9_]*[ \t]*\(\)/g,
      'style': 'sh_function'
    },
    {
      'regex': /(?:[A-Za-z]*[-\/]+[A-Za-z]+)+/g,
      'style': 'sh_normal'
    },
    {
      'regex': /\b(?:alias|bg|bind|break|builtin|caller|case|command|compgen|complete|continue|declare|dirs|disown|do|done|elif|else|enable|esac|eval|exec|exit|export|false|fc|fg|fi|for|getopts|hash|help|history|if|in|jobs|let|local|logout|popd|printf|pushd|read|readonly|return|select|set|shift|shopt|source|suspend|test|then|times|trap|true|type|typeset|umask|unalias|unset|until|wait|while)\b/g,
      'style': 'sh_keyword'
    },
    {
      'regex': /(?:[A-Za-z]|_)[A-Za-z0-9_]*(?==)/g,
      'style': 'sh_variable'
    },
    {
      'regex': /\$\{(?:[^ \t]+)\}/g,
      'style': 'sh_variable'
    },
    {
      'regex': /\$\((?:[^ \t]+)\)/g,
      'style': 'sh_variable'
    },
    {
      'regex': /\$(?:[A-Za-z]|_)[A-Za-z0-9_]*/g,
      'style': 'sh_variable'
    },
    {
      'regex': /\$(?:[^ \t]{1})/g,
      'style': 'sh_variable'
    },
    {
      'regex': /~|!|%|\^|\*|\(|\)|\+|=|\[|\]|\\|:|;|,|\.|\/|\?|&|<|>|\||(?:##){2}|%%/g,
      'style': 'sh_symbol'
    },
    {
      'next': 3,
      'regex': /#/g,
      'style': 'sh_comment'
    }
  ],
  [
    {
      'exit': true,
      'regex': /"/g,
      'style': 'sh_string'
    },
    {
      'regex': /\\./g,
      'style': 'sh_specialchar'
    }
  ],
  [
    {
      'exit': true,
      'regex': /'/g,
      'style': 'sh_string'
    },
    {
      'regex': /\\./g,
      'style': 'sh_specialchar'
    }
  ],
  [
    {
      'exit': true,
      'regex': /$/g
    }
  ]
];
