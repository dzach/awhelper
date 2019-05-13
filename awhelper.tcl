#
# A basic androwish helper
# (C) 2019, dzach
# Licensed under the GPL 3
#
package require Tk

namespace eval ::awhelper {
	variable {}

# namespace ::awhelper
proc appbar {W id args} {
	# create an action bar at the top of the toplevel
	variable {}
	array set o [subst {
		-icon {} -title Actionbar -buttons {} -command {apply {args {}}}
		-bg #313131 -fg #fff -buttonbg #313131 -buttonfg #ccc
		-activebg #424242 -activefg #fff
	}]
	array set o $args
	set icopad [list  -ipadx [dp2px 12] -ipady [dp2px 12]]
	set F $W.$id
	destroy $F
	set bopts [list -background $o(-buttonbg) -borderwidth 0 -anchor c -justify left -padx [dp2px 12
		] -pady [dp2px 12] -highlightthickness 0 -font [list $(ff) -[dp2px 16] bold
		] -foreground $o(-buttonfg) -activebackground $o(-activebg) -activeforeground $o(-activefg)]
	frame $F -background $o(-bg)
	# app icon
	if {[llength $o(-icon)]} {
		pack [button $F.back {*}$bopts -image $o(-icon) -command [concat $o(-command) $id-back $F.back]] -side left -anchor c {*}$icopad -padx [dp2px 4] -pady [dp2px 4]
		bindtags $F.back [list $F.back Button all]
	}
	# title
	pack [label $F.ttl -text $o(-title) -background $o(-bg) -font [list $(ff) -[dp2px 24] normal
		] -foreground #0af -anchor w -justify left -padx [dp2px 16] -pady 0] -side left -anchor w -fill x
	foreach b $o(-buttons) {
		lassign $b b ico
		if {[llength $ico]} {
			set tico [list -image $ico]
			set pico $icopad
		} else {
			set tico [list -text $b]
			set pico {}
		}
		pack [button $F.b[incr i] {*}$tico -command [concat $o(-command) $id-$b $F.b$i
		] {*}$bopts] -side right -padx [dp2px 4] {*}$pico
		bindtags $F.b$i [list $F.b$i Button all]
	}
	return $F
}

# namespace ::awhelper
proc borg {cmd args} {
	variable {}
	global AW
	if {[llength [info command ::borg]]} {
		::borg $cmd {*}$args
	} else {
		# we'll deal with this command locally
		switch -glob -- $cmd {
			sh* { # shortcut
				lassign $args sub name uri icon
				switch -glob -- $sub {
					add { # add short cut
						# create an emulator shortcut in the same dir as the uri
						set scname [file join [file dirname $($AW,sc,uri)] $name.aw]
						set fd [open $scname w+]
						puts $fd "name $name\nuri $uri\nicon [list $icon]"
						close $fd
						array set {} [list $AW,sc,uri {} $AW,sc,icon {} $AW,sc,name {}]
					}
					del* { # delete shortcut
						file delete $($AW,sc,uri)
					}
				}
			}
			to* { # toast
				lassign $args txt flag
				# use Tk widgets for the toast
				destroy $AW.toast
				set (toast) [dict create -W $AW.toast]
				set w [label $AW.toast -text $txt -font [list $(ff) -[dp2px 15] normal
					] -foreground #fff -background #848484 -padx [dp2px 14] -pady [dp2px 7]]
				place $w -relx 0.5 -rely 1 -y -[dp2px 64] -anchor s
				after [expr {1500 + int(([llength $flag] ? $flag : 0) * 1000)}] "destroy $w"
			}
			default {
				puts "borg $cmd $args"
			}
		}
	}
}

# namespace ::awhelper
proc dialog args {
	variable {}
	global AW
	array set o [subst {
		-name d0 -title Dialog
		-bg #313131 -fg #fff -buttonbg #313131 -buttonfg #ccc
		-activebg #424242 -activefg #fff
	}]
	array set o $args
	set W $AW.$o(-name)
	frame $W -background $o(-bg)
	pack [label $W.ttl -text $o(-title) -background $o(-bg) -font [list $(ff) -[dp2px 24] normal
		] -foreground #0af -anchor w -justify left -padx [dp2px 12] -pady [dp2px 16]] -anchor w -fill x
	set i 0
	foreach b $o(-buttons) {
		pack [frame $W.s$i -background $o(-activebg)] -side top -fill x
		pack [button $W.b$i -text $b -background $o(-buttonbg) -font [list $(ff) -[dp2px 18] normal
			] -anchor w -justify left -command [list [namespace current]::events $W $o(-name)-$i
			] -foreground $o(-buttonfg) -activebackground $o(-activebg) -padx [dp2px 12] -pady [dp2px 16
			] -activeforeground $o(-activefg) -highlightthickness 0 -borderwidth 0
			] -side top -fill x
		bindtags $W.b$i [list $W.b$i Button all]
		incr i
	}
	# show the dialog
	PageShow $AW $o(-name)
}

# namespace ::awhelper
proc dp2px dp {
	## convert dp to pixels
	variable {}
	expr {round($(densitydpi) / 160.0 * $dp)}
}

# namespace ::awhelper
proc events {W e args} {
	variable {}
	global AW
	switch -glob -- $e {
		edbar-* { # editor appbar events
			set btn [lindex [split $e -] 1]
			set btnw [lindex $args 0]
			switch -glob -nocase -- $btn {
				more {
					# hide / show more
					if {[llength [winfo manager $W.more]]} {
						place forget $W.more
					} else {
						place $W.more -in $btnw -anchor ne -relx 1 -rely 1 -y [dp2px 4]
						raise $W.more
					}
				}
				back - save {set ($W) $btn}
			}
		}
		ed-* { # editor events
			set btn [lindex [split $e -] 1]
			set btnw [lindex $args 0]
			switch -glob -- $btn {
				navb* { # navigation
					if {[llength [winfo manager $W.navf]]} {
						place forget $W.navf
					} else {
						place $W.navf -in $W.navb -anchor nw -relx 0 -rely 1 -y [dp2px 5]
						raise $W.navf
					}
				}
				nav { # menu NAV: show / hide navigation button
					if {[llength [winfo manager $W.navb]]} {
						place forget $W.navb
					} else {
						place $W.navb -in $btnw -anchor ne -relx 1 -x -[dp2px 4
							] -rely 0 -y [dp2px 4] -width [dp2px 48] -height [dp2px 48]
						raise $W.navb
					}
				}
			}
		}
		d0-0 {
			# create a shortcut
			# new dialog
			array set {} [list $AW,sc,name {} $AW,sc,icon {} $AW,sc,uri {}]
			dialog -name sc -title "Create a shortcut" -buttons {
				"Select target script"
				"Select icon PNG file\n(default: Androwish icon)"
				"Enter shortcut's name\n(default: filename)"
				"Create the shortcut"
			}
		}
		d0-1 {
			# TODO: save .wishrc here
			set fpath [file join $::env(HOME) .wishrc]
			if {[file exists $fpath] && [file isfile $fpath]} {
				if {![file readable $fpath]} {
					borg toast "ERROR:\nFile .wishrc is not readable" 1
					return
				} elseif {![file writable $fpath]} {
					borg toast "ERROR:\nFile .wishrc is not writable" 1
					return
				}
				set fd [open $fpath]; set text [read $fd]; close $fd
			} else {
				set text [subst -nocommands {# ----------------------------------
# This file is loaded automatically
# by wish on start-up.
# File: /home/dz/.wishrc
# ----------------------------------
# cd $env(HOME)
# lappend auto_path $env(HOME)/lib
# ::tcl::tm::path add $env(HOME)/tm}]
			}
			# gettext returns the widget's text, and the exit button value in opts
			catch {gettext $AW ed -title .wishrc -text $text} res opts
			if {[getdict $opts -button] eq "SAVE"} {
				set fd [open $fpath w+]; puts -nonewline $fd $res; close $fd
				borg toast "Saved $fpath"
			} else {
				borg toast "File was NOT saved"
			}
			sdltk textinput 0
			update
			PageBack $AW
		}
		d0-2 {
			# quit this helper and show the console
			if {$(android)} {
				console show
			} else {
				package require console
				console show
			}
			# if on android or awemu delete our namespace
			if {[llength [info command ::borg]]} {
				after 0 "namespace delete [namespace current]"
			}
			after 0 "destroy $::AW"
			unset ::AW
		}
		d0-3 {exit}
		sc-0 {
			set ($AW,sc,uri) [tk_getSaveFile -confirmoverwrite 0 -filetypes {{tcl *.tcl} {All *}} -parent $AW]
		}
		sc-1 {
			set ($AW,sc,icon) [imgfile2base64 [
				tk_getSaveFile -confirmoverwrite 0 -filetypes {{png *.png} {All *}} -parent $AW]]
		}
		sc-2 {
			set ($AW,sc,name) [getinput $AW -title "Shortcut name" -text "Enter shortcut's name"]
			PageBack $AW
		}
		sc-3 {
			if {[llength $($AW,sc,uri)]} {
				set name [expr {[llength $($AW,sc,name)] ? $($AW,sc,name) : [file root [file tail $($AW,sc,uri)]]}]
				# allow the user to enter just a name and create an empty file
				if {![file exists $($AW,sc,uri)]} {
					# create an empty file
					close [open $($AW,sc,uri) w+]
				}
				# create the shortcut
				if {![catch {
					borg shortcut add $name file://$($AW,sc,uri) $($AW,sc,icon)
				}]} {
					borg toast "Created shortcut $name"
				} else {
					borg toast "Could not create shortcut $name"
				}
			}
			PageBack $AW
		}
		back {
			if {$args eq $AW || ![llength $args]} {
				PageBack $AW
			}
		}
	}
}

# namespace ::awhelper
proc getdict {dict args} {
	if {[dict exists $dict {*}$args]} {dict get $dict {*}$args}
}

# namespace ::awhelper
proc getinput {top args} {
	variable {}
	array set o [subst {
		-title Input -text {Enter your input:}
		-buttons {Cancel OK}
		-bg #393939 -buttonbg #424242 -activebg #535353
		-fg #dedede -activefg #ffffff
	}]
	array set o $args
	set f $top.ef
	destroy $f
	set ($top,input) {}
	set font [list $(ff) -[dp2px 18] normal]
	# dialog frame
	set f [frame $f -background $o(-bg)]
	# dialog title
	pack [label $f.ttl -text $o(-title) -anchor sw -font [list $(ff) -[dp2px 24] normal
		] -background $o(-bg) -foreground #0af -justify left
		] -ipady [dp2px 8] -padx [dp2px 16] -pady [dp2px 4] -side top -fill x -expand 1
	# title underline
	pack [frame $f.lnf -background #0af -height [dp2px 2]] -anchor nw -fill x -expand 1 -pady [dp2px 12]
	# text and entry frame
	set tef $f.tef
	pack [frame $tef -background $o(-bg) -height [dp2px 2]] -anchor nw -fill x -expand 1
	pack [label $tef.txt -anchor w -font $font -text $o(-text) -foreground  $o(-fg) -background  $o(-bg) -justify left] -padx [dp2px 16] -pady 0 -side top -fill x -expand 1
	# entry underline container
	set ucf $tef.ucf
	pack [frame $ucf -background $o(-bg) -height [dp2px 40]] -padx [dp2px 16] -pady [dp2px 16] -side top -fill x -expand 1
	# entry underline
	set uline [dp2px 2]
	place [frame $ucf.uf -background #0af] -anchor sw -height [expr {4 * $uline}
		] -relwidth 1 -rely 1
	# entry margins
	pack [frame $ucf.ef -background $o(-bg) -height [dp2px 40]
		] -padx $uline -pady [expr {$uline * 2}] -side top -fill x -expand 1 -anchor s
	# the entry
	place [entry $ucf.ef.e -background $o(-bg) -font [list $(ff) -[dp2px 20] normal
		] -foreground  $o(-activefg) -insertbackground $o(-activefg) -insertwidth [dp2px 2
		] -highlightthickness 0 -relief flat -textvariable [namespace current]::($top,input)
		] -relx 0 -x [dp2px 8] -rely 1 -relwidth 1 -width -[dp2px 16] -relheight 1 -anchor sw
	# buttons
	set bf $f.bf
	pack [frame $bf -background $o(-bg)] -side top -fill x -expand 1
	pack [frame $bf.s0 -width 1 -background $o(-buttonbg)] -side top -fill x -expand 0
	set ll [llength $o(-buttons)]; set i 0
	foreach b $o(-buttons) {
		pack [button $bf.b$i -text $b -relief flat -pady [dp2px 16] -font $font -background $o(-bg) -highlightthickness 0 -foreground $o(-fg)	-activebackground $o(-activebg)	-activeforeground $o(-activefg) -command [list set [namespace current]::($top,input,res) $b]
			] -side left -fill x -expand 1
		bindtags $bf.b$i [list $bf.b$i Button all]
		incr i
		if {$i < $ll} {
			pack [frame $bf.s$i -width 1 -background $o(-buttonbg)] -side left -fill y -expand 0
		}
	}
	PageShow $top ef
	focus $ucf.ef.e
	vwait [namespace current]::($top,input,res)
	if {$($top,input,res) eq "OK"} {
		return $($top,input)
	}
}

# namespace ::awhelper
proc gettext {top id args} {
	variable {}
	array set o [subst {
		-title {Text editor} -text {} -font {{$(ff)} -[dp2px 18] normal}
		-buttonfont {{$(ff)} -[dp2px 18] normal}
		-bg #313131 -buttonbg #393939 -activebg #424242
		-fg #dedede -activefg #ffffff
	}]
	array set o $args
	set bopts [list -background $o(-buttonbg) -justify left -padx [dp2px 12
		] -repeatdelay 600 -repeatinterval 100 -highlightthickness 0 -relief flat -pady [dp2px 12
		] -borderwidth 0 -anchor c -font [list $(ff) -[dp2px 16] bold
		] -foreground $o(-fg) -activebackground $o(-activebg) -activeforeground $o(-activefg)]
	set f $top.$id
	destroy $f
	frame $f -background $o(-bg)
	# appbar -------------------------------------------
	pack [appbar $f ${id}bar -title $o(-title) -icon [namespace current]::close_img -buttons [
		list [list MORE [namespace current]::more_img] [list SAVE {}]] -command [list [namespace current]::events $f]] -side top -fill x
	# nav button ---------------------------------------
	button $f.navb -command [list [namespace current]::events $f $id-navbtn $f.navb
		] -image [namespace current]::nav_img {*}$bopts -background #212121
	bindtags $f.navb [list $f.navb Button all]
	# text ---------------------------------------------
	pack [frame $f.tf -background #000] -anchor nw -fill both -expand 1 -pady 0
	set txt $f.tf.txt
	text $txt -background #212121 -foreground $o(-activefg) -relief flat -borderwidth 0 -highlightthickness 0 -padx [dp2px 8] -pady [dp2px 8] -font $o(-font) -insertbackground $o(-activefg)
	pack $txt -fill both -expand 1
	bindtags $txt [list $txt Text all]
	$txt insert end $o(-text)
	# more menu-----------------------------------------
	set more $f.more
	frame $more  -background $o(-bg)
	set buttons {nav}
	set i 0; set ll [llength $buttons]
	foreach b $buttons {
		pack [button $more.b$i -command "
			[namespace current]::events $f ${id}-$b $f.tf
			place forget $more
			" -text [string toupper $b] {*}$bopts] -side top -fill x
		bindtags $more.b$i [list $more.b$i Button all]
		incr i
		# button separator
		if {$i < $ll} {
			pack [frame $more.s$i -background $o(-activebg) -height 1] -side top -fill x
		}
	}
	# navigation buttons frame -------------------------
	set nav $f.navf
	frame $nav -background $o(-bg)
	set icopad [list -ipadx [dp2px 4] -ipady [dp2px 4]]
	# navigation buttons -------------------------------
	foreach b {up down left right} {
		pack [button $nav.$b -command [list event generate $txt <[string totitle $b]>
			] -text $b -image [namespace current]::${b}_img {*}$bopts
			] -side top -fill x {*}$icopad
		bindtags $nav.$b [list $nav.$b Button all]
	}
	place $f.navb -in $f.tf -anchor ne -relx 1 -x -[dp2px 4] -y [dp2px 4
		] -width [dp2px 48] -height [dp2px 48]
	raise $f.navb
	PageShow $top $id -relwidth 1 -relheight 1
	focus $txt
	vwait [namespace current]::($f)
	set ($top,input) [$txt get 1.0 end-1c]
	return -button $($f) [$txt get 0.0 end-1c]
}

# namespace ::awhelper
proc imgfile2base64 file {
	if {[catch {package require base64}]} return
	if {[catch {set fd [open $file]}]} return
	chan configure $fd -encoding binary -buffering none -translation binary
	set icondata [read $fd]
	close $fd
	::base64::encode -maxlen 64 $icondata
}

# namespace ::awhelper
proc init args {
	variable {}
	global AW
	set ff [font families]
	if {{Noto Sans} in $ff} {
		set (ff) {Noto Sans}
	} elseif {"Roboto" in $ff} {
		set (ff) Roboto
	} else {
		# accept the default font, but avoid a 'mono' font
		set (ff) [string trim [string map -nocase {mono {}} [
			dict get [font actual default] -family]]]
	}
	if {![info exists AW]} {
		# script running either standalone, or on android, 
		wm withdraw .
		set AW .aw
		if {[winfo exists $AW]} {
			destroy {*}[winfo children $AW]
		} else {
			toplevel $AW -background #000
		}
	} elseif {[winfo exists $AW]} {
		destroy {*}[winfo children $AW]
	}
	if {[info command ::sdltk] ne "" && [::sdltk android]} {
		# android
		sdltk textinput 0
		set (android) 1
		# fullscreen for android
		wm attribute $AW -fullscreen 1
		array set {} [::borg displaymetrics]
		# if run from a shortcut cd to the script dir
		if {$::argv0 ne "wish"} {
			cd [file dirname [info script]]
			lappend ::auto_path [pwd]/libs
			::tcl::tm::path add [pwd]/tm
		}
		# remote debugging
		catch {
			package require mole
			mole::start 12345 -extended
		}
	} else {
		# non android -----------------------------------------
		set (android) 0
		# locations for packages
		lappend auto_path ~/lib
		::tcl::tm::path add ~/lib/tm
		# define geometry for non android
		if {[info command ::borg] eq {}} { 
			wm geometry $AW [expr {[llength $args] ? $args:"211x351"}]
			update
			array set {} [list densitydpi [expr {72 * [tk scaling]}] width [winfo width $AW] height [winfo height $AW]]
		} else {
			array set {} [::borg displaymetrics]
		}
	}
	package require MaterialIcons
	maticon close ::awhelper::close_img -color #fff -size 24d
	maticon more_vert ::awhelper::more_img -color #fff -size 24d
	maticon open_with ::awhelper::nav_img -color #dedede -size 32d
	foreach b {up down left right} {
		maticon keyboard_arrow_$b ::awhelper::${b}_img -color #fff -size 40d
	}
	array set {} [subst {
		$AW,pages {} $AW,sc,name {} $AW,sc,uri {} $AW,sc,icon {}
	}]
	if {$(width) <= [dp2px 352]} {
		set ($AW,dlg,place) [list -anchor c -x 0 -relx 0.5 -rely 0.5 -relwidth 1 -width -[dp2px 32]]
	} else {
		set ($AW,dlg,place) [list -anchor c -x 0 -relx 0.5 -rely 0.5 -relwidth {} -width [dp2px 320]]
	}
	bind $AW <Key-Break> [list [namespace current]::events $AW back]
	bind $AW <ButtonRelease-1> [list [namespace current]::events $AW back %W]
	dialog -name d0 -title "Androwish helper" -buttons {
		"Create a shortcut"
		"Edit & install .wishrc\n(autoloading at startup)"
		"Exit to Console"
		"Exit"
	}
}

# namespace ::awhelper
proc maticon {glyphid {name {}} args} {
	if {[llength $name]} {
		upvar ::MaterialIcons::viewbox viewbox
		array set o {-size 24d -color black -opacity 1.0}
		array set o $args
		lassign $viewbox x y w h
		if {$o(-size) < 0} {
			set scale [expr {-1.0 * $o(-size)}]
		} elseif {[string match "*d" $o(-size)]} {
			set o(-size) [string map {d {}} $o(-size)]
			set o(-size) [dp2px $o(-size)]
		} elseif {[string match "*p" $o(-size)]} {
			set o(-size) [string map {p {}} $o(-size)]
			set o(-size) [expr {[tk scaling] * $o(-size)}]
		} elseif {[string match "*m" $o(-size)]} {
			set o(-size) [string map {m {}} $o(-size)]
			set o(-size) [expr {72/25.4 * [tk scaling] * $o(-size)}]
		}
		if {![string is double $o(-size)]} {
			return -code error "expected integer size"
		}
		if {$o(-size) == 0} {
			return -code error "invalid size"
		}
		set scale [expr {1.0 * $o(-size) / $w}]
		tailcall ::image create photo $name -format [list svg -scale $scale]  -data [
			::MaterialIcons::svg $glyphid $o(-color) $o(-opacity)]
	} else {
		# search for a glyphname
		foreach n [MaterialIcons::names] {
			if {![string match "$glyphid*" $n]} continue
		}		
	}
}

# namespace ::awhelper
proc PageBack top {
	variable {}
	if {[llength $($top,pages)] > 1} {
		set page [lindex $($top,pages) end 0]
		destroy $top.$page
		set ($top,pages) [lrange $($top,pages) 0 end-1]
		lassign [lindex $($top,pages) end] page place
		if {![llength $place]} {
			place $top.$page {*}$($top,dlg,place)
		} else {
			place $top.$page {*}$place
		}
	}
	sdltk textinput 0
}

# namespace ::awhelper
proc PageShow {top page args} {
	variable {}
	if {[llength $($top,pages)]} {
		# hide previous page
		set prev [lindex $($top,pages) end 0]
		place forget $top.$prev
	}
	if {![llength $args]} {
		place $top.$page {*}$($top,dlg,place)
	} else {
		place $top.$page {*}$args
	}
	lappend ($top,pages) [list $page $args]
}

# namespace ::awhelper
proc sdltk {cmd args} {
	# fake sdltk
	if {[llength [info command ::sdltk]]} {
		::sdltk $cmd {*}$args
	} else {
		switch -glob -- $cmd {
			andr* {
				return 0
			}
			text* {
				return 0
			}
		}
	}
}
# end of namespace ::awhelper
}

::awhelper::init

