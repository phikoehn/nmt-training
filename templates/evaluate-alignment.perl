#!/usr/bin/perl -w

use strict;

die unless scalar @ARGV == 3;
my ($bpe_input,$bpe_output,$fast_align) = @ARGV;

my ($total_match_score,$total_prob_score,$count) = (0,0,0);
open(IN,$bpe_input);
open(OUT,$bpe_output);
open(ALIGN,$fast_align);
while(my $out = <OUT>) {
  my $align = <ALIGN>;
  my $in = <IN>;
  next if $align =~ /^\s*$/;
  chop($in); chop($out); chop($align);

  $out =~ /(.+) \|\|\| (.+)/ || die($out);
  $out = $1;
  my $soft_align = $2;

  my @IN_WORD = split(/ /,$in);
  my @OUT_WORD = split(/ /,$out);

  # get soft alignment matrix
  my @SOFTALIGN;
  my $o=0;
  foreach my $avector (split(/ /,$soft_align)) {
    my @AVECTOR = split(/,/,$avector);
    for(my $i=0;$i<scalar(@AVECTOR)-1;$i++) {
      $SOFTALIGN[$i][$o] = $AVECTOR[$i] / (1-$AVECTOR[$#AVECTOR]);
    }
    $o++;
  }

  # get fast align matrix
  my @COUNT;
  for(my $o=0;$o<scalar(@{$SOFTALIGN[0]});$o++) {
    $COUNT[$o] = 0;
  }
  my @ALIGN;
  foreach (split(/ /,$align)) {
    my ($i,$o) = split(/\-/);
    $ALIGN[$i][$o] = 1;
    $COUNT[$o]++;
  }
  for(my $i=0;$i<scalar(@SOFTALIGN);$i++) {
    for(my $o=0;$o<scalar(@{$SOFTALIGN[0]});$o++) {
      if ($COUNT[$o] == 0) {
        $ALIGN[$i][$o] = 1/scalar(@SOFTALIGN);
      }
      else {
        $ALIGN[$i][$o] += 0;
        $ALIGN[$i][$o] /= $COUNT[$o];
      }
    }
  }

  # score soft alignment
  my $sentence_prob_score = 0;
  my $z = 0;
  foreach (split(/ /,$align)) {
    my ($i,$o) = split(/\-/);
    $sentence_prob_score += $SOFTALIGN[$i][$o];
    $z += 1/$COUNT[$o];
  }
  $sentence_prob_score /= $z;
  $total_prob_score += $sentence_prob_score;
  # print "sentence probability mass score: $z $sentence_prob_score\n";

  my $sentence_match_score = 0;
  $z = 0;
  for(my $o=0;$o<scalar(@{$SOFTALIGN[0]});$o++) {
    next unless $COUNT[$o]>0;
    my @VALUES;
    for(my $i=0;$i<scalar(@SOFTALIGN);$i++) {
      push @VALUES, $SOFTALIGN[$i][$o];
    }
    my @SORTED = sort { $b <=> $a } @VALUES;
    for(my $i=0;$i<scalar(@SOFTALIGN);$i++) {
      if ($SOFTALIGN[$i][$o] >= $SORTED[$COUNT[$o]-1] && $ALIGN[$i][$o] > 0) {
        $sentence_match_score += 1/$COUNT[$o];
      }
    }
    $z++;
  }
  $sentence_match_score /= $z;
  $total_match_score += $sentence_match_score;
  $count++;
  #print "sentence match score: $sentence_match_score\n";

  
  # print alignment matrix
  next;
  print "        ";
  for(my $i=0;$i<scalar(@SOFTALIGN);$i++) {
    print substr($IN_WORD[$i]."       ",0,8)." ";
  }
  print "\n";
  for(my $o=0;$o<scalar(@{$SOFTALIGN[0]});$o++) {
    print substr($OUT_WORD[$o]."      ",0,7)." ";
    for(my $i=0;$i<scalar(@SOFTALIGN);$i++) {
      print substr(sprintf("%03.3f ",$SOFTALIGN[$i][$o]),2);
      printf("%01.1f  ",$ALIGN[$i][$o]);
    }
    print "\n";
  }

  #exit;
}
close(ALIGN);
close(IN);
close(OUT);

printf "match score: %.4f\n", $total_match_score/$count;
printf "prob score: %.4f\n", $total_prob_score/$count;

