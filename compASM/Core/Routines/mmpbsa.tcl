package provide mmpbsa 1.0

proc ::ASM::makeMMPBSAFile {k dirf folder name pastfol mut mmpbsa last opt} {
	set fo [pwd]
	set mmofile [open $ASM::install/Core/LIB/mm.pbsa.eK.in r+]
	if {$folder != "mut"} {
		set mmcfile [open $dirf/mmpbsa/$folder/$name/d$k/mm.pbsa.$name.e$k.in w+]
	} else {
		set mmcfile [open $dirf/mmpbsa/$folder/$name/mm.pbsa.$name.e$k.in w+]
	}
	while {[eof $mmofile]!=1} {
		set linha [gets $mmofile]
		if {[string range $linha 0 5]=="PREFIX"} {
			set un "_"
			puts $mmcfile "PREFIX           snap_$folder$un$name.d$k."
		} elseif {[string range $linha 0 3]=="PATH"} {
			puts $mmcfile "PATH                 ./"
		} elseif {[string range $linha 0 4]=="COMPT"} {
			if {$folder=="wldtp"} {
				set fil [glob -directory $dirf/strct/$folder/Complex/ *.top]
				file copy -force [glob -directory $dirf/strct/$folder/Complex/ *.crd] $fo
				file copy -force $fil $fo
				set fil [file tail $fil]
			} else {
				set fil [glob -directory $dirf/strct/$folder/$name/Complex/ *.top]
				file copy -force [glob -directory $dirf/strct/$folder/$name/Complex/ *.crd] $fo
				file copy -force $fil $fo
				set fil [file tail $fil]
			}
			puts $mmcfile  "COMPT                 ./$fil"
		} elseif {[string range $linha 0 4]=="RECPT"} {
			if {$folder=="wldtp"} {
				set fil [glob -directory $dirf/strct/$folder/receptor/ *.top]
				file copy -force [glob -directory $dirf/strct/$folder/receptor/ *.crd] $fo
				file copy -force $fil $fo
				set fil [file tail $fil]
				puts $mmcfile  "RECPT                 ./$fil"
			} else {
				if {[file isdirectory $dirf/strct/$folder/$name/receptor/]} {
					set fil [glob -directory $dirf/strct/$folder/$name/receptor/ *.top]
					file copy -force [glob -directory $dirf/strct/$folder/$name/receptor/ *.crd] $fo
					file copy -force $fil $fo
					set fil [file tail $fil]
					puts $mmcfile  "RECPT                ./$fil"
				} else {
					set fil [glob -directory $dirf/strct/wldtp/receptor/ *.top]
					file copy -force [glob -directory $dirf/strct/wldtp/receptor/ *.crd] $fo
					file copy -force $fil $fo
					set fil [file tail $fil]
					puts $mmcfile  "RECPT                 ./$fil"
				}
			}
		} elseif {[string range $linha 0 4]=="LIGPT"} {
			if {$folder=="wldtp"} {
				set fil [glob -directory $dirf/strct/$folder/ligand/ *.top]
				file copy -force [glob -directory $dirf/strct/$folder/ligand/ *.crd] $fo
				file copy -force $fil $fo
				set fil [file tail $fil]
				puts $mmcfile  "LIGPT                 ./$fil"
			} else {
				if {[file isdirectory $dirf/strct/$folder/$name/ligand/]} {
					set fil [glob -directory $dirf/strct/$folder/$name/ligand/ *.top]
					file copy -force [glob -directory $dirf/strct/$folder/$name/ligand/ *.crd] $fo
					file copy -force $fil $fo
					set fil [file tail $fil]
     					puts $mmcfile  "LIGPT                 ./$fil"
				} else {
					set fil [glob -directory $dirf/strct/wldtp/ligand/ *.top]
					file copy -force [glob -directory $dirf/strct/wldtp/ligand/ *.crd] $fo
					file copy -force $fil $fo
					set fil [file tail $fil]
					puts $mmcfile  "LIGPT                  ./$fil"
				}
			}
		} elseif {[string range $linha 0 1]=="AS"} {
			if {$folder=="wldtp"} {
				puts $mmcfile  "AS                    0"
			} else {
				puts $mmcfile  "AS                    1"
			}
		} elseif {[string range $linha 0 3]=="INDI"} {
			puts $mmcfile  "INDI                  $k.0"
		} elseif {[string range $linha 0 5]=="CHARGE"} {
			puts $mmcfile  "CHARGE                $dirf/mmpbsa/charges.cgr"
		} elseif {[string range $linha 0 3]=="SIZE"} {
			puts $mmcfile  "SIZE                  $ASM::install/Core/LIB/my_parse_delphi.siz"
		} elseif {[string range $linha 0 4]=="DIELC"} {
			puts $mmcfile  "DIELC                 $k.0"
		}  elseif {[string range $linha 0 5]=="NTOTAL"} {
			puts $mmcfile  "NTOTAL                 [string trim [lindex $ASM::complex_atoms end] " "]"
		} elseif {[string range $linha 0 5]=="NSTART"} {
			if {$opt == 1} {
				puts $mmcfile  "NSTART 0"
			} else {
				set i 0
				set stop 0
				while {[lindex $mmpbsa $i] != "" && $stop != 1} {
					set mmpbsa_aux [split [lindex $mmpbsa $i] " "]
					if {[lsearch $mmpbsa_aux "NSTART"] != -1} {
						puts $mmcfile [lindex $mmpbsa $i]
						set stop 1

					}
					incr i
				}
				if {$stop == 0} {
					puts $mmcfile  "NSTART [lindex $last 0]"
				}
			}

		} elseif {[string range $linha 0 4]=="NSTOP"} {
			if {$opt == 1} {
				puts $mmcfile  "NSTOP 1"
			} else {
				set i 0
				set stop 0
				while {[lindex $mmpbsa $i] != "" && $stop != 1} {
					set mmpbsa_aux [split [lindex $mmpbsa $i] " "]
					if {[lsearch $mmpbsa_aux "NSTOP"] != -1} {
						puts $mmcfile [lindex $mmpbsa $i]
						set stop 1

					}
					incr i
				}
				if {$stop == 0} {
					puts $mmcfile  "NSTOP [lindex $last 1]"
				}
			}
		} elseif {[string range $linha 0 4]=="NFREQ"} {
			if {$opt == 1} {
				puts $mmcfile  "NFREQ 1"
			} else {
				set i 0
				set stop 0
				while {[lindex $mmpbsa $i] != "" && $stop != 1} {
					set mmpbsa_aux [split [lindex $mmpbsa $i] " "]
					if {[lsearch $mmpbsa_aux "NFREQ"] != -1} {
						puts $mmcfile [lindex $mmpbsa $i]
						set stop 1
					}
					incr i
				}
				if {$stop == 0} {
					puts $mmcfile  "NFREQ [lindex $mmpbsa $i]"
				}

			}
        	} elseif {[string range $linha 0 16]=="NUMBER_LIG_GROUPS"} {
			puts $mmcfile  "NUMBER_LIG_GROUPS     [expr [llength $ASM::ligand_atoms]/2]"
		} elseif {[string range $linha 0 5]=="LSTART"} {
			set i 0
			while {[lindex $ASM::ligand_atoms $i]!= ""} {
				puts $mmcfile  "LSTART                [string trim [lindex $ASM::ligand_atoms $i] " "]"
				incr i
				puts $mmcfile  "LSTOP                [string trim [lindex $ASM::ligand_atoms $i] " "]"
				incr i
			}
			set linha [gets $mmofile]
		} elseif {[string range $linha 0 16]=="NUMBER_REC_GROUPS"} {
			puts $mmcfile  "NUMBER_REC_GROUPS     [expr [llength $ASM::receptor_atoms]/2]"
		}  elseif {[string range $linha 0 5]=="RSTART"} {
			set i 0
			while {[lindex $ASM::receptor_atoms $i]!= ""} {
				puts $mmcfile  "RSTART                [string trim [lindex $ASM::receptor_atoms $i] " "]"
				incr i
				puts $mmcfile  "RSTOP                 [string trim [lindex $ASM::receptor_atoms $i] " " ]"
				incr i
			}
			set linha [gets $mmofile]
		} elseif {[string range $linha 0 19]=="NUMBER_MUTANT_GROUPS"} {
			if {$folder== "wldtp"} {
				puts $mmcfile  "NUMBER_MUTANT_GROUPS 0"
			} else {
				set mutj [split $mut ","]
				set num_mut [llength $mutj]
				puts $mmcfile  "NUMBER_MUTANT_GROUPS $num_mut"
			}
		} elseif {[string range $linha 0 11]=="MUTANT_ATOM1"} {
			if {$folder != "wldtp"} {
        set i 0
				set mut [split $mut ","]
        while {[lindex $mut $i]!= ""} {
					array unset res
					array set res ""
					set resname ""
					set st 0
					set nameaux [split [lindex $mut $i] "_"]
					set pdb_size [expr [array size ASM::pdb] /10]
					set rt 0
					for {set j 1} {$j <= $pdb_size} {incr j} {
						set st 0
						while {[lindex $nameaux 1] == $ASM::pdb($j,5) && $ASM::pdb($j,6)==[lindex $nameaux 0]} {
							set res([string trim $ASM::pdb($j,2) " "]) $ASM::pdb($j,1)
							set st 1
							if {$st == 1} {
								set resname $ASM::pdb($j,4)
								break
							}
							incr i
						}
					}
					if {$resname == "THR" || $resname == "ILE" || $resname == "VAL"} {
						puts $mmcfile  "MUTANT_ATOM1     [string trim $res(CG2) " "]"
					} elseif {$resname == "SER"} {
						puts $mmcfile  "MUTANT_ATOM1    [string trim $res(OG) " "]"
					} elseif {$resname == "CYS" || $resname == "CYX" || $resname == "CYM"} {
						puts $mmcfile  "MUTANT_ATOM1    [string trim $res(SG) " "]"
					} else {
						puts $mmcfile  "MUTANT_ATOM1      [string trim $res(CG) " "]"
					}
					if {$resname == "THR"} {
						puts $mmcfile  "MUTANT_ATOM2 $res(OG1)"
					} elseif {$resname == "VAL" || $resname == "ILE"} {
						puts $mmcfile  "MUTANT_ATOM2 $res(CG1)"
					} else {
						puts $mmcfile  "MUTANT_ATOM2 0"
					}
					puts $mmcfile  "MUTANT_KEEP $res(C)"
					puts $mmcfile  "MUTANT_REFERENCE $res(CB)"

					incr i
				}
				set linha [gets $mmofile]
				set linha [gets $mmofile]
				set linha [gets $mmofile]
				set linha [gets $mmofile]
			} else {
				set linha [gets $mmofile]
				set linha [gets $mmofile]
				set linha [gets $mmofile]
				set linha [gets $mmofile]
			}
		} elseif {[string range $linha 0 9]=="TRAJECTORY"} {
			puts $mmcfile "TRAJECTORY [lindex $last 3]"
		} elseif {[string range $linha 0 5]=="DELPHI"} {
			puts $mmcfile  "DELPHI                $ASM::delphi"
		} else {
			puts $mmcfile $linha
		}
	};#####END OF WHILE
	close $mmcfile
	close $mmofile
}
