##
## This program allows to install CompASM
##
## Author: João Vieira Ribeiro
##
## Id: install.tcl,v 1.0 2009/07/09 21:32:32 NSC
##

#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

namespace eval ::installASM:: {
  package require Tk 8.5
  set ASMInst "."
  set inVMD 0
}

proc installASM::Buil {} {

  #toplevel
  wm title . "CompASM installation process"
  wm resizable .  0 0



  grid columnconfigure . 0 -weight 1; grid rowconfigure . 0 -weight 0

  grid [ttk::frame .frmp -width 500 -height 500] -row 0 -column 0 -sticky nsew

  ###top image
  grid [ttk::frame .frmp.img] -row 0 -column 0 -sticky nsew
  grid columnconfigure .frmp.img 0 -weight 1; grid rowconfigure .frmp.img 0 -weight 1
  image create photo img1 -data [installASM::SetImage]
  grid [ttk::label .frmp.img.logo -background #4a4a4c -image img1 -anchor center] -row 0 -column 0 -sticky ewns
  ###END

  installASM::buildFirst
  installASM::buildWork
  grid forget .frmp.install
  grid [ttk::frame .frmp.fmbut] -row 2 -column 0 -sticky we
  grid columnconfigure .frmp.fmbut 1 -weight 2; grid rowconfigure .frmp.fmbut 0 -weight 1

  grid [ttk::button .frmp.fmbut.btnext -text "Next ->" -padding "8 2 3 2" -command {
    set txt [.frmp.fmbut.btnext cget -text]
    if {$txt == "Install"} {
        .frmp.install.frmstst.lbprint configure -text " - Writing for directory path"
        set path [.frmp.install.frmpath.entryload get]

        if {$path != ""} {
              set path "$path/ASM"
              installASM::installProc $path
              .frmp.fmbut.btnext configure -text "Finish"
        }
    } elseif {$txt == "Finish"} {
         destroy .
    } else {
        grid forget .frmp.la
        grid conf .frmp.install -sticky news -row 1
        .frmp.fmbut.btback configure -state normal
        .frmp.fmbut.btnext configure -text "Install"
    }
  }] -row 0 -column 1 -sticky e -pady 2
  grid [ttk::button .frmp.fmbut.btback -text "<- Back"  -padding "3 2 8 2" -state disable -command {
  grid forget .frmp.install
  grid conf .frmp.la -sticky news -row 1
    .frmp.fmbut.btnext configure -text "Next ->"
    .frmp.fmbut.btback configure -state disable
  }] -row 0 -column 0 -sticky w

}

proc installASM::buildFirst {} {

  set tex {CompASM (COMPutational Alanine Scanning Mutagenesis) is a software to automate the Alanine Scanning Mutagenesis process. It allows to choose the ligand and receptor,\
	passing through the performance of a Minimazation/Molecular Dynamics calculation, to the visualisation of the final results. This software is composed by two\
	blocks: a Graphical User Interface (GUI) plugged in a largely used molecular viewer Visual Molecular Dynamics (VMD) and a set of Core routines where all calculations\
	take place.  In GUI section, the user can generate the inputfile and set the all variables values used in the Core section.\
       This inputfile can be modified "by hand" and launch by command line ".../ASM/ASM.tcl inpurfile.asm"

This software was developed by Theoretical Chemistry Group of Faculty of Science of Universidade do Porto

e-mail: joao.ribeiro@fc.up.pt}
  grid [ttk::frame .frmp.la] -row 1 -column 0 -sticky nwes
  grid columnconfigure .frmp.la 0 -weight 2; grid rowconfigure .frmp.la 0 -weight 2
  grid [ttk::label .frmp.la.te -background white -text $tex -justify left -wraplength 299 -relief sunken -padding "2 2 2 2"] -row 0 -column 0 -sticky news -padx 1
}

proc installASM::buildWork {} {
  grid [ttk::frame .frmp.install] -row 1 -column 0 -sticky news
  grid columnconfigure .frmp.install 0 -weight 1; grid rowconfigure .frmp.install 0 -weight 1

  grid [ttk::frame .frmp.install.frmlb -padding "0 2 0 1"] -row 0 -column 0 -sticky news
  grid columnconfigure .frmp.install.frmlb 0 -weight 1; grid rowconfigure .frmp.install.frmlb 0 -weight 1

  grid [ttk::label .frmp.install.frmlb.lbtxt -relief raised -padding "4 2 8 2" -justify left -wraplength 280] -row 0 -column 0 -sticky we
  .frmp.install.frmlb.lbtxt configure -text "Instalation of Alanine Scanning Mutagenesis:\n\nInsert the Path where Alanine Scanning Mutagenesis is going to be installed and the path of Amber (or AmberTools) and Delphi program"

  grid [ttk::frame .frmp.install.frmpath -padding "1 1 1 1"] -row 1 -column 0 -sticky news -pady 2
  grid columnconfigure  .frmp.install.frmpath 1 -weight 2
  grid rowconfigure  .frmp.install.frmpath 0 -weight 1
  grid rowconfigure  .frmp.install.frmpath 2 -weight 1
  grid rowconfigure  .frmp.install.frmpath 4 -weight 1
  grid [ttk::button .frmp.install.frmpath.btload -padding "3 0 4 0" -text "ASM Path" -command {
    set path [tk_chooseDirectory -title "Choose instalation directory"]
    if {$path != [pwd] && $path != ""} {
      .frmp.install.frmpath.entryload delete 0 end
      .frmp.install.frmpath.entryload insert end $path
    } elseif {$path == [pwd]} {
      tk_messageBox -icon error -message "Please choose another path to install ASM" -title "ASM installation path" -type ok
      .frmp.install.frmpath.btload invoke
    }

  }] -row 0 -column 0 -sticky w -pady 2
  grid [ttk::entry .frmp.install.frmpath.entryload] -row 0 -column 1 -sticky ew -pady 2
  grid [ttk::label .frmp.install.frmpath.lbload -text "i.g /home/USER/Desktop/" -font {-size 8} -padding "0 1 0 1"] -row 1 -column 1 -sticky ew -pady 2
  
  grid [ttk::button .frmp.install.frmpath.btloadAMB -padding "3 0 4 0" -text "Amber Path" -command {
    set path [tk_chooseDirectory -title "Choose instalation directory"]
    if {$path != ""} {
    .frmp.install.frmpath.entryloadAMB delete 0 end
    .frmp.install.frmpath.entryloadAMB insert end $path
    }
  }] -row 2 -column 0 -sticky w -pady 2
  
  grid [ttk::entry .frmp.install.frmpath.entryloadAMB] -row 2 -column 1 -sticky ew -pady 2
  grid [ttk::label .frmp.install.frmpath.lbloadAMB -text "i.g /home/programs/AMBER/exe/" -font {-size 8} -padding "0 1 0 1"] -row 3 -column 1 -sticky ew -pady 2

  grid [ttk::button .frmp.install.frmpath.btloadDEL -padding "3 0 4 0" -text "Delphi Path" -command {
    set path [tk_chooseDirectory -title "Choose instalation directory"]
    if {$path != ""} {
    .frmp.install.frmpath.entryloadDEL delete 0 end
    .frmp.install.frmpath.entryloadDEL insert end $path
    }
  }] -row 4 -column 0 -sticky w -pady 2
  grid [ttk::entry .frmp.install.frmpath.entryloadDEL] -row 4 -column 1 -sticky ew -pady 2
   grid [ttk::label .frmp.install.frmpath.lbentryloadDE -text "i.g /home/programs/Delphi/delphi" -font {-size 8} -padding "0 1 0 1"] -row 5 -column 1 -sticky ew -pady 2
   
  grid [ttk::checkbutton .frmp.install.frmpath.rdVMD -text "Install VMD plug-in" -variable installASM::inVMD] -row 6 -column 1 -sticky ew -pady 4

  grid [ttk::frame .frmp.install.frmstst -padding "1 1 1 1"] -row 2 -column 0 -sticky news -pady 1
  grid columnconfigure  .frmp.install.frmstst 0 -weight 1; grid rowconfigure  .frmp.install.frmstst 1 -weight 2

  grid [ttk::label .frmp.install.frmstst.lbstatus -padding "2 1 2 1"] -row 0 -column 0 -sticky wn

  grid [ttk::label .frmp.install.frmstst.lbprint -padding "2 1 2 1" -wraplength 400] -row 0 -column 1 -sticky ew
}

proc installASM::SetImage {} {
	set image {
		R0lGODlhLAH7AOf/AAYDAhcGBRIOAyAZFCgXFDMVGCwZCiEdCjwYEDYkEDMkHCsoHi8wFmkmIEYy
		HTA3LWAqIUMzKlYwI1YvNT85M3QsHk84IkM9N2Q3Glg6IVc6JklCGT1HGUtANkZCQUhCPFc/MVFC
		MF1BHz9JPlhCO1FEQExGQEVIRWFCLklIQWJDKUtHRlFGR15FL09JQ0hNMFRHUJo3I2RKNFRNR4k/
		N1JOTUBUSFpNQ6A9L5tALm1NOYhESm9ONGJRP49FMpdDMJdFJpNGLIdJMmZTNWFTSWtRQXtMRltV
		ToFNM0VcUYBNOllWVIdLO4NQHKpDLndQRIRMRnlROY1NJ41HY41IWnxRM3hRP4NMU4FPQZ1DaZVG
		Y3FVOXdUMnVUOnRUP6tFN3BWP3JXMrZDMYNTLbVDO4ZTKK1ESm1ZO3FXR6dKMHxTVr5DM2xaQaZK
		OMdBMb1FK6xCfWFcW25cNWRcVmpeNLBDcm1bS1xjL6tHXKFONbRJNMZDPaRIeGZiNKJRMqBRP2pg
		TLtCh55QWG5fVaBSSphYKWFlS6hMc2djYmpjXdZJJJJcMatWLpFfOqBWaoRiTdVMOp5dNohlMJ1d
		QnJsPKJYdoZmPpxhL5dkLadgKHBqaqNhL3ptMXZrZGtzPF93OJ9iVJBrKp1mOn9tTWx1NtFWQHhu
		WYJwKIdqWl91ZG52LmpyY29yXGN8MWd3XsxbS5NodddbMLpcgr1ajrFoKJptWrJrMbBrOKluObpn
		T75rLL1rN6hwSK1xM+leTHJ/a5p4RLxxMHaEQo98U7J2Lo1/Q3+DRXOHQZB5eJl5XoB/baB7N3mC
		ZrxzOm6KQHyHOHKEeKd9L3GMOspzMm6Ic42BZn6HWsV3KpWEOWqSPHmIdIuJO8h6IsZ5NepsV4qF
		f4CRLZaLL46MesKESYOSfnyVf4GTh82DSXaYe3qWiIGbRoKaUtuCPXegRXeahnGmQtWJQo+kdYKo
		iX+olKKdm5Cmk62ghZ2ohoa5VpuyXu6eV4y4op/QbZ/LttjW1Pf59iH+EUNyZWF0ZWQgd2l0aCBH
		SU1QACwAAAAALAH7AAAI/gD90fuGrFOiOXPiKETIsKHDhxAjSpxIEWKigw0xzrnI8WLFOAgVioxz
		hIhJkx9HgvxYsWXDlSE3ckSoUWKnbzhz6tzJs6fPn0CDCv1Gj54/f//oIRtEpISJDyVYSP1AtarV
		q1izat3KtavXr1xNlPhgwoSHsx6olhhbtaxbEyvixvUgte7bu3jzunXBt6/eu2THsgVb9cKMOUcQ
		H1nMuLHjx5AjS55MOTHjhjeN/vs2aO2FCxRCix4d+rPp06hTq17NujVo0rBHu25N4XXs27hz60aL
		NjTv2ahLAF9NOjBUwsiTK1fLvOyMON+QdmpqW7f169iza5dNe7tv7+Bz/ntADXu46tqmy4M2z759
		e+6na3+ooYnev05rcbvfz981+v6fXfcab2itppZwayXYwYIMNrhggoURmBpWaX32wQUHrlWYe/8B
		6OGH6X3mAiL2JWJCdaSlNh6ILJon4Wy4/XYabxeW4GCDIXRQQgg39EhCj0AGeUMIRBLZQY4L4tXW
		Ux+kRSCNaX3AwoYGXtjilSyiR4EHS9g3xwexreiamFi2eBWGaH7mWWr/bfnkWVc9WEKPPN7QQw9F
		5Knnnnz26eedgAqZYAku4OXBCYie8GaUhAG3XFeqndkil16CmSJrj0La3lcYarXfWYrC+VRZc/YI
		KJ57giGDDDq06uqr/rDG+ioYtPZ5p0lCAkkoonLJxZtbbSXXaZmmSTqhsKtR+s+X8HX6FYEUNrko
		nMlBmylVFmKbbVVnyeXCDaXeQASqedJqrhfo6sADrFbAiu67Xuhgxbzz8mCvDl5s0SoYOtRqaw+4
		3jDDwDXU0Ku3hf6l5LUMNwypssyKVixV09Lo8LUVZ/yktGghXKpJgOppLq34dgGGF12gbG8XLLMc
		xctRtCzzzF3YazMPKacMxhZe+PvvSQITXLDBBxe9gsJlzaXx0kw37TS3XS57YWnbfmD0wUhnrbXW
		V/e68bRFFzzDuHfaIfK7NLMML8ppx9wy23DXjDK6adMMr89F9GDH/q0mHTHD0IATfXBfhN/V9eGI
		J6744nNZBfHU/1mVeF5YbW15Xlgn7SvTvQ48cEl7n8122nDf3QXPONOt9tqsw5uy6i2/3EXMVrBu
		bp522HGSSX8HHjjhwBPO+PDEF7+5ByZM2WTUX643MVVwJX359NTjdfRfyPOG6KEeIDywuGXbgQat
		rM9c/vmvt67++bCn7HYUpbdeKxp66s6Y5/jn73lfKwAP1/VyeYvx4mKCFBjwgNUznObMQjHmTe00
		S0qgBE0QPIUljIJK8kAKKHaoRJ3AW98DmdmKcLLRvW19KEyhCldIN/XJ7G60QoP9GqO//fFlYH1J
		Qf/4gsEeYvCC/tU7oBCFGL0JQq1SzsvWX4LHxCbyEC8V9F9e/PLEu6CFYolawQddEMJx5Q4N4zvZ
		6lhIxjKacX0nNFkMwSjD3OmOCItZwhLERjDPDdGJQLwgHps4xD6mYIJvoVgckNgh6N1lj4j0CxT3
		OEX+AVF71OrWDucEsh6AcWSne+EZN8lJFr6QZz0718nAAEaUyFGOviuYEBnJQz0m8pVANGKTBim1
		JHbqkGVh4g5febTBSfEtjHTLCrTnwW7dEHxfPNfMuMCFMXbymdBE29vSF8rZqQ2MukvIEU45x6EN
		7IA1wCErKQhLXibOf7Fkkgdo2bxCkiWXrWQiC8o5qASVs4LX/oMLWhIlSS4ObFxFYKMJ60bNaBp0
		ky+kJq26UIWXoYuNJ0lIHE4Zzhn4TX+IhOc9f/mWenqUUFAEjNXY+cCJLVKeGy3nPJsIGEh2b4f/
		JIL4LjnQus3toDg1Y0LvhjKYwe+hbEQDQ+C4mIrWkIt4JGdK47nUwol0BSS1pSGB2cSVNnWPhGKi
		SHlDQELNQFwynSn5VOe6nqEtp2gloybRJUbXpS99aBgEU/pW1Brmj6VOzeghi2ZVlFbwqVF150mv
		mtKscrQsHHypCz6mN7GK0ZlrK+FN00pZF65QsjNzKBvtINc5EHUxdrUhYeVZF6nssa+KDORICQnB
		d1KVtKWN/q1sZytbj/4VWBTrFRdBFlCatlCtlQ1uCm06VprFDKgy7KxiLhraRNJWKlE57XPr4oJd
		VhG3UGWtSQ+py+l697ssWItTVZvbuNSABSaZKRre5baCDle48G0dQUdW07f1lrMNuZ9dkepE8ErX
		u1oFrHaVWESlAm8F4J3uoMIbFeiaFojXaxL0zFuDJZikt9Jca/tIF9/3ZviEbkUfQWe2hS2MDAyz
		0yw2B8GQx4TWuoRbC4Dx6N8AYzewrR0s8BI83f7yMJ/A6lhcSjA2ImCYvbI73RZYVrszOLnEHO6w
		ZVto08w6s26YpJky24tcGRIBIYzpJh1Fyz9vNZi2/+3x/mERu9paCraABuwhgusC46X2Ly66JCAL
		mNQkXonNyEVgXRSsILsSQzlmZxjCEKA8zdnRS8preyvLmMnMEb+OfDJzm4nZwAYUl09tduuycrkJ
		uBmwQLQlkAtq/dpU05o2l6rNrptzXJY4jzalVoTTSylsEt9O1gsOPd3c6EXseb3VC/OCdKQzvOQT
		YnZ1pByfW1lm6CV72L1eWDGLt0lRb+KvL0S7tXTzGmscbxfOBha3XoPMVX+WRKZghN1Z1WeFJ9h7
		yspmn8ys/S5fw3CsJZx0pbEtzRSyUblz6La3PTc0ddO4r7C+8YBvWes/OvyVquXeFr+aXoGOjm07
		iyw2/sXnRjsAogedzrcnrS1ZEk7bvWDIE90o3UwUCjuF0Y4rQ7gpZqMWbNUX58uDnwhEqsi6nbRG
		4I+Dvma2HEqL4fSix13WaLbGvAgmB4QpWPGLrv+CFWAHBKfFSCt+51tmozwxil9Whba7/e2rC2i+
		ukBpgqMxxVzWNph5XuoZML2qEPchk44OOdOkxS22JifQ1b2wJkG9yPHOMJffBQa96c0UplAGM8hR
		j857vh7MYIXYs2z3ympZlDpgaNvHwPrWu77tDn0Xo0vvQiv3DIwI5/kRxBbOxV986AkrepvbGTnX
		Jr66hnV44w3pz16v14RJ7kLtHMoGrWNeGeIgRznK/qGNX1Bj++Qgxz3sYYrRLxSyHX7huXDG0DGU
		oQyLaIT8G7EIUdg//mOAfe1C2VY0yjfTDaUzepcQfBdO0fV3hAN8EcdmhPca53Z8CBZ0y/dOuwVv
		kRdqbDMvYFB9mId5YGcIhgAIIrh1YKcN96ANrGAIbGBi5wcv+ydcGqZ6VTAG9icKvHCDolB/NYiD
		jeB2ryN3NscDSfZbsOM2t7diLcZt3nRqfoeALqCAgmd0gVV8iGdxFBSBF9d4cMZxX/R87dM6GggI
		rKAMoieCgBCCbIR1ZigO90AOKsiCC+WC8JUz1KR6rGeDOBh/jdB69Ad/N7iHbZcyQFh7MKNhG/Y6
		/pulXHEkR55DZOLEdFAofA34ZuhWKNXle0ulhS5wAlEnPmdUO3ZgCN0XguVCK/TyBPRjcsqgDeTw
		CyuISejyaHN4c+gSBTO4CDd4g633dm7XeouwCKwHe2blQjzQUz6VM2n3hQKIe53FbUvgN0z4iEEX
		ieU2cVMFgZi4Y7EVRbjVFtVVYSURaC7zU/82jO/SA6KoDYYgPk8wL1EAZV4QUFm3CuG3giZmYi1T
		Oy/oSf9nPqNTYuw1g2WAC+OAC/L3dkJoTXZIg7wAiFXwOnb3CI/gdrJDefQVaqTEWSymGKeEUdX1
		e4Eniea2LXBmhZf4StlIOVVhXhbliYQ2aPuo/kJnqA3aAAhmMy9YYAVgMARgUG+oaHKs8A3iYAqj
		5GQ9aQWW5o/zRlZrQ2jUxoIQ6X64MJWL0HY0B2o7Y4eNcIOLUAYNRYQ91YvzF4wPGXPS9mHOhIQI
		QWp3NY0hWY2z9jwVF3xYiEgp+T8R9k4rUDDwBmyDxifmEjvk6JdsYAi/oAymYAcbCAb3djJPcAVq
		8AScBgg4oQxo0GRnsAXGZmhJGWlP6V7ueDpG2VNWMIOXcAuX0AiywwVhMHDwEgVKYIs0iAuXUJVR
		sF46E2iy+Yv1R3+FsAmFMAZRoCdl9WnHlVwhcUqg9W1lVjgpRY0SF5ckCWetVJen5UTCJBfe/jgw
		zyg+JwM/OiBDWieCY6c2tFOLUVCYq6AMymAHndaT9/YEUOAIkIkGbGAHyvAN7fkEXmCUyTZ7I9aP
		g9aUTlliZyBG7jgGU1kIASiEMHmKT2AERjAvSlAFW4kLwDicKBNDwHaL9deQi3ALt7AJPRiPbYV+
		7PVQGpmcz7icDIdXGwWdDDiSzjKXlmidNIadb/ErJhBTREA/6LIFbNADYsh1XyeCinkyhLZ/LFN9
		q3CYppByPmlvO0AFlXAF/IkGnSAOvwAIgbYFZ4BstZOU4+hTPlVsnqlkCFqajbCgVZCBWIAFUDCn
		UHAFV7ADdIoFSiAEkZCDY9AF4hhKHSp//jXYCKc5oj1YjD1VeulzX4OAEXKkX2Q2WjI6eDS6JAZU
		ndnYF4u3MIo1Nl8EhBu4dV7nCl0nenhCN0gJNz3AdSgICEdpbxFqpVpABUaAijehDaawXiGXbI6W
		QmY6aNJXbC0Dj3CzdjETBQqKC16Zel0gn1AgCFQwrVTgCI6Ap1cwp0wwCX5aBSg2Rqv3h6z3myIq
		CvnHMoHof6yDnAQYqUZlao50VZUqhdZoSJl6o5sqdCyFWAy4l6B6SZfZM2yQeaaaCq5ADb9Ak8pg
		k+f3QkUACL9ADq4ACJc5L/ZmBFQgC1kwBVj6BPhZDqsACPJSh7FnWcmGQi94LmK6dkjZ/gVjwAsY
		WgXrxQP1Np9UcAiHkAVa4AhUsAOOIAg7sK1/WAXs9zqyKa57WAaXcAmbYK4PmWJ2pzMFx64KwZY2
		VGf3NK/DV1LTea/klHwbpVps4a+gMz7pw2nK0Iqp8AumSg3UQJOo2rA1YwUy9AvlQA0U244Wi7Gy
		wAcce6tokLa/sKsn+52DuT5qd59u9GyGJqY6CbVRsJWX4JWBli888AQ7oAWzMAuHQAV2Wq0/CwVC
		24NhYG3oaqENGYystwiFUH/nOk2WhWlGmFwbOVGo9K63prWT2FrvdK/B11TdOGFcVLbfGkrVxwrk
		oA2rsAolyH3agJg2uYIyMy9owAra/lAOrCA+xuYFT+AIsiALU0AFUIAFT9AJ5qCrPSCmZlWy8iWw
		imuGRGqGKecFPGBoR/m4hfiytVkFRfAEXRAGcqADV5AFswAHWYClanAFVLCzO4AFk/DAjVBpbDOD
		vGCurud+vwiIxwWWZRVwtnic+LVzHcmcMDpuiiR861SvvZsCzgm8bAY9zQdv36ozk4m8CiuCrqoN
		4jCUo2dNKwux3eelLcu9GSsLtYqnaoAMQrmwyMZWH4dCRIp51QB2H8h1ccs2Jaak+Cs7CnoJTVAF
		9RIGYeAFAzwLfKAFRsCYCqyz4rutD1wFzYQzbceVZSB/YyB/vBmMMYNpsUs3hZht/uyKGNxEwlrl
		XG+JWyksnTVKnVT0SsknUjBcZN5JVhuIw13HnmZoCGMYfgsrdk2MMqBopNkLbMX4BFYqC5Xws44w
		BbCgxDVpB1aHMqAExYbAnsrQdTSZsOEnerCMlI07L0sGMxbqpu44aFBABXwwC1lABU+wBWigwFpQ
		q+P7wJMwBlwwwbNZm1s5f/Tnp+fKx/g2jv3GjCLcooQco4fMZomMdHLJyExll6n1wkljUTKsSZWs
		yV7HClFafWfoqqj6yaCMBoAguIAAbLXzmIfAB4fgvX3Lyt9ADqzABvFYuWAQpikkhmSIz6xIDm7L
		fdkrLzEze8HMdouAC70QnCkG/gWZmwWo7Ln+WwRqsMC1egVYkAu50JBvijIUzLSFYIONkIOLcAmF
		UJusJ4i/9mnp84K1Q7vJuU3MJY1Zm87qdKn2ysKN7Fzx7I172Z1mC2JeUH2anMv6/J4mZwjMwAy6
		epPV9KxoQI/qiGyyerN8oNCyUAdwMAtUgAzkwAxEKVAVLVnqA7GtaKTet32G3aXIFtLwiKy22Kbn
		EJxtxwSCcAh1wLn0eas6ibnRbKtQ8Ac2XaIdWtKXMJUgCpxMC5ybAIxv2n+1B5qEFm21a7su2oTP
		KdWCpMIV90PamEhmwWdkkQJ8+aNrpzYbmHVimLBv+wsqmJFnaAiuQA4LWwR0/tszjqalcMsGUXCx
		VnrGWUDZgTALVzoHZJiYbHSGNqmYgZ2wy3vLuJwO7u0O++nLjRuQFhqi55Da8gcKeFAH/K0FDUy+
		9hbTbHwFRsAEnh0JqskFbbeVmyCiGCoKDb4JES7hGbpCXo1kR1i7LfrUTgS2waO168y1FFeJisep
		qIVaBMRmBuSvRhZvUFvJ3td1buu2KFiGIqjJpkoO4iDEMmdNAr2KEX0GbPCYVjqtawwHgQAHfFAJ
		sPANRwqUNC56Ej1ZAo28q9AJncAKZ/0L0JAO7kANyjAI/HkGclC6U1oEdLeVInoL59AMvXAOuYAH
		eCAIcyqh9ZbAU4Czndux/lgQCSPqlXA8zJlQruQ6orZgC7RgC8F5uO3LweaDnCIhqZO6WCZMdHDJ
		zgRG4icpdCf+S34UjkD4kjywgcjrDoZdD3ebCsybeWRopKy4sLCcbVnZBQJNj8zAaUN+BZVQCZ5b
		p1SQBXAQ7HyQ1+LQfZvsDqae1vGSmw9rvd3HvFueCsiODuTQCeLDaD7JpFUgCreA6M3QDOMA54JA
		5wBusTGtBd/r37fajpMgopeQf223CJuQCYNeCL8p4Ztw6In+7gPqSf5IdWDAWQdRtZJO233h4bt9
		wpcu4tdoknUJfE+Y1X32ASwMeZHnlz2jdeRg6tuH7G57yeLAnuH3tt1X/n5HmZV0CwiuUA7MAKtg
		kMC7nq1GcMxZwAfBDt5q8A31kLzagOpfPrjmx2m5g9HagLA6fMvXiw7yIA/KzjJKQC/2Mi8zuAm0
		UPW30AzwAOeEkJNPIN1WgLEMLc3rXpqiMJV7uLr5bgu3UOhrfuhmz+gIhYgrWrXmfM4In4C2vbVS
		ZXwOb1UQb1Vl0QFP4UEVOFOvWTtgIIbaVw7vPQ8eH37k8KTXC36vevJLRremQA3o4AqwjAYwz+sE
		rtJaUPN3LQt5bQ6o/n3mkA5vu7C4PpkiyJ7agA7ooA2VyQz3cA9Lj73aKztIqeAvgwSsi+i2kO/d
		EAyRMAlK8ARq4PVQ/oDuRuy5E1pvpWkJZZ+6SpsJh772IyrhIur2oqCaMalTpZORnUXws23wd2/i
		5BadmD7i2Mj+CahIgt9niPJVd+KFqgqKir991ODlADFvnjtq1LSRW6VNW7ly1MppYwUIDA8rXcB4
		8WKHFTp0htA8QaPmSqVKVHZAuUJFyyE+fOAcmgLrW72G1OqlK0fuFyCePE39ZLVKGTNmDzt1MlVt
		WLVq5Mq5AoSm4pYwYbhUqTJmzKJIt25lsmWr2TVauBopuaJGzRMjOw4d0kLlihErGK1UDLMIFy9R
		iwptskUr0yavtzYd3pTp0qVFVaLUxRhZ8mTKkbt0iQwGjZ1Bc+Ig/opzRPQM0qRdnHZRAvXq1SxY
		rDZhwkXs2B8+rIhD79+cDxcoXAB+wTbtFClky3bx+rRr1spnm+jQ4cMJ6jVmEOlx0Qvm7V7uZrSj
		zGk6au7cCRzYEBo0ck4Zto8IZkuX73YM/SrHzOMTO09GVpqCCgFXYmkWPuqIC5lvoFGInHrqQcgQ
		nlihkEJlfmGFKGbEUQapYYCx5JFRmMHQDvmqskqrQi4hzCtGbmmmGV3KagQUR+QyIqU64JqriPnu
		qmuLMQrhhZdL/rIlEyULY3ITxsZwrKLKpqyMu+0u82KzROLgcgnRjijNtNNUY6055557rrbbctvt
		Awre/E24D0xY/qG4FGY7DbnlzkSNNuikO2GFGmogggg0rrwMy7vQKMIOU8gpKJ10zkOPJnOg+UWb
		gg4iJyI2hjjDOzQAcSU/VuxAAww2QiJJi5WyOAQOOPh4KwstAlQjkVUydaehVVapEENWftmVQqaU
		WcWUURrhq5FhiPrFFDZQbKQRUS7BJcawdtmFEW53ueWSSQSRpZIbVaJ1iiueAOOMLR77rooyROFl
		nHGaUXLJwsIyTJRGxogiCioHnszKLqLAEo1BBgFtjjm+DLPMPMtkrs/jaLMNN9148y1OOWOzE0+R
		9yzTT+hM+CCFQY8wFIyDE1W0rkZN0ZSaSSkViCZqMNU0FWp+/vlFGUDYOCPUItBghaFTj2ZjVTUc
		qQTWlmR9Cda3DqnkClg6Gda8coilMFOgx3aFFVRQMYUVUx6xlt5krCGqmlEsqZbebGPURZdgaGlm
		l1z+jmQSQhyR5S10W1L3iS3cjUKJu56IYgxrcbH3HHyZDMuWW3ARBUqEuyN4YMxcfhmzzQZJxOGH
		R4u4ZIrPjC1NlNfcuLc3gxvOhJCR0zM1Pl/DeE7ZZmAZjVRh7mI++mS2AxD8bJ600nTW+6W9gnYO
		2hQ7mj66E6eYYcO7ptnwj4pKWnKJ6h0LlEWWmL5ZxRXz0tFm7ExT+QX/X1xRRhm0WZmbKATIi2EM
		wxpKoZso/iLRFWKIhVu66EY3mpGLPxDCgoTAwyHqYDX08SFxXtBOwKzwBCtgpQwr2sQ5xmGYFiVp
		MIVohGN4gBkrha5KGEGeRU6XOodBrDTLkVhrYHcxNWmsTb4Jzsd0VxyR9a4EfCqBmlJmHBdcB1WH
		CliitPMdVTnvIQvBmTvIYxCGMIQ8mPIUG3rQCWXUAyJFuIuqvOAfqBmIai3RYEtmscdKyERT5+mV
		QoCmjVQ8RCf4g4iyLMEXXkgCGMOwxCggyRcW3qIXmeDWNKYRjGDcIhcYxEMoYZUFR2ghC3jkgxZ2
		QJcnFOFKUXjCE3iQlTIc6Rbj6MUt/qIkwTgJStypoQ2r/kRDmIFBMwpT3epYN4PUBBE1FcsTEWdn
		RI55TIm7m9gzyYSaKM5uOieoIhGuiBGEXWYLW4SMqlihkIVET2c1c0g55vezaDUNEAepB1SsoIQo
		qIotKcnCKVsSUJagbxaBgEMfv2GOcghEjO0hZEHekz9oGIQVi+QFMECkUWbxohF+KUQhMIGJxOhC
		k90Ihi0iQQhyyaIOL00lFRxR0FqdBAux9FEYutDKInRBXovBRVBZ2IvM3WIRAIuMwCiDPGEiKjMg
		tAMPlblMZz5ziLLLGJuqmcTcYXNkLliBc1gQvA94gDozuIGhDpVUc0YGSCBkw32sV555jBGM5vHa
		pjA0/iEIkcMjVgiYMf9JhYAO1FYr4cMeD5pQZEAjHQLZxzxoQo76taceBllFRdFRjlEUiReWgKQk
		irTASCDmEiMtxC2C0Y1rXKOTFBQEueogKz7IhbAHIpAqUdJKqmzBCkVwpbxEEVRcIIYwgenkJZCK
		Q0QlqmBTcm53tAO6LkRVdXHwkpd+WNXkuMa7UcQq7Y5ozdwt8WIr2OYK1BtNE5TAAyzwwAoCdZ3s
		LBWHztWio5RRs0lJSlLmcWgZ87er/bFCHNozEemStwX/aCF9fDisgE4pKwPJ5LGQ3cc+JpsQME5v
		PeQQRzKyJYpkzE2ohwkLLVScJMI0Y7XdyFszNiGF/nHJYlZagAIUqMCSLEzBJXDB0RPcmqqsFAIX
		m9vELr1ii73RqAqQsQuQviOZHF4GXlBurpXAwJktLQG7YCKNdZgZRD41MXjUtB1XhWde1KC3zes1
		jpo8EF9B3QBVF8ESCIPJXMzM7BcSvSw0GALIXjGkfoh0iCu0lypjbkF5XsgRS2gbYXQFAqF8gIU5
		zpPhffSjHxrWxq7u2qv2VAMYuOTFKEydyxbSgpPB0IXmbsFkWOdtF04SxeBaYpIdOLiDs7IVFaAg
		ZLvoAAxZ4UVxnQQYWmiOySq+RQzva0PkBUypNtRMVBEBGi8R4QiDEpPEXrMC2LB3mlpNM+7WXBw9
		/rn5NOold5rKOmdBWfF4eQYdlRoFiGEdpH7xBKREBQk0p1ADKndu9I/KJ2lgBzQuDrY0HGSBDHM8
		qNOe/vRDRC1Pd3AkJ6YeBy6AMaJhHHlfr4Z1M76SCZSndHOR+IMgSOKIHdzWoA6XCwm7cxefMiuk
		lxDFklO8N1tcohGPcWrSn1owGlIbqgwDTWhEswRwO7PMvDszupGobuJQ8d3b3Kaf5kxnK5qoufMJ
		nWYmJJ76LaQckroePOPZkF8YogdF0E6irJCj286KVrWago8jXolvAPjin6YJsTLFEI5oCOS4sEQ1
		mGGJXqh81rR+9S7wBRax8CtcuJiEjs2lkoBO/ngWrgryfQGL7CMVYhHDnXXe9NbJzik1UY7G/YKj
		u1SYEcx0qIv6w5ZAdTGT2XXhRfPWgVNedrcZ7BazDb1XUPZD5TB0o7OnKfp3IYdIyrEOkShDNqUN
		CaWquVa4QkoQWyvAT6ESe5RFptHT6X0QhBqIBJrAmUGhD+FSFAW0BLFQkrBouV2YERfSHOMah0hg
		gvRTCVNylSyAg9MLsiDBIaywliMpg0VYhEuAkVpLKbN4Mh3IsnPKPUfbMyrDN+h6utTpkuGjunAr
		GZOxmCLSOvJaNyo6jufLE9uYt3rrgTt7pd0THR4wJjawA0cRB3HAj3S4ibcro5ooiOqJiPp6/iX0
		SwmScDhTegstIIk+UhB3kAf0wAnxQ6RD+xllGAVFwoWwMAtLwAR+yRyUe6Cw6AVcYBHEyIRm4IXQ
		U79bUT/DoQIjILbkoaGseL2QWoSPQpK8CcHGuDYtmq4smwxjskQU9D3T4TLPwK7hE7Mxm8HYgY2s
		qx3lUyI2w5Mz6abaSAF6IxQh3I5yWkEqKSdL3Ax+Wzy8wquaaBCdUAbt2SK7yJGaUwkBUYlDyIId
		AcOF6riBgAaGMrRU8JmDwJ9VQAq5sQRRsAVw4YtLSMDjQjkVi7Vm6IXFOAzDUJLAgQJiDBAowIId
		CCiTMAIdcDQqy4rhwpa+6EDA0JZNwAQo/sEIV5ohEowMEuSBgMEKa8sMS0ye6xud0+FEGAQzGRyT
		cqvBcytFHOw63pEYP0kZ9WKB62C0LEvB55LFyNiMtPkzjkMH8yiI9hibgxCai5iyOcqRlDDGAUlG
		rJGJb/BJTfuaXoQUn8kJX0SKn1gWxBCFTQgqxFiyJssczVkMFhE6W9iEP6g5R7iRdbECKCilnMM9
		u7gMRGQRPORAFgELr8CFxuCCxwiYGbI2KYsCrMAKKHGMa7uvkrSMyzAmLntB7doui8wmc8uqjFSz
		jcST3pEd3ZmTErAiY8pLLGlIgskifNsyXKQGjig0gwi1X8kUnQAEO/COirCIneK7cxkQ/i14qT6C
		hdaEBYr7GmnklJooBwjpH2AxBAqxhDJoAg4MqsUIqeNSMc5zIRQKC22xysFBvbSIJR1zlXWhijNY
		nrEcg+EiDLNsvcFwkjKwS7r0TmtrnKxAAq2oFrucRb3cS01MhIbxIYo8PsIUr63iOpDxOsWMJg9I
		mQ9IDZGMzBVEz4OpC3PiDjCYEFfAp4YQJAoRtb2SCO8AoXo0Apn6SqiJQMT5sUOQiaeQxs8Uv5zQ
		BmVQG5WMFkvgAi5oBEzABUzgwEgwsstrNq84jCM7Ts0Li00ghJpKv/SrOR5RnDDYgjm6iy24CuvM
		BMMIqb84jBXhTq0gz/L0ziYVIFEo/oS+MM+mUkGL4IzgW53AfCbBRL4bPEz6PA6w4qbnmLPmSytD
		ybc1ncQpSSdMxIjLZIULaQ/KEpagOAigmUkuOoMwgLQr8EJbqQRXMSX0gYNLqwRkgKcGkSd56pSe
		4DdygAYAogouGKmj4sBFYMrK8zymbEMm04Vd2JvBIARZmIUs2AEHpIIpcLAsgE4fnSMS4oIuMNFL
		GEBdQtLDWAyQCk6g8ygmlZytuBbjYowY+hwVZEFE2TKom4NCWSZQrMh46x2PjM90W74cHNMunY0V
		mDPqqKIb6AHjoa7JbCouko8fjdNbBIS0ITAMicmHCJoGrYt2CZUcIZBDKJxRQp+I/vMgWBAHMqIG
		9/CaugtNotE+aFiFqHgEtjkqYO3AT7XK4AQLWpA9TrJKQYiVLDDGKSgsCHtVBosl0uSCMbDVPTQM
		bDE5pgTOc3SSXV3ETF0Mr1gSPNSKKkBPZFVWLuMhb6OqJ9omi6lBH0w+jaTB3iE3OkGZbhUUInCl
		pivJKbPEvIMXuLKDIEzCJOQJrA2Kz3Q78PvQqBjNOAWDJxAJwsqCPRqoqzkoS/MgRYVCKVQIUyhY
		JDQFcdCGTkCVM5ADELmKrEDEvzBSv2CEfNkWvbGFP8AD2nKVqCEojXVHEWILEqLLrUjZwgAMN5zK
		4DyMtGSM12NZJFG5TTgqm41T/t7Dr8jMNtThEqmbSFC8OmkqzPEKUz8ZzG1Frw9wrxMYFCIAg7kE
		psmQsjgtgh64u7Wa2n2DVJ4whFVRFUNwhV94Rki5noAVGjtwJRDKtqO5Aqg5hFmYtNI7VEsLhER9
		O7jbH/5RhjtrmuZRBnHAW6IZBRCxBLvkghRZIM4BhqUcXKZcsmYzAwmEA1spKIIKkJOAAiMwAixY
		vbrcimQ7x6h0w6DqxgeOtSQrhK5ADNCVyl9iSKZzLtLZyyyJKi5RptYhtycaxS81zPmkXcWkkxUQ
		Wt1dAkMpJ+aSDHNlg+TdHsg0pnWtkO1Lm6HZDFZ4XnaaXoPYCUDogeSV25Aw/h9ZmJqrCajwDYRZ
		SFT/Ig9XcAVgWbRzJVDxSN/tGYVkAJF/qYIwsAS6qZZGAK1kmOA8TIxbEIRTkgVHEARfG6i4MMYr
		gILIqVmtmBdlI04XGozFuBaqjJFgULnO5QXjir1F5mBjqiH66D0Qxoj56MstiYMS5lIUBlpqHdrZ
		pY2voo3bpZOVQZXoKkk18uEQlZam6SLt+8w6BZaIcBQKSQUCW4jxwxAJMYTcDBoMMQWR0EL0aZ+3
		kJVLszAn7JX7s8bQbDTMAIQ26hAxduM15oLIq4ZksIQq4AI5YIoPGVanzAWMrWNBgJoOSlstsGNQ
		mAQBalhhRcsBpNjiPNLg/hQLV1M5fVzKFrkFk1JkXABIST7PKgthzVDdHqIqbroqUAZTFh7laTWB
		+EKZ4XlMVa4MdQLRCqEQubUnXPyzIy4b7VHJDWUnhYDXsqGQ520PLWaFQVADkkCf0kMsCsO0b0CP
		gfiZVUgEaH4059EJpGCDMTaSRQQtuRkFl9kCNmCFcDaSJKPKXJipc3aEDiostNUCQpiESIBn13s9
		KSUMJXExw9VVXr3cV2uGtXy9mIURTVJk5aoCENqOuyRCpiJoHUIdHmpP121oUpRdiKZd9lKv4Qgn
		VEm6FMzhCyFilQ7RnjCFTHEFn5GoglC0CbGff2OIxLtsQ6ufX+gETYCF/kooED1mVYEiCYrL6XnI
		iV9IhOZhA9yLq19whw/9xblp5E0okmEYhTNgg4sgUH5TCl6A0Zgt56s5ZgOBMAnEakLwg5BaoE3w
		Fw5EUrBwsRcNl84NqVlzNb1Ja8YYVrAIhpNqBrg+RLqszP4cHQU7JtRRnfbkpp+NHYde4Ws1GReu
		6DmJL7TCDjxzWgfNDI3QibFJhY6W257gPonKKwbtt84O6dpsiFweJIUwB8qSRkSABQ0qlwDBycAD
		Q3pI7fRAWJ7o0zNoHlYoD3cAMWzkhUx4EVGwBDk4A5pU1+CetcGIQ7/BA4HCV++FgzrI8T16CUH4
		A3A5DK7+qBPKw8uL/hGvcNmYRa5pIOuptFWKhfKUYoyEZGDzNpje0zMsyTap2tJwYwH4ht1qNcXy
		GuVRtI0SWK/rwDvJQNepFdvwCPBM+ZXGDkJ+M3GO20VqiAh+YwYGd4WC2EXFG5tnhJBBXwVYaJ/T
		Sz8EFgnXXKjUjix3QFgJGYUwWMPHpgZ5eJB7uIcCEm5wWYT6DZXvAC42kINshJFeUhIcd4mXCl84
		CCUNkpVDEIRc2AV+iYQy2EApR7FmSMDFKBJs0W4Q7KUVKS6KRetwWdKt4MBqScgrHVBlNR72VujA
		hCY0ke+/pm8aVPPYaPO7s2Rgqskerh5ySIU85eLQzHMKASP0cAcI/vnzDLEfBMcrziSWXTEHhprC
		0H4LdSHEIlCL1+wEbdg0DBMI+lGbuVE1e7iHTp93cmAGa/iQXIqEMahf36rJLgiDKlgEGGkGYuiF
		xOiGc8gFPJgtqkEoWo8tSeODXF8tXXCSFZlKZRO6JD1LbCHAih12tEQuRZbKKM1DATLWLc8z/uZL
		LdHrhfbkaFJhbz/FNE/Min7hV1SwB8UhqFWVx7YeTsmerF3ix/4jead3oGAGehq1AIMooHGsSUGH
		n+mEK2BVgX+CQegEZND7g094DNMwcxAHuSmgZEgGcSgHDesrZgjuX+WCc3qrLeCBg6yCj7qbO8SF
		YIAHlJ9jWKkD/peAsNia45aQBV1vrU7K4BY5R32BapR10WYvkr4A3OOMkdCVUc1xvV+60tJFni1L
		hKZnnTHpaxuc76kXRfZa83prmQ+WDy+Q8yN0numFVxAt2Oa5jz8CMMlKpLQJdKAZtDAqNNqcFHlA
		B2LphNbEyWEbBE34BmToBPzImXqALE/bB8BXCvlNBslDh3q4lE1RimSIoaUGCDBPrFjxsqULD4KP
		Gi3CdesWL164eo3jBUqQIEdZ+PA5NIUKSCpZDuEhtGsat262Mtl66PJWJpbNmt0qdMnmJYe2Wtpq
		thMir0ZjFi0SdemWrWBKaWWiZYsW002FxlTp0sULGDBWr2L1/rLVKhg7icbOmXPk7IwZLlyUYLF2
		rQkTLuLG/fBhRRx6/+Z8uEDhAuALdunSfUt48IoaM4ig6cIlSpesYLZ4JegFKxg2gH65olbuMzVX
		v1gBAsTGDiBDv6h5dudu3rxyo02ZYtVZm7Z0rl/D3u2uHDV0rufJQ/erE/JOahzhgfJkkKZvmo6s
		SmUdmnXrrFMlMc1lTJkyVc7YhlbdujZmw5I9wmqnSBGCPIaoQGFfhggMUoAAkTKmSRNSCDHJJELs
		MAWCNByIoBaCEPJHLrnsws01UO1E00MxXWhLITYZdcklm9yySYgrSdVII1VUMcYYDG2SiS66LEVL
		MLTEaMsm/otUdZVWW112mVVcWOUFGmMlUtZZR6SlFgtuueBWCXIddldee/X1V2CDESYXXHR94MEK
		KyyGBhpe+cgVV5dJxgZnrf3miiukAWIHaqxoAw001Aw3jzu/rMIKoK5oQ442n+nGW2+utdYbOX6u
		osw3yIR0hRqaTJeCDSNkOoKmNtiQBKcjhJABBqVmkIEFIYzgwhFLJJFEKnGecQYY8MWnRBU8qAAC
		CBY48KsDEkAAQanFFquCBBMom6yyVOxASC4PnTTNNN1ME8xMO8VEI7Ym4oILiOEu0uK4/qn4WBQq
		DlXiTkopdeMt41alJpBofmUVGoMMkkgcSyyBVlprhSnX/gomrDCXl1TqxZdfgQn2QWFwdWnClycc
		fEMRZYJRb5pe/XhVF2ywwoybv41mSGmAsPJLbqwdKo872vgJKMvAeVZOOrAl+ls6h6ZjjsxwaiOO
		clRooQUsahwxwgMnPPDAAgswwMDTT0edANYIGIA11gp4TcEJn7piyKxd6DAQrlWIoMEEEXDNgNcK
		bJ2AA1hLIIEGcRsgdwHKTgDFJJHc0gsxulDbTTcyrsTSU0r5pOFOJBZSxhhcVBGFEkpAxkUYXViR
		7orrfrsTVDHSJApV825s5pBfeZzvIHH0C3DAb0mMcF0KW9lwlhDHZdjEdoXpAsarc/wj8pfxgJVq
		2phz/uhn2gCq8sq4mQNNoe7A/Bs1LBPKGmvl7Laz+Lv9LLNn9ZBTtBaVJP0B1AscMD/ccXvN9QEK
		LGC/3AQQMMACHvCqVLAhDCrCHAZUlAEHRMAACHggAhQwgAEQYG5Zk8ADE2CADRKgAH2bwLPysImJ
		2MhdjyvE6GwhI2zFxCVSucS4uPAYgkBmC53zCuhWtIhCbOJFpdPF6ajSMY8l72NEssMg5jA72tnu
		dlPCy8Ku5DAtcWkuuKOYwVZQAiIUwXg4HCLywAIIUyjjeYdSn8xoxrJByaxm5ajHZ1YTGvCxxje7
		AY5v0lEObdSxHubQhBqu4D5YwIACCxDAASIQgg1s/kAEIgjDd1gUhjAMIQQdCEELRMBIEchBBBY4
		gAAesIpVFJByVVCBCk5VtwM4EAEZUEEIFvCXDnTgBiFAZakQQDe5GSAABYABCB2Ui01gohe92MlP
		ephCd0WuhyMCESbGMEnPFWQL1tzCxj6Hq6H0kCWlm0YQ5/UxMBoRDUjk1xLiwMQmcumJVWIYlgBD
		ReBtKUxi6gGZwjikIhqxCHboBDTM+JvPNOoXBv2FMlhBG1aM0ntBg5NBQaOnO4KmfHdEBzrqUQ9x
		IAMWVIAFSFlgSESG4AyjGAYwlhENYrCUGKEIBSfoYAg2DKMYnDgFTosxDAcEYADfQAQbhkK5VNZt
		/oNbywAXLCEDAwxAAE7tKd1EYAlLdEEDDuiBBXqggADAABaOcAS0eCEKSWACE0fpYQ9zcouZKCWZ
		NsEFJnABDGBYIgyUqeYWzmBNL9BwRaLoZk+CQa1g4EJHHdsnP1+XL37FwSwAa6IVryi8d0qxd4W5
		LGHCpBg7lCl5iE3s8noAiFXkqRyEwg05xJFQQ6AsZSkzBKBiq9BRDgo4GCVoGycqHN9QAxqRAiks
		kNGJGfhFAAAQQALCkNJxEIMbzo3GMoBBCUMwbQaAGIU1KEGJUQAiAgBYgCY6MYoyNKEMIligBo9q
		iWTYYasBeG8A6HaA91ZQBpYYRhikugUQEIAI/mrYAUYIMQkWgQdEUulQD3vSDMc9JEdNkEQockoJ
		OZyBr1bowjUp4wUdpKtFgNWFtbrRDFykyAvwuUwUopDY5C1WiUhSklrYOTGK6Q6eU/RdFbdEFzFh
		rLP6XDGQsDLaNho0trQBRA/YoGQlc5ZOrh1jyshIDjiyRmYNzR46wueacvi2o7DoxDe+cYQUPMCQ
		CyBAck+BjXCwORzYKMYGQAmA4wIwAnVLACgJ0ANTAMIS5MWACO7sSuVawgIEAEAAFHAGlA5jGKN4
		9BA0SACpAqOslkiADJ5wBYwwQQky1OEiInFgHsZkwdgakSgWIQlObKPVxqAEHSpsGQwf1q8Z/kpK
		MBBni0tUzsRl6gJkyMnic5bFsUuSsWRrXFl5+i6yWxqMC8a0ujR9lp9iZAU5pudaOqGhi5K5jBUe
		gQpUoGZOTa7TGjkT21UYlBpBc2M5zKEMTQRXGeQgxyhPoG8T3KAHQ1AFOAIOjmcYwxDgtRQiyJJE
		IhChNI8exULCE2iuYaARwJCDAwgQgAig4RFzlYQkGmGJUYycDT2IQABUsIhMEAMXgPbCE6AABSwo
		AdjpQlEkItEhUsvk1DlatSqkoY52qIMUfZDDFghy4TRlxXJjEAUuVoLrYOxaPJHJJ7CrHUavmHNf
		xT5LDRSDbHdGkXfM/l07p+QCxTCGdUYU/na9tsAGZmS7NGsiUxE+xgNgKwEUtXjEI9gwq6yYMzWA
		gi1DR7kK3MisEwutGXZW8Q1lwLEcqYBGpvR9hEH8+xkCB8cxrGEIP5qj9HhS/CiVYQo2bKEK4cGA
		BSguCl5wgQECCIAGpgpysl5CFHO1hMkb3oIwNKEp48AA5xKChc8hxApVQNEi0HqOcSyuKS2ZHCeM
		IY12vOMd7RCGJ2LNV8hEQemTsVwZcvKintgCXKaMzLSDDWSwtPjFYY8xZMm+u3g+DO0zxiJb3ABn
		uV2QARkOgcFm1J2PrY7SfU66CMEf/MEkgALgPYLNAZ5myBagNNT3rIIpDAJtsBsfpUJv/pVDlrmC
		dazCp5zABbhACHCC5wncMXDACHwDPVzPKiACIsiOvxyBaUzV62GABiUABkAdJnDBAQCACFRaWRFF
		MbUcLlROCEwhG4hA8dHCLTTBJIlAinkasDnfUPDQi5wDGfoEU2SCVGACqw1d973DOpDCHSDdVaSY
		0hmE0y1CiIgIuMjL5RyW1nnWVSzWkTjWEigG/tmO/tmYZUnJ//3OFg2gjxQgkJUfAv5C3cXHhWWF
		hSmdEgiBD/zBF+SBBE4CEiABgXTaI4zC460RavHRL9BGbYggcNjMb8RKKvzCqzBNCkRAHxhDDILD
		NjAABYTZN3TCHCwBDCQjDLBAklmC/iSkGuWgVwIsQi9kQi+EAXINQyg0YSNAHTHAwzmAyxiIQAuA
		QAvwwBjgQiZcAvJNkopUgQwBm+v91Ys0wznQiIJdXyGo4Tawofe1wzp4Qh/oFRF9zB1+SKrpSIpB
		BvIcxEEYYBdURRHoyyCeRSHWDjslDBTt34353xUVxmJAImLB3Y8QBBok4CoAQt4VxGQcRAN24g/o
		gRiIwRe0gQ/4QBC0QRv8gQ8wQRSgQm2sDPjYDGuIhkEZZc14xs+QA2xxB6g8wAUswAYUQ5uFwzbQ
		4PWkQkpOIVdi0hZwQSNERCNwwZ2NQS+cAzH0AhcgQDIMA4Q1gVklBeKcmilpwKl8/gcuiEI7gmUj
		IEEVTJIBpd/6kSFUYAtNoBUmnIIqDF07tEM2NOYxhB+tTMZldJa6dCNRjMsYqFiQWUWGkaRXSCSx
		EeJFQlaybaQinl3EGMyOycUNMMavRaIkbt0XnqQlkkbeeYU1ESQn+kAbiMEarIEYOAFx4sAX4AAO
		5MAP/MEjxJYc7dZu0JFRjpIrYFTPxNEvWEcSPM0BOEAxbEObbUMfvIA5pKAtAYsDhIAFtMDnVEFd
		iQDWYMAlwMM1tBwGZMDHSQJc9gK3gJhK5MgYlIoIqIAIcEEtYMAk8eW4TJIcyAFZwUQzjMO76AJT
		7MIIwVWEPUNjZoM0SIMzrAP4/tGBHNjVxnSbF/CAimAmUYwBEpRf8qSYZ2rYim1FWHid7NAO/qVd
		7qDmsvVfwbTTj9rTDPQbGvSI6wBJQQCizVViObgCIKCBA2LYrFgY5vjAF8ykcM6kGOgBcXbpF4CC
		c64GOuhMz+hG97CCMqjWKgSHPPAJn7hDOlADdzDNADCAMYCnVVrDBoyAMuTgEnyAIcVNBEQAr4CA
		DvDAxElAEzQXNxCDKCCAJACDJOAhD7XLu4ATjkxOgKKSCmxBcoVBxSWkJMgBJXACNmDCOGQCcxXO
		NOjCSjBCLyyDOm5CKGhoO0iDKpCCMKwDQJICJ0wTGjxBF6Foi4iCTUTCuJSf/hVoIg1BRlaQpI/U
		KDr9C4zl6IxNVtnxH2L8zlwEqWYR6caQH41WRhGBTIpVIjk4qR38iEMmHUFohRBcqZbOqx7Uq70y
		JxkZ1KDUw2vAaWqpHhmREW6ITz3swz7ARs/M6QMMwAFYw51ugzFYAwN0gHTEwQoY0vwoQAQoAAko
		knr+SgIogAQ0wjhcQ30iAQJ8XFzhwiYck7vECNWhIS9QxYBmQAAYACSNgVhBEzAUQzFgwzIsAyaw
		VDDECIWuRC84xC7sQq02pjPkqq6ug9TeASXcULdphQ4ZayGI1SK0qLNuIl7NXySeU7/8CxEcmxNp
		JGWZnY9yK2vGhWZxUZH2/kiwoUmSluu5JmCczElmaKKFecEQhIEQ5ACWBqeW2quWfgEhJEOh4Ik5
		8OtvpFY1mEItJANQFopFzYPBGmw6KCzDOqwxRKzBXYAyzAFxXU16npwBcOWghqwCaAAv4BoxJNBc
		AcO3rN8xPYXR/kRhBaiKqIBjuF6IsETSBi02HC82jEPitKriJO0t7AIj7IIkPEM2ZMMxkIInUAIp
		kMIxSK0xjKjcbYzTiYLOFcItwFDqCMlV1OFeiS1XLNYOGhtG6iiN8SjbbiuQFoaYyG291C2SztpX
		uGQRJGAqkAaf2R1fLd8QnIHgtkG9vgEEv8FMyqSWCmcb1AIzwGk61ANx/qCDNlTDelTBJPxdNUyZ
		PMARH7nDPvTDPqQDNDzl54au6F4Sn9mSna3nrLABAYTADVxSA8lNC5TBJkDF7HLBXH0Ly8bEttgI
		iNUIjlxCeKTOipBX1LmLMYXCMmDDNmADMVjLtRRt+zkEIzBCIQDDMzgDGmOvdnGCKnRvQIqoXkUk
		i5AvgoHIIgiFDGlYQSwdRO7TYsmOOlUr8Jzm2lJAPFER/f7ODOBTZ90LmoBb8hgPalhi9/yCak3P
		3y5wFVhpvYpBBH9ycIayHkyCKeAMbBQHM6ACKPyBA+vBK+SC3yUDMlSuMojP5rowDDNAH1iDJ1iD
		NSjUdY3CGQyBDAwB/g9MEg9sgQG0QA/0QAi4TchuwX80BTE0gRGTlUM0w7Y0hY0gTjfUSCaMSCEs
		ghRIwSKUAQ8tmDfXCDFk8RYXDswWrS64BFytmjCgsTO0QvZyAj9zwjrkQ0D2QYJ+R1Ec2IWCiyiM
		pZD8mAES0R831r+grbOpbbYeMo4ZBmGsxSJvzMY4cgFy5o9khZKpzC8Ah0bdG26wAmd1UesJQRt8
		wRekwRqUQil8MgS7AU67wRr4ACpoA2+gAzM8AiiugRuUgi94gze8QhvkQgQSAipUQznsAwd3bi6/
		AC9bAzOkaTVUA6zpFWDKkAoYQDP3QAdEwAIMgALIABcASFwhn6Ri/gIyQYVc51qIdYOFjMiobYKp
		wQM8sIPJdgNLZfFKxbM878JDJCYn3LOHZoMzhC4nRGoxqIIz9OqEQVIZ4CEuIFgK9S7nHIS5NrSZ
		HNFYNNY6feSOFnJHmkAKrPZq1wWXzMC6jpOPPCSKRXJmUM/NKIrNjMacsEEXuPQrkIET5IEehPIb
		5DRy43QbWIEy6IY2KMMj5ABRF/VR+8JRe0MpvIIYtAEolPBUUzWdLgAgVIM9GIJfpMAL0IF6swFL
		W5MMFIEBDAIRdMAAvBeiOYAIEFgZIIARmxU3e3M38PU5fDPzOvFK3No5wIM+LLg+wAPitBTRrtCE
		Lm0vZGj1cqg0/hyDMfhs7SrmM0gtKUwYyEFdEse1U3C2XaEYaNbLEe3LjT5WI9Yvai+iCZzA/63F
		EeQmx2id5/AVZmSGnRRKa7RGltWDNrAWG0TBD3zBK+CAKLYBcQJncrsBJEDCHrTBI9Ty0NTCD5BB
		TkMCUvtClY+5G+jBH9RCCQOHU9JpBBDBVi/AnB0XA7zAM2/s3mjsBMH5nBGA17BACECSuiQV7+lu
		gCu4Pnyxu7wLMtmCMdFCNzA4g/M1PHQxtVBoohutq2YxG3LoM7zZYwctqGODMaxDY/NzpN4u6bjL
		iS9CXQ1JioH2kJCJiwcyjGH0synb/ULMXFjMR0Zbjrtd62zF/kNSk5qEhcrcTB2NTz/0Qz2MxihY
		wR8odQSy8h/kwJVON5UbdVIzJzMwQzXUwh/gQHDmNE1Dwpfj9Bt8wSQkQzVog3baANQMwBahQicM
		QJwf1wH8z70b170PAKB6TQQMwYiey1RZAlEMcYxIuj44TqIvBTL1QjQQDqQvuKQHAzsMVn9K+LX0
		ghYPnTps8TKEQhO81DIYU9LWaj4Iw4YXQ6VdAku4SzdcwzePmChYgpAkxIU19JBIKw/CuGnLeLZ2
		5K6nwMCAJGMc6Y4Pu2XAR1iYgiuYls18xmfUw7LXQ/egAhasMoFMwk6usgNjOyTQ9Csw51ZXQzJU
		O3HKJE6T/jlyQ/B2o7ky/IJ5wHvUkABQmoK9z9kAbGzc5Dm/z9kF2DDWOICISsJj5FeCpl/j5Fqu
		nYNPtItcW4gtZHEofKPCNzhfT8PFIzq1VEvMX4ODE8PxthoX0wK4EFOjP0VibsM6PIMqFMNLuTy3
		IM7mB8Mt4ILhhwHOwzr92Si1zq+OYStHWtauW8yPRomvN4Zssg6teYGyXgZ82IEpCDmemFaVQUM6
		9MM8UINC1QIoiNwwTMIr+N0qXylyC+cfYAG7J0P5d6lMHveYC6ceyCtRf2kykFGfwjvU9MCjGUIS
		zhlARLBTRA2aHoAALQCwcMCNEC1ARFCgIIIcOWGsPNki/kJEmDBjFm2yFYxkMF22bt3KlMkWLZcu
		bfXCtg3bsnHwcMLTB48du2k4u5GcNnRat2vc2O3sRoxYtGg3pzWzNbVks15XQz1Tt41mKEyZaAUr
		ytNnVFyYuITp8sRLW7dv4XbpAgbNoESJ4sQ5cmTGDBd/TQQWbOLDhxVx6P2b8+EChQuPLxQ24cLE
		iRSUTawI7GIGETRy5b4F3WVLFy9drFhpC6ZIEUCuXP3SRo6ctl+uUqWqt29euV+mUD16RCnZpDZW
		RtUC9efLGjdv3ojRkwuU8klfxOwR48SJGDFv3IR3s+bLH/PMteeqMsqUqVVHLixQMIQOHUoMFgJw
		gAZN/ms7PRLIL4CHWlAhIokUSECEBBAoIAADQpChwCoWueSWqW7ZRMNNVppqJFpY6uUUTmoi5hyy
		euppLKZMGoodo9jRSZ+eguqGp2l0yTHHoYJh0ZZTuMImlFB6Caabc/RJUsWTMCkjLS+KgEtK0UxD
		ww678tqrr78wG4wwwxBT7AMKyHQssg8CS+GyyVZY4YQVXLjBM9HaMm3K0Fbzgg1DDDFFmXKo+YUV
		VqiRZ55D0zHnG1ZMYaUaUAgBxRRmmHn0Dz2gk447J/QQwzk3SlnDO+8+DW+NNkBhDxVCyJAuEinG
		eAQNECZKIAxJJBkmwIUcAMMLMHroQaGFCAChCBRa/iAhogUWoKCHLbiowosIAgBAAAIceJaLCi9Z
		ZIxGItnkwmZKwvCWszC5qhmiygpKl2muWSqsoYySUUkak+wGxx1dLGqpXnDBZZNLeqFFFxlTNKuR
		Krjgws4p7+wiCi+s7GSOOObQ0i8uu/wSzMQWa8zMM024LIXJAnMTzhuKQAPil08zTS4wAOFvEFZi
		G3QVbcqp51B30vmFmVGuQ5UZdNAhBxUmvtBj01Y9DQ8SSEqpetRS3RDjj0eq+Q2V5cz7IQcaaIAA
		AQNsxTUZB/KLwAsegO1AQBB0qLsIZSOQaAEHoG0YDSIGyE+BEHioYozDDQ+pmWbO6cbxYGiZSqqp
		/ljahaiSaCEqKGKK7KYnnJK810alIDdymhRjDAalTXa5pWBdzhmHGLFevGURhh1+GGbRJrZykIv1
		4mtjwLws7DCQGSMTMskyo+yvNt+M0w6Xd4fZTiv4A4QVQxgdZBVy6nFnHnfcKaeaSfR45YtHtEFn
		nnrEqYWQNvJIow2oP4XEF2+8CXWN/8Gjv1dMgmvKGBSjUCE/QpCtAQhI0K0swYUWtM0LOihCCPID
		gAgUQQeq0QEKQBARAyiAbw3jggjYYIcLzK0LVXCh4Qpxi8WdqCSQo8UudiEVsOSoR03phS128a5p
		NMUpxDjdUHICD8fFi3QucVxSdqKPbqzkFq37/qGRiug4W2xiYVUATfXi0ru6AE9jw/PSl44npsZA
		hmTNmwxlVCY9X4HxZagBAxtSaAeE6NEV6KCGNtKRjt5Mwjl7+IMpqCG+98EvGY3wAQ6+ADWplWJ/
		/pMOpqj2BSSwoT2/oMb46lEOZVRDHIMgwUQc8JExcKEIbeNgCwiQnwEMIkpRmBgYQOgAVJ7BIx4Z
		QgKOoAABaeBttqzCJWzRDFp0Q4pBIYmOkrm4ZoyjF6EA0ikwgQtpLmMm4YiGEHXhTGI4DkY+0UVJ
		Rhc6dmyRdReyxTl9SAxbXKIMLhyNak4DRolRDA2dwEvGhGfG4n1MjSNrI5xQ5oITRO8G06Oj/pQe
		Rho2gAEMejQEIPxUDmaAL3zi+MMa9PCHWvyiHIcyaT3qUY1HMKENX+hOqaj2PwAG0A1fUAIbBtVH
		kx4qfKkYAQUSxAMurLKVC9lgESKQHwEQoWVWsCUPPggCCyQgQRbopUeoOofALSQAxtKBF6pQCA/Z
		4hw1NKtLejGOcVgzH/nYxilOEYplcFMddcVGL3SxC5KExUhiIcpQzmmkdO6kF5gQ14UMpgtizHUZ
		mPBWFWwZsy/qU4z+zJLGuHRG44UpZAZlHkKdF8eGzhFm+HSLzLxgyyiQZi6cbA8qqmEK24iDHvT4
		2h9SRY5ygG+n+/DtPVCBBeY44X/iWYP//twACfG4gQygqAYzXHE08e2jH/2ohx9t8IAFIECoq2xB
		tTQYLGEadU62lAtUQTiRCDhABmcYwhBkkIABLGEJAhBcDzgYVlxcYr+4uBBYzrqSq3CzrfmoK1e2
		oY52tMMZqpCEhdw5L35djinjnFGMzlHYXnQosYudK66qoITUSHa1dNwnfyw7B4BuiXiD2Szy1rg8
		NLkRMG2KExF6QNqXjRgutrSCEpAA2VGMIhnKwUItaoEKZfziHpBCBTNQaqif7XQevt1HPZTBBO5E
		7TnR4bJxySDSapBDHGUWhz3ucQ9yUCMV2ZVPR9KCQaPaQc4LuQH1zNsWGVwwbxSJQAh6/kBnAgiA
		AkfwQAY78BAelIHRjS5DIQqxksTqKK+2wEQosLEOfmy6Hdl4xzsY/AlKyGEMZbiEuIK4o3DiqBfc
		XEY0iOGTGDHlh1Pha4+WQRNORDAKIwaDXCJLWX5iacV92ZhmCdpZNn4WTjVeWbB0DDHT5lNiUVCC
		EnxgnuoopxaPGEU1SHlmQhBCHPKw8pWvq8hDnfseteCUp6oWqlF56pJiIMMXCFGLIo973N22wyqS
		MAL5IKAjHumBfQGggDkMCwADKIKvgu0FGaAhBBEYQAD8PBEFDGAA9k3BEba6kBBYIAMYMPnJMYCE
		R0ea0u/KkaVPUYxN4wMfn35HNjzR/geLhIELZQhJFYNIEqZEYybP2MYyjDiUcxAjsTis4WKNXoyL
		9Fo1YChNxHd34rrgJXjGPvZA06hsGadsBSxAmY1vAO3q8fiLvVYCE37whTbgFhTVGYY1qpEMvScj
		3+aubj/8EWXyHerv1rUH+uDNv/7NmztpSEN3yIAqULRhD3tYAxnGhgVTzACoBJDArSQRBjYMKwKd
		QLgGXeZjurQsQPYlQN5YMN6GI9wFFMjgAhLggAxkQAIOcIAFJGByU4skLGGBJi5CUYx81LzmoD4G
		JbawBTbwcqghEUlh54oNrRh4HacoEr1a9Ne+tloazzAGJcJA9V+VJjW6q6MYsdR1/mO3WDAvLuiy
		Z9wmFmCm2WnP8drxiaLawu3g7g8moREsoREmoTqSoe7GzQxAodyoq/CuzMp2o7pSavKixhc40Grm
		zWm2TO5yIRdeQd7EAAd+gAlQ4QgogFlSSRJWaQtCIHAigAgyKATQIAogi5/sIKkWQgFKIG8o4AMY
		TpaO4PQEQAHQJgEMYISUMAFK7tHAgimcKXKwLx9mDh8YzBPkADXWr2EsAVesaSa2Yfn4oa2ODhMS
		SyiI4l0EKxiW4RnKjxPUwte2ILUmRthshuvK6OtcLNmSB//Ibv/g6DL8L9qmhMcEMLWuDe4moZEm
		YRLOYwQJocgikKfSYQILrx/2/qF8UKoamAAHviO5OHBqnsNT/kdTGq8NnKAESwFT1sAJxsYgWvAA
		UqkJmmAMwqAHB0AiMqgHwAqydMBK6gwAbiCE8qYDUoACTq/hEiHkEq4Jm3DjBMC+HGCoykAkxqFx
		TCJHrAITypAftFAdVKEPwuAOTysM5IATimEbtELB2gEf8uEZikESvmIkutGvAosNe2Ebys8Y5IAL
		ROxXfq399HDrLsvr6C8w7E/sHoPZmq154iRYwEgRfUViUoMJzIMXhEDbHDBSrEEeyMEdeCPKpGwC
		ecM3lAEZsKANxEBqpoYDfQES3kCmYnHLZLE7OBA6oMMJcIAGJACplNCqDict/nowACIglrgKDQqn
		CuCmB27AWhbiA45RqpLRBF7gAQSECGQv4TqgB0LgBm5gWAJABrCxEHahcfQFR3AkGKppHZavHY6B
		FOhADs6gNNpCB8LAPoTBGbIhG9rh09rhGbBJXKiiJGaHnNxlGmJhF7ChrgCSC3qNIL3AIKsnNPYw
		IeevYzwm7AJx7CaDBUqgBFzgZOBkBvDroU6rLXigLSAlD/zgB/4AFczBHMQBGZTM3HjDt95nfNBh
		8HwTHbShGqzgBzgFPGByaqbGy5wACICgO6RDDPSnfzAla34SAiSgCQlgcLbgjtggvjRIKROOg3ig
		PFEgBGwvPzrgGEMgBBwg/hlvgC8CIAAI4G4WwvXQgA2GoAcUYD4T4BEiqNRiyCiugSQsh0eqqQwb
		bNTO4Ax85Y5+LQwowRNaQRoWTDC3IRREAh9Jgpz+CrDyahcwQRW2YteqQDX449ceCjQqKv6WALM4
		5g89M8YecsZcYDRJMzPepASYinpUs05MwwoIIQ8Y4QeEQBwECX7EYTfOjTfeB1CogRqgQRu0gRr8
		yBSs4FJ4EjqSczy2Iw2AIAc4xWlespI+JQZyoAHMxgAcCKh8z/eYUAFIIOQUAL9UQAU0YFmUKtEi
		4EDyJgI6oDPorAUeAQQyCFsswAEMAFum7yIaptQ2IRiu4RqIgVza0C1z/u0YWsET6KAOrUAAu0Ad
		PaEv/3LBCBMTgKiGCPSJhuIaAMsWkE/B1MEY6LDXUhQv9WlmroTrXlR4OKZjGvIza3QzcBSO2oRH
		W+ZHT0surGDy9CAPhCAZfKZnmLS6nHR8ygFQcmMVvkEZrFQ4V+oLwmNLkys8xEDufMAHcgA7nABM
		MaWSyjUGKqCBmpCqOiBK9IQNiuA/BiHk+hQENEAD3nMBQk4AFuBP+4xZKMAFAm2iimAQMigCUKA1
		/GP6fEkECqcMioRSx2Etp2GvQiHBnEEYzJHqRiz69tIT/FIatsIr/GsqJsxGkmic3sUWQkEdam4w
		6RA1nkA1cPUyddVF/mE0s+oPEGm0jW50NI11BZDVR38UT2rhD14hD3zgEcyhHuQBpVDyZ6I0Sn8h
		FVZBGcR2FaghW5UBFLCjuJZrO9qACZAsCv6ADECKO8CjFMc1BhqoANBGAjQAGCFL+irqSvxVWXxv
		hDju9jRO45rFA1ATEPDISm6wP1oDj86gPuhgCABtCLgAE5giJ2ikJOjqLzlVMtui6nhJDiiBFITB
		GDJUQ84FZtkSiZIEKByHFrKC5kDtGegQslLDCvAEaOdiV/OiV1mMaBnSaD3LRos1M461R5W1Tk4D
		DB5hEl6hDeau3MytHtKBWskHSmdDG5YsNn5hFaChfFihOPUAa7LG/gnETBzITH4gSQ+qU39KwVwr
		oEEIIAEkoAKEoAqQIMi4YAt0QAZ6YE4FJwgnIgAE4HDzowW3809bkFn+rAVaoAhs0JVkQAbAYAjO
		YBQogRLo4AUcYghuBRPGIXR4wpl6RPs67fnCoArOkaK24AzkwD44gROAQUN3YRPOIpmCjnbUiV4W
		CwvFER+2AhgWJg/x0MSClleHlv6C9Wg/KzBytE2Y1nmftzXnwhTA5t6SYQLrwRxqg0p5ZozFQRkm
		JTaWbCQD5RGEIH2xJqRqYczEJ2tBsaW6I7lE5X+cAAMI4PWeQAjqxw+CQAqkwIV4IAMSQDwBIABu
		AEGqcYEzKAUC/mcAoPIG5KbhFiDQHIAEZiCDDqAHWqC96KMPNqAP+sAQRmAEXoCEJeGE1elxegRI
		nsH8dq1h1LGX7IMSOEEStAmIXAcXemFxruIqYLkspiEawgFnN00cn8EmIgEJugCPljhXg1dofTVG
		i3ZGkzdlbpRLrLgEWOZ5lxUMTAHJqLe57gEDzUEbDkgZyoyUgAMVvg0VYCuUNIoNhCCSsCNT2kAI
		0OBP1u3KUIEG2gCSyCCh4dgJKsAA5hMBfABTnIAR/MCQkQADJICqwKuRH1kiAqdZMogCbuAAIgAQ
		9KgDTm8AQkABiICRQyABDoABNoASrMEYjOEOOGADXuAFZPoi/nDBXpSIwoZkGbxCFBphlS7CEiyB
		EmyaE0Lhl8/lKqaimk4BG6waG6KBKJRZwd4Bd98BHLABF0RBF/EIDLDOepp4eANqeIAVeQUxM5T2
		eXZ0nMk5ZrzgEVBB70jwC+yBncU2tuwZtqohgequ7pAsGZ5LGdz4C+QOU95AjmVLkSxQHJ6AEJgg
		EnOhDZxDDO63AEgABYTgFd7gFRkBCAoZA5TgCQbBBxeiBDqgzy6gBpbg0O5zDhAiWAKNCOTkkZGy
		BAoWEAwBlTeAAe7AE2z6pnX6BTaAhDGhGVDkr7pBrcZhcW7hEi5BChgNVyyBHW94SIbZQzJhF2Li
		FLRiwcDB/pt6QZkD0+ZsbivqMYDL+nezLq3j4EUV0njRiLOE9aDi2gVURpzxlZxDwwpQwRSSIxfW
		ABSoK4xHabCFo9uUA1Jw4N5GkDr0Lgp8IA/w2Dv+GRWQ1KRQ8srEAdysIRn+YA/GowIgYAImQAek
		gBG2tLSDAAOY4AkseKMjoKMjYAgP4wPuc5Mdl4DBMiyJgAhIgCsjFhD6wBM8wRr6gAM4wBhIQcpJ
		AcpbeQjKwBaO6EOXIkmGYhcywbo15BIwAVeAoRjg6hRgbXGCSLy5yUI/TQvPGxyaTzDXux3UYR0A
		Eh2tzv3qaGYQsr7XWpuPl5vfmmlJU66Zlq4F3E4KXO9q/uEVQGE33kcZ7DnCI1ES/+B+Kk/xIi/T
		84CxRyUPlEAZRnLw6uHvfOuMKcXEnWMN8BY7VWAMYDwWYuENuAMI+BcLWmaj6xQZO4BMTGABDJar
		LEBC2jMEOqADTCAEkIrhAqAH6IDJPeEOUPnJjUEVnkEVVIEDXsAQhmAMbkFfHIfCiEFJdMEKcQGI
		BqbMgYFE3moZisTldMEqcm29u5rmvBrUFmzBAFPP6QA1fDf6mPianfi+oditQRNOEt2/5zrA59v9
		QmMLTOEb9C0ZXqEWUGp8xCE5IGUS/wCSnGN/lJM8RpCxcaA7nMAHakEczCEdonQ2tPbKBGV7otYJ
		wkNe/rEzA8bgXRWBJ9OgAmgAC57gCcSzqyDiQFqQ4wIgETrAARIgg0MoIhTgYAWC4RQAECa02nf6
		2zlgVNUBHMCBFDbAENiAC3DBrNqSJGa3G9KdFqQaVjGhzGOuGOQdr1wuGKyi1RKMvW2u3wH/L53h
		GLhQ4Ae+4Fv04Dcz4Q197P5CaScjegAcYiIqovIpn2aYFb6BAXOhGkzKHcQhgeYnB9qA9HMBO8KD
		fyBBEbxUD/j5Bx4vB4TAw80BGmreFbShzMxhFVaBFQABDOAuDTpF5xGA5/VAEZD/598g6Gmgxo2A
		BDbaWFAABSyg6gk2cAaBCOxglGUAhA6EARKgPZUq/gTsg8n7oOtfoA/uQBikQeyF4Q5ewBTCQA3D
		wlLZMF/0hYc4ByVwAVdOwR4BAhcuW8F0BTvYy5atTKG2qXv3Tp26dhSzSVMnLZszVaRIcaITpouV
		kVG8mDyJMmWXlWDsDEoUJ86SIzNqznCB04WJnSY+fFgRh96/OR8uULiA9ILPnSxwllhhwsUKFzNu
		2EGzMuvKkyKtpDS5ZcuZLWFYfYOFTByoavLmzStXTtyjP3qcOMHx5YsTMW/clPIFCZKbN2LqOvmC
		I8cPH1EeKSNHjZorV6xMoTJlChAaNI+8WBESxIkeHBUaIJCAJI0iRbEUvXnzBQIGJliYKDEAIHeE
		/iIoWoRgsGBAgAAA5tjp0UIGDx0oQERQsEDBHOK5A1ig08eTp093OLz4fkfVM3DgtlHK7onSolu7
		bBEjdlDXNH3wuk2bZrAX/Ga2BGL6n9BB98l3kEKbhMKJMRRJI01F0ggjTHpyTChHGGFs4dlIXXzF
		oRdZgYGGHYnAFMcRNNWUk0489fRTUEMVdVRSS0VVggtPneBCClTdQARWWm1lUlcpedWFWGc8wow5
		sHSiVjLyyONOPfXcU0sbpZRiFxl6rdEXJIAJ5kZhdeWVgw9C1JJMNdUwo80vhgCCCiqPdIYFFlGM
		xIQPbXyRQ2kIIIBBGm+wpogba/wBqBI00MCE/gYACABAACQU0YIFDBwwQKQAENEDcjzwYEVzDkSw
		wALD5ZYAGgnIQYchn7zaHQMvbCDeM88UUwwlrwpjySKb2KJfMLTowg489cmniy7w6dJMM71csskm
		vdASzH3WDsifQJIUs047z1DUTjbPcEKJHFFsyBVX6Hb41VZoDNIJiSbahFNUK7IIlFBEGZWUUh/w
		VEJTUum4Y48/AukhhyOZBAYbplBTDjK/kANKLeLUQ4455NhTix6leFMYGWSIsYYbbgQWmKFiiCEa
		mYtN8kgyMqtZzVVz1qIEE6AoEUXOQvygmJ8IQNDGoLHEokceTCCgAhM0VMAEGAvkBgABRKCg/oED
		CmSa2xycJudFETo4VyqkxDFAR6V0tPoqdxwwAPcdxghzxxlsDLGdMMVI8l8mu7S3yzTwnNONfOxM
		w04wzWSyUC8JERSMffd1Q3lBttyCCybATDQRPt5iw4klF26VFbume8jSu/HGMce8KOqkIk8+5fsi
		vzL+u1PAK+xOcE0GH5wuwyaNtHBLpmgTFzPMJDMJKPfMk44yyfwhBiTeEEbyGiWfnPIaK9sl5l2J
		/fDHH0zoXEstNxNCyB+g6Hy+ED78UAEEEPxJ9KCK6BEEEhYMYIVF0UAIOigC1wCgABJIQAIGOOAg
		ehACEMigCEUAAQlIRTUAhKAPfRjCdfpg/og7cKc7pTrAC6zxtgMsoAMhNIYxTnGKUGDiFtJyXDRu
		OA596LA+mehhD5t1kG5co1iVE5ZCMnGLSzRkIu14RzuwsQxgiC4sp6tikDbUkpfApHUnyom9VjQ7
		F+0rRkiZUVSkMjCc+A4NCVNJVrbQBTBgiHhP2IwdlFEOeZBDedXIxRfYEj1QfKEUXjLU9rbXPe/V
		ZWWMbGReHpmDikVhEnv6Qi4mMYk/TEJ+PqjfnwyAAOqZrA0YcMABBIACAQpBCUYwAnUAQAESTMAA
		BKDaA0PQAgoWgQgkUADVBMCAPpBCFXRIwDBAeIdkvq2ELzCEAJ4JgAUYog/G2MYzVHEK/kksQhKn
		wAY2thEObERDh/roBi0Y10NbALEbxjJWNwp0uVvQcBOYOIU0IIIPcCyjF1IMCcKs2CF3vYtEXHwd
		7O4VRn3BqF8zYoHAcpQCHfmuCF4ICxzVpRU4dsUKReiBKZRRjyeVAx3lSIYZyGAxckyPDGvwEiTe
		cEiTgUmReyHZyvSwMu3p9HuanIQPyLAHMrShfET9A/3uhwBQ0uALYiADDRwATSMs6gdBmB8NIEAd
		ASggAgSoZaSOg0sdjE0Br0zAECgxzGdQ4gCUMIQhXsCBuAJnAQJ4wAEBcIEQfkId+VCHMDghCU5Y
		k4ngCMc44KEPYmQiIYyzRbLug1h4/kyDP73YxCUEgotLYIKbD3EiNppxC0lUSAleAajp3GWH1bHO
		dV6M3U4SWjsy+ospD01RTY5gBzCAASUbOhjpwmYHQLCiHv6ghzhMQY64CPIPteBYG0qGslLE1GSG
		LMxeXuE9RnLJZNp7zRq+8IdctGEPhnJCHtqQAxyct0/36yoBsPCHHLQBAl4FgFRpALQcIOYPEsjq
		AAawVQWA4DgtaIFYURCB52zNAXTghK3UKoC2vhWucCsVAO4KADb04Q7CaAc+8CENVbjwGROBSDvC
		EY1zGCsYClHILh4rOHgEYxc01Ox/FrFZSXD2HfhQxzLGgQtO9OEMWCitaduFOi+E/ki1rauBQb8o
		uxYp1HZlxJ0JmjKVqeRkBrjVLW9Rt5IonOtDwTWENqRUDVR0AhrzqIc4qsTcSeiBul6SrslIRt3s
		6gGnr7iSdLcnUzARpg250MMeBGMYu+QFBz6AgAQIMAABSAALQmDCBKgWACOc7wc4GJkY0mA+BFDn
		vxS4ARooKAMU6MAKzAGBA6LjgD6IRxrP8ESE3TqCF1T4ARmk2gaOKbdWOKMdDJIIuCASEWwQAx7s
		0EWLbfFi+UzjILSgsWYXsU0dW4ITnOAWRNTRiygKeQhFXteRMWoS1SECEXMoEb3qBWV8iXGht9uJ
		llOEkxroO7e63W1FwdwVrYCh/geAcEUe0YEOctTDLfOQxz0omYa9UPcNV+rLGnCq0+wy8mO+ICR1
		T/YlwVzcCWv40sVxmlMxHLUAmTKABKxgBF9WR9NMoIsYSrFnPbShAqLOjQBKfRwZFHjVOqiUAxKg
		AAdwQjytaEUfAMAKQ9jgAXB7QHB6DYAEUMIY3MZVrRpk4iaaGMXdaLbihJWsc6j9IMFgRBIXUQZL
		SMISlpADJThBCmEc4xnbAAauKEGHIWjo3G5E15LXXaIT3aRe8H6tlGPLUNzdG98r0DcR+r1bOQKc
		JOgaOCCQh/B70AMZ9NjHk6bHl9cI+jXc3bN2Na49X3jDG6V4DcVnT8iZvgYw/nfOXsnWQBoIsLxq
		IHDOAQMggfPRZQ2v0AOXgH/V+nagBwRWtVgrBTcFbCA8z2iFMBgAAEAYYhVHuIDVsZ71bXNbEsBY
		Bgy9uY0mUgTZ+MhHNIhxH7YLi1pq549CalwGi0B3dMdtlHAHd8cJwGAMpEAJFxIkhMdbQDJQiLBa
		R+Bkiwc7rgVbYxR59oZvOLE7llcEaIB5GFI6J1ESJVEEgKAMyKMN5EAPV4AKapIMhMBStucNvhAm
		rOc9orFI2cMX2zN73uA9HzOE3iAYfTEYHAcJdpZnMVAaBVBLA0ABzwEpVJN8P+MEZPAKr8A9wFcB
		j3aFAbBVITBBOiB0IbAB/gyQABuwdM9wDJ5gKgKwAHYVaVjHAJQwDAQoCU2ACaEQCvsUbg6hDviA
		T/lAdpJjENSmTv93C/+XWdhWBuwHDB+xNgRoDJ7QB2HgBbtlboRXOiASLxSYeO+WgWD0eBxYbyYw
		eTmxAicggiTYbwAnPBtFQYCwCr9gcG5WC5nUBiKTehwXJnyhMomWUxknU7hnhDmIMmBiMm9whLlH
		XTGQA6ZRSwRQAhFwShkkAfKTAzHAhbTXhFjiSQbwHAikAFuVS2kINwzghnAoDBxwheiXGwfQB5SA
		j4BHB5LAHmynC7sQbuEADg9Rf9tADNI2INNWIJkQLZtwC0Y0T4WwCKIA/gxzF0dnwAVhsHWaKBKe
		CIFccS6dmFqJQIqug4FnhIq0o4pVxhMfCIKW1wMkSIufuCHFQ3AFRw7kYApIkAd7sQZ7QIyzp4OD
		QV1igBh5YV3go1N7sAe54JTS+HHb8xpXMoS+4AvdJQbViAAFEAAFQCnbSDUgkCff+AVceCVduHP3
		Y46ZQgREAAIh0AMyIANDMAS65o5LZwx9AH4A8B0coEJw8x2GwAzWoB2FyW2hgAvj8B7EACzEcEMC
		2Q75oGzJ4o/4oTi3UAiRoJm3wB+NNU+iIAqi0xVVIAd55wl00JH+9pEeci4gAi8kGRMzYVCnGGUq
		SW8suRMpcm+VVwNH/kAEuaUVHIIun8gGrKAM1fAIQtAGYpBnLTWEKcNdX/ADnNZpepAG12lTX2AG
		hGAPHANUw7hTQJhTf2GVe/B71VgAXIkAUVAFUJVBIKAEPpBeeMEydpEDfWIaawkARfAEvdECdFmX
		dumG4VAMGwApAhAP67AO8WANDUqYbdM2TXcMIlYM3gRF3nRDjokN+ZAP2xAKtkAtZzcg/dEISCAF
		kSBPC9EMRrQJotAIVcAFW2AFdiIHquAMwoCaRYIhq+khVRBHqpMIc9BuS7AETpYiKOl4qXibs5Wb
		ruiK+uabwHmCSSacLAEIgMAGUaCczsddb+AlQtlx2iNU8vMDlSQa/mIQVDjgPvYQD/FQDX9AJj55
		cd9jFzXlpR3nF6/QBg0ghQCAAHmCAgowj/DpjelVp3eBnwhAAHQFACRgBP2pAjIQBnRJYcG0DcWA
		G4+SoAvaoBD6Kk3nDNmQDeGSDXzFoaeKiNEwiOoADpM5OZITDLfgomPgKykKOYqzCYvwol1wBl5g
		J3QgbKRABzxQUTu6ml3go0WQWvEipDJRpBhIm45nm1TGpGcEgk/qZL8JBsH5gOyyFT3ABmAQBXnC
		VIDmJVY5e3qQF20gBMlQC6DwPplUlmSAA0ywJuSADtbAClHwB2YSBIZ6qDhQpxiXe97wClqZKQgA
		BYSABVwVlkpA/qY0ALBOQI1+wnKQwp9YAAFKUAVVwANDIFcHQAe58kubmqDCAKHCJqpi92GGiA/8
		ALP88GHqAEWOgw3hBB/3MUT30QyX0AhjMAZlcAm9wB+UUzm24LM+2qtW0AV9EKx0ABb/BIorsWQj
		IqRHIJvQiqTSOm/Uaka6ia0z8JtsNKWfeDpWALFwimfcY5U4lwfTSQiPYA/VMLejUA3JAAqLshYI
		p4uuAAhewDMdS6b3OZ3TmQMRBz5uIHsHy3O1FAAQQAig8AQEQB0g8BlCsCj6VafU2ADtRR1oIFUV
		YCZCUAUiELIvMAxsULIQoqDOAKqhOqr0F7Mu+2FhR7O9YBCO/vkeQsQOhxOri9CxVVAGmBAg56Cz
		LJa0UQBHTNsHwrAOpwkWxvqR7vKaQdo6RVoD+La18jZlsvW1TvqkYnsV24owvXVaXUCsI5EzP8BU
		SogySSMEmIsFj3APcFEOrjAx4sAKrKANCOcKb8KfT8C0W8ADVSA/QUBVPjA/QFOnzHkletAnWzkc
		CGAEtYAKEUAdIYAGSlABFSCxhhoDUNi5ffooqIAF+DWdZqICG5BCITAKN0A1BxAPEOIM65ANTbey
		yMZjLwuzngMuFOEMxyAuynYQu1t2vdsNsjoGwbsIuMAfzWC8kxMMuPCiYxYFZ9C8zwu1TGu257YV
		y2q1TaZv/trbeNwLeUnhAVbmklKhb72prVTqGV0cgeuCtlqYetzlBEKABEpQJ2jADOggD/XwglLS
		cPPgDverGU8gwFxcBUiwwIuhwEBjpk7gF3VBP1vJlQgEAk9AAlcYAWhgBRDgwfeJAyHMXorqVQpQ
		C0zwjeMjBDywhpdyAIbgAiVrDZ8Auysbu/gksx/WyxVhEa1ACq1Aa+K0mPZBRM2wCUhQBVbAnr7i
		YpIzDe+EC6KwxFywEmHQvHEoB3HMowkTR8tKgUKKvdAarWa8krMFFU26m20svv5mrFLbLh+iW2g7
		P6LhXSqHBD2DBU9gB6zgCtRQD+ZgDgvnFocsDspgCGBA/jxh5o3jo8DzU0l64ZMsQz8SQMIAYAAk
		cANcIwCo8ASi7MH5lagIsDW5EQK1QAM4gBeJ4QNVYCnBcQCAQAEZ5KAqO6o/jE+1W7tOFC7S4Ayf
		0BF7tw3GTAzIrA/NgAtLTBJI0AgOuQmZEDlSrMRLDKNywGHHQApysFs8IMfntmSawG5cpG/mvL0b
		uKRLsc7gy8ZtPLbzfDorAUezqKX/6gRp4Hxf8NJ3YgVPsIKrsArl4A5RUg/pYNjkoA1RF65vpKXU
		CdFl+kg5h3EqV0qlckAK0AFTkxs3UARGAAEN0MGhbRqK6ksCEACPkLd5oSU48AMYYAFINwAL8AKa
		nRsN/uoKuDyqH0ZsDfLDvS2qzgDcKOtCp7BP00Y57KAPQAa8fB0FtBoJuLAJA1EQuvBOmFkGQFsF
		2px3Wk0HYxESPGp48LJuV2uB2UvGGqikXvsva32tL9nGuMVGKRGS3gpmmFfAoHG49ikEYrYwI/h5
		gt1mA50O5aANqwAIZ4DgXnAuZ2DAQMPSiiHRZRk+EWeUrf1qFkY1VHiFAuCWEmA/9tO5f0IAW2Pa
		GpCce9KFryCdjmYAWyPbtC0ADSpCw/ay9bcREHIMwO0MGSGq6hDEwtARpOBCxYALfzPNxMAO58AL
		i5CRCG4hXECrooAJApEJw6IL57QJEimAloBWtEYK/kN2Bg54rJ2IBp0wiqtVE+Z9pGWM1urNik2K
		Ru4NpXZQBF52RV/NMFtAvloBsfOTXtK533fiBeHqBcPlDtQAPYbtDujwC4CwrQguErzKBT/j4Kzt
		4OVqXee1J+ylNRRwV/9FNbEEAgv0J6U+4sIRAAhgBXmC4l3IJ/m5NS9wBwyw4daQTJ5wDN3CY36l
		ifd4B9sN3Ap6DMcA5EIuDMZQDMDAHs2gmPAwDo2QkWGwNmtTIXQ3kdACbZ0Z3ZkTWMaw49LQCulB
		BxUC3iJp5uOdteZ8zm3uvesN5+383j2SeXd+OnQtZiuhBPEpn3lhJvluBWwA8FaACqDnDtAzUv9r
		/gdoC/C+agXiKgSkrBdvm15AaJ0RLZ+nHAEXgGE+NwAdEAIhcHQJsJWQxjUFYASUxr5c+AVtQBqj
		DR2G8OUjMDUxnkwi9Ak57QxfLgcITgeU4Alzo+OtMOw0HMTIXgycsAzLcEPLMIA9j4AFSAm9sgiX
		IE9/oxD+EVjCwOM3qokggWSF10ZJBqTjnO5eBOcp2bXt/ubWCu9lPbb+xq0BhRJczJ5kWkmMxgSC
		3jBD0AVogFzUAMiHTA1vkiELTxLxKV8Ce9dpYKiMVBfmgwRC8Adt8DSOFgEpsPHRFNsh0AEd8ByU
		SxzDkXxjiRd6oCWnXIZ0IOTW8ALARJgcJELC/pbzgGc3bHAGozAKW5eJ2vEJOO66wqAKqnAMtFbU
		23AK+fjzLqT8LgRY2oQJ0GJZNhZYnEDMFnGjmXgHXC2cYDbHhifOJdlFXnRvCJXe7e7ua0wVsOjG
		uQVweF6TXsEGcGTAocFITvADq2RkHqLndmAKygMX/wsQgNA8QQPGixcrUaJUEeLjR44veiQ6oUhR
		op4vNLBgYULDI40KDSSEKBJBAACUAAZ48EBhwQAFA1AGoIkAAhMfOXPgINMTRwUJBgYcYOCgjzFj
		njYIeGDoxYIFLz5N9SRHzhmsbB6hQjVqmCU0dlh5IkXKkzC0rZxJy5ZNnTppzpy1aiXs2TG8/seE
		qVJlrBgnTpIsDbY0ZkwYOpTOzqWLVtgnOmwMWqF80EsXzFEse1HY2QuaQZ00IYoTZ86RIzNSzHDh
		ggULE61dmEhR28SHDyvi0Ps358MFCheEX8D9wcRx2clbz6hRY8YRInYKYqa+2fplhAe7REEi5E8b
		PWLWrBHTxgcSyumjdDmIxpQpVvEBSUdzkLISJd0bPnQixr+Yif4D0IeNoBBEkI8qgEACCVAgQYEA
		UFIgAgUqHGCAk1AaIAIUOMpJpy/IwCEHGiAogKYIiWLggAVSSomBO2Lsg44wtrCxi1pq4aoWUKB4
		gg066JCjD1LQkouttqSJy5l1WlHlGSjx/uJrSlUA4+QrS8IIQw467iDlGLnClOuTPs6wMT3LqNPM
		C4M6W++zRDRJJJE5TkNNtRRKaI2FFWSjzTbcdOPNN+CGIw634xJVbrnmZpghuoK0w+w6SjlToqE2
		XnnFvzXcWOMLH4RQIj3K1gQDjbDsAGTVVb3AjwkhGvLhjz8e+oI8Af97pRQnfFACix0OFBakCjBo
		EAUQQJAAAWaXPTEAAhQgSQcsaPAhh1AbyoGiHCpQUIIJJiDhhRda0GGQRI4Y4QEGOLjDExmF1DIM
		LiYBpRZYqKACCivOkCOMM4j8RC0lk1xSrWP4sksvKhsGjBIh6ejDy7WUFNMZT84YYovs/jbL7KA2
		PUNVtDnrvBNPPV3rs7U/U7gtt916+y244YpLFLlFmTvB0eikS5O9Sg/aAowuLvWBp13Je8NTPX4Q
		1QqEKOvCRoM+Cws+Zph5BCeHfvC6a4gE7EnXV3pFAlgqHHHkQDNwiIFYbz+S+yMmYLX2Bxx4ykGI
		7rZ1IoYcAv+IBzkKk4KLPqjyxJOBp7qjD8hntEQKe2GpRAsothAy4MWYLFjJg1tJWBi8nJwSzIql
		eUYYUiiZcWJS1morm3XWwljILaibmr3tgNZOofbsIHkO0+6szbU9V56tNpcDjZlQmoWz+eZFXVDt
		hNVugLS+y3yv9EaGfrjVDfLXWHoN/j2CEKKKLsCoeurceaAMDVSqqYYcrR3aKe/AvQ6coi/g4AsD
		BOAXnKA+LEBhB/qigiDMQIYvtMFrQABCGwY4ojZAZIARCQ+n9rAHUHWnDf5JgxN60gZYIUEKQJBI
		GkRRDDDFpS3OIEWQ+kAJSlgiEn6IRC0cUYksQIELYahCvzzBJGfMLhugkwvCSicXvRhDGLVrRTba
		cUVpCMMTr1uMEqVxRWcYQ17VqZpCugC137GnCGjoRCdKZjJHsQZ5KvMT814mKJkVqmaIol71GsUz
		SL0vaNrJXfjGR75SlOIN6MsD36LAgy3wgAcLqUIV8DOqrdjPFFHIw042OKIceE2U/vsjYEXS0Mhf
		KTBteDBDK81gQCe8QUB6cMIXxOMGSPhCl4kkDwTPI4QR6qGE4vnC+sYgBUYw4g2lYIQkhKHEbNCw
		cIThRS54WAsoaOEQUKDXqOgwxSRa8YpJChNdyglFtByDLu14RzujqUXI3WGKSmyFktZhDXnljj1V
		S4j3JuWFIgjPjXSCo6Nak7LZJLRld3zezAw1PUVVrzaNgg4RUNW9QXZvIUIIQgnXkMhEQoI8TnDa
		+qJwSVl9iAmgAMVGOJIHCxIQlD/IQx78B8uKUARw54mCFaBwBUHgQaisNEMsF7kHpf1nabncpR7a
		kIcPdecHThBmGiQSBCRwwRLD/ijG5NLgB1EYI3XScFJXGzGJSIhCFH6QwiKEcKAnYMULZzji7K44
		TmjOBYnRpItewJSNdrazHVncYh+6ODu1yEWM/9Jn+y6zHn+yJyyh6QQiTHay6rEsNnZ03qAcukfj
		9DFnjnIOaiClnYxmJj8+yEN/xuOGUkDCU2L4Aray9SFR0upDNCAEIfQ3QFpyKwdtyCBEOvif4OLA
		B1XgQk8ViAdZRFcWrxTPB8kgBln65w1vYGophIlVSzJhIT5oQxqA4Af0WgKHlEDKMBqBXkYUQhLG
		eAaS1lGM9+YBrLiwKiPS8AVCYIFNYJDDJ8JpRcHetR0zFOeCozmXTwjDGVcM/uyCj7FFSlhDrLNb
		kl4gpqVJObZ7vqMOGIpAWTdeNo6L4lNCXcBZmHlWj9LjY0RH64LmLKGi3PPeddhTqu601rXj6VT5
		ApgDWrXhO6L8wYdopdsg/CCmtWxDTvNmy9eOxz+1XG5zfboDPNSBD3yQBR6u25MHAig85ltaImkJ
		3iGcsQsMqal+I9GIYpBFGMbIoSXem4avhnXC6zDGGPxwSj8kE9C5YIQf/qCEJzzBCmE4ouzYWWG8
		tsXBs2OMMNRy6XeAEZ7sPQZb4hJFT1DiKltQCNTeV50Rnyo0ciIoZlncp9i8GFAxzmP0DhVaGyvH
		oDk2baR6bB3fcYe1/cmV/njGA0EMFpemNQ3lD4Lwhw9FGSIAzKkTrnzL8pFHD38Q1asMpAUxj3m6
		aGYlLMlQ5EU6NVRIWI/7tsCQP9TUD40AhhSLdGFVF64RefhCHoyxDmFwoglAMC969VAKXgADGLzA
		hCW6UARJc4G9c/kiqBPcFnXYdYZ0IcWn2XnXdRyjhoop9am1uEU6mOmMlQGZ7qZmmZGNBhF0OlkN
		qtfiXMMYj9B7aI1xduPm1EDHFjXIsT0GUM5oy7UAyul/Iui1KE85p2mwdk607TeLiIek23K2p8Sd
		Bp4qgQk7WKA2D5EFOMzigWaoQx3aHaJOkecLTS43zYsmBPEVvBHDIN1d/pwBz8RQYuBtaIQlJNGE
		QgCarWW4RFj3XIy/yAHjVujCKCiBl457PNRLLJgVl+gMvHh6wgpuB1xUMSNPgEkdh18c5OTAMVKh
		sbGYIdo+Z71zO6XGoC4oAQtkA/TWCL2hM/71zXI92j4lHTo+w071PQYGyVgBUwIUoASDEIQqV+Sp
		ecj3lY8rBiec8vv+y0EMYkBVZ4vhfx0Ud/rzQG+1B0tfWshCHbIwi1lgJaGyu7bBO08hqb4jFYRQ
		AvLiID+whINTB4QxC0poHTlAgiDwOgpqtEiQOE6oHYxZrzPAOCWIgkeowGOoL3H6OLJSklZ4Cygq
		CymSC3Fyi5SrIYnx/gR/S7UgkYMhmAwFBAN9GjGgEShEsKzgWzHXML4lxDUXWAHlkzFfAzbqeT7Z
		GD7p65lI4Rgi1A4hZDWj+ZBsiZVrwQGLwIi8SUMDugiKMK+HCBwLgj/yGKmKEBAccJoqCIMzgoKf
		ogL+ywJAjDv/y4KhKkBmkzdRWRP7gJpL+Q4neAUXKoZ1gIsmApM94wQu2A8zdAJGuARg2IZnMD1h
		oARUeAI1UINIow5KYB1hKJiTGywmUacWlAa9WBzFIAu1WKKUS4qY2wKs+MVfpJoRkxTfaTouYA87
		oCyCshPnkCPiew0mfI0SiI2b6axeKzrno8bRYo6kew4tJMLqYA8b/skd/IgVWGGCctQWnMKICxqu
		KpOI/xAuOHzHXKEqWrI6bKG33LECI/ipK6ACQHw7OIADPni7QsygErK/UKmCehPC32kIIWOESPjA
		fAgdJ+EzOchEHwiCPJACTCiGbVCHk8uGYyDFf7wCI3iC7qGDxTksK6JFtPgS1VM5s5gRifGS1NMi
		iLk99+lJn3Qfj4E1nHusLgiLNkqxJBy+Z3yN5ECOauQ1otujbHQxYePGLDwtYpwUjhnH7VACS0IC
		ryxHh9jE4HIC4gocHCihNdMy9OsftKyIsuSg8PC2vdHHM8ICI1CDK3AEQMyCMRuzt9OCtREEQhCl
		U6IVvmHILpAk/h54rCCjpTRgBIqcC8fgi7L4MK2yBMDIh3zAhwRzBmtAhZO8ApXkgS7gEhwiizC5
		QbNYHFIYGNa5A4gJEokxLBnpg38xk5/8SS7MqPqYFNBoozc6GWdcQqb0E2pMFGuMShqbSit8QtlI
		OumbA4sCR92xtxvZDjc5KXXsj7JMv+HyGz14LbNrGiYjpQvCqYrAFlHhnZ6ygif4R1l4u78sSFmo
		BEdooB2wFicjt1hBAobUDEnijkn4Az2AL07IhybZM1LgC9FBi1TDIaSYMHzwTMGShtDcSypASd3D
		CtQ8i9Qjhce5RbIwC9mckTMAGKuwCi25Eeu0OaejFOBsI50r/iifSw5oZELNmg3lhMrPak7no8qc
		kc4aQI05sIOshDWi0ScbMU3VUsfjYsNaWsM1Ix9P2bsmA5vA2dKdsLImK0H7MKP4pIJDOIT6LNP7
		1AJ92U8aSKma+r7/LEFKekz0SgNJyIe+Ih1ZPDXFMYZSE713yIYMzU+UVEnLEELEYC9/E1GJoYR3
		IQWksMVeHEcuTIg3+Sfrw6iMQq3grKwjtBMllI3iO84dfcqh+9FDycajG1LpXIIliAMicB81Ecru
		GZqhEULMMBrxOb94zKm1JDJQEcOuOc8urSX2VALL6CceGNNDELNZeLsyLdPLoQK2q5sPqamvgqps
		0Q8hKNAD/j20OyUrgqnBuJiKTygSVfjTwHInT3gEPyRUSUMIlQQDf0mMpCiLE30XPWMdW6wRIIRP
		9QgxZNtU7UAjo3Qj0nhVHVNKUYXGpkzO41hOVDW655QN5bHKpHNVizK23vEdNAEZfgrDnTguIqOt
		ABIgKsUIvkupYXUI4jLDATpWNkEDzqsRL7gCbfK/Mg1I+jwELWA7j8gJ/pgI8hNWHyjQL4iESEgD
		YFgHvAq1C22F1tRBP/2idQ21diXTQ9jQlNQBmvPFDy0LEyWLTwATuiA53Lw9L9ABSVMPzugpziiV
		jx0k4GSjNjrCOHBV4WNY42RCp3Q+iWU+iq1Y6GwNIs2x/iU40ouC0X8F2WTdKG0RIGYbj3YcpcCp
		qTEkw2G9KYsgqVDRjFOp2S2IT3QDRG3qS78EwEM4EN6qFbADoAySsq/JtzZQWkZo2nG62sHSydQk
		Haf1OEF11+iqBFhISfu4jC3YksTQQbSQItIJE9Ahq8cJkjOQjKpx0hgl2OroVDcqDVddglA9Pod1
		sWwM3CmkwlVVDiY8XKWrKOnoPUy1VN1JE4WoAiQQWrQMEQiSIKPNiVjJj/wgw4cYJYrwj4LjqZkV
		3fjsvyxQUy14YEDkg2clREJQsgwioHhkx+F6iFnJgToVhZDUtI9jHSEZksU5hnVYQXeyhkdwhEO4
		z+KF/ppJ+ULlrUA9xQvZgSZpMNHp3Rwz6U2ClVHMCKijLJm8BV++3ZPxzbXy9VHBRV/CbY0VWJkS
		iCNHMVLqtIOmgzWPTQhk486U8hri4jt0vCT8QAKwVIh0dFniArQCpi2oordk7QI9fAIy5YMs2FA/
		zAL6nAVZIMRX2qANOsPkOkspyzdAeyG4kIZJDDlaTLXbO4ObLNtwujRBfYJKKMhK4FAzah972xLD
		0tMjQZIGezDU2zOYW7VMzd5KUaNB0ARYRsI5cNUkVuLjZGLAdeLzncrqmeIptp4ZqOI4OoLEHYT3
		nV+uzIxOHsdJepVY0dxyg9uocZPHCuBricM6FLc4/lZEjDKCKdhZKtDLKeC/vzwEVkLZ9Bxke3SC
		HLApJfOa93OCDkw5u1gdVdBJrPDFejWsL7Had8DQJ/jm++TkN6ka5GXJ5x1XTVMwL6I9FOUYgWXl
		p5sU4dG5WqPl4sTRJdYsU10+Q0nVIM0sXza+YLZipTMN6rvOZNadcSSaBTypr+wOevNkoDyISbJp
		7tSfTcxm9DEPOf4ZL/BmcP7HKZiCCOYDApRLdrwyKk0//2mDXPiDimCEjzQGK3mYGWGDHnAfrNAS
		OeCEL+G0YVCDKRizKSBobu6nMAjlJkIS1mO9bFALndwcrvxCYRzYNGkPUxCNTw2+ZsysHGUZ12ji
		/lN9YvRdgRxlgZQpgZTpE+YgLaUr5ovajNwJmi1OI2WGLMyguZ7sSrXD3/YDNCAguPEEEJ/m5psb
		UyBq4CnYvz/k4wdiy1pSQ1h6syijqohIP7ZahEYYAyBAsjy8CjZggyLwgi1ATbBO13ByhlFQA0fg
		vw1Vyeq4VYOApC25A8/pON0NNQdzuXOFuSGQuaCsvs5WE7vl69LI270FbBwlXxOARoaSwuiBqONA
		bOUYVfU1aVelTlThnrwOGomu1bh1NaJZiM8uwwGKAdEOArKjrSb7aRnmmDF1uywoaj/kP2h9oNlC
		P7ocrgCKCDEAgiAAAu8MLslrhEjQAwhaH1/M/r65gh1VSDl1gqJRgAW+3FrSHEYhlFXM8EUiiSEK
		wzTuPr2L+YRUw83K/hnemRpc1R2BGqjLWu/MWhRc7mgpBK3D1tGDItU90W8j3Vge450gbmV9es9q
		DmBZcUdYMq8oKyEcMA+TqoxJeQIj+McyxWMtGOc/xOMseKBF4nDwhMO8EQ/zGiaMmEsnAIJFAAY/
		0IMcAFAzWtIumaK3sJgkOoYa58s8Jk0ZBt3e5DwbYcl+Xui7aui5mHG5qD0aSfLukWGWZhM2Ucbh
		FL4pz6wq71E86oQZ+OjiyHL15XLXsOLneI4jmINB6O9hHHMhztRyhBXc8vCti7IBnrdW47wf/pvw
		O+/L1zZIDZelNgSCpx6gNdiDsSsg8UA/Oy2GRSgh8OqMIVrFzvRMLGILTHfuMuVaV2fyZBUaOVAM
		CbOrUuewSkwnvdizD6vsj8nKoUEVVCjiWttb5al1P+FoXI+Zb5gDEyg6irVvjdbyORJ21DCNY/9N
		TFV2j4Fox8ppMXxquKQlmxJx9YF0Of+xOifnMfNL1PVLAiQDN/hzdh6lmBoPkoIp4qKIkQICSWT0
		RE/MEkSMg6tQC12wBXMGSjACFz4ER+DQWOOnyhDCfq80gMeruBCdVoiwvGiFdSA0VbPZjpGUY1x4
		FJt1JUQoiXdvK/+Hi894Ghtcjhdfjydp/pOObMlOdpM/eZAhx/2oFa/ppBxIyOMy1gw0KaDp8TMy
		gj0GTDPF451FalYig6Vhmp+nqZjyjxz4vjoDDwBJAyk4OGPAhENTH0uKgq9vhXao0MDCBzAaBjvm
		45/ll62Pmq81YRpsi3ywZItRp3O9YbJCYWNA8pmruS7ggmM0sSeHctSQ8rp/WB69+7zH8mzse1tW
		X+sBZtL6XmNf3ML3MTnDVQaM3Xn8H3t0NvQBFUcKMd3xqee+8zo4hIHk85vvc4Ags8YNQTFf2vzw
		8aPNl4ZicvyIGNGJHjFO/DQpJsxYsWKNgiRUwoWOJ2HOsrVr9y4bPn7v2jmj9ITKoUNa/nYYeeKl
		C08wYLxYCWrFC5gwdO6QOomyHT587146i3pMGKlPn6Y6Uyet1VRKcrZ0CeqFKE+eRO106qRJU6I5
		bo8cmSHXBd0SdO/izXvXBF++LEx8+LAiDr1/3+aYuKA4cOC+fVewyMtisuS7cmfUyFxjyZI5g9Cg
		GSt6NOnSpH8G7bKFh5AfX3D8yIGjIQ4ntvVUXDPQ4A8hSqJ0AbNluFkrWK5Q0cInSxY+cOAsb86H
		Tx08ZsQQdEPmYEKFsXHgyCHeyZc0FcWkKcPJmCpVG4HlweGjSpg+JaNKS8nU6UprtahkYRNOQ5W1
		BWqpgXGGHH2Qss462UDI1DtNtbOO/jRSCWPVMVGpk81WwnhCRxhhjVbWWGgMktZabc0BV1wz4GWX
		XjPuRRdfJawQ2GCFHZbYYow5xhdkklFGowszsKAZZ0sc4RlopkEZpYFRWKFaFELk8FpEtdnW5Xli
		DLTGFz74NtRww432hBFXTMEcc8/BcYgs08FRnRlfgLldG3/40KcPQYAkXhpOiFGobhdZckx7nKjC
		iSh6kCGEUZSUtKE0EfL3kjH/MafFFUYQ2AVRW4zF0xZnnMGgMOs408qlKDWFT0qtRMXVMRtG1Q6E
		XIUYBpVD7SSqF6ChlRYiiLjV4osw3iWjkXqZYKMJOOpImGGIKXYBYx8EacKQeE0W/lmMeGGm2WZw
		JTvITlGyW6pPqW1x5Rdk4ABoGzjE0CWhhYK5xkM+IKFEqMOJ9dMTV1yhRYBZPMfHLLM4V6d1bVDc
		nRBMMCGExlJwHEQO/YKJ3iKceEIKKaq0QookfoyJxEieGLNhhE/R3I4xjwCoBRVX6GSicMF2EYYc
		RzmzjjDttdIKU7pCmA2tUdWatDNMO/NJr1FEUaqwxKaVFovKXsasCys4+yxe0bpwY46CWdtjttt2
		++1d4eZVtrkzxHXEEnHwra6wpJnIbhdsgBEUcEr4MK8TgMqWL278WgSmE70JLJRqXTxhpoEHJxdg
		wxDDOUt1hJCpsRKnK1FFFUiM/tH6GEEQ6q9FkRRDCiW3m9xoJF/0VoUclBhzUko0E28MKo4cksXO
		OoE1lk9lhWFUH6uuc/LJU3voatO1stqqqylB+IkwImKtdXAodp2I+m/BNRdecptdY9rTrr3jtT5q
		C2SQ8LtAt5GahQ1ve4vDHEIjGhMJ62+mCU7hsNYFxCmOceD5AkUKpYfb2CYIvvlVlXjyBJ0oaAhW
		QJjCpMOciAVCYjQQgup4YjjVWSKGxQBGI8yDGycAYRHB84QnKGEJTpDCEnmgl6TkAMSTEC+JwkgG
		8g6xPC8QZ1RgCdrQKGGST5CCE+vJx4OyERUIXShp3XOGNNTRIS8ewxrkyxoY/soCmq5pohMsap/7
		3ieu+MnvRoBhG4+w9SP9PeaOdPEfjVZQgwDiTW8EHIQd0NDGsojKJ+uCEol+crg/UNAJaUgDeGbT
		kEzi5oY5IBMSgBMsK2SOimcYYcKSx4eaeA5Oh8DDDrBgIqFsIQycKIYWjQGMMgChS2mQgkaOkUUt
		ckKIr2FCGH54skupJInvWAcqFLaznAineQfMJUmMAaI79IEOwMOVM44xRqp8olXSKOM6IRQVYfRh
		RGJxHhrgqAlkKesIhxQbuPB4Nmn9pVp9xN+2uOUY/hWJRs5CpIvmsMjQdEF1WXuSAksTFMLtRAmY
		pOAFxdNJ8NzGIp0cJQsv/geUVEZvC5wroRamoAWFwSlOjsDJaHBJB1I84xmqkIYxOCEFIAzKCXlo
		RDGMwZ5FjSEPX8gBE6IgB0tQ4nookaY0qqk8I4DKJ2D5iWgU1IeYCYMSdKiiN2sljLOCiIekMMk6
		pXGMC0XFaPHkApV0AgY0FEstxyIgHfnpTxqhzS97tJ/b/tiYgwqyf4mtm2UYCpdF2uGRZjkguy76
		ky5EYaMUSYN3xJMDfYk0B3vqExJUc6AqEWxNnWtOFrSABzzUpA6tpQIUUgkUm67nVTaTRBl+ukk/
		NGKXxtApJxaRh1EygYq3K1mu9PMUdTBxCgjjmah6IppT/S5mIZJD9MRJ/opjtAKLpPAEOPvQB6Q8
		rZzgLdoxrhYU0OA1fYggYD7r+FcjBdYEAeXj/d4GN8QS6Vllcyy6BsFIRwKtupX1AkYfqFk9cPZP
		EclBUAvlBIj8IRd/+AMLT3XbnZBqpclj7WtLLAudfWqet7XCFrKLRJj0lLdATYMf1POMdRhDEpHI
		gwaVoJroDc0+lTKnStRRDVSogQpKhsKvgnNABQFPGHfgbi7rUymTgXOsXvWEVcIr3rMagxJhoOtQ
		ioC+ru01Dn29b/zyu1/C+jF/gBRSYhM6o8UG0EVNMnAjL1sFUy5Ykg/0AUO+AGFAASo2HMUN78i0
		YT4h4VSFM9EToMCm/oUxLAuvNYMZXksFnPSsVELxQqoosQ7wFW0jlliEH9IABClwYlXFsASgWBgF
		HgRrOEITJ6WMgZJ1WGMYqIBFJQ7BZASNpsXA+8QdzhAW1fyuJCYTK3dRRZIripeHPeQuD7JWBDvk
		1Vh8U/OL2NxmgA62bXEu6P7qvFizITKR6frMTlrYrqH4pI1KaE0bXnFoRFP4NowmpRAqJgRJAwcs
		VlCtFmCZhTrUxDqdxsOndQI0UqHSC0PI7q2E0XFVvy4IUoCqJzgxBikIobRd0AHgdB3kY2TDQcGG
		hSxmcYWwVIk0LbaGMZit8KGkSq2kAGe1hzZkq5V3rCOiEtfQnAi+/s2BM5cxt9n4Mj8WMAbO+JOz
		QQMZYDYTGOoHrndFo/S8fRPa3zHwbBoyaZEL5gFgVWjNQYTAgzN4IQrEUdMVil2H5UBcFocQhCDw
		0CmaQhI1T3DkGXh9O0ppmw5c0JjL5MDd1ZVSWJIcixUSbu37pMwYapCFLK6A8Yoqu+d3GMKHt0AH
		IWtbrK+3j/jO6olwcleeVkDDt02hlnvOl29Sty/VZxStIAXGA+r+QLa43u6v35fAnIHsI9t1wLML
		QSGGJk9DumThg/igqVxAQuL2VAVS6R0sle77nKZTk0ro7KWklwUVbFldNHnB4gmyfPSMMnsRnQ5w
		8ATWlI9obJ5Q/mTNcJwBpdxKyqBCJZSegUzSdXHcHYTBTxRBESTI6/GQN1nD45WMx4FIH8gBqjSP
		FZhZXgHfuHHGPo1N8RlffvVF8i1f8/2X14HLuzULjTjW9HnG2LWLqHSeJJ0O3dmGQXwSniBhSAAH
		+VHMH/xGUKDJwiXMnMjSFChZcsgJ/UGBWajGFNoVqjhbF3DBqYTBEAzBFoiFFSgBFigBUXAVvhGH
		qAigAi5gAwpDNbCJGhjIZAEFtH1Ve5UgGJhZESgIB8bMJxgDD4ngVPTQGUQRaHxb1+gVCy4BZvgV
		DP6TtMzgByhfHzGffx0WDs6NDg6SkfQgunhGI1mfC4EBG3hB/hFiEpeAR6F9UtwJAYFUgULsiRBg
		jRW0EVCoVs3BifIgzA5ooSzsQBfeHyR+GFGwASwmHGYxUFAUjnEAoyQBiySRCiR9IRj0wa2oAikI
		285AkTYBBRQtiHbRwRmwQSGqozgZwzpMBSnMI3hhkViRimjwXrjtlUO1oGasgCYa3144Bg2Cog3O
		mbe427OYYp65SGc0yQ+iQdklW1i8IlAoAfl5UnhIhGzgAEIATKnMHaGRicCQBuccwizAAUsaIxRg
		wQ4UniDU0j7+2BQSyCt2HnGg5DX+HBwCDVeNxRSZiqigAR1ExVpZwyhcgRrowBQBi5lY2UZ4xRkU
		wQdVya55/kKq2aPHYVEP0YFQpiAc/SO57dMhDSRB5gXazE8nfuK1hKJhPV8OOuSz5FkioQvUGdAB
		eSEUYSQssuEuzgZE+IlCiFZC+MZYREFJblj4vWGp5B9yHIJzPIzywCQSCAENEAJNslg6ngpxWA5q
		6B0kYo2HodapmCA1EoyKlUYRIKXRGNUoGAFMCuCK/Zh9UGUJXmXmZOWCqIIjGoPJfCUdDAFXmdkg
		+N7vzRf7TJ0hrYDVqaWNUIZ+uaW6bd0NQif03dnYrEBavmBjhY2eOZSTUBQk1RRRaCT5ZUkO8FgQ
		+ElEkFLWeAEPcMHcbRjl+CHnWOHD1IHOGMFG/kEbEAIT/iiBNp0JOgrLacYLcFzWF56JNwohu4AB
		HXzCOliNJ4yCmnSQUGxj490BVbYjGGAliLXYHXSgN23E7clBccJXinhN8PHVmslPdLblQe3RWxbW
		H8VN2SiW2YTLZMiIIBFYskBWaDiQfJYGZqGdoLRnnzRmU1njGYwZv7XBfJgU3zmC4DkMxByCI/AM
		FvzAncwHF1SXeSKQHypQmZaIF6apN+5E43kCPZJCH7ABGqQSzuVfEYzFECCiigolWajG61GKyfQQ
		CZJKBqog8M3Rsnwnja6lQXai1ilk1z0Gj9pZ8RFYXj5UiUTJA2WfD2RJG+RBQmQYKBDoryTIFkwe
		oVUp/sDI5wepVnK8lMLoDBRAASGYQRsIQeBYX6/6qmm02PTIFd7d6YGGRRRwgdAAjzGQ4J9eTheg
		yoL0ASWYVzsayCSS5XK6yNQ5KmDtRQqAa7oN1KTuqHbCYLzpmdg10pNsk+a10WJmn2scBIb9wam6
		a7wgToBSjA9UDirxHXJkYXIQniCYASHQgI8p2K8qrK8GR6qAFQnelgBCEtYk6+/YYzhhHNCMhQbu
		n+WV4BkQoj8eS7IQwbJkYrfayLeGq0D1lyiWK11GJ7rCxd64hYF9hgF5o4H0YRQsaUgS5gZ54fOw
		IRPw4kHQAIFyqJoYARasiUyWGOFBQTYu7NT+quuV/sQIsh4BsiZ2cSCItGPE/s0H9cyZ+AQaoAIl
		JsI/gk3YoGxB2gi4poC4tqyO7o+lmqK5yawiiR0QQmi+5R3axQZi+thq8ACvBgXRbhQpVQEXFO4v
		BgUUOC0eQO0TaCBkUu3lmsYTTGhJVA8JOltQUG4GZiBRHKIntFc78kDnmZLBYGXBmNnZytd8cQZc
		3ADxsWXbsqUJwK3c5qjzHZTddqvMTh/fqM/NSpYDMdAA7tunppzepaHEjlreCYG+5gGHpRxmagzG
		YAwhbCZNQkFOjIpFYu7lOtI6Gg3ROWPoju5QoorphsgZpC7ycl7SjiUcpS0L9tXJtm3Kvu3K8leO
		/rJbkAAvyjLUkozbKrLiilVJMALFYi4vgX4hZgHHqGmVfeaBbeQBjxlmG+TqnvwB9zJBbfWMSY1v
		CRtlgtiHgwwdHSidqYjhEOwaboYIWBDg36iqsByniqzFscju7HLr/npr/8YtywIwdnrLAAcvRC4J
		zSIwfHGoanDe5WANwhKHA1EwG6jq6viAbaQBxRQap3FalZYJvuVd0IhvCf8qDjfeV8XDIt5eOCkr
		td6BiXKZ+Kgo+iXcT1QZyIKGi+4wjMYBk5gsEOOXyg7x/66bEZONuTpqANWA3ixxuoCbnfImFG3T
		g0Iozsnhg0YBEgBKYXoHDYhyn/xGF/BAgkgw/v6h8eXa8BoblVF14MmowlXcylRYhYqyXgeZ1lig
		SjTaQXL+8XIKslzcLSGnjSHzbiIv5CLD7P46Ml5OpFskgoFJotYkm6QpZm226wCaxeJyQX06cABG
		AdJ2nmo4W2nu4yqbMLS+nlEZjYPAs4M4Innh3udqjjaBAbi5qIocy6IuSw3QhXca8yamze4SsTKP
		opAgcdvGm1xEJGcU781K0U++Ih7n8VCCxZ/xbJnpAMspZgB2ARqi0oF8JjqfsTpbHwEm3OutFZi9
		Mg/hXhicie7dM1fF1+8parJsK9t250BDCzIf9HUu80IXX3cK9F3sE0QqEmfMwTTfrCNpI5UA/mUN
		b55wSPCvoKdoGE4d4l3llnMU/SlKT62SEoj0mBfusbCW0bDl2OZwlO2ZqUUn8DD75O9d9LRPF4m3
		dCfyIXJc+m6lMjKb/SgLlEBh989Chc0jz2xnOFQcIELxNlLlEmCC+aHzECXnAU5mc+qanrRYdyrg
		OCjZ5tvmBQt6DmAV8ARe7bNaqA8+RR0dHVJA37VP92jaTIaQPGcy+7UiE7UxZ2qTjJtTR/YEJtAk
		beNogwFwSOwZ86pne7ZFmpYql7b5mMVNp8/66HT7uCBt35m4RMtf8DWc7fZQBzYh//a4xYFws2uS
		TmxZWPX8Ond8o/GzZnIm57Mfx5H6fM1O/v8wd3/dd3fLQY93Qh9xeft2eEYk1NUsNUti5VJ3zqIj
		sMj3hC9sfUMomRLFmQXzfvO3fzukd/dPgPf1pFJqgTezo97ujAjvkswbn8GXI5UFmdY3hdM41Vo4
		hA5Lot5Teme3yervjBpzXod4eNegKJY4M5ci7h4zKhZwJNOXzR4YVN/4ZFV2jVv5AlGjjPth2aIC
		7K4F8CVLfbHtueE1iIP3QSIyQS2kiSe5h5OLIzOJAR+wcK8raXdqZ195jbspHJqZdSvnY3tGPvm4
		m/uomYu4pMpl3Ro4bTsyJC8xfc0buNW533I2nuc5hU/WT8CXHSCnDvPwchJBqOevffEo/qHXNoAT
		+bgm+u8uOncTs1xkxhIzdphDOSNNMnzxZV9e+q47j+jiVbjpVZrRV6gTASLpRTHTtpCfeaRap5G/
		bJubOlIn9WU8tCCHeVPTOe+Z2Tbzerfz3q9T4p8Dsp4FEI0ge5mn7LLzRVA7u6KfOBCneN30NLrG
		+WKjt2OrN7vuebdvtuD0KpoaJV7BLj/PdY/rDQD9eP9EO8yiOpoj+l8D9mCfO0H2hUIZNV0EUJJU
		+/BCnVNHeWhIFsCbJyVNecm7qZlCZpVD92mAxsB7Tdp+usHrk2YUkj9NPEHSzbSou263u2PMSHdK
		fNAL/dAPdglIfGEjPY8OJCYq9cw2/raCe7yt91mu84TqoHZ7T2BWc9XWA6UkeT3DQuhyB85dEctq
		v7x+Qx25bWtS1wDZGD2QErbRG3ahE33d2/2lQuq6j/iqB4leQMbdA37g/+jc60Xeiid6J0vUf/xe
		mjyVW66asmlpV3nKWziUZCCxcDraypF+f42gx8W0N8vbE7bEx4/gm/6P/nSqw2XP9/2xn/7rDz2O
		MLnh6y2kL7jNSvqtg4agNX7v+35z/8RoY77ZKyp2h7meDTqRwD3p0z3sA/5RH5/DF/lfL/nCm81R
		F35D6xmLX7s0RzTuS/q2Y/nvTzny8mq+wVefg3u4A1/MHz+5l7vfl7ryE5J/L1b0/jN7Qq569W9n
		t3ZLtwCEC4ECWbgwYWKgwYQCZzR0+PDIkSURlyyJE2dOxotxEnXsOAgkSDtoSJL0chJlF5UrWbZ0
		+XLlSTBewIApSdJOTpCdeHZKhAhoUEQbM0Y0euShw4UJSyREmJDFioUHqT5dehVrVqhLEVY18eHD
		ijj0/n2b8+FCWrAePlDVSvBtXK5Wuc41+JTu1aQOKVa0uBFwxzkeP4bMOfJmTcWLGTdmLJMmySKT
		D9vZ2WlQT55ChwLeeBTp3oZZVxS8m7epXNWrF5p2evogWLFkzaJVC7at14NXXbOOa6IgcBbDWeQ1
		bbXr7qyiZ/h1/hdjRumDCRcW/jnoMJqcN7l3917y8OWQIasDJXpxTpyJR0WrLu3CdW/Ybn3Xb113
		/gcPY8ueTXthLbB0wyov+6bSbUCt6CtwoYZqqMHBB2tw7qjppotDqOqsG4/DDj3k0KePNCTMs+lA
		i4i5GVhj0MAW32JQN9n4q+0/AHFDEEEXr0JOuawKrEqh1WaQkMgaTjRKOs8Ao27EJp180jwL00uP
		qCPbWy1BHbX8DUgEZaTNv/9wyy3LLQmcr0w0cQRyoRXchKqEIfk6wsgjK1JyySk1kpLPPjXC07Mj
		jUpxrjVZ1CqFRBVdNFEzffMyrBnDVIstMg29FNNMNd20x4SkWuqhFPZCaj07/pf4E9BUVSVKI4me
		KxXFFGdIYUdONWUU1xRs3VVT3GbrzzZKBeSV2GKNrcrNT0FNochmGzoR1lelnXZaU50TLVEJk13h
		BDePxXSFXBn9ltxKf6WxRgEtRbAEct1ds12BMn2LVoZkTUrQfPU9ca8H5bxSXrpofddQS9cl2NDi
		cNTvoAtMWAJME2q0cViELSa34jW1upfjjj1OisuL1zw4Y5F7HbOtOWhLhIUSPKDgghI+GA7lmm80
		edMSdN6Z56ps/nndgzV2QVnftj266EIzBfpmgpkGGueFf3YhEbLo6eQIsCZey4Ouvf4a7LDFHpvs
		ss0eG7ezzz7oaxM80PUgtHFNQBrperFKge4V5kbagxXA1k/twAPXj3DAv05b8MQHZ+vwtmrQxOpv
		sK5hvrwtvxzzzDXfnPPOk8XVTWZrEL3Io0cXV9FmPV+d9dZdfx1zgY5A5Bt//vGHnm800SSojTrz
		PZFVhR+e+OIx5Az5333nbPnOkn8e+uilnz55z8wzHvvmVxUq++6VTH73b+ix/Z/b/Tkf/fTVX5/9
		9t1/H/745Z+f/vrtvx///PXfn//7y/8nIAA7

	}
	return $image

}

proc installASM::installProc {Path} {
  set fileList [lsort [glob *]]
  ## Creating Directory
  .frmp.install.frmlb.lbtxt configure -wraplength 500
  .frmp.install.frmstst.lbstatus configure -text "Status: "
  set path_ini [pwd]
  if { [file isdirectory $Path] == 0} {
    if {[file exists $Path] != 1} {
      file mkdir $Path
    }

    set text [.frmp.install.frmstst.lbprint cget -text]
    .frmp.install.frmstst.lbprint configure -text "$text\n - Directory $Path was created."
  } else {
    set text [.frmp.install.frmstst.lbprint cget -text]
    .frmp.install.frmstst.lbprint configure -text "$text\n - Directory $Path already exists..."
    .frmp.install.frmstst.lbprint configure -text "$text\n - Removing Old Files..."
    if {$Path != $path_ini} {
      foreach a $fileList {file delete -force $Path/$a}
    }
  }

  ## Copying files
  set text [.frmp.install.frmstst.lbprint cget -text]
  .frmp.install.frmstst.lbprint configure -text "$text\n - Copying Files to Directory: $Path"

  if {$Path != $path_ini} {
	foreach a $fileList {
      if {[lindex [split $a "/"] end] == "amber_run.sh" && [string first "Windows" $::tcl_platform(os)] == -1} {
        set amberfile [open "$Path/amber_run.sh" w+]
        puts $amberfile {##################################################################################################
##                      	CompASM Version 1.0   						##
##												##
##                                   								##
## Run Molecular Minimization/Dynamics Simulation file: 					##
##	-$1 -Sander input values given by CompASM						##
##	-$2 -AMBER location folder path given by CompASM, set on ASMPath.tcl			##
##												##
## User can change this file in order to Run sander in a proper way				##
## i.g.:      $2/sander $1									##
##################################################################################################}
      puts $amberfile {arg1=$1
arg2=$2

$2/sander $1}
    close $amberfile
    file attributes "$Path/amber_run.sh" -permissions rwxrwxrwx
      } else {
        if {[lindex [split $a "/"] end] != "ASM_PATH.tcl"} {
          file copy -force $a $Path
        }
      }
    }
  }




####  Step 2
###Create Installation File containing the path needed
  set asm [.frmp.install.frmpath.entryload get]
  set amb [.frmp.install.frmpath.entryloadAMB get]
  set del [.frmp.install.frmpath.entryloadDEL get]
  if {$amb != ""} {
    set file [open $asm/ASM/ASM.tcl r+]
    set file_aux [open $asm/ASM/ASM_aux.tcl w+]
    set txt [read  -nonewline $file]
    puts $file_aux "lappend auto_path $asm/ASM/"
    puts $file_aux $txt
    close $file
    close $file_aux
    file delete "$asm/ASM/ASM.tcl"
    file rename "$asm/ASM/ASM_aux.tcl" "$asm/ASM/ASM.tcl"
  } else {
    tk_messageBox -title "Installing VMD plug-in only" -message "One, or more missing paths. Only VMD plug-in will be installed." -type ok -icon info
  }
  set file [open $asm/ASM/ASM_PATH.tcl w+]
  puts $file "package provide ASM_PATH 1.0\n"
  puts $file "namespace eval ::ASM_Path:: {} {namespace export *}"
  puts $file "###ASM instalation path"
  puts $file "proc ASM_Path::install {} {return $asm/ASM}"
  puts $file "###AMBER instalation path"
  if {$asm != ""} {
      set asm "$asm/exe"
  }
  puts $file "proc ASM_Path::amber {} {return $amb}"
  puts $file "###Delphi instalation path"
  if {$del != ""} {
      set del "$del/delphi"
  }
  puts $file "proc ASM_Path::delphi {} {return $del}"
  puts $file "###Type of machine"
  set mach "local"
  puts $file "proc ASM_Path::machine {} {return $mach}"
  close $file
####  Step 3

	## Adding plug-in to vmd
	if {$installASM::inVMD == 1} {
      set file ""
      if {[string first "Windows" $::tcl_platform(os)] != -1} {
        if {[file exists "C:/Program Files/University of Illinois/VMD/vmd.rc" ]!= 1} {
          tk_messageBox -message "VMD is not in C:/Program Files/University of Illinois/VMD\nPlease indicate where VMD is located" -title "VMD directory"
          set vmdpath [tk_chooseDirectory -title "Choose VMD directory"]
          set file "$vmdpath/vmd.rc"
          if {$vmdpath == ""} {
              break
          }
        } else {
          set vmdpath "C:/Program Files/University of Illinois/VMD"
          set file "$vmdpath/vmd.rc"
        }
      } else {
        set file "[file nativename ~]/.vmdrc"
      }

      if {[file exists $file ]!= 1} {
        set vmdrc [open $file w+]
      } else {
        set vmdrc [open $file r+]
        set vmdrcF [read $vmdrc]
        close $vmdrc
        set vmdrcF [split $vmdrcF "\n"]
        set vmdrc [open $file w+]
        set i 0
        while {$i <=[llength $vmdrcF]} {
          ##set line [gets $vmdrc]
          if {[lindex $vmdrcF $i] == "###ASM"} {
            incr i
            while {[lindex $vmdrcF $i] != "##END"} {
              incr i
            }
          }
          if {[lindex $vmdrcF $i] == "##END"} {
            incr i
          }
          if {[lindex $vmdrcF $i] != ""} {
            puts $vmdrc [lindex $vmdrcF $i]
          }
          incr i
        }
      }
      puts $vmdrc "###ASM"
      puts $vmdrc "variable ASMPath  $Path"
      # Add Alanine Scanning Mutagenesis extension
      puts $vmdrc "lappend auto_path $Path/"
      puts $vmdrc "vmd_install_extension ASM_GUI \"ASM_GUI::main\" \"PortoBioComp/Alanine Scanning Mutagenesis\""

      puts $vmdrc "menu main on"
      puts $vmdrc "##END"
      close $vmdrc

      set text [.frmp.install.frmstst.lbprint cget -text]
      .frmp.install.frmstst.lbprint configure -text "$text\n - ASM plug-in (Extensions»PortoBioComp»Surface and Volume Calculator) added to VMD (.vmdrc file created in the home directory)"


      set text [.frmp.install.frmstst.lbprint cget -text]

      set text [append text  "\n -INSTALLATION DONE"]
      set text [append text "\n -ASM is now installed. The extension can be found at the VMD menu Extensions » PortoBioComp » Alanine Scanning Mutagenesis"]

      set text [append text "\n Enjoy ..."]


      .frmp.install.frmstst.lbprint configure -text $text

      if {$amb != ""} {
        grid [ttk::frame .frmp.install.frmtxt] -row 3 -column 0 -sticky new
        grid columnconfigure .frmp.install.frmtxt 0 -weight 2; grid rowconfigure .frmp.install.frmtxt 0 -weight 1
        grid [tk::text .frmp.install.frmtxt.text -bg [ttk::style lookup .frmp -background] -width 66 -height 4 -relief flat -exportselection yes] -row 0 -column 0 -sticky we -padx 2
        .frmp.install.frmtxt.text insert end "To run ASM Core as a shell command, please copy this line to your bashrc or bash_profile file:"
        .frmp.install.frmtxt.text insert end "\nalias ASM='tclsh $asm/ASM/ASM.tcl'\nIMPORTANT!!!- Edit amber_run.sh file to a proper sander launch"
        .frmp.install.frmtxt.text configure -state disabled
      }
	}
}


installASM::Buil