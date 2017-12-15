package provide chargefile 1.0

proc ::ASM::creatCharge {dirf} {
	set chfile [open $ASM::install/Core/LIB/charges.cgr r+]
	if {[file exists $dirf/mmpbsa/]!=1} {
		file mkdir $dirf/mmpbsa
	}
	set chfileout [open $dirf/mmpbsa/charges.cgr w+]
	set i 0
	set linha [gets $chfile]
	puts $chfileout $linha
	set linha [gets $chfile]
	puts $chfileout $linha
	set resid 0
	set filp "$dirf/strct/wldtp/Complex/Complex_wildtype.pdb $dirf/strct/wldtp/ligand/Complex_ligand_wt.pdb $dirf/strct/wldtp/receptor/Complex_receptor_wt.pdb"
	set i 0
	while {[lindex $filp $i] != ""} {
		set fil [open [lindex $filp $i] r+]
		set stop 0
        	while {$stop != 1 && [eof $fil] != 1} {
        		set ntfile [open $ASM::install/Core/LIB/all_aminont94.in r+]
        		set linhap [gets $fil]
			if {[string range $linhap 0 3] == "ATOM"} {
				set resname [string range $linhap 17 19]
				set resid [string range $linhap 22 25]
				while {[eof $ntfile] !=1} {
					set linha [gets $ntfile]
					if {[string range $linha 1 3] == $resname} {
						set atomnum [string range $linha 1 3]
						while {[string trim $atomnum " "]!="3"} {
							set linha [gets $ntfile]
							set atomnum [string range $linha 1 3]
						}

						set atomtype [string range $linha 5 9]
						while {[string trim $atomtype] != "O"} {
							set linha [gets $ntfile]
							set atomtype [string range $linha 5 9]
							set linhaux [split $linha " "]
							if {[string index [lindex $linhaux end] 0]!="-"} {
								set st " [lindex $linhaux end]"
							} else {
								set st [lindex $linhaux end]
							}
							puts $chfileout "[string trimleft $atomtype " "]  $resname$resid  $st"
						}
					}
				}
				close $ntfile
				set ctfile [open $ASM::install/Core/LIB/all_aminoct94.in r+]
				set st 0
				set linhaux ""
				while {$st != 1 && [eof $fil] != 1 } {
					set linhap [gets $fil]
					set linhas [split $linhap " "]
					if {[lindex $linhas 0]== "TER"} {
						set st 1
					} else {
						set linhaux $linhap
					}
				}
				set linhap $linhaux
				set resname [string range $linhap 17 19]
				set resid [string range $linhap 22 25]
				while {[eof $ctfile]!=1} {
					set linha [gets $ctfile]
					if {[string range $linha 1 3] == $resname} {
						set atomnum [string range $linha 1 3]
						while {[string trim $atomnum " "]!="3"} {
							set linha [gets $ctfile]
							set atomnum [string range $linha 1 3]
						}

						set atomtype [string range $linha 5 9]
						while {[string trim $atomtype] != "OXT" && [eof $ctfile] != 1} {
							set linha [gets $ctfile]
							set atomtype [string range $linha 5 9]
							set linhaux [split $linha " "]
							if {[string index [lindex $linhaux end] 0]!="-"} {
								set st " [lindex $linhaux end]"
							} else {
								set st [lindex $linhaux end]
							}
							puts $chfileout "[string trimleft $atomtype " "]  $resname$resid  $st"
						}
					}
				}
			}
        		close $ctfile

        		while {[lindex $linhap 0]== "TER" && [eof $fil] != 1 } {
        			set linhap [gets $fil]
        			set linhap [split $linhap " "]
        		}
			set linhap [gets $fil]
        		set linhap [split $linhap " "]
			if {[lindex $linhap 0]=="END"} {
				set stop 1
				close $fil
			}
        	}
		incr i
	}
	while {[eof $chfile]!=1} {
		set linha [gets $chfile]
		puts $chfileout $linha
	}
	close $chfile
	close $chfileout
}