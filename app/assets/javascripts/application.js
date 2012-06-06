// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

var d    = $(document)
var lang = (location.pathname.match(/^\/?(da|en)(\/|$)/) || [, "da"])[1]

var strings = {
	en: {
		search: "Search",
		login: "Log in",
		cancel: "Cancel"
	},
	da: {
		search: "Søgning",
		login: "Log ind",
		cancel: "Annuller"
	}
}

d.ready(function(){
	if($("body").is("#home")){
		var loggingin = false
		$("a[href^='/login'], a.cancel").click(function(){
			if(loggingin){
				$("#login").slideUp()
				$("#searchform").slideDown()
				$("#logintro").show()
				$("a#toplogin").text(strings[lang].login)
				$("#logo h1").text(strings[lang].search)
				$("#searchform input[type='text']")[0].focus()
			} else {
				$("#login").slideDown()
				$("#searchform").slideUp()
				$("#logintro").hide()
				$("a#toplogin").text(strings[lang].cancel)
				$("#logo h1").text(strings[lang].login)
				$("#login input[type='text']")[0].focus()
			}
			loggingin = !loggingin
			return false
		})
	}
})