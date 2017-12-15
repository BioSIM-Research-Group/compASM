package provide Gui_func 1.0

proc ASM_GUI::readPdbValues {} {

    set moltop [molinfo top]
    set pdb_fil_name [molinfo $moltop get filename]
    set pdb_file [open $pdb_fil_name r+]
    set chain_name ""
    set chn 1
    set resnamei ""
    set resnum_aux 1
    set ter ""
    set ter_real ""
    set resnumi 1
    set chain_auxi ""
    set chain_n 0
    set chain_het "1"
    array unset ::ASM_GUI::pdb
    array set ::ASM_GUI::pdb ""
    set first 0
    set do 1
    set new 0
    set tprv 0
    while {[eof $pdb_file] != 1} {
        if {$new == 0} {
            set linha [gets $pdb_file]
        }
        set new 0
        if {[string range $linha 0 5]=="ATOM  "} {
                set resname [string range $linha 17 19]
                set resnum [string range $linha 22 25]
                set atnum [string range $linha 6 11]
                set chain_aux [string index $linha 21]

                if {($resnamei != $resname || $resnum != $resnumi) || $tprv == 1} {
                    set ASM_GUI::pdb($resnum_aux,0) $resname
                    set ASM_GUI::pdb($resnum_aux,1) $resnum
                    set ASM_GUI::pdb($resnum_aux,2) $chn
                    set ASM_GUI::pdb($resnum_aux,3) $chain_aux
                    incr resnum_aux
                    set tprv 0
                 }

                if {$resnum < $resnumi && [string is integer $resnum] == 1} {
                        set first 2
                        incr chn
                }

                if {$first == 0 || $first == 2} {
                        if {$chain_aux != $chain_auxi && $chain_auxi != "" } {
                                set chain_n 1
                        }
                        set chain_auxi $chain_aux
                        set chain_name [lappend chain_name $chain_aux]
                        set ter  [lappend ter [expr $resnum_aux -1] ]
                        if {$first ==2} {
                                set ter_real [lappend ter_real $resnumi ]
                        }

                        set ter_real [lappend ter_real $resnum ]
                        set first 1
                }
                set resnamei $resname
                set resnumi $resnum
                set do 1
        } elseif {[string range $linha 0 5]=="HETATM"} {
                set resname [string trim [string range $linha 17 19] " "]
                set resnum [string trim [string range $linha 22 25] " "]
                set chain_aux " "
                set un "_"

                if {$resnum != $resnumi} {
                        if {[string length [string trim $resname " "] ] < 3} {
                                set resname [string trim $resname " "]
                        }
                        if {[lsearch $ASM_GUI::heat_add $resname$un$resnum] != -1} {
                                set ASM_GUI::pdb($resnum_aux,0) $resname
                                set ASM_GUI::pdb($resnum_aux,1) $resnum
                                set ASM_GUI::pdb($resnum_aux,2) $chn
                                set ASM_GUI::pdb($resnum_aux,3) [string index $linha 21]
                                incr resnum_aux
                                incr chn
                                if {[lsearch $chain_name $chain_aux] == -1 && [string trim $chain_aux " "] != ""} {
                                        set chain_name [lappend chain_name $chain_aux]
                                        set ter  [lappend ter [expr $resnum_aux -1] ]
                                        set ter_real [lappend ter_real $resnum ]
                                }
                                set ter  [lappend ter [expr $resnum_aux -1] ]
                                set ter_real [lappend ter_real $resnum ]

                                if {$chain_aux != $chain_auxi && $chain_auxi != "" } {
                                        set chain_n 1
                                }
                                set chain_auxi $chain_aux
                                set chain_name [lappend chain_name $chain_aux]
                        }
                }

                set resnamei $resname
                set resnumi $resnum
        } elseif {[string trim [string range $linha 0 2]]=="TER"} {
            set ter  [lappend ter [expr $resnum_aux -1] ]
            set ter_real [lappend ter_real $resnum ]
            set linha [gets $pdb_file]
            set resname [string range $linha 17 19]
            set resnum [string range $linha 22 25]
            set un "_"

            set atnum [string range $linha 6 11]
            set chain_aux [string index $linha 21]
            if {[string trim [string range $linha 0 2]] !="END" } {
                set first 0
                set new 1
                if {[string trim [string range $linha 0 5]] =="ATOM  "} {
                    set resnamei $resname
                    set resnumi $resnum
                    set tprv 1
                }
            }
            if {[lsearch $ASM_GUI::heat_add $resnamei$un$resnumi] == -1} {
                incr chn
            }

        } elseif {[string trim [string range $linha 0 2]]=="END"} {
	    set ter  [lappend ter [expr $resnum_aux -1] ]
            set ter_real [lappend ter_real $resnum ]
	}


    }
    if {$ASM_GUI::heat_add != ""} {
      set frame "$ASM_GUI::topGui.nb1.f1"
      $frame.nb2.f1.flig_rec.addrm.lbres configure -state normal
      $frame.nb2.f1.flig_rec.addrm.cmb configure -state readonly
      $frame.nb2.f1.flig_rec.addrm.butadd configure -state normal
      $frame.nb2.f1.flig_rec.addrm.butrm configure -state normal
    }
    set molid [molinfo top]
    set id [mol load pdb $pdb_fil_name]
    set ASM_GUI::top $id
    mol rename $id "ASM_Prot_rep"
    mol delete $molid
    set i 0
    set j 0
    array unset chain
    array set chain ""
    array unset stchain
    array set stchain ""

    array unset ::ASM_GUI::checklig_rec
    array set ::ASM_GUI::checklig_rec ""
    array unset ::ASM_GUI::onoff
    array set ::ASM_GUI::onoff ""
    set ind 0
    set brk 0
    set arr 0
	  
    while {[lindex $chain_name $j ] != "" && $brk != 1} {
      if {[string trim [lindex $ter_real [expr $i +1]] " "] != ""} {
	if {[string trim [lindex $chain_name $j] " "] == ""} {
	    set chain([expr $arr +1]) [lappend chain([expr $arr +1])  [string trim [lindex $ter_real $i ] " "] ]
	    set chain([expr $arr +1]) [lappend chain([expr $arr +1])  [string trim [lindex $ter_real [expr $i +1]] " "] ]
	    incr arr
	}


	set stchain([expr $j +1]) [append stchain([expr $j +1]) [string trim [lindex $ter_real $i ] " "] "-"]
	set stchain([expr $j +1]) [append stchain([expr $j +1])  [string trim [lindex $ter_real [expr $i +1]] " "]  ]
      } else {
        set brk 1
      }



      if {$brk != 1} {
	if {[string trim [lindex $chain_name $j] " "] != ""} {
	    set st [split [string trim $stchain([expr $j +1]) " "] "-"]
	    set st [lindex $st 0]
	    if {[lsearch $ASM_GUI::heat_add "*_$st"] != -1} {
		set res [split [lindex $ASM_GUI::heat_add [lsearch $ASM_GUI::heat_add "*_$st"]] "_"]
		set res [lindex $res 0]
		$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb insert end "{} $res {$stchain([expr $j +1])}"
		set ASM_GUI::onoff([lindex $ASM_GUI::heat_add [lsearch $ASM_GUI::heat_add "*_$st"]],0) $j
		set ASM_GUI::onoff([lindex $ASM_GUI::heat_add [lsearch $ASM_GUI::heat_add "*_$st"]],1) 1
	    } else {
		    $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb insert end "{} [lindex $chain_name $j] {$stchain([expr $j +1])}"
		    set ASM_GUI::onoff([lindex $chain_name $j],0) $j
		    set ASM_GUI::onoff([lindex $chain_name $j],1) 1
	    }
	} else {
	    set st [split [string trim $stchain([expr $j +1]) " "] "-"]
	    set st [lindex $st 0]
	    if {[lsearch $ASM_GUI::heat_add "*_$st"] != -1} {
		set res [split [lindex $ASM_GUI::heat_add [lsearch $ASM_GUI::heat_add "*_$st"]] "_"]
		set res [lindex $res 0]
		$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb insert end "{} $res {$stchain([expr $j +1])}"
		set ASM_GUI::onoff([lindex $ASM_GUI::heat_add [lsearch $ASM_GUI::heat_add "*_$st"]],0) $j
		set ASM_GUI::onoff([lindex $ASM_GUI::heat_add [lsearch $ASM_GUI::heat_add "*_$st"]],1) 1
	    } else {
		$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb insert end "{} [expr $j +1] {$stchain([expr $j +1])}"
		set ASM_GUI::onoff([expr $j +1],0) $j
		set ASM_GUI::onoff([expr $j +1],1) 1
	    }
	}

        $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellconfigure $j,3 -window ASM_GUI::createButton
        $ASM_GUI::rdbut($j,3) configure -value 1
        $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellconfigure $j,4 -window ASM_GUI::createButton
        $ASM_GUI::rdbut($j,4) configure -value 0
        $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellconfigure $j,5 -window ASM_GUI::createCombo

        set val [expr int([expr [expr [llength $ter_real] /2] / 2])]
        $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellconfigure "$j,0" -background "#[ASM_GUI::rgbtoHEX [colorinfo rgb [expr $j+2]]]"

      }
      incr i 2
      incr j
    }
    set ASM_GUI::nchain [expr [llength $ter]/2]
    if {[expr fmod([llength $ter],2)]!= 0} {
      incr ASM_GUI::nchain
    }
    close $pdb_file
    if {[string trim [lindex $chain_name 0] " "] != " "} {
	set i 0
	set j 0
	set aux_chain ""
	while {$i < [llength $chain_name]} {
	    if {[string trim [lindex $chain_name $j] " "] != ""} {
		set aux_chain [lappend aux_chain [lindex $chain_name $j]]
		incr j
	    }
	    incr i
	}
	set chain_name $aux_chain
    }
    set do 0

    if {[string trim [lindex $chain_name 0] " "] != "" && $chain_n == 1 } {
              ASM_GUI::subUnits $chain_name 0 $ASM_GUI::top 0
    } else {
	
        ASM_GUI::subUnits [array get chain] 1 $ASM_GUI::top 0
              set do 1
    }
          set aux_chain ""
          if {[llength $ASM_GUI::heat_add ] > 0 &&  $i != $j && $do != 1} {
             set h 0
              while {$h < [llength $ASM_GUI::heat_add ]} {
                  set name [lindex $ASM_GUI::heat_add $h]
                  set res [split $name "_"]
                  set ch [string index [lindex $ASM_GUI::heat_val([lindex $ASM_GUI::heat_add $h]) 0] 21]
                  set aux_chain [lappend aux_chain "resname [lindex $res 0] and resid [lindex $res 1] and chain $ch"]

                  incr h
              }
              ASM_GUI::subUnits $aux_chain 2 $ASM_GUI::top $j
          }


    wm deiconify $ASM_GUI::topGui
    update
}

proc ASM_GUI::getChain {resid} {
	set j 0
	set chain_list ""
	while {[lindex $resid $j] != ""} {

		set i 0
		while {$i < [array size ASM_GUI::checklig_rec]} {
			set chain [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $i,2 -text]
			set chain [split $chain "-"]

			if {[lindex $resid $j] >= [lindex $chain 0] && [lindex $resid $j] <= [lindex $chain 1]} {
				set chain_list [append chain_list "[$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $i,1 -text] "]
				break
			}
			incr i
		}
		incr j
	}
	return $chain_list
}

proc ASM_GUI::loadMutations {} {
    set ligand ""
    set ligan_prot ""
    set receptor ""
    set receptor_prot ""
    set lig_chain ""
    set rec_chain ""
    set size  [array size ASM_GUI::checklig_rec]
    for {set i 0} {$i <= [expr $size -1]} {incr i} {
        if {[info exists ASM_GUI::checklig_rec($i)]} {
            if {$ASM_GUI::checklig_rec($i) == 1} {
                set ligand [lappend ligand $i]
            } else {
				set receptor [lappend receptor $i]
            }
        }
    }
    set ind 1
    set do [string is integer [string trim [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget 0,1 -text] " "]]
    if {$do == 1} {
        set i 0
        while {[lindex $ligand $i] != ""} {
            if {$i >0} {
                set ligand_prot [append ligand_prot "or "]
            }
            set st_aux [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget [lindex $ligand $i],2 -text]
            set st_aux [split $st_aux "-"]
            if { [string length [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget [lindex $ligand $i],1 -text] ] > 1} {
                set lig_chain [append lig_chain $ind]
                incr ind
            } else {
                set lig_chain [append lig_chain "[$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget [lindex $ligand $i],1 -text] "]
            }
            set ligand_prot [append ligand_prot "(resid [lindex $st_aux 0] to [lindex $st_aux 1]) "]
            incr i
        }
        set i 0
        while {[lindex $receptor $i] != ""} {
            if {$i >0} {
                set receptor_prot [append receptor_prot "or "]
            }
            set st_aux [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget [lindex $receptor $i],2 -text]
            set st_aux [split $st_aux "-"]
            if { [string length [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget [lindex $receptor $i],1 -text] ] > 1} {
                set rec_chain [append rec_chain $ind]
                incr ind
            } else {
                set rec_chain [append rec_chain "[$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget [lindex $receptor $i],1 -text] "]
            }
            set receptor_prot [append receptor_prot "(resid [lindex $st_aux 0] to [lindex $st_aux 1]) "]
            incr i
        }
    } else {
        set i 0
        while {[lindex $ligand $i] != ""} {
            if {$i >0} {
                set ligand_prot [append ligand_prot "or "]
            }
            set st_aux [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget [lindex $ligand $i],2 -text]
            set st_aux [split $st_aux "-"]
            set text [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget [lindex $ligand $i],1 -text]
            if { [string length $text ] > 1} {
                if {[lsearch $ASM_GUI::heat_add $text] != -1} {
                    set text [lindex $ASM_GUI::heat_val($text) 0]
                    set text [string trim [string index $text 21] " "]
            } else {
                set text $ind
            }
            set ligand_prot [append ligand_prot "(chain $text)"]
            incr ind
        } else {
            set ligand_prot [append ligand_prot "(resid [lindex $st_aux 0] to [lindex $st_aux 1] and chain $text)"]
        }
            incr i
        }
        set i 0
        while {[lindex $receptor $i] != ""} {
            if {$i >0} {
                set receptor_prot [append receptor_prot "or "]
            }
            set st_aux [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget [lindex $receptor $i],2 -text]
            set st_aux [split $st_aux "-"]
            set text [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget [lindex $receptor $i],1 -text]
            if { [string length $text ] > 1} {
                if {[lsearch $ASM_GUI::heat_add $text] != -1} {
                    set text [lindex $ASM_GUI::heat_val($text) 0]
                    set text [string trim [string index $text 21] " "]
                } else {
                    set text $ind
                }
                set receptor_prot [append receptor_prot "(chain $text)"]
                incr ind
            } else {
                set receptor_prot [append receptor_prot "(resid [lindex $st_aux 0] to [lindex $st_aux 1] and chain $text) "]
            }
            incr i
        }
    }

    $ASM_GUI::topGui.nb1.f1.nb2 tab 1 -state normal
    $ASM_GUI::topGui.nb1.f1.nb2 select 1
    ASM_GUI::intRes $ligand_prot $receptor_prot $do [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.frmradi.spinradii get]
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.frmradi.spinradii configure -state normal
    $ASM_GUI::topGui.nb1.f1.nb2 tab 1 -state normal
    $ASM_GUI::topGui.nb1.f1.nb2 select 1
}

proc ASM_GUI::check {} {
	set size [array size ASM_GUI::checklig_rec]
	set lig 0
	set rec 0
	set do 0
	set j 0
	if {$ASM_GUI::next == 1} {
		set ASM_GUI::next 2
		ASM_GUI::clearSlect
		mol delete [molinfo top]
		mol on [molinfo top]
		set ASM_GUI::repid 0
		set ASM_GUI::top [molinfo top]
	}

	set index -1
	for {set i 0} {$i < [molinfo [molinfo top] get numreps]} {incr i} {
		if {[info exists ASM_GUI::checklig_rec($i)] == 1} {
		    set text [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $i,1 -text]
                    set res [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $i,1 -text]
                    set num [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $i,2 -text]
                    set num [lindex [split $num "-"] 0]
                    set un "_"
                    if {[string is integer $text] != 1} {
                            set het [lindex $ASM_GUI::heat_val($text$un$num) 0]
                            set het [lsearch [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.cmb cget -values] $text$un$num]
                            set size [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size]
                            set hettotal [llength $ASM_GUI::heat_add]
                            set index [expr $het + [expr $size - $hettotal]]
                    }
                    if {[info exists ASM_GUI::checklig_rec_pv($i)] ==1} {
                            if {$ASM_GUI::checklig_rec($i) != $ASM_GUI::checklig_rec_pv($i)} {
                                    if {$ASM_GUI::checklig_rec($i)==1} {

                                            if {$index > 0} {
                                                    mol modcolor $index $ASM_GUI::top "ColorId 0"
                                            } else {
                                                    mol modcolor $i $ASM_GUI::top "ColorId 0"
                                            }
                                            $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellconfigure "$i,0" -background "#[ASM_GUI::rgbtoHEX [colorinfo rgb 0]]"
                                    } elseif {$ASM_GUI::checklig_rec($i)==0} {
                                            set text [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $i,1 -text]
                                            if {$index > 0} {
                                                    mol modcolor $index $ASM_GUI::top "ColorId 1"
                                            } else {
                                                    mol modcolor $i $ASM_GUI::top "ColorId 1"
                                            }
                                            $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellconfigure "$i,0" -background "#[ASM_GUI::rgbtoHEX [colorinfo rgb 1]]"
                                    }
                                    if {$ASM_GUI::checklig_rec($i) != -1} {
                                            set ASM_GUI::checklig_rec_pv($i) $ASM_GUI::checklig_rec($i)
                                    }
                                    if {$do == 1} {
                                            incr j
                                            if {$j==2} {
                                                    break
                                            }
                                    }


                            }
                    } else {
                            if {$ASM_GUI::checklig_rec($i)==1} {
                                    set text [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $i,1 -text]
                                    if {$index > 0} {
                                            mol modcolor $index $ASM_GUI::top "ColorId 0"
                                    } else {
                                            mol modcolor $i $ASM_GUI::top "ColorId 0"
                                    }
                                    $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellconfigure "$i,0" -background "#[ASM_GUI::rgbtoHEX [colorinfo rgb 0]]"
                            } elseif {$ASM_GUI::checklig_rec($i)==0}  {
                                    set text [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $i,1 -text]
                                    if {$index > 0} {
                                            mol modcolor $index $ASM_GUI::top "ColorId 1"
                                    } else {
                                            mol modcolor $i $ASM_GUI::top "ColorId 1"
                                    }
                                    $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellconfigure "$i,0" -background "#[ASM_GUI::rgbtoHEX [colorinfo rgb 1]]"
                            }
                            if {$ASM_GUI::checklig_rec($i) != -1} {
                                    set ASM_GUI::checklig_rec_pv($i) $ASM_GUI::checklig_rec($i)
                            }

                    }

		}

	}
	$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb selection clear 0 end
	set count 0
	set i 0
	while {$i < [molinfo [molinfo top] get numreps]} {
		if {[info exists  ASM_GUI::checklig_rec($i)]==1} {
                	if {$ASM_GUI::checklig_rec($i) == 1 ||$ASM_GUI::checklig_rec($i) == 0} {
                		incr count
                	}
		}
		incr i
	}
	if {$count == [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size]} {
		$ASM_GUI::topGui.nb1.f1.nb2.f1.btnext configure -state normal
	} else {
		$ASM_GUI::topGui.nb1.f1.nb2.f1.btnext configure -state disable
	}
}

proc ASM_GUI::addMutations {id do} {
	set sel ""
	set k_i ""
	set k 0
	set res_list ""
	set i 0
	set do 1
	set id_list ""
    if {$ASM_GUI::repid >= 3} {
        if {$do==1} {
            while {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb size]} {
                if {[info exists ASM_GUI::checkmut($i,0)]} {
                    if {$ASM_GUI::checkmut($i,0)==1} {
                        set resname [string trim [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $i,0 -text] " "]
                        set resid [string trim [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $i,1 -text] " "]
                        set reschain [string trim [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $i,2 -text] " "]
                        set k [string trim [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $i,4 -text] " "]
                        if {$k != $k_i && $k_i != ""} {
                            tk_messageBox -title "Dielectric Constant Error" -message "Please make sure that every residue has the same dielectric constant (Diele K)"\
                            -type ok -icon error
                            set do 0
                            break
                        } else {
                        if {$k_i != ""} {
                            set res_list [append res_list "\n"]
                        }
                        set un "_"
                        set res_list [append res_list "$resname$un$resid$un$reschain"]
                        set k_i $k
                        set id_list [lappend id_list $i]
                        }
                    }
                }
                incr i
            }
            set j 0
            while {$j < [array size ASM_GUI::mut_added]} {
                if {$ASM_GUI::mut_added($j) == $id_list} {
                    set do 0
                    ASM_GUI::clearSlect
                    break
                }
                incr j
            }
            if {$do ==1} {
                if {$id == "end"} {
                    set index [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb size]
                } else {
                    set index $id
                }
                set ASM_GUI::mut_added($index) $id_list
                $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb insert $index "$index {$res_list} $k"
                if {$id != "end"} {
                    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb delete [expr $index + 1]
                }
                $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb sortbycolumn 0
                set i 0
                $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb cellselection clear 0,0 [expr [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb size] -1],0
                while {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb size]} {
                    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb cellconfigure $i,0 -text $i
                    incr i
                }

            }
            set i 0
            while {[lindex $id_list $i] != ""} {
                set ASM_GUI::checkmut([lindex $id_list $i],0) 0
                ASM_GUI::rowSelection
                incr i
            }
            ASM_GUI::clearSlect
            array unset ::ASM_GUI::checkmut
            array set ASM_GUI::checkmut ""
                $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb selection clear 0 end
            $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.btnext configure -state normal
            $ASM_GUI::topGui.nb1.f1.btrunload.btreset configure -state normal
        }
    } else {
        tk_messageBox -title "No residue selected" -message "Please select at least one residue"\
        -type ok -icon info
    }
}

proc ASM_GUI::clearSlect {} {
    set $ASM_GUI::press_i ""
    set i 0
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb selection clear 0 end
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb selection clear 0 end
    $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb selection clear 0 end
    while {$i <= [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb size]} {
        if {[info exists ASM_GUI::checkmut($i,0)]} {
            if {$ASM_GUI::checkmut($i,0)==1} {
                  set ASM_GUI::checkmut($i,0) 0
                  ASM_GUI::rowSelection
            }
        }
        incr i
    }
}

proc ASM_GUI::scanSurf {} {
    set i 0
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.addbt configure -state normal
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.scanbt configure -state normal
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.clearbt configure -state normal
    ASM_GUI::clearSlect
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.addbt configure -state disabled
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.scanbt configure -state disabled
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.clearbt configure -state disabled
    ASM_GUI::clearSlect
    array unset ::ASM_GUI::checkmut
    array set ::ASM_GUI::checkmut ""
    while {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb size]} {
        set res [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $i,0 -text]
        set res [string trim $res " "]
        if {$res != "ALA" && $res != "PRO" && $res != "GLY"} {
            set ASM_GUI::checkmut($i,0) 1
            ASM_GUI::rowSelection
            ASM_GUI::addMutations end 1
            $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb rowconfigure $i -selectable 0
            $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb selection clear $i
        }
        incr i
    }
    set i 0
    while {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb size]} {
        $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb rowconfigure $i -selectable 1

        incr i
    }
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb selection clear 0 end
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb selection clear 0 end
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.addbt configure -state normal
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.scanbt configure -state normal
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.clearbt configure -state normal
}

proc ASM_GUI::sasaSel {} {
    set i 0
    set j 0
    ASM_GUI::clearSlect
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.addbt configure -state disabled
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.scanbt configure -state disabled
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.clearbt configure -state disabled

    while {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb size]} {
        set res [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $i,0 -text]
        set num [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $i,1 -text]
        set cha [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $i,2 -text]
        set un "_"
        if {[string is integer $cha] == 1} {
            set cha "X"
        }
        if {$ASM_GUI::sasa_arr($res$un$num$un$cha) > 40 && ($res != "GLY" && $res != "ALA" && $res != "PRO")} {
            set ASM_GUI::checkmut($i,0) 1
            ASM_GUI::rowSelection
            ASM_GUI::addMutations end 1
            $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb rowconfigure $j -selectable 0
            $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb rowconfigure $i -selectable 0
            incr j
        }
        incr i
    }

    set i 0
    while {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb size]} {
        $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb rowconfigure $i -selectable 1
        incr i
    }
    set i 0
    while {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb size]} {
        $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb rowconfigure $i -selectable 1

        incr i
    }

    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb selection clear 0 end
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb selection clear 0 end
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.addbt configure -state normal
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.scanbt configure -state normal
    $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.mutbut.clearbt configure -state normal
    ASM_GUI::clearSlect
}
proc ASM_GUI::tbMutSel {} {
	set id [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb curselection]
	set id [split $id " "]
	set list ""
	if {$id == "" && $ASM_GUI::press_i == ""} {
		$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb selection clear 0 end
	} else {
        if {$id == ""} {
            set i 0
            while {[lindex  $ASM_GUI::mut_added([lindex $ASM_GUI::press_i 0]) $i] != ""} {
                    set ASM_GUI::checkmut([lindex  $ASM_GUI::mut_added([lindex $ASM_GUI::press_i 0]) $i],0) 0
                    ASM_GUI::rowSelection
                    incr i
            }
        }
        set j 0
        while {[lindex $id $j]!= ""} {
            if {$ASM_GUI::press_i != ""} {
                set i 0
                set k 0
                while {[lindex $ASM_GUI::press_i $k] != ""} {
                    if {[lsearch $id [lindex $ASM_GUI::press_i $k]] == -1} {
                        while {[lindex  $ASM_GUI::mut_added([lindex $ASM_GUI::press_i $k]) $i] != ""} {
                            set ASM_GUI::checkmut([lindex  $ASM_GUI::mut_added([lindex $ASM_GUI::press_i $k]) $i],0) 0
                            ASM_GUI::rowSelection
                            incr i
                        }
                    }
                        incr k
                }
            }

			set i 0
			set val [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb cellcget [lindex $id $j],1 -text]
			while {[lindex $val $i] != ""} {
				set txt [split [lindex $val $i] "_"]
				set k 0
				while {$k < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb size]} {
					set resname [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $k,0 -text]
					set resid [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $k,1 -text]
					set chain [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $k,2 -text]
					if {[lindex $txt 0] == $resname && [lindex $txt 1] == $resid && [lindex $txt 2] == $chain} {
							set ASM_GUI::checkmut($k,0) 1
							ASM_GUI::rowSelection
							break
					}
					incr k
				}
				incr i
			}
			set list [lappend list [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb cellcget [lindex $id $j],0 -text]]
			set i 0

			set ASM_GUI::press_i $list
			incr j
        }
	}
}

proc ASM_GUI::delMutations {} {
    set id [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb curselection]
    set id [split $id " "]
    if {$id != ""} {
        array set mut_aux ""
        set i 0
        set j 0
        set k 0
        set un "_"
        while {$i < [array size ASM_GUI::mut_added]} {
            if {$i ==[lindex $id $k]} {
                $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb cellselection clear [expr [lindex $id $k] - $k],0 [expr [lindex $id $k] - $k],end
                ASM_GUI::tbMutSel
                $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb delete [expr [lindex $id $k] - $k]

                set ASM_GUI::press_i ""
                incr k
            } else {
                set mut_aux($j) $ASM_GUI::mut_added($i)
                incr j
            }
            incr i
        }
        ASM_GUI::clearSlect

        $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb sortbycolumn 0

        set i 0
        $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb cellselection clear 0,0 [expr [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb size] -1],0
        while {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb size]} {
                $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb cellconfigure $i,0 -text $i
                incr i
        }
        set i 0
        array unset ASM_GUI::mut_added
        array set ::ASM_GUI::mut_added ""
        while {$i < [array size mut_aux]} {
                set ASM_GUI::mut_added($i) $mut_aux($i)
                incr i
        }
        $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb selection clear 0 end
    }
}

proc ASM_GUI::loadButton {file} {


    set i 0
    if {$file != ""} {
		if {[$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size] > 0} {
			ASM_GUI::reset
		}

            ASM_GUI::clearSlect

            $ASM_GUI::topGui.nb1.f1.nb2 tab 1 -state normal
            $ASM_GUI::topGui.nb1.f1.nb2 tab 2 -state normal
            $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb delete 0 end
            $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb delete 0 end
            $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb delete 0 end
            set inputfile [open $file r+]
            while {[eof $inputfile] != 1} {
                    set linha [gets $inputfile]
                    set linha [string trim $linha " "]
                    switch $linha {
                            "##PROTEIN" {
								while {$linha != "END"} {
									if {[string index $linha 0] != "!"} {
										set linha [gets $inputfile]
										set linha [string trim $linha " "]
										set path [file dirname $file]
										set prot $linha
										mol off [molinfo top]
										set id [mol load pdb "$path/$prot"]
										set moltop [molinfo index $id]
										ASM_GUI::readPdbValues
									}
									set linha [gets $inputfile]
									 set linha [string trim $linha " "]
								}
                            }
                            "##LIGAND" {
                                    set chain [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget 0,1 -text]
                                    if {[string is integer $chain]== 1} {
                                            set i 0
                                            set linha [gets $inputfile]
                                            set linha [string trim $linha " "]
                                            while {$linha != "END"} {
												if {[string index $linha 0] != "!"} {
													set ASM_GUI::checklig_rec([expr $linha - 1]) 1
													ASM_GUI::check
												}
                                                set linha [gets $inputfile]
                                                set linha [string trim $linha " "]
                                            }
                                    } else {
                                            set done ""
                                            set linha [gets $inputfile]
                                            set linha [string trim $linha " "]
                                            while {$linha  != "END"} {
												if {[string index $linha 0] != "!"} {
													set chain [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget [expr $linha -1],1 -text]
													if {[string length $chain] > 1} {
														set het [lindex $ASM_GUI::heat_val($chain) 0]
														set het [string trim [string index $het 21] " "]
														set hettotal [llength $ASM_GUI::heat_add]
														set size [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size]
														set ASM_GUI::checklig_rec([expr $het -[ expr $size - $hettotal]]) 1
														set ASM_GUI::checklig_rec([expr $linha -1]) 1
														ASM_GUI::check

													} else {
															for {set h 1} {$h <= [expr [array size ASM_GUI::pdb]/4]} {incr h} {
																	if {$ASM_GUI::pdb($h,2)== $linha} {
																			set j 0
																			while {$j < [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size]} {
																					if {[$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $j,1 -text] == $ASM_GUI::pdb($h,3) && [lsearch $done $j] == -1} {
																							set ASM_GUI::checklig_rec($j) 1
																							ASM_GUI::check
																							set done [lappend done $j]
																							break
																					}
																					incr j
																			}

																			break
																	}
															}
													}
												}
                                                set linha [gets $inputfile]
                                                set linha [string trim $linha " "]
                                            }
                                    }

                            }
                            "##RECEPTOR" {
                                    set chain [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget 0,1 -text]
                                    if {[string is integer $chain]== 1} {
                                            set i 0
											set linha [gets $inputfile]
                                            set linha [string trim $linha " "]
                                            while {$linha != "END"} {
												if {[string index $linha 0] != "!"} {
                                                    set ASM_GUI::checklig_rec([expr $linha - 1]) 0
                                                    ASM_GUI::check
												}
													set linha [gets $inputfile]
                                                    set linha [string trim $linha " "]
                                            }
                                    } else {
                                            set done ""
                                            set linha [gets $inputfile]
                                            set linha [string trim $linha " "]
                                            while {$linha != "END"} {
												if {[string index $linha 0] != "!"} {
													set chain [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget [expr $linha -1],1 -text]
													if {[string length $chain] > 1} {
															set het [lindex $ASM_GUI::heat_val($chain) 0]
															set het [string trim [string index $het 21] " "]
															set hettotal [llength $ASM_GUI::heat_add]
															set size [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size]
															set ASM_GUI::checklig_rec([expr $het -[ expr $size - $hettotal]]) 0
															set ASM_GUI::checklig_rec([expr $linha -1]) 0
															ASM_GUI::check
													} else {
														for {set h 1} {$h <= [expr [array size ASM_GUI::pdb]/4]} {incr h} {
																if {$ASM_GUI::pdb($h,2)== $linha} {
																		set j 0
																		while {$j < [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size]} {
																				if {[$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $j,1 -text] == $ASM_GUI::pdb($h,3) && [lsearch $done $j] == -1} {
																						set ASM_GUI::checklig_rec($j) 0
																						ASM_GUI::check
																						set done [lappend done $j]
																						break
																				}
																				incr j
																		}

																		break
																}
														}
													}
												}
                                                set linha [gets $inputfile]
                                                set linha [string trim $linha " "]
                                            }
                                    }

                                    set ASM_GUI::next 1
                                    ASM_GUI::loadMutations

                            }
							"##MUTATIONS" {
                                    set linha [gets $inputfile]
                                    set linha [string trim $linha " "]
                                    while {$linha != "END"} {
											if {[string index $linha 0] != "!"} {


												set val [split $linha "_"]
												set list ""
												set resname $ASM_GUI::pdb([string trim [lindex  $val 0] " "],0)
												set resid $ASM_GUI::pdb([string trim [lindex  $val 0] " "],1)
												if {[string is integer [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb  cellcget $i,2 -text]] == 1} {
													set chain $ASM_GUI::pdb([string trim [lindex  $val 0] " "],2)
												} else {
													set chain $ASM_GUI::pdb([string trim [lindex  $val 0] " "],3)
												}

												set i 0
												$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb configure -state normal
												$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb configure -state normal
												while {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb size]} {
													if {$resname == [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $i,0 -text] && $resid == [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb  cellcget $i,1 -text] && $chain == [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb  cellcget $i,2 -text]} {
														set ASM_GUI::checkmut($i,0) 1
														ASM_GUI::rowSelection
														ASM_GUI::addMutations end 1
														set ASM_GUI::press_i $list
														ASM_GUI::clearSlect
														break
													}
													incr i
												}
											}
										set linha [gets $inputfile]
										set linha [string trim $linha " "]

                                    }
                            }
                            "##Minimization_Dynamic Parameters" {
                                    set linha [gets $inputfile]
                                    set linha [string trim $linha " "]
                                    while {$linha != "END"} {
										if {[string index $linha 0] != "!"} {
                                            set val [split $linha " "]
                                            switch [lindex $val 0] {
                                                imin= {
                                                    if {[lindex $val 1] == 0} {
                                                            set ASM_GUI::run 1
                                                            $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 tab 1 -state normal
                                                    } else {
                                                            set ASM_GUI::run 0
                                                            $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 tab 1 -state disable
                                                    }
                                                }
                                                ntpr= {
                                                        if {$ASM_GUI::run == 1} {
                                                                $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntpr set [lindex $val 1]
                                                                $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntpr configure -state disable
                                                        } else {
                                                                $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spstp set [lindex $val 1]
                                                        }
                                                }
                                                ntwr= {
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwr set [lindex $val 1]
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwr configure -state disable
                                                }
                                                ntwx= {
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwx set [lindex $val 1]
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwx configure -state disable
                                                }
                                                nstlim= {
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.splim set [lindex $val 1]
                                                         $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.splim configure -state disable
                                                }
                                                ntt= {
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntt set [lindex $val 1]
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntt configure -state disable
                                                }
                                                igb= {
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spgb set [lindex $val 1]
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spgb configure -state disable
                                                }
                                                cut= {
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spcut set [lindex $val 1]
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spcut configure -state disable
                                                }
                                                ntb= {
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntb set [lindex $val 1]
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntb configure -state disable
                                                }
                                                ntc= {
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntc set [lindex $val 1]
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntc configure -state disable
                                                }
                                                ntf= {
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntf set [lindex $val 1]
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntf configure -state disable
                                                }
                                                dt= {
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.sptmstp set [lindex $val 1]
                                                        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.sptmstp configure -state disable
                                                }

                                            }
										}
                                            set linha [gets $inputfile]
                                            set linha [string trim $linha " "]
                                    }

                            }
							"##MD Linear Model Values" {
								if {$ASM_GUI::run == 1} {

										while {$linha != "END"} {
												set linha [gets $inputfile]
                    set linha [string trim $linha " "]
												if {[string index $linha 0] != "!"} {
														set val [split $linha " "]
				                    switch [lindex $val 0] {
																B= {
																	 $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.frmStb.spslp set [string trim [lindex $val 1] " "]
																		$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.frmStb.spslp configure -state disable
																}
																R= {
																	 $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.frmStb.spcoe set [string trim [lindex $val 1] " "]
																	 $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.frmStb.spcoe configure -state disable
																}
																STDV= {
																	 $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.frmStb.spstdv set [string trim [lindex $val 1] " "]
																	 $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.frmStb.spstdv configure -state disable
																}
												}
										}
									}

								}

							}
                            "##Starting Minimization Parameters" {
                                    set linha [gets $inputfile]
                                    set linha [string trim $linha " "]
                                    while {$linha != "END"} {
										if {[string index $linha 0] != "!"} {
                                            set val [split $linha " "]
                                            switch [lindex $val 0] {
                                                    ntpr= {
                                                            $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spstp set [lindex $val 1]
                                                            $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spstp configure -state disable
                                                    }
                                                    maxcyc= {
                                                            $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spmaxn set [lindex $val 1]
                                                            $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spmaxn configure -state disable
                                                    }
                                                    ntmin= {
                                                            $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.splim set [lindex $val 1]
                                                            $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.splim configure -state disable
                                                    }
                                                    igb= {
                                                            $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spgb set [lindex $val 1]
                                                            $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spgb configure -state disable
                                                    }
                                                    ntc= {
                                                            $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntc set [lindex $val 1]
                                                            $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntc configure -state disable
                                                    }
                                                    ntf= {
                                                            $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntf set [lindex $val 1]
                                                            $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntc configure -state disable
                                                    }
                                            }
									}
                                            set linha [gets $inputfile]
                                            set linha [string trim $linha " "]
                                    }

                            }
                            "##Interface radii" {
                                    set linha [gets $inputfile]
                                    set linha [string trim $linha " "]
									 while {$linha != "END"} {
											if {[string index $linha 0] != "!"} {
												 $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.frmradi.spinradii set $linha
												ASM_GUI::spinInter
											}
										set linha [gets $inputfile]
										set linha [string trim $linha " "]
									 }


                            }

                            "##FORCE FIELDS" {
                                    set linha [gets $inputfile]
                                    set linha [string trim $linha " "]
                                    $ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld delete 0 end
                                    set dir [file dirname $file]
                                    while {$linha != "END"} {
										if {[string index $linha 0] != "!"} {
											set text [split $linha "/"]
											if {[llength $text] != 1} {
													set linha "$dir/$linha"
													$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld insert end $linha
													$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld configure -state disable
											}
											set linha [string trim $linha " "]
										}
                                        set linha [gets $inputfile]
                                        set linha [string trim $linha " "]
                                    }

                            }
                            "##HETAOMS Parameters" {
                                set st ""
                                set linha [gets $inputfile]
                                set linha [string trim $linha " "]
                                $ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld delete 0 end
                                set dir [file dirname $file]
                                while {$linha != "END"} {
									if {[string index $linha 0] != "!"} {
										set text [split $linha " "]
										if {[lindex $text 0] != "RESNAME"} {
												set st [append st [lindex $text 1]]
												set linha [gets $inputfile]
												set linha [string trim $linha " "]
												if {[lindex $text 0] != "MOLFILE"} {
														set st [append st "$dir/[lindex $text 1]"]
														set linha [gets $inputfile]
														set linha [string trim $linha " "]
														if {[lindex $text 0] != "PARMFILE"} {
																set st [append st "$dir/[lindex $text 1]"]
														}
												} elseif {[lindex $text 0] != "PARMFILE"} {
														set st [append st "$dir/[lindex $text 1]"]
												}
												$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld insert end $linha
												$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld configure -state disable
										}
										$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb end $st
										$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb configure -state disable
										set linha [string trim $linha " "]
									}
                                    set linha [gets $inputfile]
                                    set linha [string trim $linha " "]
                                }
                                $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.cmb configure -state disable
                                $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.butadd configure -state disable
                                $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.butrm configure -state disable
                            }
                            "##MMPBSA Parameters" {
                                set linha [gets $inputfile]
                                while {$linha != "END"} {
									if {[string index $linha 0] != "!"} {
										set linha [split $linha " "]
										if {[lsearch $linha "NFREQ"] != -1} {
											set i 0
											while {$i < [llength $linha]} {
												if {[lindex $linha $i] != "NFREQ" && [string trim [lindex $linha $i] " "] != ""} {
													$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spfreq set [lindex $linha $i]
													$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spfreq set [lindex $linha $i]
													$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spfreq configure -state disable
													break
												}
											incr i
											}
										} elseif {[lsearch $linha "NSTART"] != -1} {
											set i 0
											while {$i < [llength $linha]} {
												if {[lindex $linha $i] != "NSTART" && [string trim [lindex $linha $i] " "] != ""} {
													$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstart set [lindex $linha $i]
													$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstart configure -state disable
													break
												}
											incr i
											}
										} elseif {[lsearch $linha "NSTOP"] != -1} {
											set i 0
											while {$i < [llength $linha]} {
												if {[lindex $linha $i] != "NSTOP" && [string trim [lindex $linha $i] " "] != ""} {
													$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstop set [lindex $linha $i]
													$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstop configure -state disable
													break
												}
											incr i
											}
										} elseif {[lsearch $linha "TRAJECTORY"] != -1} {
											set i 0
											while {$i < [llength $linha]} {
												if {[lindex $linha $i] != "TRAJECTORY" && [string trim [lindex $linha $i] " "] != ""} {
													$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.labt.lbload configure -text [lindex $linha $i]
													$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.labt.btload configure -state disable
													set ASM_GUI::load 1
													$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 tab 1 -state disable
													$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 tab 0 -state disable
													$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 tab 2 -state normal
													$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 select 2
													$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.frch.mkload.rdbuload invoke
													break
												}
												incr i
											}
										}
									}
                                    set linha [gets $inputfile]
                                }
                            }

                    }

            }
        set ASM_GUI::ASM_file $file
        close $inputfile
        catch {exec cp -r [molinfo [molinfo top] get filename] [file dirname $file]}
        $ASM_GUI::topGui.nb1.f1.btrunload.btsave configure -state normal
        $ASM_GUI::topGui.frfile.enfile insert end $file
        return 1
    } else {
        return 0
    }


}

proc ASM_GUI::saveFile {} {
	set types {
    	    {{ASM}       {.asm}        }
        }
	set fil [tk_getSaveFile -filetypes $types -defaultextension ".asm"]
	if {$fil != ""} {

			set name_aux [split $fil "/"]
			set name_aux [split $fil "."]
			if {[llength $name_aux] ==1} {
				set fil "$fil.asm"

			}

		array set chain_aux ""
		set ligand ""
		set receptor ""
        	set asm_file [open $fil w+]
			puts $asm_file "#######################################################################################################
		CompASM version $ASM_GUI::version Input File

This file is generated by the ASM Graphical User Interface (GUI).
To avoid input file errors, the usage of the GUI is advised.

To comment in this file :
All comments inside instruction fields (e.g. ##Protein ... END) must have this
character ! before the comment line.

Outside the instruction fields, the comments don't need to be preceded by the characters,
but be careful to NOT duplicate either the finalizer 'END' or the instruction initializer (e.g. ##Protein).

All files path (excluding the trajectory file path) are pointed to the folder inside the folder
containing the input file (i.e. 1VFB_teste.asm).

Instructions Fields:

Protein:
	Set protein path to be loaded starting from the current folder.
	e.g. ##PROTEIN
	     1VFB_teste/LIB/1VFB_ASM.pdb == ~/<Folder containing input file>/1VFB_teste/LIB/1VFB_ASM.pdb


Interface radii:
	Value used to select and represent the interface between ligand and receptor in VMD. GUI
	information only.	     END


Mutations:
	Mutations to be performed. It is Possible to perform multiple
	mutations in each structure (same dielectric constant).
	Syntax:
		Single mutations: NumberOfResidue_NumberOfChain
   		Multiple mutations: NumberOfResidue_NumberOfChain,NumberOfResidue_NumberOfChain,...

LIGAND and RECEPTOR:
	Chain number of ligand or receptor

Minimization_Dynamic Parameters:
	Sander keywords to perform Molecular Minimization (imin= 1) or Dynamics Simulation (imin= 0).
	More informations about the keywords in: http://ambermd.org/.
	Syntax:
		Keyword='space'value

Starting Minimization Parameters:
	Only require if Molecular Dynamics Simulation is intended to perfumed
	Syntax:
		Keyword='space'value

Warming Dynamic Parameters:
	Only require if Molecular Dynamics Simulation is intended to perfumed
	Syntax:
		Keyword='space'value

MMPBSA Parameters:
	If it is intended to perform Minimization or Molecular Dynamics Simulation it is only required
	the frequency of structures from the trajectory.
	Syntax:
		NFREQ'space'value
		NSTART'space'value*
		NSTOP'space'value*
		NFREQ'space'value*
		TRAJECTORY'space'CompleteFilePath*1
	*If it is intended to load a trajectory, it is required the frequency, the starting structure
	and the final structure, and the path of the trajectory IN THIS ORDER.
	1 If the machine type is cluster, only the name of the trajectory file is require, and this
	  file must be included in the sent folder (see manual)

FORCE FIELDS:
	Force fields to be applied in amber tleap tool. If the force field is an Amber* default one,
	it is only required the name of it (e.g. leaprc.ff03). If is intended to use another one, it
	is required the path of the force field.

MD Convergence Linear Model Values:
		Values of linear model (rounded to decimal number) to be used in the stabilization evaluation in each MD iteration
		Straight slope (B) (x 10^3)
		Correlation Coefficient (R2)
		Standard Deviation (STDV)

		Syntax:
				B= value (0 to 1)
				R= value (0 to 1)
				STDV= value (0 to 1)

####################################################################################################\n\n"
        	puts $asm_file "##PROTEIN"
        	set moltop [molinfo top]
        	set prot [molinfo $moltop get filename]
        	set prot [split $prot "/"]
        	set prot [lindex $prot end]
        	set dir [file dirname $fil]

		set name [split $fil "/"]
		set name [file rootname [lindex $name end]]
		if {[file exists $dir/$name/LIB] != 1} {
			file mkdir $dir/$name/LIB
		}
		if {[file exists $dir/$name/LIB/$prot] == 1} {
			set prot [file rootname $prot]
			set un "_ASM"
			set prot "$prot$un.pdb"
		}
        	puts $asm_file "$name/LIB/$prot"
        	puts $asm_file "END"

        	puts $asm_file "##OUT"
        	puts $asm_file ""
        	puts $asm_file "END"
		set i 0

		set ligand [lappend ligand "##LIGAND"]
		set receptor [lappend receptor "##RECEPTOR"]
		set i 0
		set int 0
		while {$i < [array size ASM_GUI::checklig_rec]} {
			set chain [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $i,1 -text]
			if {[string length $chain] > 1} {
				set chain [expr $i +1]
				set int 1
			}
			if {[string is integer $chain] == 1} {
				if {$ASM_GUI::checklig_rec($i) == 1} {
					set ligand [lappend ligand $chain]
				} else {
					set receptor [lappend receptor $chain]
				}
				set int 0
			} else {
				if {[info exists chain_aux($chain)] != 1} {
					if {$ASM_GUI::checklig_rec($i) == 1} {
						if {[string length $chain] > 1 } {
							set het [lindex $ASM_GUI::heat_val($chain) 0]
							set het [string trim [string index $het 21] " "]
							set ligand [lappend ligand $het]
						} else {
        						for {set h 1} {$h <= [expr [array size ASM_GUI::pdb]/4]} {incr h} {
        							if {[string trim $ASM_GUI::pdb($h,3) " "]== $chain && [lsearch $ligand $ASM_GUI::pdb($h,2)] == -1} {
        								set ligand [lappend ligand $ASM_GUI::pdb($h,2)]
        								break
        							}
        						}
						}
					} else {
					    if {[string length $chain] > 1 } {
						    set het [lindex $ASM_GUI::heat_val($chain) 0]
						    set het [string trim [string index $het 21] " "]
						    set receptor [lappend receptor $het]
					    } else {
						    for {set h 1} {$h <= [expr [array size ASM_GUI::pdb]/4]} {incr h} {
							    if {[string trim $ASM_GUI::pdb($h,3) " "]== $chain && [lsearch $ligand $ASM_GUI::pdb($h,2)] == -1} {
								    set receptor [lappend receptor $ASM_GUI::pdb($h,2)]
								    break
							    }
						    }
					    }

					}
				} else {
					if {$ASM_GUI::checklig_rec($i) == 1} {
						set ligand [lappend ligand $chain_aux($chain)]
					} else {
						set receptor [lappend receptor $chain_aux($chain)]
					}
				}
			}
			incr i
		}
		set i 0
		while {[lindex $ligand $i] != ""} {
			puts $asm_file [lindex $ligand $i]
			incr i
		}
		puts $asm_file "END"
		set i 0
		while {[lindex $receptor $i] != ""} {
			puts $asm_file [lindex $receptor $i]
			incr i
		}
		puts $asm_file "END"

		puts $asm_file "##Interface radii"
		puts $asm_file [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.frmradi.spinradii get]
		puts $asm_file "END"

	puts $asm_file "##MUTATIONS"
		set un "_"
		set i 0
		while {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb size]} {
			set mut [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb cellcget $i,1 -text]
			set j 0
			set st ""
			while {[lindex $mut $j] != ""} {
				set mut_aux ""
				set mut_aux [string trim [lindex $mut $j] " "]
				set mut_aux [split $mut_aux "_"]
				set resname [string trim [lindex $mut_aux 0] " "]
				set resnum [string trim [lindex $mut_aux 1] " "]
				set chain [string trim [lindex $mut_aux 2] " "]
				if {[string is integer $chain] == 0} {
					set resnum [string trim [lindex $mut_aux 1] " "]
					for {set h 1} {$h <= [expr [array size ASM_GUI::pdb]/4]} {incr h} {
						if {$ASM_GUI::pdb($h,0) ==$resname && $ASM_GUI::pdb($h,1)== $resnum && $ASM_GUI::pdb($h,3)== $chain} {
							if {$st != ""} {
								set st [append st ","]
							}

							set st [append st "$h$un$ASM_GUI::pdb($h,2)"]
							set chain_aux($chain) $ASM_GUI::pdb($h,2)
							break
						}
					}

				} else {
					if {$st != ""} {
						set st [append st ","]
					}
					set st [append st "$resnum$un$chain"]
				}

				incr j
			}
			puts $asm_file $st
			set st ""
			incr i
		}
		puts $asm_file "END"



    if {$ASM_GUI::load != 1} {
        puts $asm_file "##Minimization_Dynamic Parameters"
        if {$ASM_GUI::run== 0} {
          puts $asm_file "imin= 1"
          puts $asm_file "ntx= 1"
          puts $asm_file "ntpr= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spstp get]"
          puts $asm_file "maxcyc= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spmaxn get]"
          puts $asm_file "ntmin= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.splim get]"
          puts $asm_file "ntb= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntb get]"
          puts $asm_file "igb= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spgb get]"
          puts $asm_file "scee= 1.2"
          puts $asm_file "cut= 16.0"
          puts $asm_file "ntc= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntc get]"
          puts $asm_file "ntf= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntf get]"
          puts $asm_file "END"
        } else {
          puts $asm_file "imin= 0"
          puts $asm_file "ntpr= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntpr get]"
          puts $asm_file "ntwr= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwr get]"
          puts $asm_file "ntwx= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwx get]"
          puts $asm_file "ntt= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntt get]"
          puts $asm_file "nstlim= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.splim get]"
          puts $asm_file "temp0= 300.0"
          puts $asm_file "tempi= 300.0"
          puts $asm_file "tol= 0.000001"
          puts $asm_file "dt= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.sptmstp get]"
          puts $asm_file "ntx= 5"
          puts $asm_file "irest= 1"
          puts $asm_file "igb= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spgb get]"
          puts $asm_file "nrespa= 2"
          puts $asm_file "ntb= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntb get]"
          puts $asm_file "scee= 1.2"
          puts $asm_file "cut= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spcut get]"
          puts $asm_file "ibelly= 0"
          puts $asm_file "gamma_ln= 1.0"
          puts $asm_file "ntc= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntc get]"
          puts $asm_file "ntf= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntf get]"
          puts $asm_file "END"
        }


        if {$ASM_GUI::run== 1} {
          puts $asm_file "##Starting Minimization Parameters"
          puts $asm_file "imin= 1"
          puts $asm_file "ntx= 1"
          puts $asm_file "ntpr= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spstp get]"
          puts $asm_file "maxcyc= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spmaxn get]"
          puts $asm_file "ntmin= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.splim get]"
          puts $asm_file "ntb= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntb get]"
          puts $asm_file "igb= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spgb get]"
          puts $asm_file "scee= 1.2"
          puts $asm_file "cut= 16.0"
          puts $asm_file "ntc= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntc get]"
          puts $asm_file "ntf= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntf get]"
          puts $asm_file "END"

          puts $asm_file "##Warming Dynamic Parameters"
          puts $asm_file "imin= 0"
          puts $asm_file "ntx= 1"
          puts $asm_file "ntpr= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntpr get]"
          puts $asm_file "ntwr= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwr get]"
          puts $asm_file "ntwx= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwx get]"
          puts $asm_file "igb= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spgb get]"
          puts $asm_file "nrespa= 2"
          puts $asm_file "ntb= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntb get]"
          puts $asm_file "scee= 1.2"
          puts $asm_file "cut= 16.0"
          puts $asm_file "ibelly= 0"
          puts $asm_file "ntt= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntt get]"
          puts $asm_file "gamma_ln= 1.0"
          puts $asm_file "ntc= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntc get]"
          puts $asm_file "ntf= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntf get]"
          puts $asm_file "dt=[$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.sptmstp get]"
          puts $asm_file "nstlim= 1000000"
          puts $asm_file "temp0= 300.0"
          puts $asm_file "tempi= 0.0"
          puts $asm_file "tol= 0.000001"
          puts $asm_file "END"
					puts $asm_file "##MD Linear Model Values"
					puts $asm_file "B= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.frmStb.spslp get]"
					puts $asm_file "R= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.frmStb.spcoe get]"
					puts $asm_file "STDV= [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.frmStb.spstdv get]"
					puts $asm_file "END"
        }
    }

    if {$ASM_GUI::load == 1} {
        puts $asm_file "##MMPBSA Parameters"
        puts $asm_file "NSTART  [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstart get]"
        puts $asm_file "NSTOP  [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstop get]"
				puts $asm_file "NFREQ  [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spfreq get]"
        puts $asm_file "TRAJECTORY  [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.labt.lbload cget -text]"
				puts $asm_file "END"
    } elseif {$ASM_GUI::run== 1} {
        puts $asm_file "##MMPBSA Parameters"
        puts $asm_file "NFREQ  [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spfreq get]"
        puts $asm_file "END"
		}

		if {[$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld size] != 0} {
			set size [$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld size]

			set name [split $fil "/"]
			set name [file rootname [lindex $name end]]
			set i 0

			if {[file exists $dir/$name/LIB] != 1} {
					file mkdir $dir/$name/LIB
			}
			set i 0
			while {$i < $size} {
				if {$i==0} {
					puts $asm_file "##FORCE FIELDS"
				}
				set size [split [$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld get $i] "/"]
				if {[llength $size]> 1} {
					set text [split [$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld get $i] "/" ]
					set text [lindex $text end]
					puts $asm_file "$name/LIB/$text"
					catch {exec cp -r [$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld get $i] $dir/$name/LIB} a
				 } else {
					 if {[$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld get $i] != ""} {
						 puts $asm_file [$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld get $i]
					 }
				 }
				incr i
			}
			if {$i != 0} {
				puts $asm_file "END"
			}

		}

		if {[$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb size] != 0} {
        puts $asm_file "##HETAOMS Parameters"

        set name [split $fil "/"]
        set name [file rootname [lindex $name end]]
        set i 0
        set size [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb size]
        if {[file exists $dir/$name]!=1} {
        		file mkdir $dir/$name
        }
        while {$i < $size} {
            set resname [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb cellcget $i,0 -text]
            set resname [lindex [split $resname "_"] 0]
            puts $asm_file "RESNAME $resname"
            if {[string trim [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb cellcget $i,1 -text] " "] != ""} {
                set text [split [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb cellcget $i,1 -text] "/" ]
                set text [lindex $text end]
                puts $asm_file "MOLFILE $name/LIB/$text"
                catch {exec cp -r [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb cellcget $i,1 -text] $dir/$name/LIB} a
            }
            if {[string trim  [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb cellcget $i,2 -text] " "] != ""} {
                set text [split [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb cellcget $i,2 -text] "/" ]
                set text [lindex $text end]
                puts $asm_file "PARMFILE $name/LIB/$text"
                catch {exec cp -r [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb cellcget $i,2 -text] $dir/$name/LIB} a
            }
            incr i
        }
			if {$i != 0} {
				puts $asm_file "END"
			}
		}



    close $asm_file

    set pdb_name [molinfo $moltop get filename]
    set name [split $pdb_name "/"]

	set fld_name [file rootname [lindex $name end]]
    if {[file exists "$dir/[file rootname [lindex [split $fil "/"] end]]/LIB/"] != 1} {
        file mkdir $dir/[file rootname [lindex [split $fil "/"] end]]/LIB/
    }
	set pdb "$dir/[file rootname [lindex [split $fil "/"] end]]/LIB/$prot"



    set file [open $pdb w+]
    set fil_del [open $pdb_name r+]
    while {[eof $fil_del] != 1} {
        set linha [gets $fil_del]
        if {[string range $linha 0 5] != "HETATM"} {
            puts $file $linha
        } else {
            break
        }
    }
    close $fil_del
	if {[llength $ASM_GUI::heat_add] > 0} {

		set i 0
		while {$i < [llength $ASM_GUI::heat_add]} {
			set j 0
			while {$j <= [llength $ASM_GUI::heat_val([lindex $ASM_GUI::heat_add $i]) ]} {
				set linha [lindex $ASM_GUI::heat_val([lindex $ASM_GUI::heat_add $i]) $j]
				set st1 [string range $linha 0 20]
								if {$st1 != ""} {
									set st2 [string range $linha 22 end]
									puts $file "$st1 $st2"
								}
								incr j

			}
			puts $file "TER"
			incr i
		}

	}
    close $file
		set ASM_GUI::ASM_file ""
		set ASM_GUI::ASM_file $fil


		$ASM_GUI::topGui.frfile.enfile delete 0 end
		$ASM_GUI::topGui.frfile.enfile insert end $fil
		if {$::tcl_platform(os) == "Darwin" || $::tcl_platform(os) == "Linux"} {
      $ASM_GUI::topGui.nb1.f1.btrunload.btrun configure -state normal
    }

	}
}

proc ASM_GUI::unLock {} {
    ASM_GUI::resetOut
    ASM_GUI::clearSlect
    #set ASM_GUI::next 2

    set frame $ASM_GUI::topGui.nb1.f1
    $frame.nb2.f2.fp.frtbl.tb configure -state normal
    $frame.nb2.f2.fp.muttbl.tb configure -state normal
    $frame.nb2.f2.fp.frtbl.frmradi.spinradii configure -state normal
    $frame.nb2.f1.flig_rec.addrm.cmb configure -state normal
    $frame.nb2.f1.flig_rec.addrm.butadd configure -state normal
    $frame.nb2.f1.flig_rec.addrm.butrm configure -state normal
    $frame.nb2.f1.btnext configure -state normal
    $frame.nb2.f2.fp.btnext configure -state normal
    $frame.nb2.f4.fp.frleap.cmb configure -state normal
    $frame.nb2.f4.fp.frmlist.lffld configure -state normal
    $frame.nb2.f4.fp.frmbutt.butadd configure -state normal
    $frame.nb2.f4.fp.frmbutt.butdel configure -state normal
    $frame.nb2.f3.fp.frch.mkmin_dyn.rdbuper configure -state normal
    $frame.nb2.f3.fp.frch.mkmin_dyn.frm_min_dyn.rbmin configure -state normal
    $frame.nb2.f3.fp.frch.mkmin_dyn.frm_min_dyn.rbdyn configure -state normal
    $frame.nb2.f3.fp.frch.mkload.rdbuload configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f2.fp.spntwr configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f2.fp.spntwx configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f2.fp.splim configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f2.fp.spntt configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f1.fp.spgb configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f1.fp.spcut configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f1.fp.spntb configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f1.fp.spntc configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f1.fp.spntf configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f2.fp.sptmstp configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f1.fp.spstp configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f1.fp.spmaxn configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f1.fp.splim configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f1.fp.spgb configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f1.fp.spntc configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f1.fp.spntc configure -state normal
    $frame.nb2.f1.flig_rec.addrm.cmb configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f2.fp.spfreq configure -state normal
    $frame.nb2.f3.fp.fnt.nb2.f2.fp.spntpr configure -state normal
	$frame.nb2.f3.fp.fnt.nb2.f3.fp.labt.lbload configure -state normal
	$frame.nb2.f3.fp.fnt.nb2.f3.fp.labt.btload configure -state normal
	$frame.nb2.f3.fp.fnt.nb2.f2.frmStb.spslp configure -state normal
	 $frame.nb2.f3.fp.fnt.nb2.f2.frmStb.spcoe configure -state normal
	 $frame.nb2.f3.fp.fnt.nb2.f2.frmStb.spstdv configure -state normal

		if {$ASM_GUI::load == 1} {
				$frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstop configure -state normal
				$frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstart configure -state normal
				$frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spfreq configure -state normal
		}

    set i 0
    while {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size]} {
        $ASM_GUI::rdbut($i,3) configure -state normal
        $ASM_GUI::rdbut($i,4) configure -state normal
        $ASM_GUI::index_cmb($i,0) configure -state normal
        incr i
    }
    set i 0
    while {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb size]} {
        $ASM_GUI::rdbutMut($i) configure -state normal
        incr i
    }
	$ASM_GUI::topGui.nb1 tab 1 -state disable
}

proc ASM_GUI::spinNwtxCheck {} {
	set ntwx [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwx get]
	set nstlim [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.splim get]
	if {$ntwx > [expr $nstlim/10]} {
		$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwx set [expr $nstlim/10]
	} else {
        	if {[$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spfreq get] >  [expr [expr $nstlim/10]/$ntwx]} {
        		$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spfreq set  [expr [expr $nstlim/10]/$ntwx]
        	}
	}
	set lim [expr [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.splim get]/10]
	set ntwx [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwx get]
	set freq [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spfreq get]
	$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spnumst configure -text "[expr round([expr [expr $lim/$ntwx]/$freq])]"
}

proc ASM_GUI::spinFreqCheck {} {
	set ntwx [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwx get]
	set nstlim [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.splim get]
	if {[$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spfreq get] > [expr [expr $nstlim/10]/$ntwx]} {
		while {[$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spfreq get] <=  [expr [expr $nstlim/10]/$ntwx]} {
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spfreq $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.splim invoke buttondown

		}
	}
	set lim [expr [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.splim get]/10]
	set ntwx [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwx get]
	set freq [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spfreq get]
	$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spnumst configure -text "[expr round([expr [expr $lim/$ntwx]/$freq]) +1]"
}

proc ASM_GUI::save_viewpoint {view_num} {
   global viewpoints
   foreach mol [molinfo list] {
      set viewpoints([molinfo $mol get name],0) [molinfo $mol get rotate_matrix]
      set viewpoints([molinfo $mol get name],1) [molinfo $mol get center_matrix]
      set viewpoints([molinfo $mol get name],2) [molinfo $mol get scale_matrix]
      set viewpoints([molinfo $mol get name],3) [molinfo $mol get global_matrix]

   }
}

proc ASM_GUI::restore_viewpoint {view_num} {
   global viewpoints
   foreach mol [molinfo list] {
      if [info exists viewpoints([molinfo $mol get name],0)] {
	 molinfo $mol set rotate_matrix   $viewpoints([molinfo $mol get name],0)
	      molinfo $mol set center_matrix   $viewpoints([molinfo $mol get name],1)
	      molinfo $mol set scale_matrix   $viewpoints([molinfo $mol get name],2)
	      molinfo $mol set global_matrix   $viewpoints([molinfo $mol get name],3)
      }
   }
}

proc ASM_GUI::addFfld {} {
	set sel [$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frleap.cmb get]
	if {$sel != "" && $sel != "other..."} {
		$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld insert end $sel
	}


}

proc ASM_GUI::delFfld {} {
	set sel [$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld curselection]
	if {$sel != ""} {
		set i 0
		while {$i < [llength $sel]} {
			$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld delete [expr [lindex $sel $i] -$i]
			incr i

		}
	}
	$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb selection clear 0 end

}

proc ASM_GUI::loadMol {} {
	set moltop [molinfo top]
	set pdb_fil_name [molinfo $moltop get filename]
	set path [file dirname $pdb_fil_name]
	set un "_"
	set suf "ASM"
	set name [split $pdb_fil_name "/"]
	set name [file rootname [lindex $name end]]
	set out [open "$path/ASM_Prot_fil1.pdb" w+]
	set resnamei ""
	set resnumi ""
	set pdb_file [open $pdb_fil_name  r+]
	set resname_i ""
	set resnum_i ""
	array unset ::ASM_GUI::heat_val
	array set ::ASM_GUI::heat_val ""
	set ASM_GUI::heat_add ""
	set linha_i ""
        set new 0

	while {[eof $pdb_file] != 1} {
            if {$new == 0} {
		set linha [gets $pdb_file]
            }
            set new 0
            if {[string range $linha 0 5]=="ATOM  " || [string trim [string range $linha 0 2] " "]=="TER"} {
                    if {[string trim $linha " "] != ""} {
                        if {$linha_i != $linha} {
                            puts $out $linha
                        }
                        set linha_i $linha
                    }
            } elseif {[string range $linha 0 5]=="HETATM"} {
                    set resname [string trim [string range $linha 17 19] " "]
                    set resnum [string trim [string range $linha 22 25] " "]
                    set resname_i ""
                    set resnum_i ""
                    if {[lsearch $ASM_GUI::heat_add $resname$un$resnum] == -1} {
                            set un "_"

                            set ASM_GUI::heat_add [lappend ASM_GUI::heat_add $resname$un$resnum]

                            set resnum_i $resnum
                            set resname_i $resname

                            while {$resname == $resname_i && $resnum == $resnum_i && ([string range $linha 0 3] !="ATOM" && [string range $linha 0 2]!="TER")} {
                                    set st1 [string range $linha 0 21]
                                    if {$st1 != ""} {
                                        set st2 [string range $linha 22 end]
										
                                        set ASM_GUI::heat_val($resname$un$resnum) [lappend ASM_GUI::heat_val($resname$un$resnum) "$st1$st2"]
                                        set linha [gets $pdb_file]
                                        set resnum_i $resnum
                                        set resname_i $resname
                                        set resname [string trim [string range $linha 17 19] " "]
                                        set resnum [string trim [string range $linha 22 25] " "]
                                        if {$resname != $resname_i || $resnum != $resnum_i && [string range $linha 0 5]=="HETATM"} {
                                            set new 1
                                        }
                                    }
                            }

                    }
            }
            if {[string trim [string range $linha 0 2] " "]=="END"} {
                    break
            }


	}

	close $pdb_file

	set i 0
	while {$i < [llength $ASM_GUI::heat_add]} {
		if {[lindex $ASM_GUI::heat_add $i] != ""} {

			set resname [lindex $ASM_GUI::heat_add $i]
			set j 0
			while {$j < [llength $ASM_GUI::heat_val($resname)]} {
				puts $out [lindex $ASM_GUI::heat_val($resname) $j]
				incr j
			}
			puts $out "TER"
		}
		incr i
	}
	puts $out "END"
	close $out

	file rename -force "$path/ASM_Prot_fil1.pdb" "$path/$name$un$suf.pdb"
	mol off $moltop
	return "$path/$name$un$suf.pdb"
}

proc ASM_GUI::removeHET {} {
	if { [molinfo [molinfo top] get name] != "ASM_Prot_rep"  } {
		set ASM_GUI::next 0
		ASM_GUI::clearSlect
		mol delete [molinfo top]
		mol on [molinfo top]
		set ASM_GUI::repid  0
		set ASM_GUI::top [molinfo top]
	}
        set tbind [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb curselection]
        set indj 0
        while {$indj < [llength $tbind]} {
            if {$ASM_GUI::heat_add != ""} {
                    set res [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget [expr [lindex $tbind $indj] - $indj],1 -text]
                    set num [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget [expr [lindex $tbind $indj] - $indj],2 -text]
                    set num [lindex [split $num "-"] 0]
                    set un "_"
                    if {[lsearch $ASM_GUI::heat_add $res$un$num] != -1} {
                            $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.cmb set $res$un$num
                    }
            }

            set resselec [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.cmb get]

            set size [expr [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size] -1]
            set het [lsearch [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.cmb cget -values] $resselec]
            set het [expr $het + [expr $size - [llength $ASM_GUI::heat_add]] +1]
            set num [split $resselec "_"]
            set index $het
            set res [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb columncget 1 -text]
            set num [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb columncget 2 -text]
            set un "_"
            array set aux ""
            array set aux_pv ""
            array set aux_rd ""
            array set aux_cmb ""
            array set aux_onoff ""
            set i 0
            set ind -1
            while {$i < [llength $res]} {
                set num_aux [split [lindex $num $i] "-"]
                set com "[lindex $res $i]_[lindex $num_aux 0]"
                if {"[lindex $res $i]_[lindex $num_aux 0]" == $resselec} {
                    set ind $i
                    break
                }
                set residue "[lindex $res $i]_[lindex $num_aux 0]"
                incr i
            }
            if {$ind != -1} {
                    if {[molinfo [molinfo top] get name] == "ASM_Prot_rep"  } {
                        mol showrep [molinfo top] $index off
                        set ASM_GUI::onoff($residue,1) 0
                    }
                    $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb delete $ind
                    incr ASM_GUI::nchain -1
                    set i 0
                    set j 0
                    while {$i < [molinfo [molinfo top] get numreps] } {
                            if {$i != $ind} {
                                    if {[info exists ASM_GUI::checklig_rec($i)] == 1} {
                                            set aux($j) $ASM_GUI::checklig_rec($i)
                                            $ASM_GUI::rdbut($i,3) configure -variable ASM_GUI::checklig_rec($j)
                                            $ASM_GUI::rdbut($i,4) configure -variable ASM_GUI::checklig_rec($j)
                                            set aux_rd($j,3) $ASM_GUI::rdbut($i,3)
                                            set aux_rd($j,4) $ASM_GUI::rdbut($i,4)
                                            if {[info exists  ASM_GUI::checklig_rec_pv($i)] && $i != $ind} {
                                                    set aux_pv($j) $ASM_GUI::checklig_rec_pv($i)
                                            }
                                    }
                                    if {[info exists ASM_GUI::index_cmb($i,0)] == 1} {
                                            set aux_cmb($j,0) $ASM_GUI::index_cmb($i,0)
                                            set aux_cmb($j,1) $ASM_GUI::index_cmb($i,1)

                                    }
                                    incr j
                            }
                            incr i
                    }
            }


            if {[array size aux]!= 0} {
                    array unset ::ASM_GUI::checklig_rec
                    array set ::ASM_GUI::checklig_rec ""
                    array unset ::ASM_GUI::rdbut
                    array set ::ASM_GUI::rdbut ""
                    array set ::ASM_GUI::checklig_rec [array get aux]
                    array set ::ASM_GUI::rdbut [array get aux_rd]
                    array unset aux
                    if {[array size aux_pv]!= 0} {
                            array set ASM_GUI::checklig_rec_pv ""
                            array set ASM_GUI::checklig_rec [array get aux_pv]
                            array set ASM_GUI::rdbut [array get aux_rd]
                            array unset aux_pv
                    }
                    ASM_GUI::check

            }
            if {[array size aux_cmb]!= 0} {
                    array unset ::ASM_GUI::index_cmb
                    array set ::ASM_GUI::index_cmb ""
                    array set ::ASM_GUI::index_cmb [array get aux_cmb]
            }

            if {[lsearch $ASM_GUI::heat_add $resselec] != -1} {
                    set lind [lsearch $ASM_GUI::heat_add $resselec]
                    set i 0
                    set aux_het ""
                    while {$i < [llength $ASM_GUI::heat_add]} {
                            if {$i != $lind} {
                                    set aux_het [lappend aux_het [lindex $ASM_GUI::heat_add $i]]
                            }
                            incr i
                    }
                    set ASM_GUI::heat_add $aux_het
                    set aux_het ""
            }

            $ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frload.cmb set ""
            set list [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb columncget 0 -text]
            $ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entmol delete 0 end
            $ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entfrcmod delete 0 end
            if {[lsearch $list $resselec] != -1} {
                    $ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb delete [lsearch $list $resselec]
            }
            incr indj
        }
}

proc ASM_GUI::addHET {} {
	if { [molinfo [molinfo top] get name] != "ASM_Prot_rep"  } {
		set ASM_GUI::next 0
		ASM_GUI::clearSlect
		mol delete [molinfo top]
		mol on [molinfo top]
		set ASM_GUI::repid 0
		set ASM_GUI::top [molinfo top]
	}
	set ind [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size]
	set resselec [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.cmb get]
        set num [split $resselec "_"]
	set size [expr [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size] -1]
        set het [lsearch [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.cmb cget -values] $resselec]
        set het [expr $het + [expr $size - [llength $ASM_GUI::heat_add]] ]
	set index $het
	set res [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb columncget 1 -text]
        set num [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb columncget 2 -text]
	set resselec [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.cmb get]
	set i 0
        set ind -1
        while {$i < [llength $res]} {
            set num_aux [split [lindex $num $i] "-"]
            set com "[lindex $res $i]_[lindex $num_aux 0]"
            if {"[lindex $res $i]_[lindex $num_aux 0]" == $resselec} {
                set ind $i
                break
            }
            set residue "[lindex $res $i]_[lindex $num_aux 0]"
            incr i
        }
	if {$ind == -1} {

		if {$ind == -1} {
                    set het [lsearch $ASM_GUI::heat_add $resselec]
                    set het [expr $het + [expr $size - [llength $ASM_GUI::heat_add]] ]
                    set pdbHET [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.cmb cget -values]
                    set pdbHET [split $pdbHET " "]
                    set pos 0
                    set i 0
                    while {$i < [llength $ASM_GUI::heat_add]} {
                            set het_aux [lsearch $ASM_GUI::heat_add [lindex $ASM_GUI::heat_add $i]]
                            set het_aux [expr $het + [expr $size - [llength $ASM_GUI::heat_add]] ]
                            if {$het_aux >= $het} {
                                    break
                            }
                            incr i
                    }
                    set pos $i
                    incr $i
                    if {$i != -1} {
                            set list_aux ""
                            set j 0
                            while {$j <= [llength $ASM_GUI::heat_add]} {
                                    if {$j == $i} {
                                            set list_aux [lappend list_aux $resselec]
                                            if {$j != [llength $ASM_GUI::heat_add] && [lindex $ASM_GUI::heat_add  $j] != ""} {
                                                    set list_aux [lappend list_aux [lindex $ASM_GUI::heat_add  $j]]
                                            }


                                    } else {
                                            if {[lindex $ASM_GUI::heat_add  $j] != ""} {
                                                    set list_aux [lappend list_aux [lindex $ASM_GUI::heat_add  $j]]

                                            }
                                    }
                                    incr j
                            }
                            set ASM_GUI::heat_add $list_aux
                            set list_aux ""
                    } else {
                            set list_aux $ASM_GUI::heat_add
                            set ASM_GUI::heat_add ""
                            set ASM_GUI::heat_add [lappend ASM_GUI::heat_add $resselec]
                            set ASM_GUI::heat_add [lappend ASM_GUI::heat_add $list_aux]
                            set list_aux ""
                    }

        	}
		set resnum [lindex $ASM_GUI::heat_val($resselec) 0]
		set resnum [string trim [string range $resnum 22 25] " "]
		set un "-"
		if {[string length $resselec] > 1} {
				set resselec [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.cmb get]
				set het [lsearch [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.cmb cget -values] $resselec]
				set het [expr $het + [expr $size - [llength $ASM_GUI::heat_add]] +1]
				set size [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size]
				set hettotal [llength $ASM_GUI::heat_add]
				set index [expr $het +1]
				set pos [expr $het +1]
				set name [split $resselec "_"]
				$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb insert $pos "{} [lindex $name 0] {$resnum$un$resnum}"
				$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellconfigure "$pos,0" -background "#[ASM_GUI::rgbtoHEX [colorinfo rgb [expr $index +2]]]"
				if {[molinfo [molinfo top] get name] == "ASM_Prot_rep" } {
					mol showrep [molinfo top] $index on
					set ASM_GUI::onoff($resselec,1) 0
					mol modcolor $index [molinfo top] "ColorId [expr $index +2]"
				}

		} else {
			set res [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb columncget 2 -text]
			set res [split $res "-"]
			ASM_GUI::subUnits $res 1 $ASM_GUI::top $ind
			set pos [expr [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size] -1]
		}
		if {[string length $resselec] > 1} {
			array unset aux
			array unset aux_cmb
			array unset aux_onoff
			array unset aux_pv
			array unset aux_rd
			array set aux ""
			array set aux_pv ""
			array set aux_rd ""
			array set aux_cmb ""
			array set aux_onoff ""
			set i 0
			set j 0
			if {[expr $pos +1] < [molinfo [molinfo top] get numreps]} {
        			while {$i < [molinfo [molinfo top] get numreps]} {
        				if {[info exists  ASM_GUI::checklig_rec($i)] == 1} {
        					if {[expr [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size] -1] != $pos && $i == $pos} {
							set aux($j) -1
        						incr j
        					}
						$ASM_GUI::rdbut($i,3) configure -variable ASM_GUI::checklig_rec($j)
						$ASM_GUI::rdbut($i,4) configure -variable ASM_GUI::checklig_rec($j)
						set aux($j) $ASM_GUI::checklig_rec($i)
						set aux_rd($j,3) $ASM_GUI::rdbut($i,3)
						set aux_rd($j,4) $ASM_GUI::rdbut($i,4)
						if {[info exists ASM_GUI::checklig_rec_pv($i)]} {
							set aux_pv($j) $ASM_GUI::checklig_rec_pv($i)
						}

						 if {[info exists  ASM_GUI::index_cmb($i,0)] == 1} {
							 set aux_cmb($j,0) $ASM_GUI::index_cmb($i,0)
							 set aux_cmb($j,1) $ASM_GUI::index_cmb($i,1)
						 }
						incr j
        				}

        				incr i
        			}
				if {[array size aux]!= 0} {
					array unset ASM_GUI::checklig_rec
					array set ::ASM_GUI::checklig_rec ""
					array unset ::ASM_GUI::rdbut
					array set ::ASM_GUI::rdbut ""
					array unset ASM_GUI::index_cmb
					array set ::ASM_GUI::index_cmb ""
					array set ::ASM_GUI::checklig_rec [array get aux]
					array set ::ASM_GUI::rdbut [array get aux_rd]
					array set ::ASM_GUI::index_cmb [array get aux_cmb]
					array unset aux
					if {[array size aux_pv]!= 0} {
						array unset ASM_GUI::checklig_rec_pv
						array set ::ASM_GUI::checklig_rec_pv ""
						array set ASM_GUI::checklig_rec [array get aux_pv]
						array set ASM_GUI::rdbut [array get aux_rd]
						array unset aux_pv
					}

				}

        		}

		}

		if {$pos != ""} {
			$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellconfigure $pos,3 -window ASM_GUI::createButton
			$ASM_GUI::rdbut($pos,3) configure -value 1
			$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellconfigure $pos,4 -window ASM_GUI::createButton
			$ASM_GUI::rdbut($pos,4) configure -value 0
			$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellconfigure $pos,5 -window ASM_GUI::createCombo
			if {[array size ASM_GUI::checklig_rec] >0} {
				set ASM_GUI::checklig_rec($pos) -1

			}
			incr ASM_GUI::nchain
			ASM_GUI::check
		}

	}


}

proc ASM_GUI::changeTab {} {
	if {$ASM_GUI::next ==2} {
        	ASM_GUI::clearSlect
        	ASM_GUI::loadMutations
        	set ASM_GUI::next 1
        	set j 0
        	set size [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb size]
        	while {$j < $size} {
        		set val [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb cellcget $j,1 -text]
        		set i 0
        		while {[lindex $val $i]!= ""} {
        			set txt [split [lindex $val $i] "_"]
        			set k 0
        			while {$k < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb size]} {
        				set resname [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $k,0 -text]
        				set resid [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $k,1 -text]
        				set chain [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $k,2 -text]
        				if {[lindex $txt 0] == $resname && [lindex $txt 1] == $resid && [lindex $txt 2] == $chain} {
        					set ASM_GUI::checkmut($k,0) 1
        					ASM_GUI::rowSelection
        					break
        				}
        				incr k
        			}

        			incr i
        		}
        		ASM_GUI::addMutations end 1
        		$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb selection clear 0 end
        		incr j
        	}
        	set i 0
        	while {$i < $size} {
        		$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb selection set 0
        		ASM_GUI::delMutations
        		incr i
        	}
        }
        if {[llength $ASM_GUI::heat_add] != 0} {
						$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frload.cmb configure -values $ASM_GUI::heat_add
						$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb configure -state normal
						$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frmadel.butdel configure -state normal
						$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frmadel.butadd configure -state normal
						$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.bumol configure -state normal
						$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.butfrcmod configure -state normal
						$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frload.cmb configure -state readonly
						$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entmol configure -state normal
						$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entfrcmod configure -state normal
        } else {
        	$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb configure -state disable
        	$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frmadel.butdel configure -state disable
        	$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frmadel.butadd configure -state disable
        	$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.bumol configure -state disable
        	$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.butfrcmod configure -state disable
						$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frload.cmb configure -state disable
						$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entmol configure -state disable
						$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entfrcmod configure -state disable
        }


}

proc ASM_GUI::changeComboLoad {} {
	set resname [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb columncget 0 -text]
	set st [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frload.cmb get]
	set ind [lsearch $resname $st]
	if {$ind != -1} {
		set mol [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb cellcget $ind,1 -text]
		set frcmod [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb cellcget $ind,2 -text]

		$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entmol delete 0 end
		$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entfrcmod delete 0 end

		$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entmol insert end $mol
		$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entfrcmod insert end $frcmod
	} else {
		$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entmol delete 0 end
		$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entfrcmod delete 0 end
	}

}
proc ASM_GUI::changeligrecombo {} {
	set moltop [molinfo top]
	if {[molinfo [molinfo top] get name] == "ASM_Prot_rep" } {
            for {set i 0} {$i <= [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size]} {incr i} {
                    if {[info exist ASM_GUI::index_cmb($i,1)] == 1} {
                            if {$ASM_GUI::index_cmb($i,1) != [$ASM_GUI::index_cmb($i,0) get]} {
                                    set res [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $i,1 -text]
                                            if {[$ASM_GUI::index_cmb($i,0) get] == "Off"} {
                                                    mol showrep $moltop $i off
                                                    set ASM_GUI::onoff($res,1) 0
                                                    $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb rowconfigure $i -foreground red
                                                    set ASM_GUI::index_cmb($i,1) [$ASM_GUI::index_cmb($i,0) get]
                                            } else {
                                                    mol showrep $moltop $i on
                                                    mol modstyle $i $moltop [$ASM_GUI::index_cmb($i,0) get]
                                                    $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb rowconfigure $i -foreground black
                                                    set ASM_GUI::onoff($res,1) 1
                                                    set ASM_GUI::index_cmb($i,1) [$ASM_GUI::index_cmb($i,0) get]
                                            }

                                            break
                            }
                    }
            }
        }
}

proc ASM_GUI::changemutTabRep {} {
    if {[molinfo [molinfo top] get name] != "ASM_Prot_rep" } {
        if {$ASM_GUI::radio_rep == 0 || $ASM_GUI::radio_rep == 1} {
            set i 0
            $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.frmrep.frmcombo.cmbtype set [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbtype get]
            $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.frmrep.frmcombo.cmbmat set [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbmat get]
            while {$i < [expr [llength $ASM_GUI::lig_rep] + [llength $ASM_GUI::rec_rep]]} {
                if {[llength $ASM_GUI::lig_rep] > 1 && $i == 1 && $ASM_GUI::radio_rep == 0} {
                    mol showrep [molinfo top] $i on
                    mol modstyle $i [molinfo top] [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbtype get]
                    mol modmaterial $i [molinfo top] [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbmat get]
                } elseif {[llength $ASM_GUI::lig_rep] == 1 && $i == 0 && $ASM_GUI::radio_rep == 0} {
                      mol showrep [molinfo top] $i on
                    mol modstyle $i [molinfo top] [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbtype get]
                    mol modmaterial $i [molinfo top] [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbmat get]
                } elseif {[llength $ASM_GUI::rec_rep] > 1 && $ASM_GUI::radio_rep == 1} {
                    if {[llength $ASM_GUI::lig_rep] > 1 && $i ==3} {
                        mol showrep [molinfo top] $i on
                        mol modstyle $i [molinfo top] [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbtype get]
                        mol modmaterial $i [molinfo top] [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbmat get]
                    } elseif {[llength $ASM_GUI::lig_rep] == 1 && $i ==2} {
                        mol showrep [molinfo top] $i on
                        mol modstyle $i [molinfo top] [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbtype get]
                        mol modmaterial $i [molinfo top] [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbmat get]
                    }
                } elseif {[llength $ASM_GUI::rec_rep] == 1 && $i == 2 && $ASM_GUI::radio_rep == 1} {
                    mol showrep [molinfo top] $i on
                    mol modstyle $i [molinfo top] [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbtype get]
                    mol modmaterial $i [molinfo top] [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbmat get]
                }

                incr i
            }
        }
    }
}

proc ASM_GUI::outTable {} {
    array unset ::ASM_GUI::out_values
    array set ::ASM_GUI::out_values ""
    set path [file dirname $ASM_GUI::ASM_file]
    set table_mut $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb
    set table_out $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb
    set i 0
    while {$i < [$table_mut size]} {
            $table_out insert end "$i [$table_mut cellcget $i,1  -text]"
            incr i
    }
    set fol [lindex [split [file rootname $ASM_GUI::ASM_file] "/"] end]
    if {[file exists "$path/$fol/ASM.out"] == 1} {
        set file [open "$path/$fol/ASM.out" r+]

        while {[eof $file] != 1} {
            set linha [gets $file]

            if {$linha == "## MMPBSA Procedures check table"} {
                set stop 0
                set list ""
                while {$stop != 2} {
                        set linha [gets $file]
                        if {$linha == [string repeat "=" 70]} {
                                incr stop
                        }
                }
                set linha [gets $file]
                set list [split $linha " "]
                set list [split [lindex $list 1] "\t"]
                array unset fail
                array set fail ""
                while {$linha != [string repeat "=" 70]} {
                    set linha [gets $file]
                    set list [split $linha " "]
                    set list [split [lindex $list 1] "\t"]
                    set i 0
                    set do 1
                    while {$i < [llength $list] && $do != -1} {
                      if {[string trim [lindex $list $i] " "] != "" && $do == 0} {
                           if {[string trim [lindex $list $i] " "] != "Ok" && [string is integer [string trim [lindex $list $i] " "]] != 1} {
                                set fail($name) [string trim [lindex $list $i] " "]
                                set do -1
                           }
                      }
                      if {[string trim [lindex $list $i] " "] != "" && $do == 1} {
                        set name  [string trim [lindex $list $i] " "]
                        set do 0
                      }
                      incr i
                    }
                }

            }


            if {$linha == "## Results table"} {
                set stop 0
                while {$stop != 2} {
                        set linha [gets $file]
                        if {$linha == [string repeat "=" 172]} {
                                incr stop
                        }
                }

                set linha [gets $file]
                set list [split $linha "\t"]
                while {$linha != [string repeat "=" 172]} {
                    set i 0
                    while {$i < [llength $list]} {
                            if {[lindex $list $i] != "" && $i == 0} {
                                    set name [string trim [lindex $list $i] " "]
                            }
                            if { [string trim [lindex $list $i] " "]!= "" && $i != 0} {
                                    set ASM_GUI::out_values($name) [lappend ASM_GUI::out_values($name) [string trim [lindex $list $i] " "]]
                            }
                            incr i
                    }
                    if {$i != 0 } {
                        set mut [string range $name 3 end]
                        set pdbtot_stdv [lindex $ASM_GUI::out_values($name) 8]
                        set pdbtot_stdv [split $pdbtot_stdv " "]
                        $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb cellconfig $mut,2 -text [lindex $pdbtot_stdv 0]
                        $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb cellconfig $mut,3 -text [lindex $pdbtot_stdv 2]
                        $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb cellconfig $mut,4 -text [lindex $ASM_GUI::out_values($name) 9]

                        switch [lindex $ASM_GUI::out_values($name) 9] {
                           "Null Spot" {
                                $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb rowconfig $mut -background yellow
                           }
                           "Warm Spot" {
                                $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb rowconfig $mut -background orange
                           }
                           "Hot Spot" {
                                $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb rowconfig $mut -background red
                           }

                        }

                    }
                    set linha [gets $file]
                    set list [split $linha "\t"]

                }
            }
        }
        close $file
        set text [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb columncget 4 -text]
        set i 0
        while {$i < [llength $text]} {
            if {[string trim [lindex $text $i] " "] == ""} {
                $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb cellconfig $i,2 -text "0000"
                $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb cellconfig $i,3 -text "0000"
                $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb cellconfig $i,4 -text $fail(Mut$i)
                $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb rowconfigure $i -foreground red
                $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb rowconfigure $i -background white
            }
            incr i
        }

    }



}

proc ASM_GUI::creatTable {} {
    if {[$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb sortorder] != "increasing"} {
        tablelist::sortByColumn $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb 0

    }
    if {[winfo exists $ASM_GUI::topGui.c]} {
		destroy $ASM_GUI::topGui.c
    }
    toplevel $ASM_GUI::topGui.c
    wm resizable $ASM_GUI::topGui.c 0 1
    wm title $ASM_GUI::topGui.c "Detailed information window "
    grid columnconfigure $ASM_GUI::topGui.c 0 -weight 1;grid rowconfigure $ASM_GUI::topGui.c 0 -weight 1

    grid [ttk::frame $ASM_GUI::topGui.c.fp] -row 0 -column 0 -sticky news -padx 2 -pady 2
    grid columnconfigure $ASM_GUI::topGui.c.fp 0 -weight 1 ;grid rowconfigure $ASM_GUI::topGui.c.fp 0 -weight 1
    set fro2 $ASM_GUI::topGui.c.fp

    option add *Tablelist.activeStyle       frame
    option add *Tablelist.background        gray98
    option add *Tablelist.stripeBackground  #e0e8f0
    option add *Tablelist.setGrid           yes
    option add *Tablelist.movableColumns    yes
    option add *Tablelist.labelCommand      tablelist::sortByColumn
    tablelist::tablelist $fro2.tb \
          -columns {	0 "Mutation index"	 center
          0 "Residue(s)"	 center
          0 "Type"         center
          0 "ELE" 	 center
          0 "STDV"	 center
          0 "VDW"	         center
          0 "STDV"	 center
          0 "INT"	         center
          0 "STDV"	 center
          0 "GAS"	         center
          0 "STDV"	 center
          0 "PBSUR"	 center
          0 "STDV"	 center
          0 "PBCAL"	 center
          0 "STDV"	 center
          0 "PBSOL"	 center
          0 "STDV"	 center
          0 "PBELE"	 center
          0 "STDV"	 center
          0 "PBTOT"	 center
          0 "STDV"	 center
          0 "NSCA"        center
          0 "Score"	 center} \
        -yscrollcommand [list $fro2.scr1 set] -xscrollcommand [list $fro2.scr2 set] \
        -showseparators 0 -labelrelief groove  -labelbd 1 -selectbackground blue -selectforeground white\
        -foreground black -state normal -selectmode multiple -stretch all -width 0


    $fro2.tb columnconfigure 0 -sortmode real -name "Mutation index"
    $fro2.tb columnconfigure 1 -sortmode dictionary -name "Residue(s)"
    $fro2.tb columnconfigure 2 -sortmode dictionary -name "Type"
    $fro2.tb columnconfigure 3 -sortmode real -name "ELE"
    $fro2.tb columnconfigure 4 -sortmode real -name "STDV"
    $fro2.tb columnconfigure 5 -sortmode real -name "VWD"
    $fro2.tb columnconfigure 6 -sortmode real -name "STDV"
    $fro2.tb columnconfigure 7 -sortmode real -name "INT"
    $fro2.tb columnconfigure 8 -sortmode real -name "STDV"
    $fro2.tb columnconfigure 9 -sortmode real -name "GAS"
    $fro2.tb columnconfigure 10 -sortmode real -name "STDV"
    $fro2.tb columnconfigure 11 -sortmode real -name "PBSUR"
    $fro2.tb columnconfigure 12 -sortmode real -name "STDV"
    $fro2.tb columnconfigure 13 -sortmode real -name "PBCAL"
    $fro2.tb columnconfigure 14 -sortmode real -name "STDV"
    $fro2.tb columnconfigure 15 -sortmode real -name "PBSOL"
    $fro2.tb columnconfigure 16 -sortmode real -name "STDV"
    $fro2.tb columnconfigure 17 -sortmode real -name "PBELE"
    $fro2.tb columnconfigure 18 -sortmode real -name "STDV"
    $fro2.tb columnconfigure 19 -sortmode real -name "PBTOT"
    $fro2.tb columnconfigure 20 -sortmode real -name "STDV"
    $fro2.tb columnconfigure 21 -sortmode real -name "NSCA"
    $fro2.tb columnconfigure 22 -sortmode dictionary -name "Score"

    #$fro2.tb columnconfigure 0 -sortmode dictionary -name "Chain ID"
    grid $fro2.tb -row 0 -column 0 -sticky news
    grid columnconfigure $fro2.tb 0 -weight 2; grid rowconfigure $fro2.tb 1 -weight 1

    ##Scrool_BAr V
    scrollbar $fro2.scr1 -orient vertical -command [list $fro2.tb  yview]
    grid $fro2.scr1 -row 0 -column 1  -sticky ens
    ## Scrool_Bar H
    scrollbar $fro2.scr2 -orient horizontal -command [list $fro2.tb xview]
    grid $fro2.scr2 -row 1 -column 0 -sticky swe

    wm protocol  $ASM_GUI::topGui.c WM_DELETE_WINDOW {
        set ind_list ""
        set id [$ASM_GUI::topGui.c.fp.tb curselection]
        if {[llength [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb columncget 0 -text]] > 0 && $id != ""} {
            set j 0
            while {[lindex $id $j]!= ""} {
                        set mut [$ASM_GUI::topGui.c.fp.tb cellcget [lindex $id $j],0 -text]
                        set all_mut [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb columncget 0 -text]
                        set index [lsearch $all_mut $mut]
                        set ind_list [lappend ind_list $index]
                        incr j
            }
        }
        ASM_GUI::selTable
        set id [$ASM_GUI::topGui.c.fp.tb curselection]
        $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb selection set $ind_list
        wm withdraw $ASM_GUI::topGui.c
    }
    bind [$ASM_GUI::topGui.c.fp.tb bodytag] <ButtonRelease> {
        set ind_list ""
        set id [$ASM_GUI::topGui.c.fp.tb curselection]
        if {[llength [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb columncget 0 -text]] > 0 && $id != ""} {
            set j 0
            while {[lindex $id $j]!= ""} {
                set mut [$ASM_GUI::topGui.c.fp.tb cellcget [lindex $id $j],0 -text]
                set all_mut [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb columncget 0 -text]
                set index [lsearch $all_mut $mut]
                set ind_list [lappend ind_list $index]
                incr j
            }
        }
        set id [$ASM_GUI::topGui.c.fp.tb curselection]
		$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb configure -state normal
		$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb selection clear 0 end
        $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb selection set $ind_list
        ASM_GUI::selTable
        ASM_GUI::tbMutSel
        $ASM_GUI::topGui.c.fp.tb selection set $id
		$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb configure -state disable
    }




    array unset ::ASM_GUI::sasa_arr
    array set ::ASM_GUI::sasa_arr ""
    if {[llength $ASM_GUI::ligand_sel] > 1} {
        ASM_GUI::sasa $ASM_GUI::ligand_sel ligand
    }
    if {[llength $ASM_GUI::recep_sel] > 1} {
        ASM_GUI::sasa $ASM_GUI::recep_sel receptor
    }

    set name [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb columncget 0 -text]
    set resname [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb columncget 1 -text]
    set kons [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb columncget 2 -text]
    set i 0
    while {$i < [llength $name]} {
        set j 0
        set st ""
        set st [lappend st [lindex $name $i] [lindex $resname $i]]
        set aux ""
        switch [lindex $kons $i] {
            2 {
                set aux "Nonpolar"
            }
            3 {
                set aux "Polar"
            }
            4 {
               set aux "Charged"
            }
            default {
                set aux "Not-applied"
            }
        }
        set st [lappend st $aux]
        set val [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb cellcget $i,4 -text]
        if {$val!= "Failed" && $val!= "Alanine" && $val!= "Glyicine" && $val!= "Proline" && $val!= "NOT FOUND"} {
            while {$j < [llength $ASM_GUI::out_values(Mut[lindex $name $i])]} {

                    set st_aux [lindex $ASM_GUI::out_values(Mut[lindex $name $i]) $j]
                    if {$j != 9} {
                        set st_aux [split $st_aux "  "]
                        set h 0
                        set 1 ""
                        set 2 ""
                        while {$h < [llength $st_aux]} {
                            if {[lindex $st_aux $h] != "" && $1 == ""} {
                                set 1 [lindex $st_aux $h]
                            } elseif {[lindex $st_aux $h] != "" && $2 == ""} {
                                set 2 [lindex $st_aux $h]
                            }
                            incr h

                        }
                        set st [lappend st $1 $2]
                    } else {
                        set un "_"
                        set cha [split [lindex $resname $i] "_"]
                        if {[string is integer [lindex $cha 2]] == 1} {
                            set entry "[lindex $cha 0]_[lindex $cha 1]_X"
                        } else {
                            set entry [lindex $resname $i]
                        }
                        set st [lappend st $ASM_GUI::sasa_arr($entry)]
                        set st [lappend st [lindex $ASM_GUI::out_values(Mut[lindex $name $i]) $j]]
                        $ASM_GUI::topGui.c.fp.tb insert end $st

                        switch [lindex [lindex $ASM_GUI::out_values(Mut[lindex $name $i]) $j]] {
                            "Null Spot" {
                                $ASM_GUI::topGui.c.fp.tb rowconfig $i -background yellow
                            }
                            "Warm Spot" {
                                 $ASM_GUI::topGui.c.fp.tb rowconfig $i -background orange
                            }
                            "Hot Spot" {
                                 $ASM_GUI::topGui.c.fp.tb rowconfig $i -background red
                            }

                         }
                    }

                incr j
            }

        } else {
            while {$j < 9} {
                set st [lappend st "0000" "0000"]
                incr j
            }
            set st [lappend st "0000"]
            set st [lappend st $val]
            $ASM_GUI::topGui.c.fp.tb insert end $st
            $ASM_GUI::topGui.c.fp.tb rowconfigure $i -foreground red
            $ASM_GUI::topGui.c.fp.tb rowconfigure $i -background white
        }
        incr i
    }
      set ind_list ""
    set id [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb curselection]
    if {[llength [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb columncget 0 -text]] > 0 && $id != ""} {
        set j 0
        while {[lindex $id $j]!= ""} {

                    set mut [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb cellcget [lindex $id $j],0 -text]
                    set all_mut [$ASM_GUI::topGui.c.fp.tb columncget 0 -text]

                    set index [lsearch $all_mut $mut]
                    set ind_list [lappend ind_list $index]
                    incr j

        }
    }
    $ASM_GUI::topGui.c.fp.tb selection set $ind_list


}

proc ASM_GUI::creatDynamics {opt} {

    set path [file dirname $ASM_GUI::ASM_file]
    set fol [lindex [split [file rootname $ASM_GUI::ASM_file] "/"] end]
    set m ""
    set a ""
    set ASM_GUI::pb 0
    if {[file exists "$path/$fol/ASM.out"] == 1} {
        set file [open "$path/$fol/ASM.out" r+]
        set slp ""
        set intr ""
        while {[eof $file] != 1} {
            set linha [gets $file]
            if {[$ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.frmsd.tb size] == 0} {
                if {$linha == "Molecular Dynamics Convergence table"} {
                    set stop 0
                    set list ""
                    while {$stop != 2} {
                        set linha [gets $file]
                        if {$linha == [string repeat "=" 60]} {
                            incr stop
												}
										}
									set linha [gets $file]
									puts $linha

										while {$linha != [string repeat "=" 60]} {
											set i 0
											set st ""
											set list [split $linha "\t"]
											while {$i < [llength $list]} {
													if {[string trim [lindex $list $i]] != ""} {
														set st [lappend st [string trim [lindex $list $i]]]
													}
													incr i
											}
											$ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.frmsd.tb insert end $st
											set linha [gets $file]

										}
									}


								}
								if {$linha == "Linear Model Formula: "} {
									set linha [gets $file]
									while {$linha != [string repeat "=" 60]} {
										if {$linha != ""} {
											set form $linha
											set form [split $form " "]
											set m [split [lindex $form 0] "*"]
											set m [string range [lindex $m 0] 2 end]
											set a [lindex $form 2]
											set slp [lappend slp $m]
											set intr [lappend intr $a]
										}
											set linha [gets $file]
									}
								}

            }
        close $file
        set i 0
        set x_val ""
        set y_val ""
        set xy ""
        set un "_"
        set up [expr int([$ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.frmsd.tb cellcget end,0 -text])]
        if {[winfo exists $ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.fgraph.xy] == 1} {
            destroy $ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.fgraph.xy
        }

        set scl [lappend scl "0.0" $up [expr double($up)/5]]
        set rms_file [open "$path/$fol/min_dyn/rms.out" r+]
		set max [gets $rms_file]
		set max [lindex [split $max " "] end]
		set max [expr round([expr $max +1])]

		set yaxis ""
		set yaxis [lappend yaxis 0.0 $max 0.5]

		if {[winfo exists $ASM_GUI::progGui]} {wm deiconify $ASM_GUI::progGui ;return}
		set ASM_GUI::progGui ".prg"
		toplevel $ASM_GUI::progGui -width 300 -height 90 -background #d9d9d9
		## Title of the windows
		wm title $ASM_GUI::progGui "Loading..." ;# titulo da pagina
		grid columnconfigure $ASM_GUI::progGui 1 -weight 2; grid rowconfigure $ASM_GUI::progGui 1 -weight 2
		grid [ttk::frame $ASM_GUI::progGui.fp] -row 0 -column 0 -sticky news -padx 15 -pady 10

		grid columnconfigure $ASM_GUI::progGui.fp 1 -weight 1; grid rowconfigure $ASM_GUI::progGui.fp 1 -weight 1

		grid [ttk::label $ASM_GUI::progGui.fp.lbl -text "Loading RMS file, this could take a few seconds."] -row 0 -column 0 -sticky news

		grid [ttk::progressbar $ASM_GUI::progGui.pg -mode determinate -variable ASM_GUI::pb -maximum [$ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.frmsd.tb size]] -row 1 -column 0 -sticky news
		wm attributes $ASM_GUI::progGui -topmost
		update

        canvas $ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.fgraph.xy -background white -width 480 -height 300 -offset w
        $ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.fgraph.xy postscript -x 0 -pageanchor w -pagex w
        set xyp [::Plotchart::createXYPlot $ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.fgraph.xy $scl $yaxis]
        pack $ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.fgraph.xy -fill both -anchor center
        $xyp xtext "Time(psec)"
        $xyp ytext "Å"
        $xyp background "plot" white
        $xyp dataconfig RMSDTOT -type line -colour black
        $xyp dataconfig RMSD -type line -colour red -fillcolour red
        $ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.fgraph.xy xview scroll 400 units
		wm attributes $ASM_GUI::progGui -topmost
		update
        set i 0
        set j 0
        set ji ""
        while {[eof $rms_file] != 1} {
            set linha [gets $rms_file]
            if {$linha != ""} {
                set val_x [string trim [string range $linha 0 7] " "]
                set val_y [string trim [string range $linha 8 17] " "]
                if {$ASM_GUI::rmsValue == 1} {
                    xyplot$un$ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.fgraph.xy plot RMSDTOT $val_x $val_y
                }
                while {[expr int($val_x)] > [$ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.frmsd.tb cellcget $j,0 -text]} {
					xyplot$un$ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.fgraph.xy plot RMSD $val_x $y
					incr j
					incr ASM_GUI::pb
					update
                }
                set y [expr [expr [expr double([lindex $slp $j])/1000] * $val_x] + [lindex $intr $j ] ]
				if {$j != $ji} {
						xyplot$un$ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.fgraph.xy plot RMSD $val_x $y
				}
                incr i
                set ji $j
            }

        }
				xyplot$un$ASM_GUI::topGui.nb1.f2.nb1.f2.fp.feq.fwd.fgraph.xy plot RMSD $val_x $y
				incr ASM_GUI::pb
        close $rms_file
				destroy $ASM_GUI::progGui
    }
}

proc ASM_GUI::makegraph {frame opt} {
    if {$opt == 0} {

        canvas $frame.xy -background white -width 400 -height 300

        set xyp [::Plotchart::createXYPlot $frame.xy {0 10.0 2.0} {0 10.0 2.0}]
        $xyp xtext "Time(psec)"
        $xyp ytext "Å"
        $xyp background plot white

        pack $frame.xy -fill both -expand true
        ::Plotchart::plotconfig xyplot margin left 50
    }
}

proc ASM_GUI::resetOut {} {
    destroy $ASM_GUI::topGui.nb1.f2.nb1.f1
    destroy $ASM_GUI::topGui.nb1.f2.nb1.f2
    ASM_GUI::buildOutputFrame $ASM_GUI::topGui.nb1.f2 1

}

proc ASM_GUI::createButton {tbl row col w} {
	    set key [$tbl getkeys $row]
	    grid [ttk::frame $w] -sticky news
	grid [ttk::radiobutton $w.r -variable ASM_GUI::checklig_rec($row) -command {ASM_GUI::check} -compound center -padding "6 0 0 0"] -row 0 -column 0
	set ASM_GUI::rdbut($row,$col) "$w.r"
	if {$col == 3} {
		set ASM_GUI::checklig_rec($row) -1

	}
}

proc ASM_GUI::createButtonMut {tbl row col w} {
	set key [$tbl getkeys $row]
	    grid [ttk::frame $w] -sticky news
	grid [ttk::checkbutton $w.r -variable ASM_GUI::checkmut($row,0) -command {ASM_GUI::rowSelection} -compound center -padding "6 0 0 0"] -row 0 -column 0
	set ASM_GUI::rdbutMut($row) "$w.r"
}

proc ASM_GUI::createCombo {tbl row col w} {
	  set key [$tbl getkeys $row]
	  grid [ttk::frame $w] -sticky news
    set rep "Off Beads Surf NewCartoon Licorice VDW"
    ttk::style map TCombobox -fieldbackground [list readonly #ffffff]
    grid [ttk::combobox $w.r -values $rep -width 8 -state readonly -style TCombobox] -row 0 -column 0
    set ASM_GUI::index_cmb($row,0) $w.r
    set ASM_GUI::index_cmb($row,1) "Beads"
    mol modstyle $row [molinfo top] "Beads"
    bind $w.r <<ComboboxSelected>> {ASM_GUI::changeligrecombo}
    set res [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $row,1 -text]
    $w.r set [lindex $rep 1]
}


proc ASM_GUI::rgbtoHEX {rgb} {
	set rgb [split $rgb " "]
	set i 0
	set hex ""
	while {[lindex $rgb $i] != ""} {
		set st ""
		set frst_int [expr int([expr [lindex $rgb $i]*100] /16)]
		if {$frst_int < 10 } {
			set st $frst_int
		} else {
			switch $frst_int {
				10 {
					set st "A"
				}
				11 {
					set st "B"
				}
				12 {
					set st "C"
				}
				13 {
					set st "D"
				}
				14 {
					set st "E"
				}
				15 {
					set st "F"
				}
			}
		}
		set hex [append hex $st]
		set frst_mod [expr int([expr fmod([expr [lindex $rgb $i]*100]  ,16)])]
		if {$frst_mod <10} {
			set st $frst_mod
		} else {
			switch $frst_mod {
				10 {
					set st "A"
				}
				11 {
					set st "B"
				}
				12 {
					set st "C"
				}
				13 {
					set st "D"
				}
				14 {
					set st "E"
				}
				15 {
					set st "F"
				}
			}
		}
		set hex [append hex $st]
		incr i
	}
	return $hex

}

proc ASM_GUI::loadMain {} {
	 set types {
    {{ASM}       {.asm}        }
    }
    set file [tk_getOpenFile -filetypes $types]
    set do [ASM_GUI::loadButton $file]
    if {$do == 1 && [file exists [file rootname $file]/ASM.out] == 1} {
		$ASM_GUI::topGui.nb1 tab 1 -state normal
		$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb configure -state normal
            ASM_GUI::outTable
			$ASM_GUI::topGui.nb1 select 1
            if {$ASM_GUI::run == 1} {

			 $ASM_GUI::topGui.nb1.f2.nb1 select 1
              ASM_GUI::creatDynamics 0
            }



        set i 0
        while {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb size]} {
            $ASM_GUI::rdbut($i,3) configure -state disable
            $ASM_GUI::rdbut($i,4) configure -state disable
            $ASM_GUI::index_cmb($i,0) configure -state disable
            incr i
        }
        set i 0
        while {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb size]} {
            $ASM_GUI::rdbutMut($i) configure -state disable
            incr i
        }
        $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.frmradi.spinradii configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.cmb configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.butadd configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.butrm configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f1.btnext configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.btnext configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frleap.cmb configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmbutt.butadd configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmbutt.butdel configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.frch.mkmin_dyn.rdbuper configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.frch.mkmin_dyn.frm_min_dyn.rbmin configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.frch.mkmin_dyn.frm_min_dyn.rbdyn configure -state disable
        $ASM_GUI::topGui.nb1.f1.nb2.f3.fp.frch.mkload.rdbuload configure -state disable
    }
}
proc ASM_GUI::reset {} {
	destroy $ASM_GUI::topGui
	array unset ::ASM_GUI::pdb ""
	array set ::ASM_GUI::pdb ""
	array unset ::ASM_GUI::checklig_rec
	array set ::ASM_GUI::checklig_rec ""
	array unset ::ASM_GUI::checkmut
	array set ::ASM_GUI::checkmut ""
	array unset ::ASM_GUI::checkmut_pv
	array set ::ASM_GUI::checkmut_pv ""
	array unset ::ASM_GUI::checklig_rec_pv
	array set ::ASM_GUI::checklig_rec_pv ""
	array unset ::ASM_GUI::rdbut
	array set ::ASM_GUI::rdbut ""
	array unset ::ASM_GUI::rdbutMut
	array set ::ASM_GUI::rdbutMut ""
	array unset ::ASM_GUI::mut_added
	array set ::ASM_GUI::mut_added ""
	array unset ::ASM_GUI::out_values
	array set ::ASM_GUI::out_values ""
	array unset ::ASM_GUI::index_cmb
	array set ::ASM_GUI::index_cmb ""
	array unset ::ASM_GUI::heat_val
	array set ::ASM_GUI::heat_val ""
	array unset ::ASM_GUI::onoff
	array set ::ASM_GUI::onoff ""
	array unset ::ASM_GUI::sasa_arr
	array set ::ASM_GUI::sasa_arr ""
	set ASM_GUI::top ""
	set ASM_GUI::nchain ""
	set ASM_GUI::run ""
	set ASM_GUI::repid 0
	set ASM_GUI::made 0
	set ASM_GUI::press_i ""
	set ASM_GUI::server_but ""
	set ASM_GUI::load ""
	set ASM_GUI::next 0
	set ASM_GUI::ASM_file 0
	set ASM_GUI::heat_add ""
	set ASM_GUI::lig_rep ""
	set ASM_GUI::rec_rep ""
	set ASM_GUI::radio_rep ""
	set ASM_GUI::ligand_sel ""
	set ASM_GUI::pb 0
	set ASM_GUI::recep_sel ""
	set ASM_GUI::rmsValue 0
	set i 0
	set id [molinfo list]
	while { $i < [llength $id]}  {
			if {[molinfo [lindex $id $i] get name] == "ASM_Prot_rep" || [molinfo [lindex $id $i] get name] == "ASM_Prot_lig_rec"} {
					mol delete [lindex $id $i]
					set id [molinfo list]
					set i 0
			}
		incr i
	}

	ASM_GUI::Build


 }
