package KamakuraTrash;

use v5.36;
use utf8;
use Encode qw/decode_utf8/;

use HTML::TreeBuilder::XPath;

use Data::Dumper;

sub get_trash_info_by_city {
    my $tree= HTML::TreeBuilder::XPath->new;
    $tree->parse_file("index.html");

    my @trs = $tree->findnodes('//div[@id="tmp_read_contents"]//tr');

    # ゴミタイプの取り出し
    my $header = shift @trs;
    my (undef, @trash_types) = $header->findnodes('//th');
    @trash_types = map {$_->findvalue('.')} @trash_types;
    @trash_types = map {decode_utf8($_)} @trash_types;

    # 各町のゴミ情報を追加していく
    my %trash_info_by_city = ();
    for my $row (@trs) {
        my @tds = $row->findvalues('./td');
        my $city_name = decode_utf8(shift @tds);

        my %trash_info = ();
        for my $i (0 .. $#tds) {
            my $trash_type = $trash_types[$i];
            my $trash_day = decode_utf8($tds[$i]);
            # 隔週のゴミ(例：第1水曜日)
            if ($trash_day =~ /(\d)([月火水木金])/) {
                $trash_info{$trash_type} = {
                    type => "biweekly",
                    order => $1,
                    day_of_week => $2,
                };
            }
            # 毎週のゴミ(例：月・金曜日)
            elsif ($trash_day =~ /(.+)曜日/){
                my @day_of_weeks = split(/・/, $1);
                $trash_info{$trash_type} = {
                    type => "every_weekly",
                    day_of_weeks => \@day_of_weeks,
                };
            }
        }
        $trash_info_by_city{$city_name} = \%trash_info;
    }
  return %trash_info_by_city;
}

1;
