package provide inputframe 1.0

proc ASM_GUI::buildInputFrame {frame opt} {


    ########## Notebook Input
    if {$opt == 0} {
        grid [ttk::notebook $frame.nb2 -padding "2 10 2 5"] -in $frame -row 0 -column 0 -sticky news

    }
	grid columnconfigure $frame.nb2  0 -weight 2; grid rowconfigure $frame.nb2 0 -weight 2

 	ttk::frame $frame.nb2.f1
	grid columnconfigure $frame.nb2.f1 0 -weight 2; grid rowconfigure $frame.nb2.f1 0 -weight 2

	ttk::frame $frame.nb2.f2
	grid columnconfigure $frame.nb2.f2 0 -weight 2; grid rowconfigure $frame.nb2.f2 0 -weight 2

	ttk::frame $frame.nb2.f3
	grid columnconfigure $frame.nb2.f3 0 -weight 1; grid rowconfigure $frame.nb2.f3 0 -weight 1

	ttk::frame $frame.nb2.f4
	grid columnconfigure $frame.nb2.f4 0 -weight 1; grid rowconfigure $frame.nb2.f4 1 -weight 2

	$frame.nb2 add $frame.nb2.f1 -text "Receptor/Ligand" -sticky news
	$frame.nb2 add $frame.nb2.f2 -text "Mutations"  -sticky news
	$frame.nb2 add $frame.nb2.f3 -text "Simulation"  -sticky news
	$frame.nb2 add $frame.nb2.f4 -text "Parameters"  -sticky news

	$frame.nb2 tab 1 -state disable
	$frame.nb2 tab 2 -state disable

	##################Tablelist Ligand/receptor

	grid [ttk::labelframe $frame.nb2.f1.flig_rec -text "Ligand/Receptor" -padding "3 3 3 3"] -column 0 -row 0 -sticky nswe -pady 2 -padx 2
	grid columnconfigure $frame.nb2.f1.flig_rec 0 -weight 2; grid rowconfigure $frame.nb2.f1.flig_rec 0 -weight 2


	set fro2 $frame.nb2.f1.flig_rec
	option add *Tablelist.activeStyle       frame
	option add *Tablelist.background        gray98
	option add *Tablelist.stripeBackground  #e0e8f0
	option add *Tablelist.setGrid           yes
	option add *Tablelist.movableColumns    no
	tablelist::tablelist $fro2.tb \
	    -columns { 0 "Color" center
		    0 "Chain ID"	 center
			    0 "Resid range"	 center
			    0 "Ligand"   center
			    0 "Receptor"   center
			    0 "Rep Type"   center} \
	    -yscrollcommand [list $fro2.scr1 set] -xscrollcommand [list $fro2.scr2 set] \
	    -showseparators 0 -labelrelief groove  -labelbd 1 -selectbackground blue -selectforeground white\
	    -foreground black -state normal -selectmode multiple -width 38 -height 6 -stretch all

	grid $fro2.tb -row 0 -column 0 -sticky news
	grid columnconfigure $fro2.tb 0 -weight 2; grid rowconfigure $fro2.tb 0 -weight 2

	##Scrool_BAr V
	scrollbar $fro2.scr1 -orient vertical -command [list $fro2.tb  yview]
	    grid $fro2.scr1 -row 0 -column 1  -sticky ens
	## Scrool_Bar H
	    scrollbar $fro2.scr2 -orient horizontal -command [list $fro2.tb xview]
	    grid $fro2.scr2 -row 1 -column 0 -sticky swe

	bind [$fro2.tb bodytag] <ButtonRelease> {
        set ind [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb curselection]
        if {[llength $ind] > 1} {
            set ind [lindex $ind 0]
        }
        if {$ASM_GUI::heat_add != ""} {
                set res [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $ind,1 -text]
                set num [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $ind,2 -text]
                set num [lindex [split $num "-"] 0]
                set un "_"
                if {[lsearch $ASM_GUI::heat_add $res$un$num] != -1} {
                        $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.addrm.cmb set $res$un$num
                }
        }

	}

	bind [$fro2.tb bodytag] <Double-Button> {
        if {[molinfo [molinfo top] get name] == "ASM_Prot_rep" } {
            set ind [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb curselection]
            if {$ind != ""} {
                if {[llength $ind] > 1} {
                    set ind [lindex $ind 0]
                }
                set res [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $ind,1 -text]
                set num [$ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb cellcget $ind,2 -text]
                set num [lindex [split $num "-"] 0]
                set un "_"
                if {[lsearch $ASM_GUI::heat_add "$res$un$num"] != -1} {
                    set name "$res$un$num"
                } else {
                    set name $res
                }
                if {$ASM_GUI::onoff($name,1) == 1} {
                        mol showrep [molinfo top] $ASM_GUI::onoff($name,0) off
                        set ASM_GUI::onoff($name,1) 0
                        $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb rowconfigure $ind -foreground red
                        $ASM_GUI::index_cmb($ind,0) set "Off"
                } else {
                        mol showrep [molinfo top] $ASM_GUI::onoff($name,0) on
                        set ASM_GUI::onoff($name,1) 1
                        $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb rowconfigure $ind -foreground black
                        $ASM_GUI::index_cmb($ind,0) set $ASM_GUI::index_cmb($ind,1)
                }
                $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb selection set $ind
            }
            $ASM_GUI::topGui.nb1.f1.nb2.f1.flig_rec.tb selection clear 0 end
        }
	}

	###Add and remove HETATM

	grid [ttk::frame $frame.nb2.f1.flig_rec.addrm -padding "0 4 0 4"] -row 3 -column 0 -sticky we
	grid columnconfigure $frame.nb2.f1.flig_rec.addrm 0 -weight 1; grid rowconfigure $frame.nb2.f1.flig_rec.addrm 0 -weight 1


	grid [ttk::label $frame.nb2.f1.flig_rec.addrm.lbres -text "HETATM name" -padding "4 0 0 0" ] -row 0 -column 0 -sticky nw
	grid [ttk::combobox $frame.nb2.f1.flig_rec.addrm.cmb -width 15 -values $ASM_GUI::heat_add -state readonly] -row 0 -column 1 -sticky wn -padx 2
	$frame.nb2.f1.flig_rec.addrm.cmb set [lindex $ASM_GUI::heat_add 0]

	grid [ttk::button $frame.nb2.f1.flig_rec.addrm.butadd -text "Add" -padding "2 0 2 0" -width 8 -command ASM_GUI::addHET] -row 0 -column 2 -padx 2
	grid [ttk::button $frame.nb2.f1.flig_rec.addrm.butrm -text "Del" -padding "2 0 2 0" -width 8 -command ASM_GUI::removeHET] -row 0 -column 3


	$frame.nb2.f1.flig_rec.addrm.lbres configure -state disbale
	$frame.nb2.f1.flig_rec.addrm.cmb configure -state disbale
	$frame.nb2.f1.flig_rec.addrm.butadd configure -state disbale
	$frame.nb2.f1.flig_rec.addrm.butrm configure -state disbale
	##Next button
	grid [ttk::button $frame.nb2.f1.btnext -text "Next  ->" -width 7 -state disable -command {
		set size [array size ASM_GUI::checklig_rec]
		set do 1
		set rec 0
		set lig 0
		if {$size >= 2} {
			for {set i 0} {$i < [molinfo [molinfo top] get numreps]} {incr i} {
					if {[info exists ASM_GUI::checklig_rec($i)]} {
							if {$ASM_GUI::checklig_rec($i) == 1} {
									incr lig
							} elseif {$ASM_GUI::checklig_rec($i) == 0} {
									incr rec
							}
					}

			}

			if {$lig ==0 } {
				tk_messageBox -icon error -message "You should choose at least one chain as ligand" -title "Ligand selection error" -type ok
				set do 0
			} elseif {$rec==0} {
				tk_messageBox -icon error -message "You should choose at least one chain as receptor" -title "Receptor selection error" -type ok
				set do 0
			}
		}
		if {$do == 1} {
			if {$ASM_GUI::next ==2} {
					$ASM_GUI::topGui.nb1.f1.nb2 select 1
			} elseif {$ASM_GUI::next==0} {
					ASM_GUI::loadMutations
					set ASM_GUI::next 1
			}
			$ASM_GUI::topGui.nb1.f1.btrunload.btsave configure -state normal
			$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbmat set "Opaque"
			$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbtype set "Beads"
		}
	}] -row 1 -column 0 -sticky e

	bind $ASM_GUI::topGui.nb1.f1.nb2 <<NotebookTabChanged>> {ASM_GUI::changeTab}
	###Step 2- mutations selection

	grid [ttk::frame $frame.nb2.f2.fp] -row 0 -column 0 -sticky news
	grid columnconfigure $frame.nb2.f2.fp 0 -weight 1; grid rowconfigure $frame.nb2.f2.fp 1 -weight 2

	##Residues tabele list

	grid [ttk::labelframe $frame.nb2.f2.fp.frtbl -padding "3 3 3 3" -text "Mutations Selection"] -row 1 -column 0 -sticky news -pady 2 -padx 2
	grid columnconfigure $frame.nb2.f2.fp.frtbl 0 -weight 2; grid rowconfigure $frame.nb2.f2.fp.frtbl 1 -weight 2

	grid [ttk::frame $frame.nb2.f2.fp.frtbl.frmradi] -row 0 -column 0 -sticky news -pady 2 -padx 2
	grid columnconfigure $frame.nb2.f2.fp.frtbl.frmradi 0 -weight 0; grid rowconfigure $frame.nb2.f2.fp.frtbl.frmradi 0 -weight 0

	grid [ttk::label $frame.nb2.f2.fp.frtbl.frmradi.lbradi -text "Inteface radii " -padding "2 2 2 2"] -row 0 -column 0 -sticky news -pady 2 -padx 2
	grid columnconfigure $frame.nb2.f2.fp.frtbl.frmradi.lbradi 1 -weight 1; grid rowconfigure $frame.nb2.f2.fp.frtbl.frmradi.lbradi 1 -weight 1

	grid [spinbox $frame.nb2.f2.fp.frtbl.frmradi.spinradii -width 4 -from 3 -to 10 -increment 0.5 -command ASM_GUI::spinInter ] -row 0 -column 1 -sticky w -pady 2
	$frame.nb2.f2.fp.frtbl.frmradi.spinradii set 5.0
	grid [ttk::label $frame.nb2.f2.fp.frtbl.frmradi.lbA -text "A"] -row 0 -column 2 -sticky news -pady 2 -padx 2
	grid columnconfigure $frame.nb2.f2.fp.frtbl.frmradi.lbA 0 -weight 2; grid rowconfigure $frame.nb2.f2.fp.frtbl.frmradi.lbA 0 -weight 2

	grid [ttk::labelframe $frame.nb2.f2.fp.frmrep -text "Representation Manager" -padding "2 2 2 2"] -row 0 -column 0 -sticky news -padx 2 -pady 2
	grid columnconfigure $frame.nb2.f2.fp.frmrep 0 -weight 1; grid rowconfigure $frame.nb2.f2.fp.frmrep 1 -weight 2
	grid [ttk::frame $frame.nb2.f2.fp.frmrep.frmlb -padding "130 0 6 4"] -row 0 -column 0 -sticky nws

	grid columnconfigure $frame.nb2.f2.fp.frmrep.frmlb 0 -weight 1; grid rowconfigure $frame.nb2.f2.fp.frmrep.frmlb 1 -weight 1

	grid [ttk::radiobutton $frame.nb2.f2.fp.frmrep.frmlb.chelig -text "Ligand" -variable ASM_GUI::radio_rep -value 0 ] -row 0 -column 0 -sticky n -pady 4 -padx 6
	grid [ttk::radiobutton $frame.nb2.f2.fp.frmrep.frmlb.cherec -text "Receptor" -variable ASM_GUI::radio_rep -value 1 ] -row 0 -column 1 -sticky n -pady 4
	grid [ttk::frame $frame.nb2.f2.fp.frmrep.frmcombo] -row 1 -column 0 -sticky news -pady 4

		grid [ttk::label $frame.nb2.f2.fp.frmrep.frmcombo.lbtype -text "Representation Type :" -padding "10 0 6 0"] -row 1 -column 0 -sticky nw
		set rep "Off Beads Surf NewCartoon VDW"
		set mat "Opaque Transparent"
		ttk::style map TCombobox -fieldbackground [list readonly #ffffff]
		grid [ttk::combobox $frame.nb2.f2.fp.frmrep.frmcombo.cmbtype -values $rep -width 14 -state readonly -style TCombobox] -row 1 -column 1 -sticky nw
		$frame.nb2.f2.fp.frmrep.frmcombo.cmbtype set "Beads"
		grid [ttk::combobox $frame.nb2.f2.fp.frmrep.frmcombo.cmbmat -values $mat -width 14 -state readonly -style TCombobox] -row 1 -column 2 -sticky nw -padx 4
		$frame.nb2.f2.fp.frmrep.frmcombo.cmbmat set "Opaque"
		bind $frame.nb2.f2.fp.frmrep.frmcombo.cmbtype <<ComboboxSelected>> {ASM_GUI::changemutTabRep}
        bind $frame.nb2.f2.fp.frmrep.frmcombo.cmbmat <<ComboboxSelected>> {ASM_GUI::changemutTabRep}

        ttk::style map TRadiobutton -background [list active #d9d9d9]
        $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmlb.chelig configure -style TRadiobutton
         $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmlb.cherec configure -style TRadiobutton
		set fro2 $frame.nb2.f2.fp.frtbl


	option add *Tablelist.activeStyle       frame
	option add *Tablelist.background        gray98
	option add *Tablelist.stripeBackground  #e0e8f0
	option add *Tablelist.setGrid           yes
	option add *Tablelist.movableColumns    no
	tablelist::tablelist $fro2.tb \
	    -columns {	0 "Resname"	 center
			    0 "Res ID"	 center
			    0 "Chain ID"   center
				0 "Lig/Rec"   center
				0 "Diele K"   center
			    0 "Mutate"   center} \
	    -yscrollcommand [list $fro2.scr1 set] \
	    -showseparators 0 -labelrelief groove  -labelbd 1 -selectbackground blue -selectforeground white\
	    -foreground black -state normal -selectmode single -width 55 -height 5 -stretch all -height 8



	grid $fro2.tb -row 1 -column 0 -sticky news
	grid columnconfigure $fro2.tb 0 -weight 1; grid rowconfigure $fro2.tb 0 -weight 1

	##Scrool_BAr V
	scrollbar $fro2.scr1 -orient vertical -command [list $fro2.tb  yview]
	    grid $fro2.scr1 -row 1 -column 1  -sticky ens

	##bind row selection
	bind [$fro2.tb bodytag] <ButtonRelease> {
		set id [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb curselection]
		if {$id == "" || $ASM_GUI::made ==2} {
			$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.tb selection clear 0 end
		} else {
			$ASM_GUI::rdbutMut($id) invoke
		}
	}

	###Add mutation button
	grid [ttk::frame $frame.nb2.f2.fp.mutbut] -row 2 -column 0 -sticky nwes -padx 3
	grid columnconfigure $frame.nb2.f2.fp.mutbut 0 -weight 1; grid rowconfigure $frame.nb2.f2.fp.mutbut 0 -weight 1

	grid [ttk::button $frame.nb2.f2.fp.mutbut.addbt -text "Add Mut" -command {
		set do 1
		set id "end"
		if {$do ==1} {
			ASM_GUI::addMutations $id $do
		}

	}] -row 0 -column 0 -sticky ew -padx 1

	grid [ttk::button $frame.nb2.f2.fp.mutbut.scanbt -text "Surf Scan" -command ASM_GUI::scanSurf] -row 0 -column 1 -sticky ew -padx 1
        grid [ttk::button $frame.nb2.f2.fp.mutbut.sasabt -text "NSCA Sel" -command {
            array unset ::ASM_GUI::sasa_arr
            array set ::ASM_GUI::sasa_arr ""
            if {[llength $ASM_GUI::ligand_sel] > 1} {
                ASM_GUI::sasa $ASM_GUI::ligand_sel ligand
            }
            if {[llength $ASM_GUI::recep_sel] > 1} {
                ASM_GUI::sasa $ASM_GUI::recep_sel receptor
            }
            if {[array size ASM_GUI::sasa_arr] != 0} {
                ASM_GUI::sasaSel
            }
        }] -row 0 -column 2 -sticky ew
	grid [ttk::button $frame.nb2.f2.fp.mutbut.clearbt -text "Clear" -command ASM_GUI::clearSlect] -row 0 -column 3 -sticky ew -padx 1

	###Mutations tablelist
	grid [ttk::labelframe $frame.nb2.f2.fp.muttbl -padding "3 3 3 3" -text "Mutations List"] -row 3 -column 0 -sticky news -pady 2 -padx 2
	grid columnconfigure $frame.nb2.f2.fp.muttbl 0 -weight 1; grid rowconfigure $frame.nb2.f2.fp.muttbl 0 -weight 1

	set fro2 $frame.nb2.f2.fp.muttbl

	option add *Tablelist.activeStyle       frame
	option add *Tablelist.background        gray98
	option add *Tablelist.stripeBackground  #e0e8f0
	option add *Tablelist.setGrid           yes
	option add *Tablelist.movableColumns    no
	option add *Tablelist.labelCommand      tablelist::sortByColumn
	tablelist::tablelist $fro2.tb \
	    -columns {	0 "Mut index"	 center
			0 "Residues List"	 center
			0 "Diele K"	 center} \
	    -yscrollcommand [list $fro2.scr1 set]  \
	    -showseparators 0 -labelrelief groove  -labelbd 1 -selectbackground blue -selectforeground white\
	    -foreground black -state normal -selectmode multiple -width 38 -height 7 -stretch "1 2"

	$fro2.tb columnconfigure 0 -sortmode real -name "Mut index"
	$fro2.tb columnconfigure 1 -sortmode dictionary -name "Residues List"
	$fro2.tb columnconfigure 2 -sortmode dictionary -name "Diele K"
	grid $fro2.tb -row 0 -column 0 -sticky news
	grid columnconfigure $fro2.tb 0 -weight 1; grid rowconfigure $fro2.tb 0 -weight 2

	##Scrool_BAr V
	scrollbar $fro2.scr1 -orient vertical -command [list $fro2.tb  yview]
	    grid $fro2.scr1 -row 0 -column 1  -sticky ens

			grid [ttk::button $frame.nb2.f2.fp.muttbl.delbt -text "Delete Mutation(s)" -command ASM_GUI::delMutations] -row 1 -column 0 -sticky w

	##bind row selection
	bind [$fro2.tb bodytag] <ButtonRelease> {ASM_GUI::tbMutSel}

	###Next button
	grid [ttk::button $frame.nb2.f2.fp.btnext -text "Next  ->" -width 7 -state disable -command {
		$ASM_GUI::topGui.nb1.f1.nb2 tab 2 -state normal
		$ASM_GUI::topGui.nb1.f1.nb2 select 2

	}] -row 4 -column 0 -sticky e


	###Minimisation parameters

	grid [ttk::frame $frame.nb2.f3.fp] -row 0 -column 0 -sticky news
	grid columnconfigure $frame.nb2.f3.fp 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp 1 -weight 2


	grid [ttk::frame $frame.nb2.f3.fp.fnt] -row 1 -column 0 -sticky news
	grid columnconfigure $frame.nb2.f3.fp.fnt 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.fnt 0 -weight 1

	grid [ttk::notebook $frame.nb2.f3.fp.fnt.nb2 -padding "2 0 2 5"] -row 0 -column 0  -pady 10 -sticky news
	grid columnconfigure $frame.nb2.f3.fp.fnt.nb2 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.fnt.nb2 0 -weight 1

	ttk::frame $frame.nb2.f3.fp.fnt.nb2.f1
	grid columnconfigure $frame.nb2.f3.fp.fnt.nb2.f1 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.fnt.nb2.f1 1 -weight 1

	ttk::frame $frame.nb2.f3.fp.fnt.nb2.f2
	grid columnconfigure $frame.nb2.f3.fp.fnt.nb2.f2 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.fnt.nb2.f2 1 -weight 1

	ttk::frame $frame.nb2.f3.fp.fnt.nb2.f3
	grid columnconfigure $frame.nb2.f3.fp.fnt.nb2.f3 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.fnt.nb2.f3 1 -weight 1


	$frame.nb2.f3.fp.fnt.nb2 add $frame.nb2.f3.fp.fnt.nb2.f1 -text "Minimization" -sticky news
	$frame.nb2.f3.fp.fnt.nb2 add $frame.nb2.f3.fp.fnt.nb2.f2 -text "Dynamics"  -sticky news -state disable
	$frame.nb2.f3.fp.fnt.nb2 add $frame.nb2.f3.fp.fnt.nb2.f3 -text "Load Min/Dyn"  -sticky news -state disable


	####Min/Dyn choose buttons

	grid [ttk::labelframe $frame.nb2.f3.fp.frch -text "Procedure" -relief sunken] -row 0 -column 0 -sticky news -padx 3 -pady 3
	grid columnconfigure $frame.nb2.f3.fp.frch 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.frch 0 -weight 1

	grid [ttk::frame $frame.nb2.f3.fp.frch.mkmin_dyn_space1] -row 0 -column 0 -sticky nws -pady 4
	grid columnconfigure $frame.nb2.f3.fp.frch.mkmin_dyn_space1 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.frch.mkmin_dyn_space1 0 -weight 1

	grid [ttk::frame $frame.nb2.f3.fp.frch.mkmin_dyn -relief groove ] -row 0 -column 1 -sticky nws -pady 4
	grid columnconfigure $frame.nb2.f3.fp.frch.mkmin_dyn 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.frch.mkmin_dyn 0 -weight 1


	grid [ttk::radiobutton $frame.nb2.f3.fp.frch.mkmin_dyn.rdbuper -text "Perform" -value 0 -variable ASM_GUI::load -command {
		if {$ASM_GUI::load == 0} {
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 tab 0 -state normal
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 tab 1 -state disable

			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.frch.mkmin_dyn.frm_min_dyn.rbmin configure -state normal
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.frch.mkmin_dyn.frm_min_dyn.rbdyn configure -state normal
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 tab 2 -state disable
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 select 0
			set ASM_GUI::run 0
		}
	}] -pady 2 -sticky w -padx 2


	grid [ttk::frame $frame.nb2.f3.fp.frch.mkmin_dyn.frm_min_dyn] -row 0 -column 1 -sticky nws -pady 2
	grid columnconfigure $frame.nb2.f3.fp.frch.mkmin_dyn.frm_min_dyn 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.frch.mkmin_dyn.frm_min_dyn 0 -weight 1

	grid [ttk::radiobutton $frame.nb2.f3.fp.frch.mkmin_dyn.frm_min_dyn.rbmin -text "Minimization" -value 0 -variable ASM_GUI::run -command {
		if {$ASM_GUI::run == 0} {
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 tab 1 -state disable
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 select 0
		}
	}] \
	-row 0 -column 0 -sticky nw -pady 2 -padx 10

	grid [ttk::radiobutton $frame.nb2.f3.fp.frch.mkmin_dyn.frm_min_dyn.rbdyn -text "Molecular Dynamics" -value 1 -variable ASM_GUI::run -command {
		if {$ASM_GUI::run == 1} {
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 tab 1 -state normal
			#$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 select 1
		}
	}] \
	-row 1 -column 0 -sticky sw -pady 2 -padx 10

	set ASM_GUI::run 0

	grid [ttk::frame $frame.nb2.f3.fp.frch.mkmin_dyn_space2 -width 23 ] -row 0 -column 2 -sticky ns -pady 4
	grid columnconfigure $frame.nb2.f3.fp.frch.mkmin_dyn_space2 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.frch.mkmin_dyn_space2 0 -weight 1

	grid [ttk::frame $frame.nb2.f3.fp.frch.mkload -relief groove] -row 0 -column 3 -sticky nes -pady 4
	grid columnconfigure $frame.nb2.f3.fp.frch.mkload 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.frch.mkload 0 -weight 1

	grid [ttk::radiobutton $frame.nb2.f3.fp.frch.mkload.rdbuload -text "Load" -value 1 -variable ASM_GUI::load -command {
		if {$ASM_GUI::load == 1} {
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 tab 0 -state disable

			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 tab 1 -state disable

			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.frch.mkmin_dyn.frm_min_dyn.rbmin configure -state disable
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.frch.mkmin_dyn.frm_min_dyn.rbdyn configure -state disable
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 tab 2 -state normal
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2 select 2
			set ASM_GUI::run -1

		}
	}] -pady 4 -sticky ns -padx 2

	set ASM_GUI::load 0

	grid [ttk::frame $frame.nb2.f3.fp.frch.mkmin_dyn_space3 -width 36 ] -row 0 -column 4 -sticky nes -pady 4
	grid columnconfigure $frame.nb2.f3.fp.frch.mkmin_dyn_space3 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.frch.mkmin_dyn_space3 0 -weight 1
	#####Minimazation frame

	grid [ttk::frame $frame.nb2.f3.fp.fnt.nb2.f1.fp] -row 0 -column 0 -sticky news -padx 3 -pady 5
	grid columnconfigure $frame.nb2.f3.fp.fnt.nb2.f1.fp 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.fnt.nb2.f1.fp 0 -weight 1


	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f1.fp.lblim -text "Minimization gradient (NTMIN)"] -row 0 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f1.fp.splim -width 10 -from 0 -to 2 -increment 1] -row 0 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f1.fp.splim set 2


	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f1.fp.lbestp -text "Print energy (NTPR) (nº steps)"] -row 1 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f1.fp.spstp -width 10 -from 100 -to 100000 -increment 50] -row 1 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f1.fp.spstp set 300

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f1.fp.lbgb -text "Generalized Born (IGB)"] -row 2 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f1.fp.spgb -width 10 -from 0 -to 10 -increment 1] -row 2 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f1.fp.spgb set 5

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f1.fp.lbcut -text "Cutoff non-bounded radius (CUT) (Angs)"] -row 3 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f1.fp.spcut -width 10 -from 0 -to 30.0 -increment 1] -row 3 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f1.fp.spcut set 16.0

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f1.fp.lbmaxn -text "Maximum number of cycles (MAXCYC)"] -row 4 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f1.fp.spmaxn -width 10 -from 1 -to 500000 -increment 100] -row 4 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f1.fp.spmaxn set 3000

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f1.fp.lbntf -text "Force evaluation (NTF)"] -row 5 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f1.fp.spntf -width 10 -from 1 -to 3 -increment 1 -command {
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntc set [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntf get]
		}] -row 5 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f1.fp.spntf set 2

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f1.fp.lbntc -text "Bond length constraints (NTC)"] -row 6 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f1.fp.spntc -width 10 -from 1 -to 3 -increment 1 -command {
		$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntf set [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f1.fp.spntc get]
	}] -row 6 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f1.fp.spntc set 2

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f1.fp.lbntb -text "Periodic boundary (NTB)"] -row 7 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f1.fp.spntb -width 10 -from 0 -to 2 -increment 1] -row 7 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f1.fp.spntb set 0


	#####Dynamic frame

	grid [ttk::frame $frame.nb2.f3.fp.fnt.nb2.f2.fp] -row 0 -column 0 -sticky news -padx 3 -pady 5
	grid columnconfigure $frame.nb2.f3.fp.fnt.nb2.f2.fp 0 -weight 2; grid rowconfigure $frame.nb2.f3.fp.fnt.nb2.f2.fp 0 -weight 0

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f2.fp.lblim -text "Number of MD-steps (NSTLIM)"] -row 0 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f2.fp.splim -width 10 -from 1 -to 1000000000 -increment 500000 -command {
		$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwx configure -to [expr [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.splim get]/10]
		set lim [expr [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.splim get]/10]
		set ntwx [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwx get]
		set freq [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spfreq get]
		$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spnumst configure -text "[expr round([expr [expr $lim/$ntwx]/$freq]) +1]"
	}] -row 0 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f2.fp.splim set 10000000

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f2.fp.lbntpr -text "Print energy (NTPR) (nº steps)"] -row 1 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f2.fp.spntpr -width 10 -from 100 -to 1000000 -increment 50] -row 1 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f2.fp.spntpr set 300

        grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f2.fp.lbtmstp -text "Time step (psec)"] -row 2 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f2.fp.sptmstp -width 10 -from 0.00 -to 0.5 -increment 0.001] -row 2 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f2.fp.sptmstp set 0.002

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f2.fp.lbntwr -text "Write restart file (NTWR) (nº steps)"] -row 3 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f2.fp.spntwr -width 10 -from 100 -to 1000000 -increment 50] -row 3 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f2.fp.spntwr set 300

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f2.fp.lbntwx -text "Write coordinates file (NTWX) (nº steps)" ] -row 4 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f2.fp.spntwx -width 10 -from 100 -to 10000000 -increment 50 -command ASM_GUI::spinNwtxCheck] -row 4 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f2.fp.spntwx set 300

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f2.fp.lbntt -text "Switch for temperature scaling (NTT)"] -row 5 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f2.fp.spntt -width 10 -from 0 -to 3 -increment 1] -row 5 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f2.fp.spntt set 3

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f2.fp.lbfreq -text "MMPBSA Frequence (NFREQ)"] -row 6 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f2.fp.spfreq -width 10 -from 1 -to 50000000 -increment 1  -command ASM_GUI::spinFreqCheck] -row 6 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f2.fp.spfreq set 67

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f2.fp.lbnumst -text "MMPBSA Number of Structures"] -row 7 -column 0 -sticky w -padx 2 -pady 2
	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f2.fp.spnumst -width 12 -background white -relief sunken] -row 7 -column 1 -sticky w -padx 2 -pady 2
	set lim [expr [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.splim get]/10]
	set ntwx [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spntwx get]
	set freq [$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f2.fp.spfreq get]
	$frame.nb2.f3.fp.fnt.nb2.f2.fp.spnumst configure -text "[expr round([expr [expr $lim/$ntwx]/$freq])]"

	grid [ttk::frame $frame.nb2.f3.fp.fnt.nb2.f2.frmStb -relief sunken] -row 1 -column 0 -sticky nwe -pady 4
	grid columnconfigure $frame.nb2.f3.fp.fnt.nb2.f2.frmStb 0 -weight 2; grid rowconfigure $frame.nb2.f3.fp.fnt.nb2.f2.frmStb 0 -weight 0

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f2.frmStb.lblb -text "MD Simulation Convergence Linear Model Values"] -row 0 -column 0 -sticky w -padx 2 -pady 2

  grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f2.frmStb.lbslp -text "Slope (B) x 10^3 below or equal (<=)"] -row 1 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f2.frmStb.spslp -width 10 -from 0 -to 1 -increment 0.1] -row 1 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f2.frmStb.spslp set 0.4

  grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f2.frmStb.lbcoe -text "Correlation Coefficient (R2) above or equal (>=)"] -row 2 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f2.frmStb.spcoe -width 10 -from 0 -to 1 -increment 0.1] -row 2 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f2.frmStb.spcoe set 0.8

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f2.frmStb.lbstdv -text "Standard Deviation (STDV) below or equal (<=)"] -row 3 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f2.frmStb.spstdv -width 10 -from 0 -to 1 -increment 0.1] -row 3 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f2.frmStb.spstdv set 0.5

	###LOAD MIN/DYN
	grid [ttk::frame $frame.nb2.f3.fp.fnt.nb2.f3.fp] -row 0 -column 0 -sticky new -padx 3 -pady 5
	grid columnconfigure $frame.nb2.f3.fp.fnt.nb2.f3.fp 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.fnt.nb2.f3.fp 0 -weight 1


	grid [ttk::frame $frame.nb2.f3.fp.fnt.nb2.f3.fp.labt] -row 0 -column 0 -padx 2 -pady 2 -sticky ewn
	grid columnconfigure $frame.nb2.f3.fp.fnt.nb2.f3.fp.labt 1 -weight 2; grid rowconfigure $frame.nb2.f3.fp.fnt.nb2.f3.fp.labt 1 -weight 2
	$frame.nb2.f3.fp.fnt.nb2.f3.fp.labt configure -height 1

	grid [ttk::button $frame.nb2.f3.fp.fnt.nb2.f3.fp.labt.btload -text "Load" -padding "5 0 1 0" -command {
		set file [tk_getOpenFile]
		if {$file != ""} {


			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.labt.lbload configure -text $file
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstop configure -state normal
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstart configure -state normal
			$ASM_GUI::topGui.nb1.f1.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spfreq configure -state normal
		}
	}] -row 0 -column 0 -sticky we -pady 2

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f3.fp.labt.lbload -background white -relief sunken -wraplength 280] -row 0 -column 1 -sticky ewns -padx 2 -pady 2

	grid [ttk::frame $frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa ] -row 1 -column 0 -sticky news -padx 3 -pady 5
	grid columnconfigure $frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa 0 -weight 1; grid rowconfigure $frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa 0 -weight 1


	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.lbstart -text "MMPBSA Start structure (NSTAR)"] -row 0 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstart -from 1 -to 50000000 -increment 1] -row 0 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstart set 0

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.lbstop -text "MMPBSA Stop structure (NSTOP)"] -row 1 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstop -from 1 -to 50000000 -increment 1] -row 1 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstop set 1667

	grid [ttk::label $frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.lbfreq -text "MMPBSA Frequence (NFREQ)"] -row 2 -column 0 -sticky w -padx 2 -pady 2
	grid [spinbox $frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spfreq -from 1 -to 50000000 -increment 1] -row 2 -column 1 -sticky w -padx 2 -pady 2
	$frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spfreq set 67

	$frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstop configure -state disable
	$frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spstart configure -state disable
	$frame.nb2.f3.fp.fnt.nb2.f3.fp.fmmpbsa.spfreq configure -state disable


	###Leap force fild

	grid [ttk::labelframe $frame.nb2.f4.fp -text "Leap force field"] -row 0 -column 0 -sticky nwe -padx 3 -pady 3
	grid columnconfigure $frame.nb2.f4.fp 0 -weight 1; grid rowconfigure $frame.nb2.f4.fp 0 -weight 0

	grid [ttk::frame $frame.nb2.f4.fp.frleap] -row 0 -column 0 -sticky nwes
	grid columnconfigure $frame.nb2.f4.fp.frleap 1 -weight 1; grid rowconfigure $frame.nb2.f4.fp.frleap 0 -weight 1

	grid [ttk::label $frame.nb2.f4.fp.frleap.frc -text "Force field: " -padding "8 0 3 0"] -row 0 -column 0 -sticky wn -padx 3

	set val {leaprc.Glycam.06 leaprc.ff84 leaprc.ff99SB leaprc.rna.ff02EP leaprc.ff02pol.r0 leaprc.ff86 leaprc.ffAM1 leaprc.rna.ff84 leaprc.ff02pol.r1 leaprc.ff94 leaprc.ffPM3 leaprc.rna.ff98\
	leaprc.ff02polEP.r0 leaprc.ff94.nmr leaprc.gaff leaprc.rna.ff99 leaprc.ff02polEP.r1 leaprc.ff96 leaprc.glycam04 leaprc.toyrna\
	leaprc.ff03 leaprc.ff98 leaprc.glycam04EP protein.cmd leaprc.ff03ua leaprc.ff99 leaprc.rna.ff02}
	set val [split $val " "]
	set val [lappend val "other..."]
	grid [ttk::combobox $frame.nb2.f4.fp.frleap.cmb -values $val ] -row 0 -column 1 -sticky ewn -padx 3
	$frame.nb2.f4.fp.frleap.cmb set "leaprc.ff03"

	bind $ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frleap.cmb <<ComboboxSelected>> {
		if {[$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frleap.cmb get] == "other..."} {
			set file [tk_getOpenFile]
			if {$file != ""} {
				$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld insert end $file
			}

		}
	}

	grid [ttk::frame $frame.nb2.f4.fp.frmlist] -row 1 -column 0 -sticky en -padx 3
	grid columnconfigure $frame.nb2.f4.fp.frmlist 0 -weight 0; grid rowconfigure $frame.nb2.f4.fp.frmlist 0 -weight 0

	set frame_list $frame.nb2.f4.fp.frmlist
	$frame_list configure -width 47

	grid [tk::listbox $frame_list.lffld] -row 0 -column 0 -sticky ne
	$frame_list.lffld configure -yscrollcommand [list $frame_list.scr1 set] -xscrollcommand [list $frame_list.scr2 set] -width 47 -height 5 -selectmode multiple \
	-foreground blue

	 ##Scrool_BAr V
		 scrollbar $frame_list.scr1 -orient vertical -command [list $frame_list.lffld yview]
		 grid $frame_list.scr1 -row 0 -column 1  -sticky ens
	 ###Scrool_Bar H
		scrollbar $frame_list.scr2 -orient horizontal -command [list $frame_list.tb xview]
		grid $frame_list.scr2 -row 1 -column 0 -sticky ews




	grid [ttk::frame $frame.nb2.f4.fp.frmbutt] -row 2 -column 0 -sticky ne -pady 2 -padx 2
	grid columnconfigure $frame.nb2.f4.fp.frmbutt 0 -weight 0; grid rowconfigure $frame.nb2.f4.fp.frmbutt 0 -weight 0
	$frame.nb2.f4.fp.frmbutt configure -width 34

	grid [ttk::button $frame.nb2.f4.fp.frmbutt.butadd -text "Add force field" -width 23 -command ASM_GUI::addFfld -padding "1 1 1 1"] -row 0 -column 0
	grid [ttk::button $frame.nb2.f4.fp.frmbutt.butdel -text "Delete force field" -width 24 -command ASM_GUI::delFfld -padding "1 1 1 1"] -row 0 -column 1 -padx 1

	$ASM_GUI::topGui.nb1.f1.nb2.f4.fp.frmlist.lffld insert end "leaprc.ff03"

	grid [ttk::labelframe $frame.nb2.f4.fextfil -text "Extra Files"] -row 1 -column 0 -sticky nwse -padx 3 -pady 3
	grid columnconfigure $frame.nb2.f4.fextfil 0 -weight 1; grid rowconfigure $frame.nb2.f4.fextfil 0 -weight 0

	grid [ttk::frame $frame.nb2.f4.fextfil.frload] -row 0 -column 0 -sticky nwe -pady 6
	grid columnconfigure  $frame.nb2.f4.fextfil.frload 1 -weight 1; grid rowconfigure  $frame.nb2.f4.fextfil.frload 0 -weight 1

	grid [ttk::label $frame.nb2.f4.fextfil.frload.lbres -text "HETATM residue name" -padding "10 0 3 0"] -row 0 -column 0 -sticky nwe



	grid [ttk::combobox $frame.nb2.f4.fextfil.frload.cmb ] -row 0 -column 1 -sticky wne -padx 4

	bind $frame.nb2.f4.fextfil.frload.cmb <<ComboboxSelected>> {ASM_GUI::changeComboLoad}


	grid [ttk::frame $frame.nb2.f4.fextfil.frfiles] -row 1 -column 0 -sticky nwe -pady 4
	grid columnconfigure $frame.nb2.f4.fextfil.frfiles 1 -weight 2; grid rowconfigure  $frame.nb2.f4.fextfil.frfiles 0 -weight 1

	grid [ttk::label $frame.nb2.f4.fextfil.frfiles.lbmol -text "Mol2 file" -padding "10 0 3 0"] -row 0 -column 0 -sticky we -padx 4 -pady 2
	grid [ttk::entry $frame.nb2.f4.fextfil.frfiles.entmol] -row 0 -column 1 -sticky we
	grid [ttk::button $frame.nb2.f4.fextfil.frfiles.bumol -padding "8 0 3 0" -text "Load" -command {
		set types {
			{{Mol2}       {.mol2}        }
		}
		set file [tk_getOpenFile -filetypes $types]
		if {$file != ""} {
			$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entmol delete 0 end
			$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entmol insert end $file
		}
	}] -row 0 -column 2 -padx 2 -pady 2 -sticky w

	grid [ttk::label $frame.nb2.f4.fextfil.frfiles.lbfrcmod -text "FrcMod file" -padding "10 0 3 0"] -row 1 -column 0 -sticky we -padx 4 -pady 2
	grid [ttk::entry $frame.nb2.f4.fextfil.frfiles.entfrcmod] -row 1 -column 1 -sticky we
	grid [ttk::button $frame.nb2.f4.fextfil.frfiles.butfrcmod -padding "8 0 3 0" -text "Load" -command {
		set types {
			{{Parameters}       {.frcmod}        }
		}
		set file [tk_getOpenFile -filetypes $types]
		if {$file != ""} {
			$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entfrcmod delete 0 end
			$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entfrcmod insert end $file
		}
	}] -row 1 -column 2 -padx 2 -pady 2 -sticky w

	grid [ttk::frame $frame.nb2.f4.fextfil.frmadel] -row 2 -column 0 -padx 2 -pady 2 -sticky e


	grid [ttk::button $frame.nb2.f4.fextfil.frmadel.butadd -padding "8 0 3 0" -text "Add" -command {
		set st ""
		set resname [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb columncget 0 -text]
		set st [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frload.cmb get]
		if {[lsearch $resname $st] == -1 && ($st != "")} {
			set mol [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entmol get]
			set frcmod [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entfrcmod get]

			if {$mol != ""} {
				set st [lappend st $mol]
			} else {
				set st [lappend st " "]
			}

			if {$frcmod != ""} {
				set st [lappend st $frcmod]
			} else {
				set st [lappend st " "]
			}
			if {[string trim $st "{ }"] != [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frload.cmb get]} {
				$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb insert end $st

			}
		} elseif {[lsearch $resname $st] != -1 && ($st != "")} {
			set ind [lsearch $resname $st]
			set mol [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entmol get]
			set frcmod [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frfiles.entfrcmod get]

			if {$mol != ""} {
				set st [lappend st $mol]
			} else {
				set st [lappend st " "]
			}

			if {$frcmod != ""} {
				set st [lappend st $frcmod]
			} else {
				set st [lappend st " "]
			}
			set line [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb get $ind]
			if {$line != $st} {
				$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb delete $ind
				$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb insert $ind $st
			}
		}


	}] -row 0 -column 0 -padx 2 -pady 2 -sticky e
	grid [ttk::button $frame.nb2.f4.fextfil.frmadel.butdel -padding "8 0 3 0" -text "Delete" -command {
		set ind [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb curselection]

		if {$ind != -1} {
			$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb delete $ind
		}
	}] -row 0 -column 1 -padx 2 -pady 2 -sticky e

	grid [ttk::frame $frame.nb2.f4.fextfil.fmtb -padding "10 4 3 0"] -row 3 -column 0 -sticky we
	grid columnconfigure $frame.nb2.f4.fextfil.fmtb 0 -weight 1; grid rowconfigure $frame.nb2.f4.fextfil.fmtb 0 -weight 1

	set fro2 $frame.nb2.f4.fextfil.fmtb

	option add *Tablelist.activeStyle       frame
	option add *Tablelist.background        gray98
	option add *Tablelist.stripeBackground  #e0e8f0
	option add *Tablelist.setGrid           yes
	option add *Tablelist.movableColumns    no
	option add *Tablelist.labelCommand      tablelist::sortByColumn
	tablelist::tablelist $fro2.tb \
	    -columns {	0 "Resname"	 center
			0 "Mol2"	 center
			0 "FrcMod"	 center} \
	    -yscrollcommand [list $fro2.scr1 set] -xscrollcommand [list $fro2.scr2 set] \
	    -showseparators 0 -labelrelief groove  -labelbd 1 -selectbackground blue -selectforeground white\
	    -foreground black -state normal -selectmode multiple -width 38 -height 7 -stretch "1 2"

	$fro2.tb columnconfigure 0 -sortmode dictionary -name "Resname"
	$fro2.tb columnconfigure 1 -sortmode dictionary -name "Mol2"
	$fro2.tb columnconfigure 2 -sortmode dictionary -name "FrcMod"

	grid $fro2.tb -row 0 -column 0 -sticky news
	grid columnconfigure $fro2.tb 0 -weight 1; grid rowconfigure $fro2.tb 0 -weight 2

	##Scrool_BAr V
	scrollbar $fro2.scr1 -orient vertical -command [list $fro2.tb  yview]
	    grid $fro2.scr1 -row 0 -column 1  -sticky ens
	###Scrool_Bar H
	    scrollbar $fro2.scr2 -orient horizontal -command [list $fro2.tb xview]
	    grid $fro2.scr2 -row 1 -column 0 -sticky swe

	bind [$fro2.tb bodytag] <ButtonRelease> {
		set res [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb curselection]
                if {$res != ""} {
                    $ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.frload.cmb set [$ASM_GUI::topGui.nb1.f1.nb2.f4.fextfil.fmtb.tb cellcget $res,0 -text]
                    ASM_GUI::changeComboLoad
                }

	}
}

proc ASM_GUI::emptyStr val {
     return " "
}
