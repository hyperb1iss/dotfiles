#!/usr/bin/perl
use strict;
use Device::USB;
use Time::HiRes;
use Fcntl;
use Scalar::Util;
use List::Util qw[min max];

eval "use Device::SerialPort;";
if (!($@ eq "")) {
    print "Device::SerialPort module not found.\n";
    print "This can be installed with the command:\n";
    print "sudo apt-get install libdevice-serialport-perl\n";
    exit;
}

my($verbose) = 1;

my($usb) = Device::USB->new();

#for vibrant
#my($read_size) = 500;

#for garnett/atlas
my($read_size) = 0x40000;

use constant SAMSUNG_VENDOR_ID => 0x04e8;
use constant CDC_DATA_CLASS => 0x0A;
use constant USB_BULK_EP => 0b10;
use constant USB_EP_ADDRESS_DIR_MASK => 0b10000000;
use constant USB_EP_DIR_OUT => 0;
use constant USB_EP_DIR_IN => 0b10000000;

use constant CMD_INIT => 100;
use constant CMD_PIT => 101;
use constant CMD_XMIT => 102;
use constant CMD_CLOSE => 103;
use constant CMD_REFORMAT => 104;

use constant CLOSEARG_END => 0;
use constant CLOSEARG_REBOOT => 1;

use constant XMITARG_DOWNLOAD => 0;
use constant XMITARG_DUMP => 1;
use constant XMITARG_START => 2;
use constant XMITARG_COMPLETE => 3;
use constant XMITARG_SMD => 4;

use constant DUMPTYPE_RAM => 0;
use constant DUMPTYPE_NAND => 1;

use constant BINARYTYPE_PDA => 0;
use constant BINARYTYPE_MODEM => 1;

use constant DEVICE_TYPE_ONENAND => 0;
use constant DEVICE_TYPE_NAND => 1;
use constant DEVICE_TYPE_MOVINAND => 2;

use constant FINAL => 1;
use constant NOT_FINAL => 0;

use constant EFS_CLEAR => 1;
use constant NO_EFS_CLEAR => 0;

use constant UPDATE_BOOTLOADER => 1;
use constant NO_UPDATE_BOOTLOADER => 0;

my(%cmds);
$cmds{"connect"} = \&cmd_connect;
$cmds{"readpit"} = \&cmd_readPit;
$cmds{"dumppit"} = \&cmd_dumpPit;
$cmds{"parsepit"} = \&cmd_parsePit;
$cmds{"reboot"} = \&cmd_reboot;
$cmds{"read"} = \&cmd_read;
$cmds{"flash"} = \&cmd_flash;
$cmds{"reformat"} = \&cmd_reformat;
$cmds{"repartition"} = \&cmd_repartition;
$cmds{"dumppitfile"} = \&cmd_dumpPitFile;
$cmds{"help"} = \&cmd_help;

use constant INITARG_TARGET => 0;
use constant INITARG_RESETTIME => 1;
use constant INITARG_TOTALSIZE => 2;
my(%initArgs);
$initArgs{"target"} = INITARG_TARGET;
$initArgs{"resettime"} = INITARG_RESETTIME;
$initArgs{"totalsize"} = INITARG_TOTALSIZE;

use constant PITARG_SET => 0;
use constant PITARG_GET => 1;
use constant PITARG_START => 2;
use constant PITARG_COMPLETE => 3;
my(%pitArgs);
$pitArgs{"set"} = PITARG_SET;
$pitArgs{"get"} = PITARG_GET;
$pitArgs{"start"} = PITARG_START;
$pitArgs{"complete"} = PITARG_COMPLETE;


my($cmdName) = lc($ARGV[0]);
my($cmd) = $cmds{$cmdName};
if ($cmdName eq "help" || !$cmd)
{
    cmd_help();
    exit;
}


if ($cmdName eq "dumppitfile")
{
	cmd_dumpPitFile();
	exit;
}

my($device, $config, $interface, $in_ep, $out_ep) = find_odin_device();
die "could not find connected odin device" if (!$device);

$device->open() || die "could not open device";

my($in_ep_num) = $in_ep->bEndpointAddress;
my($out_ep_num) = $out_ep->bEndpointAddress;


eval {&{$cmd}();};
if ($@) {
    print $@;
}


sub find_odin_device {
	my(@devices) = $usb->list_devices(SAMSUNG_VENDOR_ID);
	for my $device (@devices) {
		for (my $i=0; $i<$device->bNumConfigurations; $i++) {
			my($config) = $device->get_configuration($i);
			for my $altinterfaces ($config->interfaces()) {
				for my $interface (@$altinterfaces) {
					if ($interface->bInterfaceClass == CDC_DATA_CLASS) {
						my($in_ep, $out_ep);
						for my $ep ($interface->endpoints) {
							if ($ep->bmAttributes == USB_BULK_EP) {
								if (($ep->bEndpointAddress & USB_EP_ADDRESS_DIR_MASK) == USB_EP_DIR_IN) {
									$in_ep = $in_ep || $ep;
								} else {
									$out_ep = $out_ep || $ep;
								}
							}
						}
						
						if ($in_ep && $out_ep) {
							return ($device, $config, $interface, $in_ep, $out_ep);
						}
					}
				}
			}
		}
	}
}

sub connect_device {
	$device->detach_kernel_driver_np($interface->bInterfaceNumber);
	die "could not set configuration - $!" if ($device->set_configuration($config->bConfigurationValue) != 0);
	die "could not claim interface - $!" if ($device->claim_interface($interface->bInterfaceNumber) != 0);
	die "could not set alt interface setting - $!" if ($device->set_altinterface($interface->bAlternateSetting) != 0);
}


sub cmd_connect
{
	connect_device();
	
    debugDataOut("ODIN");
    writeData("ODIN");

    my($response) = readData(4, 10);

    debugDataIn($response);
    die "No response to handshake" unless $response;
    die "Invalid handshake response" unless $response eq "LOKE";

    sendCommand(CMD_INIT, INITARG_TARGET);
    readStandardResponse();
    sendCommand(CMD_INIT, INITARG_RESETTIME);
    readStandardResponse();
}

sub cmd_readPit
{
    my($pitFile) = readPit();
    print $pitFile;
}

sub cmd_parsePit
{
    my($pitFile) = $ARGV[1];
    die "No pit file specified" unless $pitFile;
    
    die "Couldn't find pit file $pitFile" unless (-e $pitFile);
    my($fileSize) = -s $pitFile;

    my($file);
    open($file, "<", $pitFile) || die "Couldn't open pit file for reading";
    
    my($data);
    my($count) = read($file, $data, $fileSize);
    die "Didn't read the full file" if ($count != $fileSize);

    my(@partitions) = decodePit($data);

    my($i) = 0;
    
    foreach (@partitions)
    {
        print "partition $i\n";
        print "\tszName => $_->{szName}\n";
        print "\tszFileName => $_->{szFileName}\n";
        print "\tszDeltaName => $_->{szDeltaName}\n";
        print "\tnBinType => $_->{nBinType}\n";
        print "\tnDevType => $_->{nDevType}\n";
        print "\tnID => $_->{nID}\n";
        print "\tnAttribute => $_->{nAttribute}\n";
        print "\tnUpdateAttr => $_->{nUpdateAttr}\n";
        print "\tdwBlkSize => $_->{dwBlkSize}\n";
        print "\tdwBlkLen => $_->{dwBlkLen}\n";
        print "\tdwOffset => $_->{dwOffset}\n";
        print "\tdwFileSize => $_->{dwFileSize}\n";

        $i++;
    }
}

sub cmd_dumpPit
{
    my($pitFile) = readPit();
    my(@partitions) = decodePit($pitFile);

    my($i) = 0;
    
    foreach (@partitions)
    {
        print "partition $i\n";
        print "\tszName => $_->{szName}\n";
        print "\tszFileName => $_->{szFileName}\n";
        print "\tszDeltaName => $_->{szDeltaName}\n";
        print "\tnBinType => $_->{nBinType}\n";
        print "\tnDevType => $_->{nDevType}\n";
        print "\tnID => $_->{nID}\n";
        print "\tnAttribute => $_->{nAttribute}\n";
        print "\tnUpdateAttr => $_->{nUpdateAttr}\n";
        print "\tdwBlkSize => $_->{dwBlkSize}\n";
        print "\tdwBlkLen => $_->{dwBlkLen}\n";
        print "\tdwOffset => $_->{dwOffset}\n";
        print "\tdwFileSize => $_->{dwFileSize}\n";

        $i++;
    }
}

sub readPit
{
    sendCommand(CMD_PIT, PITARG_GET);

    my(@response) = readStandardResponse();
    die "LOKE returned error code" if ($response[1] == 0xFFFFFFFF);
    my($pitSize) = $response[1];
    my($pitFile);
    my($i);


    do
    {
        sendCommand(CMD_PIT, PITARG_START, $i);

        my($readSize) = min(500, $pitSize - length($pitFile));
        my($data) = readData($readSize, 10);

        

        $pitFile .= $data;

        print STDERR ("got " . length($data) . " bytes, total " . length($pitFile) . " bytes\n");

        $i++;
    } while($i * 500 < $pitSize);

    return $pitFile;
}

sub cmd_reboot
{
    sendCommand(CMD_CLOSE, CLOSEARG_END);
    my(@response) = readStandardResponse();
    sendCommand(CMD_CLOSE, 1, CLOSEARG_REBOOT);
    my(@response) = readStandardResponse();
}

sub cmd_read
{
    my($partitionName) = lc($ARGV[1]);
    die "No partition specified\n" unless $partitionName;

    my($pitFile) = readPit();
    my(@partitions) = decodePit($pitFile);
    my($partitionsByName, $partitionsByFilename) = buildPartitionMap(\@partitions);

    my($partition) = $partitionsByName->{$partitionName};
    die "Could not find partition with name $partitionName\n" unless $partition;

    sendCommand(CMD_XMIT, XMITARG_DUMP, DUMPTYPE_NAND, $partition->{nID});

    #readdata(DUMPTYPE_NAND, $partition->{nID}, $partition->{dwBlkLen} * $partition->{dwBlkSize} * 1024, { print $_; });

    #sendCommand(CMD_XMIT, XMITARG_DUMP, $dumpType, $dumpId);
    my(@response) = readStandardResponse();
    my($readSize) = $partition->{dwBlkLen} * $partition->{dwBlkSize} * 1024;
    #my($readSize) = $expectedReadSize; #response[1];
    #die "Returned size doesn't match expected size.\n" if($readSize != $expectedReadSize && $expectedReadSize != -1);

    my($dataSize) = 0;
    my($i) = 0;

    do
    {
        sendCommand(CMD_XMIT, XMITARG_START, $i);

        my($sizeToRead) = min($read_size, $readSize - $dataSize);
        my($data) .= readData($sizeToRead, 20);

        print $data;
        
        $dataSize += length($data);

        $i++;
    } while($i * $read_size < $readSize);
}

sub cmd_repartition
{
    my($pitFile) = $ARGV[1];
    die "No pit file specified" unless $pitFile;
    
    die "Couldn't find pit file $pitFile" unless (-e $pitFile);
    my($fileSize) = -s $pitFile;

    my($file);
    open($file, "<", $pitFile) || die "Couldn't open pit file for reading";
    
    my($data);
    my($count) = read($file, $data, $fileSize);
    die "Didn't read the full file" if ($count != $fileSize);

    sendCommand(CMD_PIT, PITARG_SET);
    my(@response) = readStandardResponse();

    sendCommand(CMD_PIT, PITARG_START, $fileSize);
    my(@response) = readStandardResponse();

    writeData($data);
    my(@response) = readStandardResponse();

    sendCommand(CMD_PIT, PITARG_COMPLETE, $fileSize);
    my(@response) = readStandardResponse();
}

sub cmd_dumpPitFile
{
	my($fileName) = $ARGV[1];
	die "No file specified\n" unless $fileName;
    
    die "Couldn't find file $fileName" unless (-e $fileName);
    my($fileSize) = -s $fileName;

	my($file);
	open($file, "<", $fileName) || die "Couldn't open file for reading";
	my($data);
	my($readSize) = 4096;
	my($count) = read($file, $data, $readSize);

	my(@partitions) = decodePit($data);

	my($i)=0;
	foreach (@partitions)
    {
        print "partition $i\n";
        print "\tszName => $_->{szName}\n";
        print "\tszFileName => $_->{szFileName}\n";
        print "\tszDeltaName => $_->{szDeltaName}\n";
        print "\tnBinType => $_->{nBinType}\n";
        print "\tnDevType => $_->{nDevType}\n";
        print "\tnID => $_->{nID}\n";
        print "\tnAttribute => $_->{nAttribute}\n";
        print "\tnUpdateAttr => $_->{nUpdateAttr}\n";
        print "\tdwBlkSize => $_->{dwBlkSize}\n";
        print "\tdwBlkLen => $_->{dwBlkLen}\n";
        print "\tdwOffset => $_->{dwOffset}\n";
        print "\tdwFileSize => $_->{dwFileSize}\n";

        $i++;
    }
}

# reformating is implemented in a custom SBL, and is used to facilitate
# the transition from a nexus s style bootloader to a samsung style bootloader
sub cmd_reformat
{
    my($fileName) = $ARGV[1];
    die "No file specified\n" unless $fileName;
    
    die "Couldn't find file $fileName" unless (-e $fileName);
    my($fileSize) = -s $fileName;

    my($fileName2, $fileSize2);
    if ($fileSize == (256 * 1024))
    {
        $fileName2 = $ARGV[2];
        die "Please specify either a single bootloader.img style file, or both a boot.bin and Sbl.bin file" unless $fileName2;

        die "Couldn't find file $fileName2" unless (-e $fileName);

        $fileSize2 = -s $fileName2;
        if ($fileSize2 != (5 * 256 * 1024))
        {
            die "Please specify either a single bootloader.img style file, or both a boot.bin and Sbl.bin file";
        }
    } elsif ($fileSize != (6 * 256 * 1024))
    {
        die "Please specify either a single bootloader.img style file, or both a boot.bin and Sbl.bin file";
    }    

    my($file);
    open($file, "<", $fileName) || die "Couldn't open $fileName for reading";

    my($fileBytesRead) = 0;
    my($readFileData) = sub
    {
            my($fileSize) = shift;
            my($readSize) = min(0x1000, $fileSize - $fileBytesRead);
            my($data);

            if($readSize > 0)
            {
                my($count) = read($file, $data, $readSize);
                die "Didn't read a full block" if ($count != $readSize);
                $fileBytesRead += $count;
            }

            $data = pack("a[4096]", $data);
            return $data;
    };
   
    sendCommand(CMD_REFORMAT, 0, 6 * 256 * 1024);
    my(@response) = readStandardResponse();

    my($i);
    for ($i=0; $i<(256*1024)/0x1000; $i++)
    {
        my($data) = &$readFileData($fileSize);
        die "Error while reading file - wrong read length" if (length($data) != 0x1000);

        writeData($data);
    }

    if ($fileName2)
    {
        close($file);
        open($file, "<", $fileName2) || die "Couldn't open $fileName for reading";
        $fileBytesRead = 0;
    }

    for ($i=0; $i<(5*256*1024)/0x1000; $i++)
    {
        my($data) = &$readFileData($fileSize2);
        die "Error while reading file - wrong read length" if (length($data) != 0x1000);
        
        writeData($data);
    }

    my(@response) = readStandardResponse();
}

sub cmd_flash
{
    my($partitionName) = lc($ARGV[1]);
    die "No partition specified\n" unless $partitionName;

    my($fileName) = $ARGV[2];
    die "No file specified\n" unless $fileName;
    
    die "Couldn't find file $fileName" unless (-e $fileName);
    my($fileSize) = -s $fileName;

    my($file);
    open($file, "<", $fileName) || die "Couldn't open file for reading";

    my($pitFile) = readPit();
    my(@partitions) = decodePit($pitFile);
    my($partitionsByName, $partitionsByFilename) = buildPartitionMap(\@partitions);

    my($partition) = $partitionsByName->{$partitionName};
    die "Could not find partition with name $partitionName\n" unless $partition;

    if (lc($partition->{szName}) eq "ipbl") {
        #For the nexus s style bootloader, when you flash the ipbl partition, you
        #actually have to upload an image which contains both the IPbl partition and
        #the SBL partition. The size of the file must exactly match the size of the ipbl
        #partition plus the size of the sbl partition minus the 2 block spare area

        my($ipblPartition) = $partition;
        my($sblPartition) = $partitionsByName->{"sbl"} || die "Couldn't find the SBL partition";

        my($expectedSize) = ($ipblPartition->{dwBlkLen} + $sblPartition->{dwBlkLen} - 2) * 0x40000;

        die "Unexpected block size" if ($partition->{dwBlkSize} != 256);
        die "Incorrect file size. $fileSize != $expectedSize" if ($fileSize != $expectedSize);
    } elsif (($partition->{nDevType} != DEVICE_TYPE_MOVINAND) && (lc($partition->{szName}) ne "modem")) {
        #the movinand and modem partitions don't have the correct size information
        #in the pit file, so don't do the file size check for them

        die "Unexpected block size" if ($partition->{dwBlkSize} != 256);
        die "File too big" if ($fileSize > $partition->{dwBlkLen} * 0x40000);
    }

    my($currentFilePosition) = 0;
    my($remainingBytes) = $fileSize;
    
    my($fileBytesRead) = 0;

    my($readFileData) = sub
    {
            my($readSize) = min(0x1000, $fileSize - $fileBytesRead);
            my($data);

            if($readSize > 0)
            {
                my($count) = read($file, $data, $readSize);
                die "Didn't read a full block" if ($count != $readSize);
                $fileBytesRead += $count;
            }

            $data = pack("a[4096]", $data);

			return ($data, $readSize, 1);
    };

    my($completeCommand);

    if (lc($partition->{szName}) ne "modem") {
        $completeCommand = sub {
            my($partition) = shift;
            my($transactionSize) = shift;
            my($final) = shift;
            sendCommand(CMD_XMIT, XMITARG_COMPLETE, BINARYTYPE_PDA, $transactionSize, $partition->{nBinType}, $partition->{nDevType}, $partition->{nID}, $final);
            my(@response) = readStandardResponse();            
        }   
    } else {
        my($efsClear, $phoneBootUpdate);
        my($i);
        for ($i=3; $i<scalar(@ARGV); $i++) {
            if (lc($ARGV[$i]) eq "efsclear") {
                $efsClear = 1;
            } elsif (lc($ARGV[$i]) eq "phonebootupdate") {
                $phoneBootUpdate = 1;
            }
        }

        $completeCommand = sub {
            my($partition) = shift;
            my($transactionSize) = shift;
            my($final) = shift;
            sendCommand(CMD_XMIT, XMITARG_COMPLETE, BINARYTYPE_MODEM, $transactionSize, $efsClear, $phoneBootUpdate, $final, 0);
            my(@response) = readStandardResponse();            
        }
    }

    while ($remainingBytes > 0)
    {
        #we can only transmit ~32mb in one transaction
        my($transactionBytes) = min($remainingBytes, 0x1E00000);
        $remainingBytes -= $transactionBytes;
        my($final) = $remainingBytes>0?NOT_FINAL:FINAL;

        #if (($transactionBytes % 0x20000) > 0)
        #{
            #round up to the nearest 128k
            #$transactionBytes = (int($transactionBytes/0x20000) + 1) * 0x20000;
        #}

        do_write_transaction($partition, $transactionBytes, $final, $readFileData, $completeCommand);
    }
}

sub do_write_transaction
{
    my $partition = shift;
    my $transactionSize = shift;
    my $final = shift;
    my $getFileData = shift;
    my $completeCommand = shift;

	my $roundedTransactionSize = $transactionSize;

	if (($roundedTransactionSize % 0x20000) > 0) {
		$roundedTransactionSize = (int($roundedTransactionSize/0x20000) + 1) * 0x20000;
	}

    #if (($transactionSize % 0x20000) != 0)
    #{
	#        die "Invalid transaction size ($transactionSize), must be a multiple of 128k\n";
    #}

    sendCommand(CMD_XMIT, XMITARG_DOWNLOAD);
    my(@response) = readStandardResponse();

    sendCommand(CMD_XMIT, XMITARG_START, $roundedTransactionSize);
    my(@response) = readStandardResponse();
    
	my($count) = 0;
    my($i);
    for ($i=0; $i<$roundedTransactionSize/0x20000; $i++) {
        my($j);
        for ($j=0; $j<0x20000/0x1000; $j++) {
            my($data, $readLength) = &$getFileData();
            
			die "Error while reading file - wrong read length" if (length($data) != 0x1000);
            writeData($data);

			$count += $readLength;
        }
        my(@response) = readStandardResponse();
    }
    
    &$completeCommand($partition, $count, $final);
}

sub debugDataOut
{
    if ($verbose)
    {
        print STDERR "> " . shift() . "\n";
    }
}

sub debugDataIn
{
    if ($verbose)
    {
        print STDERR "< " . shift() . "\n";
    }
}

sub writeData
{
    my($data) = shift;
	die "error writing data - $!" if ($device->bulk_write($out_ep_num, $data, length($data), -1) < 0);
}

sub readStandardResponse
{
    my(@response) = unpack("LL", readData(8, 20));
    debugDataIn(join(", ", @response));
    return @response;
}

my($readBuf) = pack("C[500],");
sub readData
{
    my($toRead) = shift;
    my($timeout) = shift;
	$timeout *= 1000;

	if ($toRead > length($readBuf)) {
		$readBuf = pack("C[$toRead],");
	}
    
	my($count) = $device->bulk_read($in_ep_num, $readBuf, $toRead, $timeout);
	if ($count < 0) {
		die "Error while reading data - $!";
	}
	return $readBuf;
}

sub sendCommand
{
    my($request) = pack("L[256]", @_);
    
    debugDataOut(join(", ", @_));
    writeData($request);
}

sub buildPartitionMap
{
    my($partitions) = shift;

    my(%partitionsByName, %partitionsByFilename);
    
    for my $partition (@$partitions)
    {
        $partitionsByName{lc($partition->{szName})} = $partition;
        $partitionsByFilename{lc($partition->{szFileName})} = $partition;
    }
    
    return (\%partitionsByName, \%partitionsByFilename);
}

sub decodePit
{
    my($pitFile) = shift;
    my($dwMagic, $nCount, @dummy) = unpack("Ll[6]", $pitFile);

    die "PIT file has invalid magic number\n" if ($dwMagic != 0x12349876);
    
    my(@partitions);
    my($index) = 0;
    my($position) = 7*4;
    while($index < $nCount && $position < length($pitFile))
    {
        my(%partInfo);
        ($partInfo{nBinType},
         $partInfo{nDevType},
         $partInfo{nID},
         $partInfo{nAttribute},
         $partInfo{nUpdateAttr},
         $partInfo{dwBlkSize},
         $partInfo{dwBlkLen},
         $partInfo{dwOffset},
         $partInfo{dwFileSize},
         $partInfo{szName},
         $partInfo{szFileName},
         $partInfo{szDeltaName}) = unpack("l[5]L[4]Z[32]Z[32]Z[32]", substr($pitFile, $position, 132));
        $position += 132;
        $index++;
        
        push(@partitions, \%partInfo);
    }

    return @partitions;
}

sub cmd_help
{
    print "---Usage---\n";
    print "odin.pl connect\n";
    print "    connect to a device in downloader mode\n";
    print "odin.pl readpit\n";
    print "    read the binary pit data from the device and output to stdout\n";
    print "odin.pl dumppit\n";
    print "    read the pit data from the device and print a human readable\n";
    print "    representation\n";
    print "odin.pl read <partition_name>\n";
    print "    read the specified partition from the device and output to stdout\n";
    print "odin.pl flash <partition_name> <file_name>\n";
    print "    flash <file_name> to the specified partition\n";
    print "odin.pl repartition <pit_file>\n";
    print "    repartition the device using the given pit file\n";
    print "odin.pl reboot\n";
    print "    reboot the device\n";
    print "odin.pl help\n";
    print "    print this help message\n";
    print "---Example session---\n";
    print "odin.pl connect\n";
    print "odin.pl flash factoryfs factoryfs.img\n";
    print "odin.pl flash dbdatafs dbdata.img\n";
    print "odin.pl reboot\n";
}
