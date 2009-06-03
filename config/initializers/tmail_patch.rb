# 規約に違反した携帯メールアドレスへの対応
TMail.instance_eval{remove_const 'Parser'}
require 'tmail_1_2_3_1_parser_fix'