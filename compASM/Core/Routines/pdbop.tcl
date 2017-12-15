package provide pdboperation 1.0

proc ::ASM::pdbMem {filePdb} {
	set ::ASM::TER ""
	array unset ::ASM::pdb
	array set ::ASM::pdb ""
	set pdbfile [open $filePdb r]
	##pdb(ATOM, ATNUM, ATNAME, ATLOC, Resname, CHAINID, Resnumber, InsertCod,   x   ,     y   ,  z    , occupacy , Bfactor  , element sy, charge)
	##    1-6 , 7-11,  13-16,    17,    18-20,  22    ,    23-26 ,    27    , 31-38 ,  39-46 , 47-54 ,  55-60 , 61-66       ,   77-78   , 79-80.	
	set chainid 1
	set rt 0
	while {[eof $pdbfile] !=1} {
		set linha [gets $pdbfile]
		if {[string range $linha 0 5]=="ATOM  " || [string range $linha 0 5]=="HETATM"} {
			set atnum [string range $linha 6 11]
			set atname [string range $linha 12 15]
			set atloc [string index $linha  16]
			set resname [string range $linha 17 19]
			set resnum [string range $linha 22 25]
			set inscod [string index $linha 26]
			set x [string range $linha 30 37]
			set y [string range $linha 38 45]
			set z [string range $linha 46 55]
			set ASM::pdb([string trim $atnum " "],1) $atnum
			set ASM::pdb([string trim $atnum " "],2) $atname
			set ASM::pdb([string trim $atnum " "],3) $atloc
			set ASM::pdb([string trim $atnum " "],4) $resname
			set ASM::pdb([string trim $atnum " "],5) $chainid
			set ASM::pdb([string trim $atnum " "],6) $resnum
			set ASM::pdb([string trim $atnum " "],7) $inscod
			set ASM::pdb([string trim $atnum " "],8) $x
			set ASM::pdb([string trim $atnum " "],9) $y
			set ASM::pdb([string trim $atnum " "],10) $z
			if {$rt == 0} {
				set ::ASM::complex_atoms [lappend ::ASM::complex_atoms $atnum]
				set rt 1
			}
		}
		if {[string range $linha 0 2]=="TER"} {
			incr chainid 
			set ::ASM::TER [lappend ::ASM::TER $atnum]
		} 
	}
	set ASM::complex_atoms [lappend ASM::complex_atoms $atnum]
	
	close $pdbfile
}

proc ::ASM::makeMut {resid chain inputfile st serie ligand receptor} {
	####Muation in complex
	set resid [split [string trimright [string trimleft $resid "{"] "}"] " "]
	set chain [split [string trimright [string trimleft $chain "{"] "}"] " "]
	set st [split [string trimright [string trimleft $st "{"] "}"] " "]
	set dirf $inputfile
	set un "_"
	if {[file exists $dirf/strct/mut/Mut$serie/Complex]!=1} {
		file mkdir $dirf/strct/mut/Mut$serie/Complex
	}
	set dirfmut  $dirf/strct/mut/Mut$serie/Complex
	set file1 [open $dirfmut/scriptAmber_pdb w+]
	
	set pdb_size [expr [array size ASM::pdb] /10]
	set file1 [open $dirfmut/Complex.pdb w+]
	set stop 1
	set res 0
	set indaux ""
	
	for {set i 1} {$i <= $pdb_size} {incr i} {
		set ind [lsearch $resid [string trim $ASM::pdb($i,6) " "]]
		if {$ASM::pdb($i,6) == [lindex $resid $ind]} {
			if {$indaux != $ind} {
				set stop 1
			}
			set indaux $ind
			if {$stop != 0} {
				if {$res==0} {
					set ASM::mut_name(Mut$serie) [lappend ASM::mut_name(Mut$serie) $ASM::pdb($i,4)]
					set res 1
				}
				puts $file1 "ATOM  $ASM::pdb($i,1)$ASM::pdb($i,2)$ASM::pdb($i,3)ALA  $ASM::pdb($i,6)$ASM::pdb($i,7)   $ASM::pdb($i,8)$ASM::pdb($i,9)$ASM::pdb($i,10)1.00  0.00"
			}
			if {[string trim $ASM::pdb($i,2) " "]=="CB"} {
				set stop 0
				set res 0
			}
			
		} else {
			if {$stop ==0} {
				 set indaux 0
				 set resaux ""
				 while {[lindex $resid $indaux] != ""} {
					 if {$indaux != $ind} {
						 set resaux [lappend resaux [lindex $resid $indaux] ]
					 }
					 incr indaux
				 }
				 set resid $resaux
				 set stop 1
				set res 0
			 }
			puts $file1 "ATOM  $ASM::pdb($i,1)$ASM::pdb($i,2)$ASM::pdb($i,3)$ASM::pdb($i,4)  $ASM::pdb($i,6)$ASM::pdb($i,7)   $ASM::pdb($i,8)$ASM::pdb($i,9)$ASM::pdb($i,10)1.00  0.00"
		}
		if {[lsearch $ASM::TER $ASM::pdb($i,1)]!= -1} {
			puts $file1 "TER"
		}
	}
	close $file1
	
	#####Mutation in Ligand or Receptor
	set ligres ""
	set recres ""
	set resligmut ""
	set resrecpmut ""
	set k 0
	
	while {$k < [llength $st] } {
		if {[string trim [lindex $st $k] " "] != ""} {
			
		
			if {[lindex $st $k]=="ligand"} {
				set ligres [lappend ligres [lindex $chain $k]]
				set resligmut [lappend  resligmut [lindex $resid $k]]
			} else {
				set recres [lappend recres [lindex $chain $k]]
				set resrecpmut [lappend resrecpmut [lindex $resid $k]]
			}
		}
		incr k
	}
	set stop 0
	if {[llength $ligres] > 0} {
		set dirf $inputfile
		if {[file exists $dirf/strct/mut/Mut$serie/ligand]!=1} {
			file mkdir $dirf/strct/mut/Mut$serie/ligand
		}
		set dirfmut  $dirf/strct/mut/Mut$serie/ligand
		set file1 [open $dirfmut/scriptAmber_pdb w+]
		
		set pdb_size [expr [array size ASM::pdb] /10]
		set file1 [open $dirfmut/Complex.pdb w+]
		set stop 1
		for {set i 1} {$i <= $pdb_size} {incr i} {
			set ind [lsearch $ligres $ASM::pdb($i,5)]
			if {[lsearch $ligres $ASM::pdb($i,5)] != -1 || [lsearch $ligand $ASM::pdb($i,5)] != -1} {
				if {[lindex $resligmut $ind]==$ASM::pdb($i,6) && [lindex $ligres $ind]== $ASM::pdb($i,5)} {
					if {$stop != 0} {
						puts $file1 "ATOM  $ASM::pdb($i,1)$ASM::pdb($i,2)$ASM::pdb($i,3)ALA  $ASM::pdb($i,6)$ASM::pdb($i,7)   $ASM::pdb($i,8)$ASM::pdb($i,9)$ASM::pdb($i,10)1.00  0.00"
					}
					if {[string trim $ASM::pdb($i,2) " "]=="CB"} {
						set stop 0
					}
					
				} else {
					if {$stop ==0} {
						set indaux 0
						set res ""
						set reschain ""
						while {[lindex $resligmut $indaux] != ""} {
							if {$indaux != $ind} {
								set res [lappend res [lindex $resligmut $indaux] ]
								set reschain [lappend reschain  [lindex $ligres $indaux] ]
							}
							incr indaux
						}
						if {$res != ""} {
							set resligmut $res
						}
						if {$reschain != ""} {
							set ligres $reschain
						}
						if {[llength $ligres] == 0} {
							set recres [lindex $ligres $ind]
						}
					}
					puts $file1 "ATOM  $ASM::pdb($i,1)$ASM::pdb($i,2)$ASM::pdb($i,3)$ASM::pdb($i,4)  $ASM::pdb($i,6)$ASM::pdb($i,7)   $ASM::pdb($i,8)$ASM::pdb($i,9)$ASM::pdb($i,10)1.00  0.00"
				  set stop 1   
				}
			}
			if {[lsearch $ASM::TER $ASM::pdb($i,1)]!= -1} {
				puts $file1 "TER"
			}
		}
		close $file1
	}
	
	set stop 0
	if {[llength $recres] > 0} {
		set dirf $inputfile
		if {[file exists $dirf/strct/mut/Mut$serie/receptor]!=1} {
			file mkdir $dirf/strct/mut/Mut$serie/receptor
		}
		set dirfmut  $dirf/strct/mut/Mut$serie/receptor
		set file1 [open $dirfmut/scriptAmber_pdb w+]
		
		set pdb_size [expr [array size ASM::pdb] /10]
		set file1 [open $dirfmut/Complex.pdb w+]
		set stop 1
		for {set i 1} {$i <= $pdb_size} {incr i} {
			set ind [lsearch $recres $ASM::pdb($i,5)]
			if {[lsearch $recres $ASM::pdb($i,5)] != -1 || [lsearch $receptor $ASM::pdb($i,5)] != -1} {
				if {[lindex $resrecpmut $ind]==$ASM::pdb($i,6)  && [lindex $recres $ind]== $ASM::pdb($i,5)} {
					if {$stop != 0} {
						puts $file1 "ATOM  $ASM::pdb($i,1)$ASM::pdb($i,2)$ASM::pdb($i,3)ALA  $ASM::pdb($i,6)$ASM::pdb($i,7)   $ASM::pdb($i,8)$ASM::pdb($i,9)$ASM::pdb($i,10)1.00  0.00"
					}
					if {[string trim $ASM::pdb($i,2) " "]=="CB"} {
						set stop 0
					}
					
				} else {
					if {$stop ==0} {
						set indaux 0
						set res ""
						set reschain ""
						while {[lindex $resrecpmut $indaux] != ""} {
							if {$indaux != $ind} {
								set res [lappend res [lindex $resrecpmut $indaux] ]
								set reschain [lappend reschain  [lindex $recres $indaux] ]
							}
							incr indaux
						}
						if {$res != ""} {
							set resrecpmut $res
						}
						if {$reschain != ""} {
							set recres $reschain
						}
						if {[llength $recres] == 0} {
							set recres [lindex $recres $ind]
						}
					}
					puts $file1 "ATOM  $ASM::pdb($i,1)$ASM::pdb($i,2)$ASM::pdb($i,3)$ASM::pdb($i,4)  $ASM::pdb($i,6)$ASM::pdb($i,7)   $ASM::pdb($i,8)$ASM::pdb($i,9)$ASM::pdb($i,10)1.00  0.00"
					set stop 1
					
				}
			}
			if {[lsearch $ASM::TER $ASM::pdb($i,1)]!= -1} {
				puts $file1 "TER"
			}
		}
		close $file1
	}
}

proc ::ASM::ligand_receptor {chainl chainr inputfile} {
	set dirf $inputfile
	set chainl [split [string trimright [string trimleft $chainl "{"] "}"] " "]
	set chainr [split [string trimright [string trimleft $chainr "{"] "}"] " "]
	if {[file exists $dirf/ligand]!=1} {
		file mkdir $dirf/strct/wldtp/ligand
	}
	set dirfLigand $dirf/strct/wldtp/ligand
	set file1 [open $dirfLigand/Complex.pdb w+]
	
	if {[file exists $dirf/receptor]!=1} {
		file mkdir $dirf/strct/wldtp/receptor
	}
	set dirfReceptor $dirf/strct/wldtp/receptor
	set file2 [open $dirfReceptor/Complex.pdb w+]
	
	
	set pdb_size [expr [array size ASM::pdb] /10]
	set rt 0
	set ASM::ligand_atoms ""
	for {set i 1} {$i <= $pdb_size} {incr i} {
		if {[lsearch $chainl $ASM::pdb($i,5)]!= -1} {
			if {$rt == 0} {
				set ASM::ligand_atoms [lappend ASM::ligand_atoms $ASM::pdb($i,1)]
				set rt 1
			}
			puts $file1 "ATOM  $ASM::pdb($i,1)$ASM::pdb($i,2)$ASM::pdb($i,3)$ASM::pdb($i,4)  $ASM::pdb($i,6)$ASM::pdb($i,7)   $ASM::pdb($i,8)$ASM::pdb($i,9)$ASM::pdb($i,10)1.00  0.00"
			if {[lsearch $ASM::TER $ASM::pdb($i,1)]!= -1} {
    		puts $file1 "TER"
				set ASM::ligand_atoms [lappend ASM::ligand_atoms $ASM::pdb($i,1)]
				set rt 0
    	}
		}
	}
	set rt 0
	set ASM::receptor_atoms ""
	for {set i 1} {$i <= $pdb_size} {incr i} {
		if {[lsearch $chainr $ASM::pdb($i,5)]!= -1} {
			if {$rt == 0} {
				set ASM::receptor_atoms [lappend ASM::receptor_atoms $ASM::pdb($i,1)]
				set rt 1
			}
			puts $file2 "ATOM  $ASM::pdb($i,1)$ASM::pdb($i,2)$ASM::pdb($i,3)$ASM::pdb($i,4)  $ASM::pdb($i,6)$ASM::pdb($i,7)   $ASM::pdb($i,8)$ASM::pdb($i,9)$ASM::pdb($i,10)1.00  0.00"
			if {[lsearch $ASM::TER $ASM::pdb($i,1)]!= -1} {
				set ASM::receptor_atoms [lappend ASM::receptor_atoms $ASM::pdb($i,1)]
    		puts $file2 "TER"
				set rt 0
    	}
		}
	}
	
	close $file1
	close $file2
}
