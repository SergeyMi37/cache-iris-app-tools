Include App.LogMacro

/// Query and SQL statements
Class App.UikitAdminStatic [ Abstract ]
{

/// s h=##class(App.rest).getStatic("App.UikitAdminStatic:html",.desc) w !,h,!!,desc
XData html [ MimeType = application/yaml ]
{
<!doctype html>
<html lang="ru" class="no-js">
<head>
	<!--head-start-->
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	
	<!-- ## UIKit dark admin ### by expresspixel.com -->
	
	<link rel="stylesheet" href="css/theme.css"> <!-- Resource style -->
	<link rel="stylesheet" href="css/nav.css"> <!-- CSS reset -->
	<!--<link rel="stylesheet" href="css/style.css"> <!-- Resource style -->
	<link rel="stylesheet" href="css/uikit.min.css"> <!-- CSS reset -->
	
	<script src="js/jquery-2.1.4.js"></script>
	<script src="js/uikit.min.js"></script>
	<script src="js/uikit-icons.min.js"></script>
	<script src="js/jquery-ui.js"></script>
	<script src="js/jquery.blockui.js"></script>
	<link rel="stylesheet" href="css/jquery-ui.css">
	<title>TitleUIKitDarkAdmin</title>
	<!--head-end-->
</head>
<body>
	<header class="cd-main-header" style="position: fixed; top: 0px;" >
		<a href="#" class="cd-logo">
			HeaderUIKitDarkAdmin
		</a>
		
		<div class="cd-search is-hidden">
			<form action="#0">
				<input type="search" placeholder="Search..." id="searchstr" name="searchstr">
			</form>
		</div> <!-- cd-search -->

		<a href="#" class="cd-nav-trigger"><span></span></a>

		<nav class="cd-nav">
			<ul class="cd-top-nav">
				<!--#(menuTop)#-->
			</ul>
		</nav>
	</header> <!-- .cd-main-header -->

	<main class="cd-main-content">
		<nav class="cd-side-nav">
			<ul class="uk-nav uk-nav-default">
			  <li class="cd-label">...</li>
			  <!--#(menu)#-->
			</ul>
		</nav>

		<div id=MainBody class="content-wrapper">
        <!-- Page Content -->
		<br />
			<div class="uk-grid">
			    <div class="uk-width-1-1 uk-margin-left uk-margin-right " style='overflow: auto;' id="mainApp" >
					<ul id='tabMenu' class="uk-tab uk-tab-grid uk-tab-top" data-uk-tab="{connect:'#tabList', animation: 'fade'}">
						<li id='t1' class="uk-active"><a href="#">About</a></li>
					</ul>
					<ul id="tabList" class="uk-switcher uk-margin uk-tab-content">
						<li id='ta1' >
						 <div class="uk-alert-success" uk-alert>
							<!--#($username)#-->
						 </div>
						</li>
					</ul>
				</div>
			</div>
		   <!-- /#page-content-wrapper -->
		</div> <!-- .content-wrapper -->
	</main> <!-- .cd-main-content -->
<script src="js/jquery.menu-aim.js"></script>
<script src="js/main.js"></script> <!-- Resource jQuery -->

<script>
/*
function get_content(tpl, div) {
$.get(tpl, function(result){
    $result = $(result);

    $( div ).html( result );
    $result.find('script').appendTo(div);
}, 'html');

}

crossroads.addRoute('/{section}/{subsection}', function(section, subsection){  
  get_content('templates/'+section+'/'+subsection+'.html', '#content');
});
crossroads.addRoute('/', function(id){  
  get_content('templates/home.html', '#content');
}); 

//setup hasher
function parseHash(newHash, oldHash){
  crossroads.parse(newHash);
}
hasher.initialized.add(parseHash); //parse initial hash
hasher.changed.add(parseHash); //parse hash changes
hasher.init(); //start listening for history change
*/

(function($) {
    var $window = $(window),
        $html = $('#wrapper');

    function resize() {
        if ($window.width() < 768) {
            return $html.removeClass('toggled');
        }
		
        $html.addClass('toggled');
    }

    $window
        .resize(resize)
        .trigger('resize');
})(jQuery);
</script>
<div id='MainHidden' style='display:none;'></div>
<div id="dialog" title="Dialog Title">
	<div id=dialogContent></div>
</div>
<!--js-end-->
</body>
</html>
}

/// s h=##class(App.rest).getStatic("App.UikitAdminStatic:css") w !,h
XData css [ MimeType = application/yaml ]
{
<style type="text/css">
 
 	/* https://habr.com/ru/post/453744/
table {
  overflow: hidden;
}

tr:hover {
  background-color: #ffa;
}

td, th {
  position: relative;
}
td:hover::after,
th:hover::after {
  content: "";
  position: absolute;
  background-color: #ffa;
  left: 0;
  top: -5000px;
  height: 10000px;
  width: 100%;
  z-index: -1;
}
*/

 
 /*
	div {
  max-width: 400px;
  max-height: 150px;
  overflow: scroll;
}
*/

/* Use position: sticky to have it stick to the edge
 * and top, right, or left to choose which edge to stick to: */

thead th {
  position: -webkit-sticky; /* for Safari */
  position: sticky;
  top: 0;
}

tbody th {
  position: -webkit-sticky; /* for Safari */
  position: sticky;
  left: 0;
}

/* To have the header in the first column stick to the left: */

thead th:first-child {
  left: 0;
  z-index: 1;
}


/* Just to display it nicely: */

thead th {
  background: #E7EBF9;

}

tbody th {
  background: #E7EBF9;

}

table {
  border-radius: 10px; 
  border: 1px solid #72a7cf
}

td,
th {
  padding: 0.5em;
}

.bigbox { 
height: 20px; width: 20px 
}
 
</style>
}

/// s h=##class(App.rest).getStatic("App.UikitAdminStatic:javascript") w !,h
XData javascript [ MimeType = application/yaml ]
{
<script language="javascript">
$('#tWHAT').keydown(function (e) {
  	if (e.ctrlKey && e.keyCode == 13) {
    // Ctrl-Enter pressed
    document.getElementById('WHAT').value=document.getElementById('tWHAT').value;
    document.forms['loginfo'].submit();
   }
});
// 
function ActionJs(FormId,ResultId,appClass,appMethod,appPar,appNsp){
	var $data =[];
	;var appNspace ='#(ns)#';
	;if (!appNsp) {appNsp =appNspace;}
	var classname ='#(class)#';
	if (!appClass) var appClass =classname;
	if (FormId) {
		$data = $('#'+FormId).serializeArray(); 
		//alert(FormId);
	}
	//Add to array
	$data.push({name:"appClass",value:appClass});
	$data.push({name:"appMethod",value:appMethod});
	$data.push({name:"appNsp",value:appNsp});
	$data.push({name:"appPar",value:appPar});
	$.ajax({
	  url: 'App.Action.cls',
	  type: 'post',
	  data: $data,
	  crossDomain: true,
	  success: function(result) {
	  if (ResultId) {$('#'+ResultId).html(result);}
	  }
	});
}
// Collect data from the form, serialize, send to the server, execute and paste the result into the container
// FormId - source form identifier <form id='FormInpur'>...</form>
// ResultId -  identifier of the target container <div id='ResultDiv'>...</div>
// appAct -  parameters for executing code on the server
//     namespace:classname:methodname:par1=val1&par2=val2...&parX-valX
function AppAct(FormId,ResultId,appAct){
	var $data =[]; //json array initialization
	$data.push({name:"params",value:{}});
	if (FormId) { //if the form id is specified, then we collect all input elements from it
		// elements must have an id attribute matching the name.
		// For example <input type='text' id='elem2' name='elem2'>
		$data = $('#'+FormId).serializeArray();
	}
	$data.push({name:"appAct",value:appAct}); //add execution parameters that will be parsed in App.Action.cls
	//if (jsonExt) {
	//  if there is additional json, then add it
	//	$data.push({"jsonExt":jsonExt});
	//	}
	//var url1='App.Action.cls';	if (url2) { url1=url2;}
	//execute an asynchronous request to the App.Action.cls
	$.ajax({  
	  url: 'App.Action.cls',
	  type: 'post',
	  data: $data,
	  success: function(result) {  // if successful
	  	// if the resulting container is specified, put everything sent from the server into it
	  	if (ResultId) {$('#'+ResultId).html(result);}
	  }
	});
}
// Collect data from the form, serialize, send to the server, execute and paste the result into the container
// FormId - source form identifier <form id='FormInpur'>...</form>
// ResultId -  identifier of the target container <div id='ResultDiv'>...</div>
// appAct -  parameters for executing code on the server
//     namespace:classname:methodname:par1=val1&par2=val2...&parX-valX
//     namespace:routine:label:par1=val1&par2=val2...&parX-valX
function AppRpc(FormId,ResultId,appAct,url,json){
	var data ={"jsonrpc":"2.0",params:{}};
	
	if (FormId) {
		data.params.formId=FormId;
		data.params.form=JSON.stringify($('#'+FormId).serializeArray());
	}
	if (json) {
		data.params.json = json;
	}

	data.method=appAct;
	$.ajax({
	  url: url,
	  type: 'post',
	  contentType:'application/json; charset=UTF-8',
	  dataType:'html', 
	  crossDomain: true,
	  data: JSON.stringify(data),
	  success: function(result) {
	  if (ResultId) {
		  $('#'+ResultId).html(result);
	  }
	  else {
		  return result;
	  	}
	  }
	});
}

// The function of opening the dialog box
function WinOpen(ns,classname,met,el,title,rest) {
	
	var titlename="Method "+met+" parameter "+decodeURIComponent(el);
	if (title) {titlename=title;}

	//$("#dialogContent").load("App.Action.cls","appClass="+classname+"&appMethod="+met+"&appNsp="+ns+"&appPar="+el);
	
	if (rest) {AppRpc('anyForm','dialogContent',ns+':'+classname+':'+met+':'+decodeURIComponent(el),rest);}
	else { ActionJs('anyForm',"dialogContent",classname,met,el,ns);}
	$( "#dialog" ).dialog({
		modal: true, 
        title: titlename, 
        autoOpen: true, 
        width:window.innerWidth-200, 
        height:window.innerHeight-300,
		position: { my: 'top', at: 'top+150' },
		buttons: [
		{
			text: "Cancel",
			click: function() {
				$( this ).dialog( "close" );
			}
		}
		]
		});
	try { event.preventDefault();
	} catch (e){};
}
</script>
}

}

