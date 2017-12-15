package provide ASM_PATH 1.0

namespace eval ::ASM_Path:: {} {namespace export *}
###ASM instalation path
proc ASM_Path::install {} {return /opt/programs/vmd/plugins/compASM}
###AMBER instalation path
proc ASM_Path::amber {ver} {
	puts $ver
	if {$ver == 9} {
		return /opt/programs/amber/9/mpich2-intel-13/exe
	} else {
		return /opt/programs/amber/12/mpich2-gnu-4.7.1/bin
	}
}
###Delphi instalation path
proc ASM_Path::delphi {} {return /opt/programs/delphi/5.1/gnu-4.4.5/delphi77}
###Type of machine
proc ASM_Path::machine {} {return local}
