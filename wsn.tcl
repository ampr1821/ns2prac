set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)       50                       ;# max packet in ifq
set val(netif)        Phy/WirelessPhy          ;# network interface type
set val(mac)          Mac/802_11               ;# MAC type
set val(nn)           10                        ;# number of mobilenodes
set val(rp)           AODV                     ;# routing protocol
set val(x)            800			;
set val(y)            800			;
set val(energymodel) EnergyModel ;#Energy set up

set ns [new Simulator]
#ns-random 0

set f [open wsn.tr w]
$ns trace-all $f
set namtrace [open wsn.nam w]
$ns namtrace-all-wireless $namtrace $val(x) $val(y)
set topo [new Topography]
$topo load_flatgrid 800 800

create-god $val(nn)

Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

set chan_1 [new $val(chan)]

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
$val(netif) set CPThresh_ 10.0
$val(netif) set CSThresh_ 8.91754e-10 ;#sensing range of 200m
$val(netif) set RXThresh_ 8.91754e-10 ;#communication range of 200m
$val(netif) set Rb_ 2*1e6
$val(netif) set Pt_ 0.2818
$val(netif) set freq_ 914e+6
$val(netif) set L_ 1.0

$ns node-config  -adhocRouting $val(rp) \
		 -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
		 -energyModel $val(energymodel) \
		 -initialEnergy 10 \
		 -rxPower 0.5 \
		 -txPower 1.0 \
		 -idlePower 0.0 \
		 -sensePower 0.3 \
                 #-channelType $val(chan) \
                 -topoInstance $topo \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON \
                 -movementTrace OFF \
                 -channel $chan_1

$ns node-config -initialEnergy 1000 \
		 -rxPower 0.5 \
		 -txPower 1.0 \
		 -idlePower 0.0 \
		 -sensePower 0.3

proc finish {} {
    global ns namtrace
    $ns flush-trace
        close $namtrace
        exec nam -r 5m wsn.nam &
    exit 0
}

for {set i 0} {$i < 10} {incr i} {
	global ns
	set node($i) [$ns node]
	set sink($i) [new Agent/LossMonitor]
	set tcp($i) [new Agent/TCP]
	$ns attach-agent $node($i) $sink($i)
	$ns attach-agent $node($i) $tcp($i)
	#$node($i) set X_ [expr 10 + round(rand()*700)]
	#$node($i) set Y_ [expr 10 + round(rand()*700)]
	#$node($i) set Z_ 0.0
	$ns initial_node_pos $node($i) 30
	#$ns at 0.0 "$node($i) setdest [expr 10 + round(rand()*700)] [expr 10 + round(rand()*700)] 100.0"
}

source pos/data.txt

$ns at 0.0 "$node(0) color blue"
$node(0) color "blue"
$ns at 0.0 "$node(6) color red"
$node(6) color "red"

$ns at 0.0 "[$node(3) set ragent_] malicious"

set cbr [new Agent/CBR]
$ns attach-agent $node(0) $cbr
$cbr set packetSize_ 1000
$cbr set interval_ 0.030
$ns connect $cbr $sink(6)

$ns at 0.5 "$cbr start"
$ns at 10.0 "finish"

$ns run
