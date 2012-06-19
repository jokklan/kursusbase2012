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
	$("body").addClass("js")
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
			$("#head form input[type='text']").val(strings[lang].placeholder).addClass("empty").focus(function(){
				if(this.value == strings[lang].placeholder){
					$(this).val("").removeClass("empty")
				}
			}).blur(function(){
				if(!this.value){
					$(this).val(strings[lang].placeholder).addClass("empty")
				}
			})
		}
		$("table.schedule td.course").click(function(i){
			var a = $("a", this)
			if(a.length > 0){
				location.href = a[0].href
			}
		})
		if("Hyphenator" in window){
			Hyphenator.config({ displaytogglebox : true })
			Hyphenator.run()
		}
	}
	
	// Studyplan - coursebox hover
	$("td.course").each(function() {
		$(this).find("a.studyplan_item_remove").hide()
	})
	$("td.course").hover(function() {
		$(this).find("a.studyplan_item_remove").show()
	},function() {
		$(this).find("a.studyplan_item_remove").hide()
	})
	
	// Semester dropdown
	$("select#semester").change(function() {
		var semester 		= $(this).val().substring(0,1)
		var url_suffix	= semester == 'A' ? '' : '/' + semester
		document.location = "/studyplan" + url_suffix
	})	
	
	// LOGIN XHR FORM
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
})