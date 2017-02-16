
$(function () {

  // put your own error messages and/or message translation logic here

  var errorMessages = {
    "REQUIRED": "This field is required",
    "UNIQUE": "This value already exists",
    "TYPE": "Invalid data type",
    "REGEX":"Invalid data format",
    "number": "Must be an integer number",
    "money": "Must be a number with max two decimals",
    "JSON":"Not a valid JSON",
    "float_number":"Must be a decimal number",
    "email": "Must be a valid email",
    "FILESIZE": "Upload exceeds file size limit per field (max 10 MB)",
    "UPLOADERROR": "Unable to upload file, please try again",
    "GENERIC_ERROR": "A server error occured, please reload page"
  }

  var successMessage = "Thank you!";

  // enable javascript datetimepicker unless supported
  // Docs and settings: http://xdsoft.net/jqplugins/datetimepicker/

  $.datetimepicker.setLocale('sv');

  // if missing support for datetime, then use jquery.datetimepicker

  if (!Modernizr.inputtypes.datetime){
      $("input[data-type=date]").datetimepicker({timepicker:false,format:"Y/m/d"}).attr("type","text");
      $("input[data-type=datetime]").datetimepicker({}).attr("type","text");
      $("input[data-type=time]").datetimepicker({datepicker:false,format:"H:i",value:"12:00"}).attr("type","text");
  }

  $("#people-form input[data-type=file], #people-form input[data-type=image]").on("change",function(){
    $(this).data("uploadedfiles",[]);    
  });

  var apikey = "58a0ad7a54dd01867326429e"; // // TODO: INSERT YOUR CORS API KEY HERE

  if (!apikey) alert("Please insert a CORS API key");

  var ajaxSettings = {
    "async": true,
    "crossDomain": true,
    "url": "https://groupwork-caca.restdb.io/rest/people",
    "method": "POST",
    "headers": {
      "x-apikey": apikey,
      "content-type": "application/json"
    },
    "processData": false
  }

  var ajaxSettingsAttachments = {
     "async": true,
     "url": "https://groupwork-caca.restdb.io/media",
     "method": "POST",
     "contentType": false,
     "headers": {
       "x-apikey": apikey
     },
     "cache": false,
     "processData": false
   }

  function uploadAttachment(item){
    var deferred = $.Deferred();
    var datatype = $(item).attr("data-type");
    var element_name = $(item).attr("name");
    var formData = new FormData();
    var files = $(item)[0].files;
    var totalsize = 0;
    var files_to_upload = []
    _.each(files,function(file){
      // ignore non-images
      if(datatype==="image" && !file.type.match('image.*')){
        return;
      }else{
        files_to_upload.push(file);
        totalsize += file.size;        
      }
    });

    // check max upload file size for development plan
    if (totalsize<=10000000){
      _.each(files_to_upload,function(file){
        formData.append(element_name, file, file.name);
      });
      var asa = _.clone(ajaxSettingsAttachments);
      asa.xhr = function() {
        var xhr = new window.XMLHttpRequest();
        xhr.upload.addEventListener("progress", function(evt) {
          if (evt.lengthComputable) {
            var percentComplete = evt.loaded / evt.total;
            percentComplete = parseInt(percentComplete * 100)+"%";
            $("#"+element_name+"_progress")
            .css("width",percentComplete)
          }
        }, false);
        return xhr;
      }
      asa.data = formData;
      var uploadedbefore = $(item).data("uploaded");
      if (!uploadedbefore){
        $("#"+element_name+"_progress").parent().removeClass("hidden");
        $("#btn-submit").button("loading");
        $.ajax(asa)
        .success(function(data){
          var result = data.ids || [];
          var successObj = {};
          successObj[element_name] = result;
          $(item).data("uploaded",result);
          deferred.resolve(successObj);       
        })
        .fail(function(){
          deferred.reject({field: element_name, error: errorMessages.UPLOADERROR});
        });
      }else{
        var obj = {};
        obj[element_name]=uploadedbefore;
        deferred.resolve(obj);
      }
    }else{
      deferred.reject({field: element_name, error: errorMessages.FILESIZE});
    }
    return deferred.promise();
  }

  function postForm() {

    // clear errors
    $("#people-form .has-error").removeClass("has-error");
    $("#people-form .help-block").remove();

    $("#btn-submit").button("loading");

    // get the form data
    var formObj = $("#people-form").serializeObject();

    // get attachments from inputs
    var attachments = [];

    $("#people-form input[data-type=file], #people-form input[data-type=image]").each(function(input){
      var files = $(this)[0].files;
      if(files && files.length>0){
        attachments.push($(this));
      }
    });

    var attachFuncs = [];
    _.each(attachments,function(attachment){
      attachFuncs.push(uploadAttachment(attachment));
    });
  
    // upload all attachments and return with ids when done
    $.when.apply(null,attachFuncs)
      .done(function(){
        // get the attachment id's from arguments and store into form obj

        _.each(arguments,function(fieldObj){
          formObj = _.assign(formObj,fieldObj);
        });

       // submit the whole form with attachment ids 

       ajaxSettings.data = JSON.stringify(formObj);
        $.ajax(ajaxSettings)
        .done(function (response) {
          // replaces form with a thank you message, please replace with your own functionality
          $("#people-form").replaceWith("<div class='thank-you'>"+successMessage+"</div>");
        })
        .fail(function (response) {
          $("#btn-submit").button("reset");
          var error = response.responseJSON;
          if (error && error.name==="ValidationError"){
            _.each(error.list,function(fielderr){
              var inputSelector = "[name="+fielderr.field+"]";
              var errorMessageCode = fielderr.message[1];
              var errorMessage = errorMessages[errorMessageCode] || "Invalid value";
              if (errorMessageCode==="TYPE"){
                var fieldType = $(inputSelector).data("type");
                errorMessage = errorMessages[fieldType] || "Invalid value";
              }
              $(inputSelector).after("<div class='help-block'>"+errorMessage+"</div>");
              $(inputSelector).parents(".form-group").addClass("has-error");
            });
          }
          else{
            var msg = (ajaxSettings.headers["x-apikey"] && ajaxSettings.headers["x-apikey"].length < 24) ? "Missing API-key": "Server Error";
            alert(msg);
          }
        });
      })
      .fail( function (response) {
        $("#btn-submit").button("reset");
        if (response.field && response.error){
          var inputSelector = "[name="+response.field+"]";
          $(inputSelector).after("<div class='help-block'>"+response.error+"</div>");
          $(inputSelector).parents(".form-group").addClass("has-error");
        }else{
          var errorMessage = errorMessages.GENERIC_ERROR || "Problem submitting form";
          $("#fg-errors").addClass("has-error")
          .append("<div class='help-block'>"+errorMessage+"</div>");
        }
      });
  };

  $("#people-form").submit(function (event) {
        postForm();
        event.preventDefault();
        return false;
    });
});

		
		

	
  $(document).ready(function(item){
  var settings = {
 "async": true,
 "crossDomain": true,
 "url": "https://groupwork-caca.restdb.io/rest/people",

 "method": "GET",
 "headers": {
   "content-type": "application/json",
   "x-apikey": "58a0ad7a54dd01867326429e",
   "cache-control": "no-cache"
    }
  }
$.ajax(settings).done(function (response) {
 
//for(var j=0;j<response.length;j++){
	var i=Math.floor(Math.random()*response.length);
	$("#randnumbers").append(i+'<br/>');
//settings.append('<br><img src=\"https://groupwork-caca.restdb.io/media/'+response['photo'][0]+'?s=t\">');
$("#result").append('<br><img src=\"https://groupwork-caca.restdb.io/media/'+response[i].Photo+'?s=t\">'+'<br/>');
$("#result").append('<b>'+response[i].FirstName+'</b>'+'<br/>');
$("#result").append(response[i].Bio+'<br/>');
console.log(response)
//}
	})
  });

