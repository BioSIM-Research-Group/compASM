package provide outputframe 1.0

proc ASM_GUI::buildOutputFrame {frame opt } {
    if {$opt == 0} {
        grid [ttk::notebook $frame.nb1 -padding "2 10 2 5"] -row 0 -column 0 -sticky news
        
    }

    grid columnconfigure $frame.nb1  0 -weight 1; grid rowconfigure $frame.nb1 0 -weight 0
	grid [ttk::frame $frame.nb1.f1] -sticky news
	grid columnconfigure $frame.nb1.f1 0 -weight 1; grid rowconfigure $frame.nb1.f1 0 -weight 1

	grid [ttk::frame $frame.nb1.f2] -sticky news
	grid columnconfigure $frame.nb1.f2 0 -weight 1; grid rowconfigure $frame.nb1.f2 0 -weight 1

	$frame.nb1 add $frame.nb1.f1 -text "Score" -sticky news
	$frame.nb1 add $frame.nb1.f2 -text "Dynamics" -sticky news

	##Build Score frame

	grid [ttk::frame $frame.nb1.f1.fp] -row 0 -column 0 -sticky nswe
	grid columnconfigure $frame.nb1.f1.fp  0 -weight 1; grid rowconfigure $frame.nb1.f1.fp 1 -weight 2

	grid [ttk::labelframe $frame.nb1.f1.fp.frmrep -text "Representation Manager" -padding "2 2 2 2"] -row 0 -column 0 -sticky news -padx 2 -pady 2
	grid columnconfigure $frame.nb1.f1.fp.frmrep 0 -weight 1; grid rowconfigure $frame.nb1.f1.fp.frmrep 0 -weight 0
	grid [ttk::frame $frame.nb1.f1.fp.frmrep.frmlb -padding "130 0 6 4"] -row 0 -column 0 -sticky news
	grid [ttk::radiobutton $frame.nb1.f1.fp.frmrep.frmlb.chelig -text "Ligand" -variable ASM_GUI::radio_rep -value 0 ] -row 0 -column 0 -sticky n -pady 4 -padx 6
	grid [ttk::radiobutton $frame.nb1.f1.fp.frmrep.frmlb.cherec -text "Receptor" -variable ASM_GUI::radio_rep -value 1 ] -row 0 -column 1 -sticky n -pady 4
	grid [ttk::frame $frame.nb1.f1.fp.frmrep.frmcombo] -row 1 -column 0 -sticky news -pady 4

	grid [ttk::label $frame.nb1.f1.fp.frmrep.frmcombo.lbtype -text "Representation Type :" -padding "10 0 6 0"] -row 1 -column 0 -sticky nw
	set rep "Off Beads Surf NewCartoon VDW"
	set mat "Opaque Transparent"
	ttk::style map TCombobox -fieldbackground [list readonly #ffffff]
	grid [ttk::combobox $frame.nb1.f1.fp.frmrep.frmcombo.cmbtype -values $rep -width 14 -state readonly -style TCombobox] -row 1 -column 1 -sticky nw
	$frame.nb1.f1.fp.frmrep.frmcombo.cmbtype set "Beads"
	grid [ttk::combobox $frame.nb1.f1.fp.frmrep.frmcombo.cmbmat -values $mat -width 14 -state readonly -style TCombobox] -row 1 -column 2 -sticky nw -padx 4
	$frame.nb1.f1.fp.frmrep.frmcombo.cmbmat set "Opaque"

    bind $frame.nb1.f1.fp.frmrep.frmcombo.cmbtype <<ComboboxSelected>> {
        $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbtype set [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.frmrep.frmcombo.cmbtype get]
        ASM_GUI::changemutTabRep
    }
    bind $frame.nb1.f1.fp.frmrep.frmcombo.cmbmat <<ComboboxSelected>> {
        $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frmrep.frmcombo.cmbmat set [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.frmrep.frmcombo.cmbmat get]
        ASM_GUI::changemutTabRep
    }

    ttk::style map TRadiobutton -background [list active #d9d9d9]
    $frame.nb1.f1.fp.frmrep.frmlb.chelig configure -style TRadiobutton
    $frame.nb1.f1.fp.frmrep.frmlb.cherec configure -style TRadiobutton


	grid [ttk::labelframe $frame.nb1.f1.fp.fdt -text "Resumed Info"] -column 0 -row 1 -sticky nswe -pady 2 -padx 2
	grid columnconfigure $frame.nb1.f1.fp.fdt 0 -weight 1; grid rowconfigure $frame.nb1.f1.fp.fdt 0 -weight 1

	set fro2 $frame.nb1.f1.fp.fdt

	option add *Tablelist.activeStyle       frame
	option add *Tablelist.background        gray98
	option add *Tablelist.stripeBackground  #e0e8f0
	option add *Tablelist.setGrid           yes
	option add *Tablelist.movableColumns    no
	option add *Tablelist.labelCommand      tablelist::sortByColumn
	tablelist::tablelist $fro2.tb \
	    -columns {	0 "Mutation index"	 center
			0 "Residue(s)"	 center
			0 "PBTOT"	 center
			0 "STDV"	 center
			0 "Score"	 center} \
	    -yscrollcommand [list $fro2.scr1 set] -xscrollcommand [list $fro2.scr2 set] \
	    -showseparators 0 -labelrelief groove  -labelbd 1 -selectbackground blue -selectforeground white\
	    -foreground black -state normal -selectmode multiple -stretch "2 3 4"


	$fro2.tb columnconfigure 0 -sortmode real -name "Mutation index"
	$fro2.tb columnconfigure 1 -sortmode dictionary -name "Residue(s)"
	$fro2.tb columnconfigure 2 -sortmode real -name "PBTOT"
	$fro2.tb columnconfigure 3 -sortmode real -name "STDV"
	$fro2.tb columnconfigure 4 -sortmode dictionary -name "Score"

	#$fro2.tb columnconfigure 0 -sortmode dictionary -name "Chain ID"
	grid $fro2.tb -row 0 -column 0 -sticky news
	grid columnconfigure $fro2.tb 0 -weight 1; grid rowconfigure $fro2.tb 0 -weight 1

	##Scrool_BAr V
	scrollbar $fro2.scr1 -orient vertical -command [list $fro2.tb  yview]
	    grid $fro2.scr1 -row 0 -column 1  -sticky ens
	## Scrool_Bar H
	    scrollbar $fro2.scr2 -orient horizontal -command [list $fro2.tb xview]
	    grid $fro2.scr2 -row 1 -column 0 -sticky swe

	bind [$fro2.tb bodytag] <ButtonRelease> {
        set id [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb curselection]
		$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb configure -state normal
        ASM_GUI::selTable
        ASM_GUI::tbMutSel
		$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb configure -state disable
        $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb selection set $id
    }


    grid [ttk::button $frame.nb1.f1.fp.btgraph -text "Detailed table" -command {ASM_GUI::creatTable}] -row 2 -column 0 -sticky e -pady 3 -padx 3

	##Build Dynamics frame

	grid [ttk::frame $frame.nb1.f2.fp] -row 0 -column 0 -sticky nswe
	grid columnconfigure $frame.nb1.f2.fp 0 -weight 1; grid rowconfigure $frame.nb1.f2.fp 0 -weight 1

	grid [ttk::labelframe $frame.nb1.f2.fp.feq -text "Molecular Dynamics"] -column 0 -row 0 -pady 2 -padx 2 -sticky news
	grid columnconfigure $frame.nb1.f2.fp.feq 0 -weight 1; grid rowconfigure $frame.nb1.f2.fp.feq 1 -weight 2

	grid [ttk::frame $frame.nb1.f2.fp.feq.fwd] -row 0 -column 0 -pady 2 -padx 2 -sticky news
	grid columnconfigure $frame.nb1.f2.fp.feq.fwd 0 -weight 1; grid rowconfigure $frame.nb1.f2.fp.feq.fwd 0 -weight 1

	grid [ttk::label $frame.nb1.f2.fp.feq.fwd.lbtex -text "Equilibration Values : "] -row 0 -column 0 -pady 6 -padx 5 -sticky w

	grid [ttk::frame $frame.nb1.f2.fp.feq.fwd.frmsd -padding "0 0 0 4"] -row 1 -column 0 -sticky news
	grid columnconfigure $frame.nb1.f2.fp.feq.fwd.frmsd 0 -weight 1; grid rowconfigure $frame.nb1.f2.fp.feq.fwd.frmsd 0 -weight 1

	set fro2 $frame.nb1.f2.fp.feq.fwd.frmsd

	option add *Tablelist.activeStyle       frame
	option add *Tablelist.background        gray98
	option add *Tablelist.stripeBackground  #e0e8f0
	option add *Tablelist.setGrid           yes
	option add *Tablelist.movableColumns    no
	option add *Tablelist.labelCommand      tablelist::sortByColumn

	tablelist::tablelist $fro2.tb \
	    -columns {0 "Time (psec)"	 center
                0 "Slope *10³"	 center
                0 "R²"	 center
                0 "STDV"	 center
				0 "FRMI"	 center
				0 "FRMF"	 center
                0 "Converged"	 center} \
	    -yscrollcommand [list $fro2.scr1 set] -xscrollcommand [list $fro2.scr2 set] \
	    -showseparators 0 -labelrelief groove  -labelbd 1 -selectbackground blue -selectforeground white\
	    -foreground black -state normal -selectmode multiple -width 38 -height 5 -stretch all

    $fro2.tb columnconfigure 0 -sortmode real -name "Time (psec)"
    $fro2.tb columnconfigure 1 -sortmode real -name "Slope *10³"
    $fro2.tb columnconfigure 2 -sortmode real -name "R²"
    $fro2.tb columnconfigure 2 -sortmode real -name "STDV"
	$fro2.tb columnconfigure 2 -sortmode real -name "FRIMI"
	$fro2.tb columnconfigure 2 -sortmode real -name "FRIMF"
    $fro2.tb columnconfigure 2 -sortmode dictionary -name "Converged"
    grid $fro2.tb -row 0 -column 0 -sticky news
    grid columnconfigure $fro2.tb 0 -weight 1; grid rowconfigure $fro2.tb 0 -weight 1

	##Scrool_BAr V
	scrollbar $fro2.scr1 -orient vertical -command [list $fro2.tb  yview]
	    grid $fro2.scr1 -row 0 -column 1  -sticky ens
	###Scrool_Bar H
	    scrollbar $fro2.scr2 -orient horizontal -command [list $fro2.tb xview]
	    grid $fro2.scr2 -row 1 -column 0 -sticky swe


    grid [ttk::label $frame.nb1.f2.fp.feq.fwd.lbgraph -text "RMSD Values Plot: "] -row 2 -column 0 -pady 6 -padx 5 -sticky w
    grid [ttk::frame $frame.nb1.f2.fp.feq.fwd.fgraph -relief groove -width 5 -height 5] -row 3 -column 0 -sticky news -pady 10
    ASM_GUI::makegraph $frame.nb1.f2.fp.feq.fwd.fgraph 0
    
    grid [ttk::frame $frame.nb1.f2.fp.feq.fwd.frbtgraph] -row 4 -column 0 -sticky we
    grid [ttk::checkbutton $frame.nb1.f2.fp.feq.fwd.frbtgraph.chkpnt -text "Display RMSD Points" -command {ASM_GUI::creatDynamics 1} -variable ASM_GUI::rmsValue] -row 0 -column 0 -sticky we -pady 2 -padx 2
}

proc ASM_GUI::selTable {} {
    set ind_list ""
    set id [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb curselection]
    if {[llength [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb columncget 0 -text]] > 0 && $id != ""} {
        set j 0
        while {[lindex $id $j]!= ""} {
            set mut [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb cellcget [lindex $id $j],0 -text]
            set all_mut [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb columncget 0 -text]
            set index [lsearch $all_mut $mut]
            set ind_list [lappend ind_list $index]
            incr j
        }
		$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb selection clear 0 end
		$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb selection set $ind_list
    } elseif {$id == ""} {
		$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb selection clear 0 end
	}
    
}