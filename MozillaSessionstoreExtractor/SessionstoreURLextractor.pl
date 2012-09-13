#!/usr/bin/perl
my @array;

open(FILE,"sessionstore.bak");

for (<FILE>) {   
   (@array) = split(/,{/,$_);
}

# extract everything that looks like a url
for $line (@array) {
   my $f;
   
   ($f) = ($line =~ /"url":"([^"]*)"/);

   print "$f \n";  
}
