<%@ Page Language="C#" masterpagefile="~masterurl/custom.master" title="Untitled 1" inherits="Microsoft.SharePoint.WebPartPages.WebPartPage, Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" meta:progid="SharePoint.WebPartPage.Document" %>
<%@ Register tagprefix="SharePoint" namespace="Microsoft.SharePoint.WebControls" assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<asp:Content id="Content2" runat="Server" contentplaceholderid="PlaceHolderAdditionalPageHead">
  <link href="styles/custom.css" rel="stylesheet">
  <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" rel="stylesheet" integrity="sha256-7s5uDGW3AHqw6xtJmNNtr+OBRJUlgkNJEo78P4b0yRw= sha512-nNo+yCHEyn0smMxSswnf/OnX6/KwJuZTlNZBjauKhTK0c+zT+q5JOCx0UFhXQ6rJR9jg6Es8gPuD2uZcYDLqSw==" crossorigin="anonymous">
  <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.6.1/css/font-awesome.min.css" rel="stylesheet" integrity="sha384-hQpvDQiCJaD2H465dQfA717v7lu5qHWtDbWNPvaTJ0ID5xnPUlVXnKzq7b8YUkbN" crossorigin="anonymous">
  <link href="https://groupwork-caca.restdb.io/assets/css/jquery.datetimepicker.min.css" rel="stylesheet">
</asp:Content>

<asp:Content id="Content1" runat="Server" contentplaceholderid="PlaceHolderMain">
    <header>
		<h1 id="header">Rainbow GroupArbete</h1>
	</header>
	<div id="container">
		<p>Random number is : <span id="randnumbers"></span></p>
		
		<div id="result"></div>
		<ul id="users"></ul>
		<div>
			<h1>Fill up the form To add New Member</h1>
		<form role="form" id="people-form">
<div class="form-group">
  <label>Email: </label><input class="form-control" name="email" data-type="email" type="email">
</div>
<div class="form-group">
  <label>Photo: </label>
  <input class="form-control" name="Photo" data-type="image" accept="image/*" type="file" multiple>
  <div class="progress hidden">
    <div id="Photo_progress" class="progress-bar" role="progressbar" aria-valuenow="0"
    aria-valuemin="0" aria-valuemax="100" style="width:0">
      <span class="sr-only">0%</span>
    </div>
  </div>  
</div>
<div class="form-group">
  <label>Bio: </label><input class="form-control" name="Bio" data-type="text" type="text">
</div>
<div class="form-group">
  <label>Firstname: </label><input class="form-control" name="FirstName" data-type="text" type="text">
</div>
<div class="form-group">
  <label>Lastname: </label><input class="form-control" name="LastName" data-type="text" type="text">
</div>
<div class="form-group">
  <label>Classname: </label><input class="form-control" name="ClassName" data-type="text" type="text">
</div>

  <div id="fg-errors" class="form-group">
  </div>
  <button class="btn btn-primary btn-lg" id="btn-submit" type="submit" data-loading-text="<i class='fa fa-circle-o-notch fa-spin'></i> Submitting...">Submit</button> 
</form>
		</div>
<!-- <script>
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
</script>
		
		
	

	<script>
	
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

</script>--> 

<script src="https://code.jquery.com/jquery-3.1.0.min.js"></script>
<script src="https://code.jquery.com/jquery-2.2.0.min.js"></script>	
<script src="https://cdnjs.cloudflare.com/ajax/libs/modernizr/2.8.3/modernizr.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha256-KXn5puMvxCw+dAYznun+drMdG1IFl3agK0p/pqT9KAo= sha512-2e8qq0ETcfWRI4HJBzQiA3UoyFk6tbNyG+qSaIBZLyW9Xf3sWZHN/lxe9fTh1U45DpPf07yj94KsUHHWe4Yk1A==" crossorigin="anonymous"></script>
<script src="https://groupwork-caca.restdb.io/assets/js/jquery-serialize-object.min.js"></script>
<script src="https://groupwork-caca.restdb.io/assets/js/jquery.datetimepicker.full.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.5.1/lodash.min.js"></script>
<script src="scripts/custom1.js"></script>

</asp:Content>


