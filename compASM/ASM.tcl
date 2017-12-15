lappend auto_path /opt/programs/vmd/plugins/compASM
package provide ASM 1.0

namespace eval ::ASM:: {
    global variable tcl_precision 17
			package require ASM_PATH 1.0

    variable install [ASM_Path::install]
    variable delphi [ASM_Path::delphi]
    variable Amber [ASM_Path::amber [lindex $argv 1]]
    variable machine [ASM_Path::machine]
	package require ASM_Constant 1.0
    lappend auto_path $install/Core
    package require chargefile 1.0
    package require tleapop 1.0
    package require pdboperation 1.0
    package require min 1.0
    package require mmpbsa 1.0
    lappend auto_path $install/Core/LIB/
	package require math 1.2.4
    package require math::statistics 0.5
    package require math::bignum
    package require Thread
    lappend auto_path $install
    array set mut_name ""
    variable proce ""
    array set result ""
    variable IDproce 0
    array set id ""
    array set pdb ""
    variable TER "0"
    variable debug ""
    variable ligand_atoms ""
    variable receptor_atoms ""
    variable complex_atoms ""
    variable rms_x ""
    variable rms_y ""
    variable debug 1
    variable procid ""
    variable version "1.0"
	set proce 2
    if {$::tcl_platform(os) == "Darwin"} {
      catch {exec sysctl -n hw.ncpu} proce
    } elseif {$::tcl_platform(os) == "Linux"} {
      catch {exec grep -c "model name" /proc/cpuinfo} proce
    }

    ### NUNO alterar
    set proce 1
    ###

    variable proce $proce
    variable log ""
    variable out_file ""
    variable list_2 "VAL LEU ILE PHE MET TRP"
    variable list_3 "ASN GLN CYS TYR SER THR CYM CYX"
    variable list_4 "ASP GLU LYS ARG HIS HIE HID HIP LYN GLH ASH ACE"

}

proc ::ASM::run {dirf} {

  set ASM::procid ""
  set inputfile [open $dirf r+]
  set un "_"
  set inf_st_min ""
  set inf_dyn_wm ""
  set hetat ""
  set forfld ""
  set leapadd 1
  set opt -1
  set char "!"
  set inf 0
  set mmpbsa ""
  array set MD ""
  while {[eof $inputfile]!=1} {
    set linha [gets $inputfile]
    if {$inf == 0 && [string repeat "#" 100] == $linha } {
      set linha [gets $inputfile]
      while {[string repeat "#" 100] == $linha} {
        set linha [gets $inputfile]
      }
      set inf 1
    }
    if {$linha == "##PROTEIN"} {
        while {[string index $linha 0] == $char} {
          set linha [gets $inputfile]
        }
        set linha [gets $inputfile]
        set prot_in "[pwd]/$linha"

        set dir_out "[pwd]/"
        set dir_prot [split $dirf "/"]

        set name [file rootname [lindex $dir_prot end]]
        if {[file exists $dir_out$name ]!=1} {
            file mkdir $dir_out$name
        }
        set dirf "$dir_out$name"
        set ASM::log [open $dirf/log.txt w+]
        set ASM::out_file [open $dirf/ASM.out w+]
        puts $ASM::out_file [string repeat "#" 100]
        puts $ASM::out_file "[string repeat " " 20] ASM version $ASM::version\n\n"
        ::ASM::printDebug [string repeat "#" 100]
        ::ASM::printDebug "Start"
        ::ASM::printDebug "Reading Inputfile"
    } elseif {$linha == "##MUTATIONS"} {
      set linha [gets $inputfile]
      while {$linha != "END"} {
          if {[string index $linha 0] != $char} {
            set mut [lappend mut $linha]
          }
          set linha [gets $inputfile]
      }
    } elseif {$linha == "##LIGAND"} {
      set linha [gets $inputfile]
      while {$linha != "END"} {
        if {[string index $linha 0] != $char} {
          set ligand [lappend ligand $linha]
        }
        set linha [gets $inputfile]
      }
    } elseif {$linha == "##RECEPTOR"} {
      set linha [gets $inputfile]
      while {$linha != "END"} {
        if {[string index $linha 0] != $char} {
          set receptor [lappend receptor $linha]
        }
        set linha [gets $inputfile]
      }

    } elseif {$linha == "##Minimization_Dynamic Parameters"} {
      set inf ""
      set leapadd 1
      set linha [gets $inputfile]
      set linha [string trim $linha]
      while {$linha != "END"} {
          if { $linha != "" && [string index $linha 0] != $char} {
              set inf [lappend inf [string trim $linha "," ]]
              set eqind [string last "=" $linha]
              set str [string range $linha 0 [expr $eqind -1]]
              set str [string trim $str]
              set val [string trim [string range $linha [expr $eqind +1] end ] ]
              if {$str == "igb" && ( $val== 5 || $val== 2)} {
                set leapadd 1
              }
          }
          set linha [gets $inputfile]
          set linha [string trim $linha]
      }
      set opt 1
      set min_text $inf
    } elseif {$linha == "##MD Linear Model Values"} {
      set linha [gets $inputfile]
      set linha [string trim $linha " "]
      while {$linha != "END"} {
          if { $linha != "" && [string index $linha 0] != $char} {
              set val [split $linha "="]
              set MD([string trim [string trim [lindex $linha 0]  "="] " "]) [string trim [lindex $linha 1]  " "]
          }
          set linha [gets $inputfile]
      }
    } elseif {$linha == "##Starting Minimization Parameters"} {
      set inf_st_min ""
      set linha [gets $inputfile]
      set linha [string trim $linha]
      while {$linha != "END"} {
          if {$linha != "" && [string index $linha 0] != $char} {
            set inf_st_min [lappend inf_st_min [string trim $linha "," ]]
          }
          set linha [gets $inputfile]
          set linha [string trim $linha]
      }
    } elseif {$linha == "##Warming Dynamic Parameters"} {
      set inf_dyn_wm ""
      set linha [gets $inputfile]
      set linha [string trim $linha]
      while {$linha != "END"} {
          if {$linha != "" && [string index $linha 0] != $char} {
              set inf_dyn_wm [lappend inf_dyn_wm [string trim $linha " " ]]
          }
          set linha [gets $inputfile]
          set linha [string trim $linha]
      }
    } elseif {$linha == "##MMPBSA Parameters"} {
      set mmpbsa ""
      set linha [gets $inputfile]
          while {$linha != "END"} {
              if {[string index $linha 0] != $char} {
              set mmpbsa [lappend mmpbsa $linha]
              set mmpbsa_aux [split $linha " "]
              if {[lsearch $mmpbsa_aux "NFREQ"] != -1} {
                  set i 0
                  while {$i < [llength $mmpbsa_aux]} {
                      if {[lindex $mmpbsa_aux $i] != "NFREQ" && [string trim [lindex $mmpbsa_aux $i] " "] != "" } {
                          if {[lindex $mmpbsa_aux $i] == 1} {
                              set opt 1
                          } else {
                              set opt 0
                          }
                      }
                      incr i
                  }

              }
            }
            set linha [gets $inputfile]
          }
          if {[llength $mmpbsa] ==4} {
            set opt 2
          }
      } elseif {$linha == "##FORCE FIELDS"} {
        set linha [gets $inputfile]
        set forfld ""
        while {$linha != "END"} {
          if {[string index $linha 0] != $char} {
            set forfld [lappend forfld $linha]
          }
          set linha [gets $inputfile]
        }
        if {$forfld == ""} {
          set forfld leaprc.ff03
        }
      } elseif {$linha == "##HETAOMS Parameters"} {
        set linha [gets $inputfile]
        set hetat ""
        while {$linha != "END"} {
          if {[string index $linha 0] != $char} {
            set hetat [lappend hetat $linha]
          }
          set linha [gets $inputfile]
        }

      }
    }
    close $inputfile

    if {$hetat != "" && [expr fmod([llength $hetat],3)] != 0} {
        ::ASM::printDebug "HETAOMS Parameters are not completed"
        exit
    }
    puts $ASM::out_file "##Protein information\n"
    puts $ASM::out_file [string repeat "=" 60]
    set name [file tail $prot_in]
    set name [split $name "."]
    set filename [lindex $name 0]

    puts $ASM::out_file "Protein: $filename"
    ::ASM::printDebug "Creating Amber Complex from $prot_in"
    ::ASM::amber $prot_in $dirf/strct/wldtp Complex wldtp $leapadd $forfld $hetat
    ::ASM::pdbMem $dirf/strct/wldtp/Complex/Complex_wldtp.pdb
    ::ASM::printDebug "Creating Ligand and Receptor from $prot_in"
    ::ASM::ligand_receptor $ligand $receptor $dirf
    ::ASM::amber $dirf/strct/wldtp/ligand/Complex.pdb $dirf/strct/wldtp ligand ligand_wt $leapadd $forfld $hetat
    ::ASM::amber $dirf/strct/wldtp/receptor/Complex.pdb $dirf/strct/wldtp receptor receptor_wt $leapadd $forfld $hetat

    ####Write protein information

    set ligand [split [string trimright [string trimleft $ligand "{"] "}"] " "]
    set receptor [split [string trimright [string trimleft $receptor "{"] "}"] " "]
    puts $ASM::out_file [string repeat "=" 60]
    puts $ASM::out_file "[string repeat " " 16]Chain(s) number  Residue_id Range"
    set space [expr 7 - [expr [string length $ligand]/2] ]
    set ligand_range "Ligand Chain   [string repeat " " $space]$ligand  [string repeat " " $space]"
    set i 0
    set j 0
    while {[lindex $ligand $i] != ""} {
        set ini [string trim [lindex $ASM::ligand_atoms [expr 0 + $j ]] " "]
        set ini [split [string trimright [string trimleft $ini "{"] "}"] " "]
        set fin [string trim [lindex $ASM::ligand_atoms [expr 1 + $j ] ] " " ]
        set fin [split [string trimright [string trimleft $fin "{"] "}"] " "]
        set fin [expr $fin - 1]
        if {$i > 0} {
          set ligand_range [append ligand_range  "\n[string repeat " " [expr 44 - [string length "$ASM::pdb($ini,6) - $ASM::pdb($fin,6)"]]]" ]
        }
        set ligand_range [append ligand_range "$ASM::pdb($ini,6) - $ASM::pdb($fin,6)"]
        incr i
        incr j 2
    }
    puts $ASM::out_file $ligand_range

    set space [expr 7 - [expr [string length $receptor]/2] ]

    set receptor_range "Receptor Chain [string repeat " " $space]$receptor    [string repeat " " $space]"
    set i 0
    set j 0
    while {[lindex $receptor $i] != ""} {
        set ini [string trim [lindex $ASM::receptor_atoms [expr 0 + $j ]] " "]
        set ini [split [string trimright [string trimleft $ini "{"] "}"] " "]
        set fin [string trim [lindex $ASM::receptor_atoms [expr 1 + $j ] ] " " ]
        set fin [split [string trimright [string trimleft $fin "{"] "}"] " "]
        set fin [expr $fin - 1]
        if {$i > 0} {
          set receptor_range [append receptor_range  "\n[string repeat " " [expr 44 - [string length "$ASM::pdb($ini,6) - $ASM::pdb($fin,6)"]]]" ]
        }
        set receptor_range [append receptor_range "$ASM::pdb($ini,6) - $ASM::pdb($fin,6)"]
        incr i
        incr j 2
    }
    puts $ASM::out_file $receptor_range
    puts $ASM::out_file "[string repeat "=" 60]\n\n"

    ::ASM::printDebug "Generating Charge Files"
    ::ASM::creatCharge $dirf
	set last ""
    if { [llength $mmpbsa] != 4 && $opt != 2} {
      if {$opt == 1} {
        set eqind [string last "=" [lindex $min_text 0]]
        set opt [string trim [string range [lindex $min_text 0] [expr $eqind +1] end]]
        set opt [string trim $opt]
        set last [::ASM::min_dyn_run $dirf $min_text $opt $inf_st_min $inf_dyn_wm 1 0]
        puts $ASM::out_file "## Minimisation Information\n"
        puts $ASM::out_file "[string repeat "=" 110]\n"
        puts $ASM::out_file "A minimisation was performed using the key words \n presented in the file $dirf/min_dyn/min_dyn_ala.in"
        puts $ASM::out_file "[string repeat "=" 110]\n"
      } else {
        set eqind [string last "=" [lindex $min_text 0]]
        set opt [string trim [string range [lindex $min_text 0] [expr $eqind +1] end]]
        set opt [string trim $opt]
        set i 0
        set mmpbsa_aux [split [lindex $mmpbsa 0] " "]
        while {$i < [llength $mmpbsa_aux]} {
          if {[lindex $mmpbsa_aux $i] != " " && [lindex $mmpbsa_aux $i] != "NFREQ"} {
            set freq [lindex $mmpbsa_aux $i]
          }
          incr i
        }
        if {[array get MD] == ""} {
          set MD(B) 0.4
          set MD(R) 0.8
          set MD(STDV) 0.5
        }
        puts $ASM::out_file "## Molecular Dynamics Information\n"
        puts $ASM::out_file "[string repeat "=" 110]\n"
        puts $ASM::out_file "Molecular Dynamics Convergence table"
        puts $ASM::out_file "Convergence values: B <= $MD(B); R2 >= $MD(R); STDV <= $MD(STDV)"
        puts $ASM::out_file "[string repeat "=" 60]"
        puts $ASM::out_file "Time\tSlope\tR2\tSTDV\tFRMI\tFRMF\tConverged"
        puts $ASM::out_file "[string repeat "=" 60]"

        set last [::ASM::min_dyn_run $dirf $min_text $opt $inf_st_min $inf_dyn_wm $freq [array get MD]]
        puts $ASM::out_file "[string repeat "=" 60]\n"
        puts $ASM::out_file "\nLegend: \n"
        puts $ASM::out_file "All values are refered to the linear regression of the molecular dynamics RMSD\n\nSlope = Slope of the straight * 10^3\nR2 = Correlation coefficient\nSTDV = Strandard deviation of RMSD points"
        puts $ASM::out_file "[string repeat "=" 110]\n"
        puts $ASM::out_file "Minimization: $dirf/min_dyn/st_min_ala.in;\n\
        Warmup Molecular Dynamics: $dirf/min_dyn/wm_dyn_ala.in;\n\
        Production Molecualr Dynamics [lindex $last 3] and will be used [expr round ([expr double([expr [lindex $last 1] - [lindex $last 0]])/[lindex $last 2]])] frames:\nNSTART [lindex $last 0]\nNSTOP [lindex $last 1]\nNFREQ [lindex $last 2]"
      }
    }

    if {[llength $mmpbsa] != 4 && $opt == 2} {
      ::ASM::printDebug "Minimisation/Dynamic Insufficient information"
      exit
    } elseif {[llength $mmpbsa] == 4} {
      set i 0
      while {$i < [llength $mmpbsa]} {
        set mmpbsa_aux [split [lindex $mmpbsa $i] " "]
        set j 0
        set inic 1
        while {$j < [llength $mmpbsa_aux]} {
          if {[lindex $mmpbsa_aux $j] != "" && $inic != -1} {
            incr inic -1
            if {$inic == -1} {
                set last [lappend last [lindex $mmpbsa_aux $j]]
            }
          }
          incr j
        }
        incr i
      }
    }

    if {$opt == 2} {
      if {$ASM::machine == "local"} {
        set min [lindex $last 3]
      } else {
        set last_aux $last
        set last ""
        set i 0
        while {$i < [llength $last_aux]} {
                if {$i == 3} {
                        set last [lappend last "$dirf/min_dyn/[lindex $last_aux 3]"]
                } else {
                        set last [lappend last [lindex $last_aux $i]]
                }
                incr i
        }
        set min [lindex $last 3]
      }
        if {[file exists $min] != 1} {
          ::ASM::printDebug "Minimisation/Dynamic $min doesen't exist"
          exit
        }
    }

    set res_check ""
    set i 0
    while {[lindex $mut $i]!= ""} {
      set st 0
      set mut_aux [split [lindex $mut $i] ","]
      set k 0
      while {$k < [llength $mut_aux]} {
        set nameaux [split [lindex $mut_aux $k] "_"]
        set pdb_size [expr [array size ASM::pdb] /10]
        set rt 0
        for {set j 1} {$j <= $pdb_size} {incr j} {
          set st 0
          if {[lindex $nameaux 1] == $ASM::pdb($j,5) && $ASM::pdb($j,6)==[lindex $nameaux 0]} {
            if {$ASM::pdb($j,4)== "ALA" || $ASM::pdb($j,4)== "PRO" || $ASM::pdb($j,4)== "GLY"} {
              set res_check [lappend res_check "0"]
              set ASM::mut_name(Mut$i) "$ASM::pdb($j,4)$ASM::pdb($j,6)"
              break
            } else {
              set res_check [lappend res_check "1"]
              break
            }
          }
        }
        if {[info exists ASM::mut_name(Mut$i)] != 1 && [lindex $res_check $i] != 1} {
          set res_check [lappend res_check "0"]
          set ASM::mut_name(Mut$i) "NOT FOUND"
          break
        }
        incr k
      }
      incr i
    }

    if {[file exists "$dirf/strct/wldtp/ligand/Complex_ligand_wt.pdb"]==1 && [file exists "$dirf/strct/wldtp/receptor/Complex_receptor_wt.pdb"]==1 } {
      set i 0
      while { $i < [llength $mut]} {
        if {[lindex $res_check $i] == 1} {
          set mut_i [split [lindex $mut $i] ","]
          set j 0
          set res ""
          set residue ""
          set chain ""
          set st ""
          while { $j < [llength $mut_i]} {
            set res [split [lindex $mut_i $j] "_"]
            set residue [lappend residue [lindex $res 0]]
            set chain [lappend chain [lindex $res 1]]
            if {[lsearch $ligand [lindex $res 1]]!= -1} {
                set st [lappend st "ligand"]
            } else {
                set st [lappend st "receptor"]
            }
            incr j
          }
          ::ASM::printDebug "Creating Mutaion in Complex in folder Mut$i"
          ::ASM::makeMut $residue $chain $dirf $st $i $ligand $receptor
          ::ASM::amber $dirf/strct/mut/Mut$i/Complex/Complex.pdb $dirf/strct/mut/Mut$i/ Complex Mut$i $leapadd $forfld $hetat
          ::ASM::printDebug "Creating Mutaion in folder Mut$i"
          set k 0
          set ligres ""
          set recres ""
          while {$k < [llength $st]} {
            if {[string trim [lindex $st $k] " "] != ""} {
              if {[lindex $st $k]=="ligand"} {
                  set ligres [lappend ligres [lindex $chain $k]]
              } else {
                  set recres [lappend recres [lindex $chain $k]]
              }
            }
            incr k
          }
          set mutst "Mut"
          if {[llength $ligres]>0} {
            ::ASM::amber $dirf/strct/mut/Mut$i/ligand/Complex.pdb $dirf/strct/mut/Mut$i/ ligand ligand$un$mutst$i $leapadd $forfld $hetat
          }
          if {[llength $recres]>0} {
            ::ASM::amber $dirf/strct/mut/Mut$i/receptor/Complex.pdb $dirf/strct/mut/Mut$i/ receptor receptor$un$mutst$i $leapadd $forfld $hetat
          }

        }
        incr i
      }
	  ::ASM::printOut $mut 1 ""
      ::ASM::printDebug "Runing MMPBSA for Complex wldtp"
      set fo [pwd]


			set const [ASM_Const::const]
			set const [split $const " "]
			set ind 0
			while {$ind < [llength $const]} {
				if {[file exists $dirf/mmpbsa/wldtp/Complex/d[lindex $const $ind]]!=1} {
          file mkdir $dirf/mmpbsa/wldtp/Complex/d[lindex $const $ind]
        }
        cd  $dirf/mmpbsa/wldtp/Complex/d[lindex $const $ind]
        if {[info exists mmpbsa] != 1} {
          set mmpba 0
        } else {
          if {[llength $mmpbsa] >= 3 && $last == ""} {
            set last ""
            set last $mmpbsa
          }
        }
        ::ASM::makeMMPBSAFile [lindex $const $ind] $dirf wldtp Complex $fo 0 $mmpbsa $last $opt
        cd $fo
				incr ind
			}

      cd $fo
			set ind 0
			while {$ind < [llength $const]} {
				set ASM::id([lindex $const $ind]) [thread::create]
        tsv::set dirf 0 $dirf
        tsv::set dirf 1 [lindex $const $ind]
        tsv::set dirf 2 $fo
        tsv::set dirf 3 $ASM::Amber
        thread::send -async $ASM::id([lindex $const $ind]) {
        		set dirf [tsv::get dirf 0]
        		set i [tsv::get dirf 1]
        		set fo [tsv::get dirf 2]
            set Amber [tsv::get dirf 3]
        		cd  $dirf/mmpbsa/wldtp/Complex/d$i
        		catch {exec $Amber/mm_pbsa.pl $dirf/mmpbsa/wldtp/Complex/d$i/mm.pbsa.Complex.e$i.in > $dirf/mmpbsa/wldtp/Complex/d$i/mm.pbsa.Complex.e$i.out} a
		puts $a
            cd $fo
        } ASM::result([lindex $const $ind])
    		cd $fo
    		incr ASM::IDproce

				if {$ASM::IDproce == $ASM::proce} {
          vwait ASM::result
          incr ASM::IDproce -1
        }
				incr ind
			}


    cd $fo

    ::ASM::printDebug "End of MMPBSA for Complex wldtp"
    if {[info exists mmpbsa] != 1} {
      set mmpba 0
    } else {
      if {[llength $mmpbsa] >= 3 && $last == ""} {
        set last ""
        set last [lappend last [lrange $mmpbsa 0 1]]
      }
    }

    ::ASM::mmpbsa_run $mut $dirf $fo $mmpbsa $last $opt $res_check
    if {$opt == 0} {
	  set frm [expr round([expr double([expr [lindex $last 1] - [lindex $last 0]])/[lindex $last 2]])]
    } elseif {$opt == 2} {
      set ini ""
      set fin ""
      set fre ""
      set i 0
      while {$i <= 2} {
        set mmpbsa_aux [split [lindex $mmpbsa $i] " "]
        set j 0
        while {$j < [llength $mmpbsa_aux]} {
          if {[lindex $mmpbsa_aux $j] != "NSTART" && [lindex $mmpbsa_aux $j] != "NSTOP" && [string trim [lindex $mmpbsa_aux $j] " "] != " " && [lindex $mmpbsa_aux $j] != "NFREQ"} {
            if {$i == 0} {
              set ini [lindex $mmpbsa_aux $j]
            } elseif {$i == 1} {
              set fin [lindex $mmpbsa_aux $j]
            } else {
              set fre [lindex $mmpbsa_aux $j]
            }
          }
          incr j
        }
        incr i
      }
      set frm [expr round([expr double([expr $fin - $ini])/$fre])]
	} else {
	  set frm 1
	}
    ::ASM::results $dirf $mut $res_check $frm
    ::ASM::printDebug "Finished"
	::ASM::printDebug [string repeat "#" 40]

	close $ASM::log
    close $ASM::out_file
	} else {
      ::ASM::printDebug "######ERROR"
      ::ASM::printDebug "The sander process  developed an error trying create ligand and receptor"
      ::ASM::printDebug "######END ERROR"
	}
}

proc ::ASM::mmpbsa_run {mut dirf fo mmpbsa last opt res_check} {
	set j 0
	set pdb_size [expr [array size ASM::pdb]/10]
	set h 0
	set const [ASM_Const::const]
	while { $j < [llength $mut]} {
	  if {[lindex $res_check $j] == 1} {
        set mutj [split [lindex $mut $j] ","]
        set chres [split [lindex $mutj 0] "_"]
        set ASM::id([expr $h+[expr [lindex $const end] +1]]) [thread::create -joinable]
        ::ASM::printDebug "Runing MMPBSA for Mutation Mut$j"
        set resname ""
        set resname $ASM::mut_name(Mut$j)
        set resname [split $resname "_"]
        set resname [lindex $resname 0]
        set k [ASM_Const::res $resname]
				set folder "mut"
        set name "Mut$j"
        if {[file exists $dirf/mmpbsa/$folder/$name]!=1} {
          file mkdir $dirf/mmpbsa/$folder/$name
        }

        cd $dirf/mmpbsa/$folder/$name
    	::ASM::makeMMPBSAFile $k $dirf $folder $name $fo [lindex $mut $j] $mmpbsa $last $opt
    	cd $fo
        set a ""
        tsv::set arr 0 $dirf
        tsv::set arr 1 $folder
        tsv::set arr 2 $k
        tsv::set arr 3 $name
        tsv::set arr 4 $fo
        tsv::set arr 5 $ASM::Amber

			set const [split $const " "]
        thread::send -async $ASM::id([expr $h+[expr [lindex $const end] +1]]) {
          set dirf [tsv::get arr 0]
          set folder [tsv::get arr 1]
          set k [tsv::get arr 2]
          set name [tsv::get arr 3]
          set Amber [tsv::get arr 5]
          cd $dirf/mmpbsa/$folder/$name
          catch {exec $Amber/mm_pbsa.pl $dirf/mmpbsa/$folder/$name/mm.pbsa.$name.e$k.in > $dirf/mmpbsa/$folder/$name/mm.pbsa.$name.e$k.out} error
          cd [tsv::get arr 4]
        } ASM::result([expr $h+[expr [lindex $const end] +1]])
        incr ASM::IDproce
        
    	if {$ASM::IDproce >= $ASM::proce} {
          vwait ASM::result
          incr ASM::IDproce -1
        }
		incr h
	  }
	  incr j
    }
    set i [lindex $const 0]
    incr h -1
    while {$i <= ([expr $h+[expr [lindex $const end] +1]])} {
      if {[info exists ASM::result($i)] != 1} {
        vwait ASM::result($i)
      }
      incr i
    }
    set i [lindex $const 0]
    incr j -1
    while {$i <= ([expr $j+[expr [lindex $const end] +1]])} {
	  if {$i>=[lindex $const 0] && $i<= [lindex $const end]} {
        if {[file exists "$dirf/mmpbsa/wldtp/Complex/d$i/snap_wldtp_Complex.d$i._statistics.out"] == 1} {
          puts $ASM::out_file " Complex$i\t\t\tOk\t\t\t$i"
        } else {
        puts $ASM::out_file " Complex$i\t\t\tFailed\t\t\t$i"
        }
	  } else {
        set ind [lindex $const 0]
        set ext 0
        while {$ind <= [lindex $const end]} {
						set index [lindex $const $ind]
            if {[file exists "$dirf/mmpbsa/mut/Mut[expr $i - [expr [lindex $const end] +1]]/snap_mut_Mut[expr $i -[expr [lindex $const end] +1]].d$index._statistics.out"] == 1 && $ext != 1} {
              set ext 1
              break
            } else {
              set ext 0
            }
            incr ind
        }
        set resname ""
        set resname $ASM::mut_name(Mut[expr $i -[expr [lindex $const end] +1]])
        set resname [split $resname "_"]
        set resname [lindex $resname 0]
        set k [ASM_Const::res $resname]
        if {$ext==1} {
          puts $ASM::out_file " Mut[expr $i -5]\t\t\t\tOk\t\t\t$k"
        } else {
          set rep 4
          if {[string length " Mut[expr $i -5]"] >= [string length " Complex2"]} {
            set rep 3
          }
          switch [lindex $resname 0] {
              "ALA" {
                  puts $ASM::out_file " Mut[expr $i -5][string repeat "\t" $rep]Alanine[string repeat "\t" [expr $rep -1]]0"
              }
              "GLY" {
                  puts $ASM::out_file " Mut[expr $i -5][string repeat "\t" $rep]Glyicine[string repeat "\t" [expr $rep -2]]0"
              }
              "PRO" {
                  puts $ASM::out_file " Mut[expr $i -5][string repeat "\t" $rep]Proline[string repeat "\t" [expr $rep -1]]0"
              }
              "NOT FOUND" {
                  puts $ASM::out_file " Mut[expr $i -5][string repeat "\t" $rep]NOT FOUND[string repeat "\t" [expr $rep -2]]0"
              }
              default {
                  puts $ASM::out_file " Mut[expr $i -5][string repeat "\t" $rep]Failed[string repeat "\t" [expr $rep -1]]$k"
              }
          }
        }
	  }
	  incr i
	}
	puts $ASM::out_file "[string repeat "=" 70]\n\n"
	::ASM::printDebug "End of $folder MMPBSA"
	return
}

proc ::ASM::results {dirf mut res_check frm} {
    array unset del_comp
    array set del_comp ""
    set fil_results_all [open $dirf/results_all.txt w+]
    set fil_results_resume [open $dirf/results_resume.txt w+]

    puts $fil_results_resume "## Results table resumed\n\n"
    puts $fil_results_resume [string repeat "=" 70]
    puts $fil_results_resume "|Score\t      Mutation Serie"
    puts $fil_results_resume [string repeat "=" 70]
    set ns ""
    set ws ""
    set hs ""
    
    	set const [ASM_Const::const]
			set const [split $const " "]
			set ind 0
			while {$ind < [llength $const]} {
        set i [lindex $const $ind]
        if {[file exists "$dirf/mmpbsa/wldtp/Complex/d$i/snap_wldtp_Complex.d$i._statistics.out"] ==1} {
            set fil [open "$dirf/mmpbsa/wldtp/Complex/d$i/snap_wldtp_Complex.d$i._statistics.out" r+]
            set line [split [read $fil] "\n"]
    
            for {set j [expr [llength $line] -10]} {$j<= [expr [llength $line] -2]} {incr j} {
              set text [split [lindex $line $j] " "]
                set k 0
                set list_values ""
                while {$k <= [llength $text]} {
                  if {[lindex $text $k] != ""} {
                    set list_values [lappend list_values [lindex $text $k]]
                  }
                  incr k
                  if {[llength $list_values]==3} {
                    set del_comp($i,[lindex $list_values 0],avg) [lindex $list_values 1]
                    set del_comp($i,[lindex $list_values 0],stdv) [lindex $list_values 2]
                    set list_values ""
                  }
                }
            }
            close $fil
        }
        incr ind
      }
    

    set j 0
    set folder "mut"
    puts $fil_results_all [string repeat "=" 172]
    puts $fil_results_all "|Mutation Serie[string repeat " " 6]ELE[string repeat " " 11]VDW\t\t   INT\t\t  GAS\t\t  PBSUR\t\t  PBCAL\t\t  PBSOL\t\t  PBELE\t\t  PBTOT\t\t  Score"
    puts $fil_results_all [string repeat "=" 172]
    set line_out ""
    while {[lindex $mut $j]!= ""} {
      set do 0
      
			set const [split $const " "]
			set ind 0
			while {$ind < [llength $const]} {
        set w [lindex $const $ind] 
         if {[file exists "$dirf/mmpbsa/$folder/Mut$j/snap_mut_Mut$j.d$w._statistics.out"] ==1} {
          set do 1
          break
        }
        incr ind
      }
      
      if {$do==1} {
        set name Mut$j
        set und "_"
        set resnaux [split $ASM::mut_name($name) " "]
        set mutaux [split [lindex $mut $j] ","]
        set i 0
        set resname ""
        while {[lindex $mutaux $i]!= ""} {
          set mutname [split [lindex $mutaux $i] "_"]
          set resname [lappend resname "[lindex $resnaux $i]_[lindex $mutaux $i]" ]
          incr i
        }
        set line_out " $name\t\t"
        set filein [glob -directory $dirf/mmpbsa/$folder/$name/ snap_$folder$und$name.d*._statistics.out]
        set resname $ASM::mut_name($name)
        set resname [split $resname "_"]
        set resname [lindex $resname 0]
        set k [ASM_Const::res $resname]
        set fil [open $filein r+]
        set line [split [read $fil] "\n"]

        for {set in [expr [llength $line] -10]} {$in<= [expr [llength $line] -2]} {incr in} {
          set text [split [lindex $line $in] " "]
          set h 0
          set list_values ""
          while {$h <= [llength $text]} {
            if {[lindex $text $h] != ""} {
                set list_values [lappend list_values [lindex $text $h]]
            }
            incr h
            if {[llength $list_values]==3} {
              set avg [expr [lindex $list_values 1] - $del_comp($k,[lindex $list_values 0],avg)]
              set stdv [expr [expr [lindex $list_values 2] * [lindex $list_values 2]] + [expr $del_comp($k,[lindex $list_values 0],stdv) *$del_comp($k,[lindex $list_values 0],stdv)] ]
              set avg [format "%3.2f" $avg]
              set stdv [format "%3.2f" [expr double([expr sqrt($stdv)])/[expr sqrt($frm)]]]
              set line_out [append line_out "$avg  $stdv\t"]
              if {[lindex $list_values 0]== "PBTOT"} {
                if {$avg < 2.0} {
                  set ns [append ns "$name "]
                  set line_out [append line_out " Null Spot"]
                } elseif {$avg >= 2.0 && $avg < 4.0} {
                  set ws [append ws "$name "]
                  set line_out [append line_out " Warm Spot"]
                } else {
                  set hs [append hs "$name "]
                  set line_out [append line_out " Hot Spot"]
                }
              }
              set list_values ""
            }
          }
        }
              close $fil
      }
      if {$line_out != ""} {
        puts $fil_results_all "$line_out"

      }
      set line_out ""
      incr j
    }


	puts $fil_results_all [string repeat "=" 172]
	close $fil_results_all
	puts $fil_results_resume " Null Spot"
	if {$ns == ""} {
	  puts $fil_results_resume "\t\t[string repeat "-" 30]"
	} else {
      set ns [split $ns " "]
      if {[llength $ns] > 8} {
        set j 9
        set w 9
        set nsaux ""
        puts $fil_results_resume "\t\t[lrange $ns 0 8]"
        while {[lindex $ns $j]!= ""} {
          set nsaux [append nsaux "[lindex $ns $j] "]
          if {[expr $j - $w]==8} {
            puts $fil_results_resume "\t\t$nsaux"
            set w $j
            set nsaux ""
          }
          incr j
        }
        if {$nsaux != ""} {
          puts $fil_results_resume "\t\t$nsaux"
        }
      } else {
          puts $fil_results_resume "\t\t[string trim $ns "{}" ] "
      }
	}
	puts $fil_results_resume " Warm Spot"
	if {$ws == ""} {
	  puts $fil_results_resume "\t\t[string repeat "-" 30]"
	} else {
      set ws [split $ws " "]
      if {[llength $ws] > 8} {
        set j 9
        set w 9
        set wsaux ""
        puts $fil_results_resume "\t\t[lrange $ws 0 8]"
        while {[lindex $ws $j]!= ""} {
          set wsaux [append wsaux "[lindex $ws $j] "]
          if {[expr $j - $w]==8} {
            puts $fil_results_resume "\t\t$wsaux"
            set w $j
            set wsaux ""
          }
          incr j
        }
        if {$wsaux != ""} {
            puts $fil_results_resume "\t\t$wsaux"
        }
      } else {
        puts $fil_results_resume "\t\t[string trim $ws "{}" ] "
      }
	}
	puts $fil_results_resume " Hot Spot"
	if {$hs == ""} {
      puts $fil_results_resume "\t\t[string repeat "-" 30]"
    } else {
      set hs [split $hs " "]
      if {[llength $hs] > 8} {
        set j 9
        set w 9
        set hsaux ""
        puts $fil_results_resume "\t\t[lrange $hs 0 8]"
        while {[lindex $hs $j]!= ""} {
          set hsaux [append hsaux "[lindex $hs $j] "]
          if {[expr $j - $w]==8} {
            puts $fil_results_resume "\t\t$hsaux"
            set w $j
            set hsaux ""
          }
          incr j
        }
        if {$hsaux != ""} {
          puts $fil_results_resume "\t\t$hsaux"
        }
      } else {
        puts $fil_results_resume "\t\t[string trim $hs "{}" ] "
      }
    }

	puts $fil_results_resume [string repeat "=" 70]

	close $fil_results_resume


	puts $ASM::out_file "## Results table\n\n"
	set fil_results_all [open $dirf/results_all.txt r+]
	while {[eof $fil_results_all]!=1} {
      set linha [gets $fil_results_all]
      puts $ASM::out_file $linha
	}
	puts $ASM::out_file "\n\n"
	set fil_results_resume [open $dirf/results_resume.txt r+]
	while {[eof $fil_results_resume]!=1} {
      set linha [gets $fil_results_resume]
      puts $ASM::out_file $linha
	}
	close $fil_results_all
	close $fil_results_resume
}
proc ::ASM::printDebug {text} {
  if {$ASM::debug==1} {
    puts $ASM::log $text
    puts $text
  }
}

proc ::ASM::printOut {mut phase text} {
    if {$phase ==1} {
      puts $ASM::out_file "## mut table\n\n"
      puts $ASM::out_file [string repeat "=" 120]
      puts $ASM::out_file "| Mutation serie[string repeat " " 10] | [string repeat " " 5] Resideu(s)"
      puts $ASM::out_file [string repeat "=" 120]
      set i 0
      while {[lindex $mut $i] != ""} {
        set mutaux [split [lindex $mut $i] ","]
        set resnaux [split $ASM::mut_name(Mut$i) " "]
        if {$ASM::mut_name(Mut$i) != "NOT FOUND"} {
          set resname ""
          set j 0
          while {[lindex $mutaux $j] != ""} {
              set mutaux2 [split [lindex $mutaux $j] "_"]
              set resname [lappend resname "[lindex $resnaux $j]_[lindex $mutaux2 0]" ]
              incr j
          }
          if {$j > 10} {
              puts $ASM::out_file "| Mut$i[string repeat " " [expr 26 - [string length Mut$i]]] [lrange $resname 0 9]"
              set w 10
              set wi 10
              set resnameaux ""
              while {[lindex $resname  $w]!=""} {
                set resnameaux [lappend resnameaux [lindex $resname  $w]]
                if {$w == [expr $w + 9]} {
                  puts $ASM::out_file "| [string repeat " " 26] [lrange $resname  $wi $w]"
                  set wi $w
                  set resnameaux ""
                }
                incr w
              }
              if {$resnameaux != ""} {
                puts $ASM::out_file "| [string repeat " " 26] $resnameaux"
              }
          } else {
            puts $ASM::out_file "| Mut$i[string repeat " " [expr 26 - [string length Mut$i]]] $resname"
          }
        } else {
            puts $ASM::out_file "| Mut$i[string repeat " " [expr 26 - [string length Mut$i]]] NOT FOUND"
        }
        incr i
      }
      puts $ASM::out_file "[string repeat "=" 120]\n\n"
      puts $ASM::out_file "## MMPBSA Procedures check table\n\n"
      puts $ASM::out_file "[string repeat "=" 70]"
      puts $ASM::out_file "| Mutation serie[string repeat " " 10] | [string repeat " " 5] Done [string repeat " " 5]|[string repeat " " 2 ]Dieletric Constant"
      puts $ASM::out_file "[string repeat "=" 70]"

    } else {
      puts $ASM::out_file $text
    }

}
set inputfile [lindex $argv 0]
set inputfile "[pwd]/$inputfile"
ASM::run $inputfile
