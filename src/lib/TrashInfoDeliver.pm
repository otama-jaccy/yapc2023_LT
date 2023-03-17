package TrashInfoDeliver;

use v5.36;
use utf8;

use URI;
use HTTP::Tiny;
use JSON qw/encode_json/;
use Time::Piece;

use Data::Dumper;

sub send_to_slack {
    my @trash_types = @_;
    my $trash_text = join("と", @trash_types);

    my $url = URI->new($ENV{"SLACK_WEBHOOK_URL"});
    my $ht = HTTP::Tiny->new;
    my $header = {
        header => {
            'Content-Type'  => 'application/json; charset=utf-8'
        },
        content => encode_json {
            trash_types => $trash_text
        }
    };

    my $response = $ht->request ( 'POST', $url, $header);
    die($response->{'content'}) if $response->{'status'} >= 300;
}

# 曜日をlocaltimeのwdayに変換する
sub day_of_week2wday {
    my $day_of_week = shift;
    return index("日月火水木金土", $day_of_week)+1;
}

# 渡された曜日（例：土）が次のゴミ捨て日かを判別
sub is_next_trash_day {
    my $trash_day_of_week = shift;
    my $trash_wday = day_of_week2wday($trash_day_of_week);

    # 金曜、土曜は日曜として扱う
    my $today_wday = localtime->wday;
    if ($today_wday == 6 || $today_wday == 7) {
        $today_wday = 1;
    }

    return $today_wday+1 == $trash_wday;
}

sub send_trash_info {
    my ($trash_info_by_city, $city_name) = @_;

    my $trash_info = $trash_info_by_city->{$city_name};
    my @tommorow_trash = ();

    for my $trash_type (keys $trash_info->%*) {
        my $trash_day = $trash_info->{$trash_type};

        # 曜日が次のゴミ捨て日でないものは弾く
        my $days = $trash_day->{"day_of_weeks"} // [$trash_day->{"day_of_week"}];
        my @active_days = grep { is_next_trash_day($_) } $days->@*;
        if ($#active_days<0) {
            next;
        }

        # 隔週であるゴミ捨てで今週でないものは弾く
        my $today = localtime;
        if ($trash_day->{"type"} eq "biweekly" && $trash_day->{"order"}!=int($today->mday/7)+1){
            next;
        }

        push(@tommorow_trash, $trash_type);
    }
    send_to_slack(@tommorow_trash);
}

1;
