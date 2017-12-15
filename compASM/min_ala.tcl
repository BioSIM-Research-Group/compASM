package provide min 1.0

proc ::ASM::makeMinFile {text dirf opt out} {
	if {[file exists $dirf/min_dyn]!=1} {
		file mkdir $dirf/min_dyn
	}
	if {$opt ==1} {
		set min_fil [open $dirf/min_dyn/$out w+]
		puts $min_fil "Minimization"
		puts $min_fil "&cntrl"
		set i 0
		while {[lindex $text $i] != ""} {
			if {[lindex $text [expr $i+1] ] == ""} {
				puts $min_fil "[lindex $text $i]"
			} else {
				puts $min_fil "[lindex $text $i],"
			}
			incr i
		}
		puts $min_fil "&end"
		puts $min_fil "END"
		close $min_fil
	} else {
		set aux_text $text
		set j 0
		while {[lindex $aux_text $j]!= ""} {
			set line [split [lindex $aux_text $j] " "]
			set eqind [string last "=" $line]
			set str [string range $line 0 [expr $eqind -1]]
			set str [string trim $str]
			set val [string trim [string range $line [expr $eqind +1] end ]]
			if {$str == "nstlim"} {
				set max [expr [string trim $val/10]]
				break
			}
			incr j
		}
		set j 0
		set tim ""
		set frmi ""
		set min_fil [open $dirf/min_dyn/min_dyn_ala.in w+]
		puts $min_fil "Molecular Dynamic"
		puts $min_fil "&cntrl"
		set i 0
		while {[lindex $text $i] != ""} {
			set aux_text [lindex $text $i]
			set eqind [string last "=" $aux_text]
			set str [string range $aux_text 0 [expr $eqind -1]]
			set str [string trim $str]
			set val [string trim [string range $aux_text [expr $eqind +1] end]]
			if {$str== "nstlim"} {
				set text_max "nstlim = $max,"
				puts $min_fil "$text_max"
			} elseif {$str== "dt" && $tim == ""} {
				set tim [string trim $val ","]
				if {[lindex $text [expr $i+1] ] == ""} {
					puts $min_fil "[lindex $text $i]"
				} else {
					puts $min_fil "[lindex $text $i],"
				}
					} elseif {$str== "ntpr" && $frmi == ""} {
				set frmi [string trim $val ","]
				if {[lindex $text [expr $i+1] ] == ""} {
					puts $min_fil "[lindex $text $i]"
				} else {
					puts $min_fil "[lindex $text $i],"
				}
			} else {
				if {[lindex $text [expr $i+1] ] == ""} {
					puts $min_fil "[lindex $text $i]"
				} else {
					puts $min_fil "[lindex $text $i],"
				}
			}
			incr i
		}
		puts $min_fil "&end"
		puts $min_fil "END"
		close $min_fil
    set timscl [expr [expr double($frmi)/$max] * 1000]
		set frm [expr int([expr $max/$frmi])]
		return "$timscl $frm"
	}
}

proc ::ASM::min_dyn_run {dirf text opt inf_st_min inf_dyn_wm freq MDr} {
	set ::ASM::rms ""
	::ASM::printDebug "Run minimization/dynamic"
	set j 0
	puts $opt
	if {$opt==1} {
		set in "min_dyn_ala.in"
		::ASM::makeMinFile $text $dirf $opt $in
		set top "$dirf/strct/wldtp/Complex/Complex_wldtp.top"
		set crd "$dirf/strct/wldtp/Complex/Complex_wldtp.crd"
		set out "$dirf/min_dyn/min_dyn_out.out"
		set rst "$dirf/min_dyn/min_dyn_out.rst"
		set trj	"$dirf/min_dyn/traj_res.out"
		set fo [pwd]
		cd $dirf/min_dyn/

    catch {exec $ASM::install/amber_run.sh "-O -i $dirf/min_dyn/$in -p $top -c $crd -o $out -r $rst" "$ASM::Amber"} 
		cd $fo
		if {[file exists $rst]!= 1} {
			::ASM::printDebug "######ERROR"
			::ASM::printDebug "The sander process for minimization developed an error"
			::ASM::printDebug "######END ERROR"
			exit
		} else {
			set trajin [open $dirf/min_dyn/traj.in w+]
			puts $trajin "trajin $dirf/min_dyn/min_dyn_out.rst"
			puts $trajin "trajout $dirf/min_dyn/min_dyn_traj_out.trj trajectory nobox"
			close $trajin
			catch {exec $ASM::Amber/ptraj $top < $dirf/min_dyn/traj.in > $trj}
			if {[file exists $dirf/min_dyn/min_dyn_traj_out.trj]!=1} {
			::ASM::printDebug "######ERROR"
			::ASM::printDebug "The ptraj process developed an error"
			::ASM::printDebug "######END ERROR"
			exit
			}
			::ASM::printDebug "End of minimization"
		}
		return "0 1 1 $dirf/min_dyn/min_dyn_traj_out.trj"
	} else {
		array set MD $MDr
		##Starting minimazation
		if {[file exists $dirf/min_dyn/st_min_out.rst]!=1} {
			set in "st_min_ala.in"
			set top "$dirf/strct/wldtp/Complex/Complex_wldtp.top"
			set crd "$dirf/strct/wldtp/Complex/Complex_wldtp.crd"
			set out "$dirf/min_dyn/st_min_out.out"
			set rst "$dirf/min_dyn/st_min_out.rst"
			set traj "$dirf/min_dyn/st_min_traj_out.trj"
			::ASM::makeMinFile $inf_st_min $dirf 1 $in
			catch {exec $ASM::install/amber_run.sh "-O -i $dirf/min_dyn/$in -p $top -c $crd -o $out -r $rst -x $traj " "$ASM::Amber"} a
			puts $a
		}
		set rst "$dirf/min_dyn/st_min_out.rst"
		##Warming Dynamic
		if {[file exists $dirf/min_dyn/wm_dyn_traj_out.trj]!=1} {
			set in "wm_dyn_ala.in"
			set top "$dirf/strct/wldtp/Complex/Complex_wldtp.top"
			set crd	$rst
			set out "$dirf/min_dyn/wm_dyn_out.out"
			set rst "$dirf/min_dyn/wm_dyn_out.rst"
			set traj "$dirf/min_dyn/wm_dyn_traj_out.trj"
			::ASM::makeMinFile $inf_dyn_wm $dirf 1 $in
			catch {exec $ASM::install/amber_run.sh "-O -i $dirf/min_dyn/$in -p $top -c $crd -o $out -r $rst -x $traj " "$ASM::Amber"}
		}
		set rst "$dirf/min_dyn/wm_dyn_out.rst"
		set traj "$dirf/min_dyn/wm_dyn_traj_out.trj"
		##Dynamic
		set in "min_dyn_ala.in"
		set dy_list [::ASM::makeMinFile $text $dirf $opt $in]
		set dy_list [split $dy_list " "]
		set timscl [lindex $dy_list 0]
		set frm [lindex $dy_list 1]
		set j 0
		set brk 0
		set bi 0
		set b ""
		set ri ""
		set r ""
		set perbi ""
		set do 0
		set fom ""
		set maxi 0
		set max 0
		set st ""
		while {$j<=9 && $brk == 0} {

      if {$j==0} {
				if {[file exists $dirf/min_dyn/min_dyn_traj_total_aux.trj] == 1} {
					file delete $dirf/min_dyn/min_dyn_traj_total_aux.trj
				}
				set top "$dirf/strct/wldtp/Complex/Complex_wldtp.top"
				set crd $rst
			} else {
				set num [expr $j -1]
				set crd "$dirf/min_dyn/min_dyn_out$num.rst"
			}
			set out "$dirf/min_dyn/min_dyn_out$j.out"
			set rst "$dirf/min_dyn/min_dyn_out$j.rst"
			set traj "$dirf/min_dyn/min_dyn_traj_out$j.trj"

			if {[file exists $dirf/min_dyn/min_dyn_traj_out$j.trj] != 1} {
				catch {exec $ASM::install/amber_run.sh "-O -i $dirf/min_dyn/$in -p $top -c $crd -o $out -r $rst -x $traj " "$ASM::Amber"}
			}
			set merg_fil [open $dirf/min_dyn/min_dyn_merg_trj w+]
			if {$j>1} {
				puts $merg_fil "trajin $dirf/min_dyn/min_dyn_traj_total.trj"
				puts $merg_fil "trajin $traj"
				puts $merg_fil "trajout $dirf/min_dyn/min_dyn_traj_total_aux.trj"
				close $merg_fil
				catch {exec $ASM::Amber/ptraj $top < $dirf/min_dyn/min_dyn_merg_trj} error
				file delete $dirf/min_dyn/min_dyn_traj_total.trj
				file rename $dirf/min_dyn/min_dyn_traj_total_aux.trj $dirf/min_dyn/min_dyn_traj_total.trj
				set traj_total "$dirf/min_dyn/min_dyn_traj_total.trj"
				file delete $dirf/min_dyn/min_dyn_traj_out$j.trj
				file delete $dirf/min_dyn/min_dyn_out$j.out
				file delete $dirf/min_dyn/min_dyn_out[expr $j -1].rst
			} elseif {$j==1} {
				puts $merg_fil "trajin $dirf/min_dyn/min_dyn_traj_out0.trj"
				puts $merg_fil "trajin $traj"
				puts $merg_fil "trajout $dirf/min_dyn/min_dyn_traj_total.trj"
				close $merg_fil
				catch {exec $ASM::Amber/ptraj $top < $dirf/min_dyn/min_dyn_merg_trj} error
				set traj_total "$dirf/min_dyn/min_dyn_traj_total.trj"
				file delete $dirf/min_dyn/min_dyn_traj_out1.trj
				file delete $dirf/min_dyn/min_dyn_out1.out
				file delete $dirf/min_dyn/min_dyn_traj_out0.trj
				file delete $dirf/min_dyn/min_dyn_out0.out
				file delete $dirf/min_dyn/min_dyn_out0.rst
			}
			if {$j == 0 } {
				set traj_total "$dirf/min_dyn/min_dyn_traj_out0.trj "
			}

			set rms_file [open $dirf/min_dyn/min_dyn_calc_rms w+]
			puts $rms_file "trajin $traj_total"
			puts $rms_file "rms first mass out $dirf/min_dyn/rms.out time $timscl @N,C,CA"
			close $rms_file

			catch {exec $ASM::Amber/ptraj $top < $dirf/min_dyn/min_dyn_calc_rms}
			set rms_val [::ASM::rms_Calc $dirf $j $frm]
			set rms_val [split $rms_val " "]
			set b [lindex $rms_val 0]
			set b [format %3.3f [expr $b * 1000]]
			set r [lindex $rms_val 1]
			set stdv [lindex $rms_val 2]
			set stdv [format %-0.3f $stdv]
			set max [format %-0.3f [lindex $rms_val 4]]
			if {$max > $maxi} {
				set maxi $max
			}
			set form [append form  "Y=$b*x + [format %2.3f [lindex $rms_val 3]]\n"]
			set resb [format %2.1f $b]

      if {$j > 0} {
        if {[format %1.1f [expr abs($b)]] <= $MD(B) && [format %1.1f $r] >= $MD(R)  && [format %1.1f $stdv] <= $MD(STDV)  && $do==0} {
					set brk 1
					incr do -1
        }
      }
			if {$do == -1 } {
				set r [format %1.2f $r]
				puts $ASM::out_file "[format %1.0f [expr round([expr $frm * [expr $j +1] * $timscl])]]\t$b\t[format %1.3f  $r]\t$stdv\t[expr $frm * $j]\t[expr $frm * [expr $j +1]]\t   Yes"

			} else {
				set r [format %1.2f $r]
				puts $ASM::out_file "[format %1.0f [expr round([expr $frm * [expr $j +1] * $timscl])]]\t$b\t[format %1.3f $r]\t$stdv\t[expr $frm * $j]\t[expr $frm * [expr $j +1]]\t   No"
			}
      set bi $b
    	incr j
    }
		puts $ASM::out_file "[string repeat "=" 60]"
		catch {exec $ASM::Amber/ambpdb -p "$dirf/strct/wldtp/Complex/Complex_wldtp.top" < $rst > $dirf/final_str.pdb} a
		set file [open "$dirf/min_dyn/rms.out" r+]
		set txt [read -nonewline $file]
		close $file
		set file [open "$dirf/min_dyn/rms.out" w+]
		set line "#max $max"
		puts $file $line
		puts $file $txt
		close $file

  }
	file delete $dirf/min_dyn/min_dyn_out[expr $j -1].rst
	puts $ASM::out_file "[string repeat "=" 60]\nLinear Model Formula: \n$form"
	incr j -1
	set res [expr [expr [expr $frm * $j] -1] + $frm]
	set ini [expr $frm * $j]
  return "$ini $res $freq $dirf/min_dyn/min_dyn_traj_total.trj"
}


proc ::ASM::rms_Calc {dirf j frm} {

	set file [open "$dirf/min_dyn/rms.out" r+]
  set start [expr [expr $frm * $j] -1]
	if {$j==0} {
		set start 0
		while {[eof $file] != 1} {
			set linha [gets $file]
			set val_x [string trim [string range $linha 0 7] " "]
			set val_y [string trim [string range $linha 8 17] " "]
			set ASM::rms_x [lappend ASM::rms_x $val_x]
			set ASM::rms_y [lappend ASM::rms_y $val_y]
		}

	} else {
		set i 0
		set start [expr [expr $frm * $j] -1]
		while {[eof $file] != 1} {
		  set linha [gets $file]
		  if {$i == $start} {
				while {$i <= [expr $start + $frm] && [eof $file] != 1} {
					set linha [gets $file]
					set val_x [string trim [string range $linha 0 7] " "]
					set val_y [string trim [string range $linha 8 17] " "]
					set rms_x [lappend ASM::rms_x $val_x]
					set rms_y [lappend ASM::rms_y $val_y]
					incr i
				}
		  }
		  incr i
		}
	}
	set val [::math::statistics::linear-model [lrange $ASM::rms_x $start [expr $start + $frm]] [lrange $ASM::rms_y $start [expr $start + $frm]]]
	set stdv [::math::statistics::stdev [lrange $ASM::rms_y $start [expr $start + $frm] ]]
	set max [::math::statistics::max [lrange $ASM::rms_y $start [expr $start + $frm] ]]
	set val [split $val " "]
	set b [lindex $val 1]
	set r [lindex $val 3]
	close $file
	return "$b $r $stdv [lindex $val 0] $max"
}
