package provide ASM_Constant 1.0

namespace eval ::ASM_Const:: {} {namespace export *}
###ASM Dielectric constants
##################################################################################################
##                      	CompASM Version 1.0   						##
##												##
##                                   								##
## Edit and set dielectric constants for mmpbsa tool: 	 					##
##	proc ASM_Const::const									##
##		list of constants separated by a space character				##
##		Syntax:										##
##			return "constantSPACEcosntantSPACE"					##
##	proc ASM_Const::res									##
##		Correspondence between constants and the respective residues			##
##		Syntax:										##
##			if {[lsearch {residueSPACEresidueSPACE} $res]!= -1} {			##
##				return CONSTANTvalue						##
##				set a 1								##
##			}									##
## 												##
##												##
##################################################################################################

proc ASM_Const::const {} {
		return "2 3 4"
}
proc ASM_Const::res {res} {
		set a 0
		if {[lsearch {VAL LEU ILE PHE MET TRP} $res]!= -1} {
					return 2
					set a 1
		}
		if {[lsearch {ASN GLN CYS TYR SER THR CYM CYX} $res]!= -1} {
					return 3
				set a 1
		}
		if {[lsearch {ASP GLU LYS ARG HIS HIE HID HIP LYN GLH ASH ACE} $res]!= -1} {
					return 4
				set a 1
		}
		#MUST CAME IN LAST OF THE THE OTHER IFS
		if {$a == 0} {
				return 0
		}
	}


