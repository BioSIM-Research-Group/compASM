package provide ASM_GUI 1.0

namespace eval ::ASM_GUI:: {

  package require Tk

  variable install $::ASMPath
	package require ASM_Constant 1.0
  package require inputframe 1.0
  package require outputframe 1.0
  package require aboutframe 1.0
  package require vmdinfo 1.0
  package require Gui_func 1.0
  package require ASM_PATH 1.0

  #lappend auto_path $install/GUI/LIB/tablelist4.11/
  package require tablelist 
  package require Plotchart 1.9.2
  variable topGui ""
  variable msgGui ""
  variable progGui ""
  array set pdb ""
  array set checklig_rec ""
  array set checkmut ""
  array set checkmut_pv ""
  array set checklig_rec_pv ""
  array set rdbut ""
  array set rdbutMut ""
  array set mut_added ""
  array set out_values ""
  variable top ""
  variable nchain
  variable run "" ;  #run  == 0 it's pretended to run just a minimization, if run == 1 a dynamic somulation
  variable repid 0
  variable made 0
  variable press_i ""
  variable server_but ""
  variable load ""
  variable next 0
  variable ASM_file 0
  variable heat_add ""
  array set index_cmb ""
  array set heat_val ""
  array set onoff ""
  variable lig_rep ""
  variable rec_rep ""
  variable radio_rep ""
  variable ligand_sel ""
  variable pb 0
  variable recep_sel ""
  variable rmsValue 0
  variable imgAbout ""
  variable imgLogo ""
  variable imageFCUP ""
  variable imageLicense ""
  variable imageREQUIMTE ""
  variable version "1.0"
  array set sasa_arr ""

}

proc ASM_GUI::Build {} {

  set ASM_GUI::topGui ".asm"

  ## Title of the windows
  toplevel $ASM_GUI::topGui -background #d9d9d9
  wm title $ASM_GUI::topGui " CompASM $ASM_GUI::version" ;# titulo da pagina
  wm protocol $ASM_GUI::topGui WM_DELETE_WINDOW {
    ASM_GUI::reset
    #wm withdraw $ASM_GUI::topGui
    wm withdraw $ASM_GUI::topGui
  }
  grid columnconfigure $ASM_GUI::topGui 0 -weight 1; grid rowconfigure $ASM_GUI::topGui 1 -weight 1
  if {$::tcl_platform(os) == "Darwin"} {
    wm geometry $ASM_GUI::topGui 34x6
  } else {
    wm geometry $ASM_GUI::topGui 38x6
  }

  wm resizable $ASM_GUI::topGui 0 0


  ########## Frame 1
  #grid [frame $ASM_GUI::topGui.f1 -bg black] -row 0 -column 0 -sticky news
  image create photo ASM_GUI::imgLogo -data [ASM_GUI::SetLogoImage]
  grid [label $ASM_GUI::topGui.logo -bg black -image ASM_GUI::imgLogo -anchor e] -row 0 -column 0 -sticky ew

  ########## Notebook
  grid [ttk::notebook $ASM_GUI::topGui.nb1] -row 2 -column 0 -sticky news
  grid columnconfigure $ASM_GUI::topGui.nb1 0 -weight 2; grid rowconfigure $ASM_GUI::topGui.nb1 0 -weight 2

  ttk::frame $ASM_GUI::topGui.nb1.f1
  ttk::frame $ASM_GUI::topGui.nb1.f2
  ttk::frame $ASM_GUI::topGui.nb1.f3

  $ASM_GUI::topGui.nb1 add $ASM_GUI::topGui.nb1.f1 -text "Input"  -sticky news
  grid columnconfigure $ASM_GUI::topGui.nb1.f1 0 -weight 2; grid rowconfigure $ASM_GUI::topGui.nb1.f1 0 -weight 2

  $ASM_GUI::topGui.nb1 add $ASM_GUI::topGui.nb1.f2 -text "Output" -sticky news -state disable
  grid columnconfigure $ASM_GUI::topGui.nb1.f2 0 -weight 1; grid rowconfigure $ASM_GUI::topGui.nb1.f2 0 -weight 1

  $ASM_GUI::topGui.nb1 add $ASM_GUI::topGui.nb1.f3 -text "About"  -sticky news
  grid columnconfigure $ASM_GUI::topGui.nb1.f3 0 -weight 2; grid rowconfigure $ASM_GUI::topGui.nb1.f3 0 -weight 2


  grid [ttk::frame $ASM_GUI::topGui.frfile] -row 1 -column 0 -padx 2 -pady 5 -sticky ew
  grid columnconfigure $ASM_GUI::topGui.frfile 1 -weight 2; grid rowconfigure $ASM_GUI::topGui.frfile 1 -weight 1

  grid [ttk::label $ASM_GUI::topGui.frfile.lbfile -text "ASM file"] -row 0 -column 0 -sticky w

  grid [ttk::entry $ASM_GUI::topGui.frfile.enfile] -row 0 -column 1 -sticky news

  grid [ttk::button $ASM_GUI::topGui.frfile.btfile -text "Load" -padding "5 2 2 2" -command ASM_GUI::loadMain] -row 0 -column 2 -sticky e



  ## Build Run-Save-reset buttons
  set frame $ASM_GUI::topGui.nb1.f1
  grid [ttk::frame $ASM_GUI::topGui.nb1.f1.btrunload] -row 3 -column 0 -sticky ewns
  grid columnconfigure $ASM_GUI::topGui.nb1.f1.btrunload 1 -weight 2; grid rowconfigure $ASM_GUI::topGui.nb1.f1.btrunload 1 -weight 1

  grid [ttk::button $ASM_GUI::topGui.nb1.f1.btrunload.btrun -text "Run" -state disable -command {
    if {$ASM_GUI::ASM_file == 0} {
      ASM_GUI::saveFile
    }
    if {($::tcl_platform(os) == "Darwin" || $::tcl_platform(os) == "Linux") && [ASM_Path::amber] != ""} {
      if {[$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb size] != 0} {

        set name [split $ASM_GUI::ASM_file "/"]
        cd [file dirname $ASM_GUI::ASM_file]
        if {[file exists [file dirname $ASM_GUI::ASM_file]/runAsm.sh] == 1} {
          file delete "[file dirname $ASM_GUI::ASM_file]/runAsm.sh"
        }
        set runfile [open "[file dirname $ASM_GUI::ASM_file]/runAsm.sh" w+]
        puts $runfile "xterm -geometry 100x30+0+0 -title ASM -sb -e '/bin/bash /opt/programs/vmd/plugins/compASM/compasm [lindex $name end] -n ASM; sleep 50000000000000h '"
        close $runfile

        file attributes "[file dirname $ASM_GUI::ASM_file]/runAsm.sh" -permissions rwxrwxrwx
        set id [exec sh "[file dirname $ASM_GUI::ASM_file]/runAsm.sh" &]
        tk_messageBox -icon info -message "Your Job was submitted successfully.\n\nTo cancel or delete ASM calculation close ASM window.\n" -title "Running" -type ok
      } else {
        tk_messageBox -icon info -message "ASM Core is only functional under Unix System.\nPlease run ASM Core on Linux or MacOS" -title "Information" -type ok
      }
    }
  }] -row 0 -column 1 -sticky ew -padx 2

  grid [ttk::button $ASM_GUI::topGui.nb1.f1.btrunload.btsave -text "Save ASM file" -state disable -command ASM_GUI::saveFile] -row 0 -column 0 -sticky ew -padx 2
  grid [ttk::button $ASM_GUI::topGui.nb1.f1.btrunload.btunlck -text "Unlock" -command ASM_GUI::unLock] -row 0 -column 2 -sticky ew -padx 2
  grid [ttk::button $ASM_GUI::topGui.nb1.f1.btrunload.btreset -text "Reset" -command {
    ASM_GUI::reset
    if {[molinfo top] != -1} {
      ASM_GUI::readPdbValues
    }
  }] -row 0 -column 3 -sticky ew -padx 2

  ASM_GUI::buildInputFrame $ASM_GUI::topGui.nb1.f1 0

  ##Build Output

  ASM_GUI::buildOutputFrame $ASM_GUI::topGui.nb1.f2 0


    ## Build About
  set frame $ASM_GUI::topGui.nb1.f3
  ASM_GUI::buildAboutFrame $frame

  bind $ASM_GUI::topGui.nb1 <<NotebookTabChanged>> {
    set ind_list ""
    set id ""
    set tab ""
    if {[$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb curselection] == "" && [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb curselection] != ""} {
      set tab 1
      set id [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb curselection]
    } elseif {[$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb curselection] != "" && [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb curselection] == ""} {
      set tab 2
      set id [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb curselection]
    }


    if {[llength [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb columncget 0 -text]] > 0 && $id != ""} {
      set j 0
      while {[lindex $id $j]!= ""} {
        if {$tab == 1} {
          set mut [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb cellcget [lindex $id $j],0 -text]
          set all_mut [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb columncget 0 -text]
        } elseif {$tab == 2} {
          set mut [$ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb cellcget [lindex $id $j],0 -text]
          set all_mut [$ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb columncget 0 -text]
        }
        set index [lsearch $all_mut $mut]
        set ind_list [lappend ind_list $index]
        incr j
      }
    }
    if {$tab == 1} {
      $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.muttbl.tb selection set $ind_list
    } elseif {$tab == 2} {
      $ASM_GUI::topGui.nb1.f2.nb1.f1.fp.fdt.tb selection set $ind_list
    }

  }

}
proc ASM_GUI::msgbox {} {
  set ASM_GUI::msgGui ".msg"
  toplevel $ASM_GUI::msgGui -width 300 -height 90 -background #d9d9d9
  ## Title of the windows
  wm title $ASM_GUI::msgGui "Warning" ;# titulo da pagina
  grid columnconfigure $ASM_GUI::msgGui 1 -weight 2; grid rowconfigure $ASM_GUI::msgGui 1 -weight 2
  grid [ttk::frame $ASM_GUI::msgGui.fp] -row 0 -column 0 -sticky news -padx 15 -pady 10
  wm protocol $ASM_GUI::msgGui WM_DELETE_WINDOW {
    catch {return ""}
  }

  grid columnconfigure $ASM_GUI::msgGui.fp 1 -weight 1; grid rowconfigure $ASM_GUI::msgGui.fp 1 -weight 1
  grid [ttk::label $ASM_GUI::msgGui.fp.lbwrn -text "Please make sure that your PDB are under AMBER numenclature.\nTo do so submite your structure under PDB2PQR Server in:" -justify left]\
  -row 0 -column 0 -sticky ns -padx 2 -pady 2

  grid [tk::text $ASM_GUI::msgGui.fp.text -bg [ttk::style lookup $ASM_GUI::msgGui.fp -background] -width 30 -height 1 -relief flat -exportselection yes -foreground blue] -row 1 -column 0 -sticky w

  $ASM_GUI::msgGui.fp.text see 35.0
  $ASM_GUI::msgGui.fp.text tag add link 1.0 25.0
  $ASM_GUI::msgGui.fp.text insert 1.0 "http://kryptonite.nbcr.net/pdb2pqr/" link
  $ASM_GUI::msgGui.fp.text tag bind link <Button-1> {
    if {$::tcl_platform(os) == "Linux"} {
      eval exec "xdg-open http://kryptonite.nbcr.net/pdb2pqr/ &"
    }
    set ASM_GUI::server_but 1
  }
  bind link <Button-1> <Enter>
  $ASM_GUI::msgGui.fp.text tag configure link -foreground blue -underline true
  $ASM_GUI::msgGui.fp.text configure -state disabled
  grid [ttk::button $ASM_GUI::msgGui.fp.btok -text "Ok" -command {
    set file ""
    set top [molinfo top]
    if {$ASM_GUI::server_but == 1} {
      set file [tk_getOpenFile]
      if {$file != ""} {
        set top [mol load pdb $file]
      }
      destroy $ASM_GUI::msgGui
      set fil [ASM_GUI::loadMol]
      mol load pdb $fil
      set top [molinfo top]
    } elseif {$top != -1} {
      destroy $ASM_GUI::msgGui
      set fil [ASM_GUI::loadMol]
      mol load pdb $fil
      set top [molinfo top]
    } else {
      destroy $ASM_GUI::msgGui
    }
    set ASM_GUI::go 1
  }] -row 2 -column 0 -sticky ns -padx 15 -pady 5
  bind $ASM_GUI::msgGui <Return> {$ASM_GUI::msgGui.fp.btok invoke}
  wm resizable $ASM_GUI::msgGui 0 0
}
proc ASM_GUI::loadProtein {} {
  set moltop [molinfo top]
  if {$moltop != -1} {
    set top [molinfo top get name]
    set do [tk_messageBox -icon question -message "Do you want to use protein $top?" -title "Top molecule" -type yesnocancel]
  } else {
    set do "yes"
  }

  if {$do == "no"} {
    set prot [tk_getOpenFile]
  }
}


proc ASM_GUI::spinInter {} {
  $ASM_GUI::topGui.nb1.f1.nb2.f2.fp.frtbl.frmradi.spinradii configure -state disable
  ASM_GUI::save_viewpoint 1
  ASM_GUI::clearSlect
  mol delete [molinfo top]
  mol on [molinfo top]
  set ASM_GUI::repid 0
  set ASM_GUI::top [molinfo top]
  ASM_GUI::loadMutations
  ASM_GUI::restore_viewpoint 1
}
##### RUN Application
proc ASM_GUI::main {} {
  if {[info exists ::ASM_GUI::pdb]} {
    array unset ::ASM_GUI::pdb
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
    array unset ::ASM_GUImut_added
    array set ::ASM_GUImut_added ""
    set ::ASM_GUI::top ""
    set ::ASM_GUI::nchain ""
    variable saved 0
  }
  if {[molinfo top] != -1} {
    ASM_GUI::msgbox
    vwait ASM_GUI::go
  }

  if {[winfo exists $ASM_GUI::topGui] == 1} {
    wm deiconify $ASM_GUI::topGui
  } else {
    ASM_GUI::Build
  }

  if {[molinfo top] != -1} {
    ASM_GUI::readPdbValues
  }

  return $ASM_GUI::topGui
}

proc ASM_GUI::SetLogoImage {} {
  set image {
R0lGODlhaQAaAMZxAAAAAAICAg8PDhERERcXFxkZGR8gHyAgHyIiIR5FMDw+Oz5APEFBQUBDP0lN
RyRaN0lOSElRRypdOSZfNy9fO1NaUFRbUVtlV1xnWDx0QFxoWVRwTkJ4Q11xVWJwXDmBPWNyXVx2
U2NzXWV1XjuGPTKLO2d5X2h5X1aBTWl8YFqDUHR5cUqLQ2p/YGqAYGuBYGaFWmyDYG2GYG2HYHmC
d3qDeG6LYG+MYG6NX26OXm6QXW6RXW6SXG2TW26TXG6UW22WWWyXWG2XWWuYVjqqNT2pNzqqNmyY
V2qZVTyqNT+pNzyqNj2qNkCpOGmaVEanPEGpOGqaVESoOkGpOWibUkWoOkWoO0OpOWecUkeoO0Sp
OkqnPmadUEioPEunPlSkQk6mQFKlQWWeT1CmQE2nP16hSVOlQmGgS1akRFyiR2SfTl+hSVqjRVek
RGKgTGSgTWKhS////////////////////////////////////////////////////////////yH+
GkNyZWF0ZWQgd2l0aCBHSU1QIG9uIGEgTWFjACwAAAAAaQAaAAAH/oAAgoOEhYaHhCs1NIwMiI+Q
kZKTlIUmZ5iZmmcmgyJXT6FaREAIlaeoqZQ7RF42MaxEsrI7gzNEV7JNTVBpqr/Av6wVgxiztLZE
TxYAC2xEWsyTCHBwC8HYpztuhW7HtYK3y+GyL4IQ0oPM6AgWWtGFFhDZ9IU7VIVU38njCGm4F3Ic
e2PKiZIsRIp0wZWLSIoFb47lqFdvh5cBgxQcIwIOgDg0ZXD1ysGECEhZZQCElHXFDJpQIDWgQfml
CJMZFLNZJCAIg7d95GaNKkXECrgYXq5ACKlUkIVQzNxVESFIDK6clETsmHFt0AIeLQBo3IiM3JMe
JyxcczcOwNNl/iFTOoXqUVYyIlgltVkia8o8ACaIxAggAAfZsnW1pLAgbYGSJ1QBaHgSLa46uiKa
EOkqEG/eRy6KHOtiYYToGIIOHOY4aAgRI1IoE8GCYAuuGCnAECGjkohcAAiUBZmhYRebFDamKAHy
+dGZ1bJiGOhQQB/ZjlaPPTFpYUqSWU0tD0ojWvALzbPQmGp+CAlZLM+IqNiQAMXPjR11EGnCDMEY
IkosgIAMP/iQwnopDPHDDBaYgkAKM8TgwQw6DIHEDFQtoMEMxHUFAAQMLgChCKZYwKEGgzx4oAgc
phNPebKc0YwsJFDAwQMlHNaRONJE1MQ1MShxRX9ANPEdEVBs/iENBGSMguSQHk3BF4BTmAMAHNA0
UdIVYbjG0htOXXGFFOARdEhgWSixxnomXAGDBB9kEIEgCggxy47K9JADG0ooAWZd4+zwGBlOsFEF
EVMggAAZRIQxxhu5xKABFFBcgcUbUwDIzEomkXEFemV4egVVTymBS6hQNIHTIe14OAgPLEzQQCF2
shbUMUqIYQqPwREBxnoxPAFFCpNaEYQgDyIQhix/WXAoF70RQVWvUC6gWS1PEcGGgyyhwkoIhoyF
51kz9EDGLszxmO2qHx4qhDgoEoISIbmEEe0gM/0277qDrOStYIcgxiOyDQHK2HbsQoDQgsq4CMC8
g4xir7+C+Yj3sG9uIdyvXdoAbIjADRN8FY8Q5PInADFY0UQKKUBhBWrApVAyLutZoBm0FPemL8bZ
6gqcLFv824YhIID8BEhlfFpEDwb3pkUaMzih2RUILJBpE07kcMUSHCoBBRg59JALf/dWjLEg+27n
aw9gVMruKogB4IAXiKVg6iypOrErkswsQAYUeJMhTWZ3i4biG3dTmYLZnuk8SNqylITLyZXEQkQb
McACFHAxcMihCB6CCLMgItygxg0kErJADFEc8ZA6M2Dxw+uCbBiZZMQNAuE82fYQAxeoq3LBDsQX
b/wOF7DXHL/KN/+ZBYC/7fz02SDQ+XrUZ698IAA7

  }
  return $image
}
