package Net::Docker::Registry::Client;

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request;
use JSON::MaybeXS;
use URI::Escape;
use Data::Dumper;
use Carp;

sub new { my ($class,%opts) = @_; return bless \%opts, $class }

sub catalog {
  my ($self) = @_;
  my $api_url = '/v2/_catalog';
  return $self->_get("/v2/_catalog", 'repositories');
}

sub manifests {
  my ($self, $name, $reference) = @_;
  return $self->_get("/v2/$name/manifests/$reference");
}

sub list_tags {
  my ($self, $name) = @_;
  return $self->_get("/v2/$name/tags/list", 'tags')->{tags};
}

sub repositories {
  my ($self, $name) = @_;
  return $self->catalog()->{repositories};
}

sub obs_info_json {
  my ($self, $name) = @_;
  return $self->_get("/v2/$name/info.json");
}

sub manifestinfos {
  my ($self, $name, $distmanifest) = @_;
  return $self->_get("/v2/$name/manifestinfos/$distmanifest");
}

sub _get {
  my ($self, $url, $merge) = @_;
  my $port = ($self->{port}) ? ":$self->{port}" : '';
  my $uri = ( $self->{proto} || 'https' ) . "://$self->{host}$port$url";

  my $req = HTTP::Request->new(GET => $uri); # User-Agent:
  $req->header("Host"       => $self->{host});

  $req->authorization_basic($self->{user}, $self->{pass}) if ($self->{user} && $self->{pass});

  my $ua = LWP::UserAgent->new();
  my $res = $ua->request($req);

  if ( $res->is_success ) {
    my $result = decode_json($res->content);
    my $link = $res->header('Link');
    if ($link) {
      die "Do not know what to merge ($url)" if (!$merge);
      $link =~ s/<(.*)>.*/$1/;
      my $mresult = $self->_get($link, $merge);
      if (ref($mresult->{$merge}) eq 'ARRAY' && ref($result->{$merge}) eq 'ARRAY') {
        push (@{$result->{$merge}}, @{$mresult->{$merge}});
      }
    }
    return $result;
  } elsif ($res->code == 401) {
    $self->_authenticate($res);
  } else {
    my $err = $res->status_line . " ($uri)\n";
    if ($self->{trace}) {
      $err .= "### REQUEST  ################################################\n";
      $err .= $req->as_string;
      $err .= "### RESPONSE ################################################\n";
      $err .= $res->as_string;
      $err .= "### END      ################################################\n";
    }
    croak $err;
  }

}

sub _authenticate {
  my ($self, $response) = @_;

  my $realms = $self->_split_realms($response);
  my $type2meth = {
    Bearer => "_oauth_Bearer",
  };

  while (my $next = shift(@$realms)) {
    my $method = $type2meth->{$next->{type}};
    if ($method) {
      my $auth = $self->$method($next);
      return $auth if $auth;
    }
  }
}

sub _oauth_Bearer {
  my ($self, $data) = @_;
  my $post_data = {
    grant_type => 'password',
    client_id  => 'perl-client',
    scope      => $data->{scope},
    service    => $data->{service},
    username   => $self->{user},
    password   => $self->{pass}
  };
  my $req = HTTP::Request->new('POST', $data->{realm});
  $req->header('content-type'=>'application/x-www-form-urlencoded');
  my @ds;
  while ( my ($k, $v) = each(%$post_data) ) {
    next if ($k eq 'realm' or $k eq 'type');
    push @ds, "$k=".uri_escape($v);
  }
  $req->content(join('&',@ds));
  print $req->as_string();
  my $ua = LWP::UserAgent->new();
  my $res = $ua->request($req);
  if ( $res->is_success ) {
    return decode_json($res->content);
  } else {
    die $res->status_line;
  }
}

sub _split_realms {
  my ($self, $response) = @_;
  my $auth_header = $response->header('www-authenticate');
  my @aheader = split(/,/, $auth_header);
  my $realms = [];
  my $rc = 0;
  foreach my $ahf (@aheader) {
    if ($ahf =~ /^(\S*) realm=(?:"|')?([^,"']+)(?:"|')?$/) {
      $rc++;
      $realms->[$rc-1]{type} = $1;
      $realms->[$rc-1]{realm} = $2;
    } else {
      my ($field, $value) = split(/=/,$ahf,2);
      $value =~ s/^(?:"|')?([^,"']+)(?:"|')?$/$1/;
      $realms->[$rc-1]{$field} = $value;
    }
  }
print Dumper($realms);
  return $realms;
}

1;
