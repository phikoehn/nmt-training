#!/usr/bin/perl -w

use strict;
use Getopt::Long "GetOptions";
use FindBin qw($RealBin);

# configurable variables
my ($working_dir,$train_s,$train_t,$dev_s,$dev_t,$lang_s,$lang_t);
my $gpu = 0;
my $ensemble = 4;
my $multiple_models = 0;
my $step_size = 20000;
my $bpe = 49500;
my $guided_alignment = 0;
my ($action,$test_s,$base_model) = (undef,undef,undef);
my ($model,$model_tag) = ("MODEL","NMT");

# from local-settings.sh: jobs submitted by qsub? yes -> get settings
my $qsub = undef;
if (`grep qsub_settings $RealBin/templates/local-settings.sh` =~ /^export qsub_settings="(.+)"\s*$/) {
  $qsub = $1;
}
# from local-settings.sh: amunmt directory
my $amun;
if (`grep '^export amun=' $RealBin/templates/local-settings.sh` =~ /^export amun=(.+)\/build\/amun\s*$/) {
  $amun = $1;
}

# get default settings from info file
for(my $i=0; $i<@ARGV; $i++) {
  next unless $ARGV[$i] eq "-dir";
  $working_dir = $ARGV[++$i];
}
if (defined($working_dir) && -e "$working_dir/info") {
  foreach (`cat $working_dir/info`) {
    /^(\S+) = (.+)$/ || next;
    $lang_s = $2 if $1 eq "lang-s";
    $lang_t = $2 if $1 eq "lang-t";
    $train_s = $2 if $1 eq "train-s";
    $train_t = $2 if $1 eq "train-t";
    $dev_s = $2 if $1 eq "dev-s";
    $dev_t = $2 if $1 eq "dev-t";
    $step_size = $2 if $1 eq "step-size";
    $ensemble = $2 if $1 eq "ensemble";
    $bpe = $2 if $1 eq "bpe";
    $multiple_models = $2 if $1 eq "multiple-models";
    $guided_alignment = $2 if $1 eq "guided-alignment";
  }
}
my $settings = join(" ",@ARGV);

# get variables from command line
die("TRAIN A NEURAL MACHINE TRANSLATION SYSTEM

Switches
--------
Specify action
-action ACTION (= train, continue, adapt, get-system, translation, status)

Core settings
-dir WORKING_DIR - where all process data will be stored
-train-s TRAIN_SRC - source side of training corpus
-train-t TRAIN_TRG - target side of training corpus
-dev-s DEV_SRC - source side of dev set to track progress
-dev-t DEV_TRG - target side of dev set
-lang-s LANGUAGE_EXTENSION_SRC - source language code
-lang-t LANGUAGE_EXTENSION_SRC - target language code

Action-specific settings
-test-s FILE - text to be translated by action 'translate'
-base-model MODEL_DIR - base model to be adapted by 'adapt'

Optional settings
-gpu NUMERICAL_ID (default $gpu) - ID of GPU to use
-ensemble COUNT (defailt $ensemble) - number of models in ensemble
-multiple-models (defailt $multiple_models) - do not merge models in ensemble
-bpe (default: $bpe) - number of bpe operations
-step-size  (default $step_size) - number of iterations per validation
-guided-alignment (default 0) - prime with specified iterations (e.g., 20000) of guided alignment training

Actions
-------
train:      train a system from scratch
continue:   continue an interrupted training run
adapt:      adapt an existing model to a new corpus
get-system: assemble all files for production in folder system
translate:  translate a sentence with most recent system
status:     progress status of current run\n")
unless &GetOptions(
  'dir=s' => \$working_dir,
  'train-s=s' => \$train_s,
  'train-t=s' => \$train_t,
  'dev-s=s' => \$dev_s,
  'dev-t=s' => \$dev_t,
  'test-s=s' => \$test_s,
  'lang-s=s' => \$lang_s,
  'lang-t=s' => \$lang_t,
  'gpu=s' => \$gpu,
  'ensemble=i' => \$ensemble,
  'bpe=i' => \$bpe,
  'multiple-models' => \$multiple_models,
  'step-size=i' => \$step_size,
  'base-model=s' => \$base_model,
  'guided-alignment=i' => \$guided_alignment,
  'action=s' => \$action
) && defined($action);

# check paths
die("training source file '$train_s' does not exist") if defined($train_s) && ! -e $train_s;
die("training target file '$train_t' does not exist") if defined($train_t) && ! -e $train_t;
die("dev source file '$dev_s' does not exist") if defined($dev_s) && ! -e $dev_s;
die("dev target file '$dev_t' does not exist") if defined($dev_t) && ! -e $dev_t;
die("test source file '$test_s' does not exist") if defined($test_s) && ! -e $test_s;
die("ERROR: you need to specify working directory with -dir") unless defined($working_dir);
die("working directory '$working_dir' does not exist") if $action ne "train" && $action ne "adapt" && ! -e $working_dir;
die("ERROR: you need to specify gpu with -gpu") unless defined($gpu) || $action eq "get-system" || $action eq "status";
die("ERROR: working directory already exists (use continue?)") if $action eq "train" && -e $working_dir;

`mkdir -p $working_dir` unless -e $working_dir;
open(INFO,">$working_dir/info");
print INFO "lang-s = $lang_s\n" if defined($lang_s);
print INFO "lang-t = $lang_t\n" if defined($lang_t);
print INFO "train-s = $train_s\n" if defined($train_s);
print INFO "train-t = $train_t\n" if defined($train_t);
print INFO "dev-s = $dev_s\n" if defined($dev_s);
print INFO "dev-t = $dev_t\n" if defined($dev_t);
print INFO "step-size = $step_size\n";
print INFO "bpe = $bpe\n";
print INFO "ensemble = $ensemble\n";
print INFO "multiple-models = $multiple_models\n";
print INFO "guided-alignment = $guided_alignment\n";
close(INFO);

open(LOG,">>$working_dir/log");
my $date = `date +"%Y-%m-%d.%H-%M-%S"`;
chop($date);
print LOG "$date $settings\n";
close(LOG);

# selection action
if (!defined($action)) { die("ERROR: no action defined"); }
elsif ($action eq "train")      { &train(); }
elsif ($action eq "continue")   { &continue(); } 
elsif ($action eq "adapt")      { &adapt(); } 
elsif ($action eq "translate")  { &translate(); } 
elsif ($action eq "get-system") { &get_system(); } 
elsif ($action eq "status")     { &status(); } 
else { die("ERROR: unknown action '$action' - specify: train, continue, adapt, translate, get-system, status"); }

# train from scratch
sub train {
  die("ERROR: you need to specify training source with -train-s") unless defined($train_s);
  die("ERROR: you need to specify training target with -train-t") unless defined($train_t);
  die("ERROR: you need to specify dev source with -dev-s") unless defined($dev_s);
  die("ERROR: you need to specify dev target with -dev-t") unless defined($dev_t);
  die("ERROR: you need to specify source language with -lang-s") unless defined($lang_s);
  die("ERROR: you need to specify target language with -lang-t") unless defined($lang_t);
  &setup_training();
  &copy_corpus();
  `$working_dir/preprocess.sh`;
  &my_system("$working_dir/marian.sh >$working_dir/marian.log 2>&1 &");
}

# continue training
sub continue {
  # remove guided alignment priming 
  if ($guided_alignment) {
    $guided_alignment = 0;
    &copy_file("marian.sh");
  }
  # possibly change GPU
  if (defined($gpu)) {
    &copy_file("local-settings.sh");
  }
  # resume training
  &my_system("$working_dir/marian.sh >$working_dir/marian.continue.log 2>&1 &");
}

# adapt existing model to new training data
sub adapt {
  die("ERROR: base model not specified") if !defined($base_model);
  die("ERROR: base model '$base_model' does not exist") if ! -e $base_model;
  &setup_training();
  &copy_corpus();
  # copy bpe model files (from base model)
  `cp -p $base_model/model/$lang_s$lang_t.bpe $working_dir/model`;
  `cp -p $base_model/data/train.bpe.??.json $working_dir/data`;
  # preprocess training and dev data with given bpe model
  `$working_dir/preprocess-with-given-bpe.sh`;
  # copy most recent model (from base model)
  `cp -p $base_model/model/model.npz $working_dir/model`;
  `cp -p $base_model/model/model.npz.yml $working_dir/model`;
  # copy and score three most recent models
  open(LS,"ls -tr $base_model/model | grep ^model.iter | grep 'npz\$' | tail -n 3 |");
  while(<LS>) {
    chop;
    `cp -p $base_model/model/$_ $working_dir/model`;
    `SPEC_MODEL=model/$_ $working_dir/validate.sh >>$working_dir/train.log 2>&1`; 
  }
  close(LS);
  # train 
  &my_system("$working_dir/marian.sh >>$working_dir/marian.log 2>&1 &");
}

sub translate {
  die("ERROR: you need to specify test source with -test-s") unless defined($test_s);
  &get_system();
  &my_system("$working_dir/system/translate.sh >$test_s.$model_tag.log 2>&1");
}

sub get_system {
  die("ERROR: you need to specify source language with -lang-s") unless defined($lang_s);
  die("ERROR: you need to specify target language with -lang-t") unless defined($lang_t);
  die("ERROR: could not fine byte pair encoding model $working_dir/model/$lang_s$lang_t.bpe") unless -e "$working_dir/model/$lang_s$lang_t.bpe";
  my @MODEL = `ls $working_dir/model/* | grep 'model.iter' | grep 'npz\$'`;
  chop(@MODEL);
  die("ERROR: No single model finished ... cannot build system yet.") unless scalar @MODEL;
  print "WARNING: Fewer models (".scalar(@MODEL).") than specified for ensemble ($ensemble)\n" if $ensemble > @MODEL;
  my %MODEL;
  foreach my $model (@MODEL) {
    if (`cat $model.bleu` =~ /BLEU = ([\d\.]+),/) {
      $MODEL{$model} = $1;
    }
    else {
      print "WARNING: no BLEU score for $model\n";
      $MODEL{$model} = 0;
    }
  }

  @MODEL = sort { $MODEL{$b} <=> $MODEL{$a} } @MODEL;
  foreach (@MODEL) { s/.+\///g; }

  `mkdir -p $working_dir/system`;
  `rm -f $working_dir/system/*`;

  # copy model files
  ($model_tag,$model) = ("NMT","");
  for(my $i=0;$i<$ensemble && $i<@MODEL;$i++) {
    if ($multiple_models) {
      `ln $working_dir/model/$MODEL[$i] $working_dir/system`;
      &copy_yml("$working_dir/model/model.npz.yml","$working_dir/system/$MODEL[$i].yml","$working_dir/system");
    }
    $MODEL[$i] =~ /iter(\d+).npz/;
    $model_tag .= sprintf("%g",$1/1000)."k";
    $model .= "$working_dir/system/$MODEL[$i] " if $multiple_models;
    $model .= "$working_dir/model/$MODEL[$i] " unless $multiple_models;
  }
  if (! $multiple_models) {
    system("$amun/scripts/average.py -m $model -o $working_dir/system/model.$model_tag.npz");
    $model = "$working_dir/system/model.$model_tag.npz";
    &copy_yml("$working_dir/model/model.npz.yml","$working_dir/system/model.$model_tag.npz.yml");
  }

  # create nematus translation script
  $test_s = "REPLACE_WITH_TEST_FILE_NAME" unless defined($test_s);
  &copy_file("translate.sh","$working_dir/system");
  &copy_file("translate.sh");

  # byte pair encoding and vocabulary files
  `ln $working_dir/model/$lang_s$lang_t.bpe $working_dir/system/$lang_s$lang_t.bpe` && die("ERROR: failed copy $working_dir/model/$lang_s$lang_t.bpe");
  `ln $working_dir/data/train.bpe.$lang_s.json $working_dir/system/train.bpe.$lang_s.json` && die("ERROR: failed copy $working_dir/data/train.bpe.$lang_s.json");
  `ln $working_dir/data/train.bpe.$lang_t.json $working_dir/system/train.bpe.$lang_t.json` && die("ERROR: failed copy $working_dir/data/train.bpe.$lang_t.json");

   # AmuNMT configuration file
   open(AMUNMT,">$working_dir/system/amunmt.cfg");
   print AMUNMT "### OMNISCIEN AMUNMT RUNTIME SYSTEM\n
# Paths are relative to config file location
relative-paths: yes

# performance settings
beam-size: 12
devices: [$gpu]
normalize: yes
gpu-threads: ".scalar(split(/ /,$gpu))."

# scorer configuration
scorers:\n";
  if ($multiple_models) {
    for(my $i=0;$i<$ensemble && $i<@MODEL;$i++) {
      print AMUNMT "  F$i:\n";
      print AMUNMT "    path: $MODEL[$i]\n";
      print AMUNMT "    type: Nematus\n";
    }
  }
  else {
    print AMUNMT "  F0:\n";
    print AMUNMT "    path: model.$model_tag.npz\n";
    print AMUNMT "    type: Nematus\n";
  }
  print AMUNMT "\n# scorer weights\nweights:\n";
  if ($multiple_models) {
    for(my $i=0;$i<$ensemble && $i<@MODEL;$i++) {
      print AMUNMT "  F$i: ".(1/$ensemble)."\n";
    } 
  }
  else {
    print AMUNMT "  F0: 1\n";
  }
  print AMUNMT "\n# vocabularies\n";
  print AMUNMT "source-vocab: train.bpe.$lang_s.json\n";
  print AMUNMT "target-vocab: train.bpe.$lang_t.json\n";
  close(AMUNMT);
}

sub copy_yml {
  my ($original,$copy) = @_;
  open(IN,$original) || die("ERROR: cannot open $original for read: $!");
  open(OUT,">$copy") || die("ERROR: cannot open $copy for write: $!");
  while(<IN>) {
    s/data\/train.bpe.(.+).json/$working_dir\/system\/train.bpe.$1.json/;
    print OUT $_;
  }
  close(OUT);
  close(IN);
}

sub status {
  print `nvidia-smi`;
  return unless defined($working_dir);
  print "\n=== train.log =================================================================\n";
  if (-e "$working_dir/train.log") {
    my $filetime = (stat("$working_dir/train.log"))[9];
    printf "Last change %d minutes ago.\n\n",(time()-$filetime)/60;
    if (`cat $working_dir/train.log | wc -l` > 50) {
      print `head -2 $working_dir/train.log`;
      print "[...]\n";
    }
    print `tail -n 50 $working_dir/train.log`;
  }
  else {
    print "Training not started.\n";
  }
  print "\n=== models ====================================================================\n";
  print `ls -lt $working_dir/model/* | grep 'model.iter' | grep 'npz\$'`;
  print "\n=== BLEU ======================================================================\n";
  print `cat $working_dir/model/bleu_scores` if -e "$working_dir/model/bleu_scores";
}

sub setup_training {
  `mkdir -p $working_dir/data`;
  `mkdir -p $working_dir/model`;

  open(FILE,"ls $RealBin/templates|");
  while(my $file = <FILE>) {
    chop($file);
    &copy_file($file);
  }
  close(FILE);
  `chmod +x $working_dir/*.sh`;
}

sub copy_corpus {
  `cp $train_s $working_dir/data/train.tok.$lang_s`;
  `cp $train_t $working_dir/data/train.tok.$lang_t`;
  `cp $dev_s $working_dir/data/dev.tok.$lang_s`;
  `cp $dev_t $working_dir/data/dev.tok.$lang_t`;
}

sub copy_file {
  my ($file,$dir) = @_;
  $dir = $working_dir unless defined($dir);
  my $guided_alignment_cmd  = $guided_alignment ? "python config-guided-alignment.py" : "";
  my $guided_alignment_prep = $guided_alignment ? "sh get-alignment-guidance.sh" : "";
  open(TEMPLATE,"$RealBin/templates/$file");
  open(INSTANTIATION,">$dir/$file");
  while(<TEMPLATE>) {
    s/<XXX DIR>/$working_dir/;
    s/<XXX SRC>/$lang_s/;
    s/<XXX TGT>/$lang_t/;
    s/<XXX GPU>/$gpu/;
    s/<XXX MODEL>/$model/;
    s/<XXX TEST>/$test_s/g if defined($test_s);
    s/<XXX STEP_SIZE>/$step_size/g;
    s/<XXX BPE>/$bpe/;
    s/<XXX MODEL_TAG>/$model_tag/g;
    s/<XXX GUIDED_ALIGNMENT_CMD>/$guided_alignment_cmd/g;
    s/<XXX GUIDED_ALIGNMENT_PREP>/$guided_alignment_prep/g;
    s/<XXX GUIDED_ALIGNMENT>/$guided_alignment/g;
    print INSTANTIATION $_;
  }
  close(INSTANTIATION);
  close(TEMPLATE);
  `chmod +x $dir/$file` if $file =~ /\.sh$/;
}

sub my_system {
  my ($cmd) = @_;
  if (!defined($qsub)) {
    system($cmd);
    return;
  }
  $cmd =~ /^(.+) \>\>?\s*(\S+)/ || die("&my_system($cmd)");
  my ($script,$log) = ($1,$2);
  my $date = `date +"%Y-%m-%d.%H-%M-%S"`;
  chop($date);
  `mkdir -p $working_dir/qsub`;
  my $qsub_script = $script;
  $qsub_script =~ s/\/([^\/]+)$/\/qsub\/$1.$date/;
  `cp $script $qsub_script`;
  $log =~ s/^.+\///;
  print "qsub -l '$qsub' -o $working_dir/qsub/$log.$date.out -e $working_dir/qsub/$log.$date.err $qsub_script\n";
  `qsub -l '$qsub' -o $working_dir/qsub/$log.$date.out -e $working_dir/qsub/$log.$date.err $qsub_script`;
}

