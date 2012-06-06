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
		cancel: "Cancel",
		placeholder: "Search for courses\u2026"
	},
	da: {
		search: "S\u00f8gning",
		login: "Log ind",
		cancel: "Annuller",
		placeholder: "Søg efter kurser\u2026"
	}
}

d.ready(function(){
	if($("body").is("#home")){
		// HOME
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
	} else {
		// NOT HOME
		if(!("placeholder" in document.createElement("input"))){
			var searchField = $("#head form input[type='text']")
			searchField.val(strings[lang].placeholder).addClass("empty").focus(function(){
				if(this.value == strings[lang].placeholder){
					$(this).val("").removeClass("empty")
				}
			}).blur(function(){
				if(!this.value){
					$(this).val(strings[lang].placeholder).addClass("empty")
				}
			})
		}
	}
})
$(document).ready(function(){
  var submitText = "";
  $("#login_form").bind("ajax:beforeSend", function(evt, xhr, settings){
    submitText = $("#submit_button").val();
    if (lang == "en"){
      $("#submit_button").val("Processing...");
    }else{
      $("#submit_button").val("Arbejder...");
    }
  }).bind("ajax:complete", function(evt, xhr, status){
    $("#submit_button").val(submitText);
  }).bind("ajax:error", function(evt, xhr, status, error){
    var $form = $(this),
        errorText;

    try {
      // Populate errorText with the comment errors
      response = $.parseJSON(xhr.responseText);
      errorText = response["error"];
    } catch(err) {
      // If the responseText is not valid JSON (like if a 500 exception was thrown), populate errors with a generic error message.
      if (lang == "en"){
        errorText = "Please reload the page and try again";
      }else{
        errorText = "Genindlæs siden og prøv igen";
      }
    }

    // Insert error list into form
    $form.find('div.validation-error').html(errorText);
  }).bind("ajax:success", function(evt, data, status, xhr){
    document.location="/"
  });
});