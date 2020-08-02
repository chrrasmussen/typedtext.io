module Hello

import Erlang


%cg erlang export exports


exports : ErlExport
exports = Fun "foo" "hello"
