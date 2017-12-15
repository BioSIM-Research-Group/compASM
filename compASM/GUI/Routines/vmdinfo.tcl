package provide vmdinfo 1.0

proc ASM_GUI::intRes {ligand receptor opt dist} {
	set moltop [molinfo top]
	set lig_cmm ""
	set rec_cmm ""
	set int_lig ""
	set rec_cmm ""
	set ASM_GUI::lig_rep ""
	set ASM_GUI::rec_rep ""
	mol selection ""
	set ASM_GUI::ligand_sel ""
	set ASM_GUI::recep_sel ""
	$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb delete 0 end
	set lig_cmm "(($ligand) and protein within $dist of ($receptor) and not backbone)"
	set rec_cmm "(($receptor) and protein within $dist of ($ligand) and not backbone)"
	set int_lig [atomselect $moltop $lig_cmm]
	set int_rec [atomselect $moltop $rec_cmm]
	set res_lig [$int_lig get resid]
	set res_lig [split $res_lig " "]
	set res_rec [$int_rec get resid]
	set res_rec [split $res_rec " "]
	set res ""
	set resi ""
	set lig ""
	set rec ""
	set i 0
	while {[lindex $res_lig $i]!= ""} {
		set resi [lindex $res_lig $i]
		if {$resi != $res} {
			set lig [append lig "$resi "]
			set res $resi
		}
		incr i
	}
	set res ""
	set resi ""
	set i 0
	while {[lindex $res_rec $i]!= ""} {
		set resi [lindex $res_rec $i]
		if {$resi != $res} {
			set rec [append rec "$resi "]
			set res $resi
		}
		incr i
	}

	set moltop [molinfo top]
	set pdb_fil_name [molinfo $moltop get filename]
	mol off $moltop
	set id [mol load pdb $pdb_fil_name]
	set moltop [molinfo top]
	mol delrep 0 $moltop
	mol rename $id "ASM_Prot_lig_rec"
	set repr "licorice"

    set sel [atomselect $moltop $lig_cmm]
	set tb_resname ""
	set tb_id ""
	set tb_chain ""
	set tb_resname_i ""
	set tb_id_i ""
	set tb_chain_i ""
	set tb_resname [$sel get resname]
	set tb_id [$sel get resid]
	if {$opt != 1} {
		set tb_chain [$sel get chain]
	} else {
		set tb_chain [ASM_GUI::getChain $tb_id]
	}
	set i 0
	set h 0
	set tb_resname [split $tb_resname " "]
	set tb_id [split $tb_id " "]
	set tb_chain [split $tb_chain " "]
	set resname_id ""
	while {[lindex $tb_resname $i] != ""} {
		set st_aux ""
		if {($tb_resname_i != [lindex $tb_resname $i] || $tb_id_i != [lindex $tb_id $i] || $tb_chain_i != [lindex $tb_chain $i])} {
        		set st_aux "[lindex $tb_resname $i] [lindex $tb_id $i] [lindex $tb_chain $i] Lig "
			if {$resname_id != ""} {
				set resname_id [append resname_id "or "]
			}
			if {$opt != 1} {
				set resname_id [append resname_id "(resid [lindex $tb_id $i] and chain [lindex $tb_chain $i]) "]
			} else {
				set resname_id [append resname_id "resid [lindex $tb_id $i] "]
			}
			set k ""
			set k [ASM_Const::res [lindex $tb_resname $i]]

			set st_aux [append st_aux $k]
			$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb insert end $st_aux
			$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellconfigure $h,5 -window ASM_GUI::createButtonMut
			incr h
		}
		set tb_resname_i  [lindex $tb_resname $i]
		set tb_id_i [lindex $tb_id $i]
		set tb_chain_i [lindex $tb_chain $i]
		incr i
	}
	if {$resname_id != ""} {
            mol selection ""
            mol representation $repr
            mol color "ColorID 6"
            mol addrep $moltop
            mol modselect $ASM_GUI::repid $moltop $resname_id
            set ASM_GUI::ligand_sel ""
            set ASM_GUI::ligand_sel [lappend ASM_GUI::ligand_sel "$ligand" "$resname_id"]
            incr ASM_GUI::repid
            set sel ""
            update
            set ASM_GUI::lig_rep [lappend ASM_GUI::lig_rep "Licorice"]
	}
	set repr "Beads"
	mol representation $repr
	mol color "ColorID 0"
	mol addrep $moltop
	if {$resname_id != ""} {
	    mol modselect $ASM_GUI::repid $moltop "($ligand) and not ($resname_id)"
	} else {
            set ASM_GUI::ligand_sel "$ligand"
	    mol modselect $ASM_GUI::repid $moltop "($ligand)"
	}
	set ASM_GUI::lig_rep [lappend ASM_GUI::lig_rep "Beads"]
	set sel ""
	incr ASM_GUI::repid
	set repr "licorice"



	set sel [atomselect $moltop $rec_cmm]
	set tb_resname ""
	set tb_id ""
	set tb_chain ""
	set tb_resname_i ""
	set tb_id_i ""
	set tb_chain_i ""
	set tb_resname [$sel get resname]
	set tb_id [$sel get resid]
	if {$opt != 1} {
		set tb_chain [$sel get chain]
	} else {
		set tb_chain [ASM_GUI::getChain $tb_id]
	}
	set tb_resname [split $tb_resname " "]
	set tb_id [split $tb_id " "]
	set tb_chain [split $tb_chain " "]
	set j 0
	set resname_id ""
	while {[lindex $tb_resname $j] != ""} {
		if {($tb_resname_i != [lindex $tb_resname $j] || $tb_id_i != [lindex $tb_id $j] || $tb_chain_i != [lindex $tb_chain $j])} {
			set st_aux "[lindex $tb_resname $j] [lindex $tb_id $j] [lindex $tb_chain $j] Rec "
			if {$resname_id != ""} {
				set resname_id [append resname_id "or "]
			}
			if {$opt != 1} {
				set resname_id [append resname_id "(resid [lindex $tb_id $j] and chain [lindex $tb_chain $j]) "]
			} else {
				set resname_id [append resname_id "resid [lindex $tb_id $j] "]
			}
			set k ""

				set k [ASM_Const::res  [lindex $tb_resname $j]]
		
			set st_aux [append st_aux $k]
			$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb insert end $st_aux
			$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellconfigure $h,5 -window ASM_GUI::createButtonMut
			incr h
		}
		set tb_resname_i  [lindex $tb_resname $j]
		set tb_id_i [lindex $tb_id $j]
		set tb_chain_i [lindex $tb_chain $j]
		incr j
	}
	if {$resname_id != ""} {
        	mol selection ""
        	mol representation $repr
        	mol color "ColorID 14"
        	mol addrep $moltop
        	mol modselect $ASM_GUI::repid $moltop $resname_id
                set ASM_GUI::recep_sel ""
                set ASM_GUI::recep_sel [lappend ASM_GUI::recep_sel "$receptor" "$resname_id"]
        	set sel ""
		incr ASM_GUI::repid
        	update
		set ASM_GUI::rec_rep [lappend ASM_GUI::rec_rep "Licorice"]
	}

	set repr "Beads"


	mol selection ""
	mol representation $repr
	mol color "ColorID 1"
	mol addrep $moltop
	set ASM_GUI::rec_rep [lappend ASM_GUI::rec_rep "Beads"]
	if {$resname_id != ""} {
	    mol modselect $ASM_GUI::repid $moltop "($receptor) and not ($resname_id)"
	} else {
            set ASM_GUI::recep_sel "$receptor"
	    mol modselect $ASM_GUI::repid $moltop $receptor
	}
	incr ASM_GUI::repid
	set sel ""
	update
    unset upproc_var_$int_lig
    unset upproc_var_$int_rec


}

proc ASM_GUI::subUnits {chain opt moltop ind} {
    if {$opt==0} {
        if {$ind == 0} {
            mol delrep 0 $moltop
        }
        set i 0
        while {[lindex $chain $i] != ""} {
        		set repr "Beads"
            mol selection ""
        		mol selection "all and chain [lindex $chain $i] "
        		mol representation $repr
        if {$ind != 0} {
            mol color ""
            mol color "ColorID [expr $ind +2]"
            mol modrep $ind $moltop
        } else {
            mol color "ColorID [expr $i +2]"
            mol modrep $i $moltop
        }
        mol addrep $moltop
        		set sel ""
        		incr i
        	}
    } elseif {$opt ==1} {
        array set chainar $chain
        if {$ind < 1} {
          mol delrep 0 $moltop
        }
        set i 1
        while {$i <= [array size chainar]} {
            set repr "Beads"

            set element [split $chainar($i) " "]
            set id1 [string trimright [string trimleft [lindex $element 0] "{"] "}"]
            set id2 [string trimright [string trimleft [lindex $element 1] "{"] "}"]
            mol selection ""
            mol selection "all and resid $id1 to  $id2"
            mol representation $repr
            if {$ind != 0} {
                mol color "ColorID [expr $ind +$i]"
                mol modrep [expr $ind -1] $moltop
            } else {
            mol color "ColorID [expr $i +1]"
            mol modrep [expr $i -1] $moltop
        }
        mol addrep $moltop
        set sel ""
        incr i
        }
    } elseif {$opt == 2} {
        set i 0
        while {[lindex $chain $i] != ""} {
            set repr "Beads"

            mol selection ""
        		mol selection "all and [lindex $chain $i] "
        		mol representation $repr
            mol color ""
            mol color "ColorID [expr $ind +2 + $i]"
            mol modrep [expr $ind +$i] $moltop
        		mol addrep $moltop
        		set sel ""
        		incr i
        	}
    }

}

proc ASM_GUI::rowSelection {} {
    set ASM_GUI::made 2
    set moltop [molinfo top]
    mol selection ""
    mol representation "Surf"
    set id [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb curselection]
    if {$id == ""} {
      for {set i 0} {$i < [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb size] } {incr i} {
        if {[info exists ASM_GUI::checkmut($i,0)]} {
            if {[info exists ASM_GUI::checkmut_pv($i)]} {
                if {$ASM_GUI::checkmut($i,0) != $ASM_GUI::checkmut_pv($i)} {
                set id $i
                set ASM_GUI::checkmut_pv($i) $ASM_GUI::checkmut($i,0)
                break
                }
            } else {
                set id $i
                set ASM_GUI::checkmut_pv($i) 1
                break
            }
        }
      }
    }
    if {$id != ""} {
        if {$ASM_GUI::checkmut($id,0) == 1} {
            set ASM_GUI::checkmut($id,1) $ASM_GUI::repid
			set resname [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $id,0 -text]
			set resid [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $id,1 -text]
			set do [string is integer [string trim [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $id,2 -text] " "]]
			set st ""
			if {$do != 1} {
				set chain [string trim [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $id,2 -text] " "]
				set st "resname $resname and resid $resid and chain $chain"
			} else {
				set st "resname $resname and resid $resid"
			}
			set ASM_GUI::checkmut_pv($id) 1
            set repr "Surf"
            mol addrep $moltop
            mol modselect $ASM_GUI::repid $moltop $st
            mol representation $repr
            incr ASM_GUI::repid
            if {[llength [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb columncget 0 -text]] > 0} {
                    set mut [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb columncget 0 -text]
					set un "_"
					set id_aux [lsearch [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb columncget 1 -text] $resname$un$resid$un[$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb cellcget $id,2 -text] ]
                    set all_mut [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb  cellcget $id_aux,0 -text]
                    set index [lsearch $mut $all_mut]

                    set score [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb  cellcget $index,4 -text]
                      switch $score {
                        "Null Spot" {
                             mol modcolor $ASM_GUI::checkmut($id,1) [molinfo top] "ColorID 4"
                        }
                        "Warm Spot" {
                             mol modcolor $ASM_GUI::checkmut($id,1) [molinfo top] "ColorID 3"
                        }
                        "Hot Spot" {
                             mol modcolor $ASM_GUI::checkmut($id,1) [molinfo top] "ColorID 1"
                        }
                        default {
                            mol modcolor $ASM_GUI::checkmut($id,1) [molinfo top] "ColorID 2"
                        }
                     }
            } else {
                mol modcolor $ASM_GUI::checkmut($id,1) [molinfo top] "ColorID 2"
            }

            update
            while {[molinfo $moltop get numreps] > $ASM_GUI::repid  } {
              mol delrep [expr [molinfo $moltop get numreps] -1 ] $moltop
            }
        } else {
            mol delrep $ASM_GUI::checkmut($id,1) $moltop
            incr ASM_GUI::repid -1
            while {[molinfo $moltop get numreps] > $ASM_GUI::repid } {
              mol delrep [expr [molinfo $moltop get numreps] -1 ] $moltop
            }
            set ASM_GUI::checkmut_pv($id) 0
        }
    }
	set ASM_GUI::made 1
 }

 proc ASM_GUI::sasa {sel opt} {
    set sel1 [atomselect [molinfo top] "all"]
    set sel2 [atomselect [molinfo top] [lindex $sel 0]]
    set residues [atomselect [molinfo top] [lindex $sel 1]]
    set un "_"
    set selction ""
    array set sasa_arr ""
    set idd -1
    set selection ""
    set i 0
		set ASM_GUI::progGui ".prg"
    if {[winfo exists $ASM_GUI::progGui]} {wm deiconify $ASM_GUI::progGui ;return}

    toplevel $ASM_GUI::progGui -width 300 -height 90 -background #d9d9d9
    ## Title of the windows
    wm title $ASM_GUI::progGui "Calculating..." ;# titulo da pagina
    grid columnconfigure $ASM_GUI::progGui 1 -weight 2; grid rowconfigure $ASM_GUI::progGui 1 -weight 2
    grid [ttk::frame $ASM_GUI::progGui.fp] -row 0 -column 0 -sticky news -padx 15 -pady 10

    grid columnconfigure $ASM_GUI::progGui.fp 1 -weight 1; grid rowconfigure $ASM_GUI::progGui.fp 1 -weight 1

    grid [ttk::label $ASM_GUI::progGui.fp.lbl -text "Calculating $opt residues surface. This could take few seconds."] -row 0 -column 0 -sticky news

    grid [ttk::progressbar $ASM_GUI::progGui.pg -mode determinate -variable ASM_GUI::pb -maximum [llength [$residues get resname]]] -row 1 -column 0 -sticky news
    wm attributes $ASM_GUI::progGui -topmost

    set ASM_GUI::pb 0
    foreach  index [$residues get resid] name [$residues get resname] chain [$residues get chain] {
        set sasa_arr2 ""
        set sasa_arr1 ""
        if {$idd != "$index$un$name"} {
            set sasa ""
            set res [atomselect [molinfo top] "resname $name and resid $index and chain $chain" ]
            set sasa [measure sasa 1.4 $sel1 -restrict $res -points pts -samples 50]
            if {$sasa>=0 &&  [lsearch $selection $index$un$name$un$chain] == -1} {
                set selection "$selection $index$un$name$un$chain"
                set sasa [format %3.3f $sasa]
                set sasa_arr1 $sasa
                unset upproc_var_$res

                set sasa ""
                set res [atomselect [molinfo top] "(resname $name and resid $index and chain $chain)" ]
                set sasa [measure sasa 1.4 $sel2 -restrict $res -points pts -samples 50]
                set sasa [format %3.3f $sasa]
                set sasa_arr2 $sasa

                unset upproc_var_$res

                set sasa ""
                set res [atomselect [molinfo top] "(resname $name and resid $index and chain $chain) and not backbone" ]
                set sasa [measure sasa 1.4 $res -restrict $res -points pts -samples 50]
                set sasa [format %3.3f $sasa]
                set sasa_tot $sasa

                unset upproc_var_$res

                set ASM_GUI::sasa_arr($name$un$index$un$chain) [format %3.1f [expr abs([expr $sasa_arr2 - $sasa_arr1])]]


            }


        }
        set idd "$index$un$name$un$chain"
        incr ASM_GUI::pb
        update
    }
    destroy $ASM_GUI::progGui
    set ASM_GUI::pb 0

    unset upproc_var_$sel1
    unset upproc_var_$sel2
    unset upproc_var_$residues
 }