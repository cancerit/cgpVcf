#!/usr/bin/perl

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME          => 'cgpVcf',
  VERSION_FROM  => 'lib/Sanger/CGP/Vcf.pm',
  EXE_FILES     => [qw()],
  PREREQ_PM     => {
                     'Const::Fast' => 0.014,
                   }
);
