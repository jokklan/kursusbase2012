// Hello
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
		search: "S\u00f8gning",
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