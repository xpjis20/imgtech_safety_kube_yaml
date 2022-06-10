MAIN:
{
    if(! @ARGV){
        print "Usage:./dockremove.pl ContainerName\n";
        print "Usage:./dockremove.pl -a (all remove) \n";
       exit(0);
    }




    if($ARGV[0] eq "-a"){
        my $dockerCommand = "docker ps -a";
        #my $dockerCommand = "docker container ls";
        my @resultStr = `$dockerCommand`;
        my $existContainer = 0;
        if(@resultStr == 1){
            print "no running container\n";
            exit(0);
        }

        foreach (@resultStr){
            if($_ !~ /^CONTAINER ID/){
                if($_ =~ /apache/ || $_ =~ /tomcat/ || $_ =~ /mariadb/){
                    my @containerID = split(/   /,$_);# tab으로 구분을 안하네???
                    $dockerCommand = "docker stop ".$containerID[0];
                    `$dockerCommand`;
                    print $containerID[0]."-container stop\n";
                    $dockerCommand = "docker rm ".$containerID[0];
                    `$dockerCommand`;

                }

            }

        }

    }
    elsif(@ARGV != 0 && $ARGV[0] ne "-a" &&  $ARGV[0] ne ""){
        print $ARGV[0]."\n";
        print "logic not yet!\n";
    }

    my @resultCommand = `docker ps -a`;
    foreach(@resultCommand){
       print $_;
    }

}
