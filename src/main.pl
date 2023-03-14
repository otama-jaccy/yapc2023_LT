use 5.36.0;
use strict;
use warnings;
use utf8;

use Encode qw/decode_utf8/;
use Data::Dumper;

use lib '.';

require 'lib/KamakuraTrash.pm';
require 'lib/TrashInfoDeliver.pm';

my %trash_info_by_city = KamakuraTrash::get_trash_info_by_city();
TrashInfoDeliver::send_trash_info(\%trash_info_by_city, decode_utf8($ENV{"CITY"}));
