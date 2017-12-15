package provide tleapop 1.0
proc ::ASM::amber {prot_in inputfile name namefile leapadd forfld hetat} {
	set dirf_pdb $inputfile
	##creat amber pdb
	set dirf [::ASM::makeScriptAmber_pdb $dirf_pdb/$name $prot_in $namefile $forfld $hetat]
	set fo [pwd]
	cd $dirf_pdb/$name
	catch {exec $ASM::Amber/tleap -s -f $dirf/scriptAmber_pdb}
	cd $fo
	##memorize amber pdb

	##creat top and coor od amber pdb
	::ASM::makeScriptAmber_top_coor $dirf "$dirf/Complex.pdb" $namefile $leapadd $forfld $hetat
	set script_top_coor $dirf/scriptamber_top_coor
	cd $dirf_pdb
  catch {exec $ASM::Amber/tleap -s -f $script_top_coor} 
	cd $fo
}

proc ::ASM::makeScriptAmber_pdb {dirf protein_in namefile forfld hetat} {
	if {[file exists $dirf]!=1} {
		file mkdir $dirf
	}
  set file1 [open $dirf/scriptAmber_pdb w+]
	
	if {$forfld != ""} {
		set i 0
    while {[lindex $forfld $i] != ""} {
			if {[llength [split [lindex $forfld $i] "/"]  ] > 1} {
				puts $file1 "source [pwd]/[lindex $forfld $i]"
			} else {
				puts $file1 "source [lindex $forfld $i]"
			}	
    	incr i
    	}
	} else {
		puts $file1 "source leaprc.ff03"
	}
	if {$hetat != ""} {
		set i 0
		set resname ""
		set mol2 ""
		set parm ""
		while {$i < [llength $hetat]} {
			set hetat_aux [split [lindex $hetat $i] " "]
			if {[lsearch $hetat_aux "RESNAME"] != -1} {
				set j 0
				while {$j < [llength $hetat_aux]} {
					if {[string trim [lindex $hetat_aux $j] " "] != "" && [string trim [lindex $hetat_aux $j] " "] != "RESNAME"} {
						set resname [lindex $hetat_aux $j]
					}
					incr j
				}
			} elseif {[lsearch $hetat_aux "MOLFILE"] != -1} {
				set j 0
				while {$j < [llength $hetat_aux]} {
					if {[string trim [lindex $hetat_aux $j] " "] != "" && [string trim [lindex $hetat_aux $j] " "] != "MOLFILE"} {
						set mol2 [lindex $hetat_aux $j]
					}
					incr j
				}
			} elseif {[lsearch $hetat_aux "PARMFILE"] != -1} {
				set j 0
				while {$j < [llength $hetat_aux]} {
					if {[string trim [lindex $hetat_aux $j] " "] != "" && [string trim [lindex $hetat_aux $j] " "] != "PARMFILE"} {
						set parm [lindex $hetat_aux $j]
					}
					incr j
				}
			}
			incr i
		}
		puts $file1 "$resname = loadmol2 [pwd]/$mol2"
		puts $file1 "loadaqmberparams [pwd]/$parm"
	}
	puts $file1 "21q = loadpdb $protein_in"
	puts $file1 "savepdb 21q $dirf/Complex_$namefile.pdb"
	close $file1
	return $dirf
}
proc ::ASM::makeScriptAmber_top_coor {dirf protein namefile leapadd forfld hetat} {
	set file1 [open $dirf/scriptamber_top_coor w+]
	if {$forfld != ""} {
		set i 0
		while {[lindex $forfld $i] != ""} {
			if {[llength [split [lindex $forfld $i] "/"]  ] > 1} {
				puts $file1 "source [pwd]/[lindex $forfld $i]"
			} else {
				puts $file1 "source [lindex $forfld $i]"
			}
			incr i
		}
	} else {
		puts $file1 "source leaprc.ff03"
	}
	if {$hetat != ""} {
		set i 0
		set resname ""
		set mol2 ""
		set parm ""
		while {$i < [llength $hetat]} {
			set hetat_aux [split [lindex $hetat $i] " "]
			if {[lsearch $hetat_aux "RESNAME"] != -1} {
				set j 0
				while {$j < [llength $hetat_aux]} {
					if {[string trim [lindex $hetat_aux $j] " "] != "" && [string trim [lindex $hetat_aux $j] " "] != "RESNAME"} {
						set resname [lindex $hetat_aux $j]
					}
					incr j
				}
			} elseif {[lsearch $hetat_aux "MOLFILE"] != -1} {
				set j 0
				while {$j < [llength $hetat_aux]} {
					if {[string trim [lindex $hetat_aux $j] " "] != "" && [string trim [lindex $hetat_aux $j] " "] != "MOLFILE"} {
						set mol2 [lindex $hetat_aux $j]
					}
					incr j
				}
			} elseif {[lsearch $hetat_aux "PARMFILE"] != -1} {
				set j 0
				while {$j < [llength $hetat_aux]} {
					if {[string trim [lindex $hetat_aux $j] " "] != "" && [string trim [lindex $hetat_aux $j] " "] != "PARMFILE"} {
						set parm [lindex $hetat_aux $j]
					}
					incr j
				}
			}
			incr i
		}
		puts $file1 "$resname = loadmol2 [pwd]/$mol2"
		puts $file1 "loadamberparams [pwd]/$parm"
	}
  puts $file1 "21q = loadpdb $dirf/Complex_$namefile.pdb"
  if {$leapadd == 1} {
		puts $file1 "set default PBradii bondi"    
	}    
	puts $file1 "saveamberparm 21q $dirf/Complex_$namefile.top $dirf/Complex_$namefile.crd"
	close $file1
}

