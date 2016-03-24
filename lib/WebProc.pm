use strict;
use warnings;
use 5.014;

package WebProc {

  use Mojo::Base qw( Clustericious::App );

  # ABSTRACT: Web interface to /proc

}

package WebProc::Routes {

  use Clustericious::RouteBuilder;

  authenticate;
  
  get '/cpuinfo' => sub {
    my($c) = @_;
    my %cpus = %{ WebProc::CpuInfo->get };
    
    foreach my $cpu (keys %cpus)
    {
      $cpus{$cpu}->{url} = $c->url_for('cpu', cpu_number => $cpu)->to_abs->to_string;
    }
    
    $c->stash->{autodata} = \%cpus;
  } => 'cpu_overview';

  get '/cpuinfo/:cpu_number' => sub {
    my($c) = @_;
    
    my $cpu = WebProc::CpuInfo->get->{$c->param('cpu_number')};
    
    defined $cpu ? $c->stash->{autodata} = $cpu : $c->reply->not_found;
  } => 'cpu';

}

package WebProc::CpuInfo {

  our $filename = "/proc/cpuinfo";

  sub get
  {
    use autodie;
    my %cpus;
    my $cpu = {};
    open my $fh, '<', $filename;
    while(<$fh>)
    {
      if(/^(.*)\s*:\s*(.*)$/)
      {
        my($name,$value) = ($1,$2);
        $name =~ s{\s+$}{};
        $value =~ s{\s+$}{};
        $value = int $value if $value =~ /^[0-9]+$/;
        $cpu->{$name} = $value;
        if($name eq 'processor')
        {
          $cpus{$value} = $cpu;
        }
      }
      elsif(/^$/)
      {
        $cpu = {};
      }
      else
      {
        die "bad parse of /proc/cpuinfo: $_";
      }
    }
    close $fh;
    \%cpus;
  }

}

1;
