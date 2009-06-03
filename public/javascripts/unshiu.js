/*!
 * Unshiu JavaScript Library v1.0.9
 * http://drecom.co.jp/
 *
 * Require JQuery Library v1.3.2
 *
 * Copyright (c) 2009 Drecom
 * Dual licensed under the MIT and GPL licenses.
 * http://unshiu.com/License
 *
 * Date: 2009-03-18 
 * Revision: 0001
 */
(function(){

/* ================================================================
	 UA Alert
	 http://webtech-walker.com/archive/2007/07/04135627.html
	 http://dogmap.jp/2008/10/03/jquery-google-chrome/
 ================================================================*/
 	jQuery(function ua(){
 		var ua = $.browser;
 		if(ua.msie){
 			//alert("Browser is msie");
			$("head").append('<link rel="stylesheet" href="/stylesheets/blueprint/ie.css"type="text/css" />');
		}
 		if(ua.mozilla){
 			//alert("Brower is mozilla");
 		}
 		if(ua.safari){
 			//alert("Brower is safari");
 		}
 	});
/* ================================================================
	 CSS Switch Changer
	 http://h2ham.seesaa.net/article/108514585.html
 ================================================================*/
 /*
	
	$(function(){
		$.styleChanger();
	});
	
	$.styleChanger = function(settings){
		var c = $.extend({
 			 cssSelector: '.style'
 			},settings);

		var cssHref="";

		$(c.cssSelector).click(function(){
			$('link[href='+cssHref+']'.remove();
			cssHref = $(this).attr('href');
			$("head").append('<link rel="stylesheet" href="'+cssHref+'"type="text/css" />');
			return false;
			});
		}
*/
/* ================================================================
	menu pulldown
	http://ma-creators.com/ajax/14.html
 ================================================================*/
	$(document).ready(function(){
		$("#menu_list li ul").css({display:"none"}),
		$("#menu_list li span").click(function(){
				$("#menu_list li ul").animate(
					{height: "toggle"},
					{duration: "fast"}
				);
				if ( (this).className.indexOf("menu_clicked") != -1){
					$("#menu_list li span").removeClass("menu_clicked");
				}
				else{
					$("#menu_list li span").addClass("menu_clicked");
				}
		});
	
	});
/* ================================================================
	search pulldown
 ================================================================*/
	$(document).ready(function(){
		$("#search_list ul").css({display:"none"}),
		$("#header_search_box a").click(function(){
				$("#search_list ul").animate(
					{height: "toggle"},
					{duration: "fast"}
				);
				if ( (this).className.indexOf("menu_clicked") != -1){
					$("#search_list form a").removeClass("menu_clicked");
				}
				else{
					$("#search_list form a").addClass("menu_clicked");
				}
		});
		$("#search_list ul li a").click(function(){
			$("#header_search_category").replaceWith("<span id='header_search_category'>"+$(this).text()+"から ▼</span>");
			$("#base_search_scope").val($(this).attr("id"));
			$("#search_list ul").css({display:"none"});
		});

	});
/* ================================================================
	show author edit delete
 ================================================================*/
	$(document).ready(function(){
		$(".editdelete").css({display:"none"}),
		$(".diary_story_box,.comment").mouseover(function(){
				$(this).css({background:"#f1f1f1"}).find(".editdelete").css(
					{display: "block"}
				);
		}).mouseout(function(){
				$(this).css({background:"transparent"}).find(".editdelete").css({display:"none"});
				});
	});

/* ================================================================
	show album detail
 ================================================================*/
	$(document).ready(function(){
		$(".album_detail").css({display:"none"}),
		$(".album_box").mouseover(function(){
				$(this).find(".album_detail").css({display:"block"});
		}).mouseout(function(){
				$(this).find(".album_detail").css({display:"none"});
		});

	});
	$(document).ready(function(){
		$(".album_box").mouseover(function(){
			$(this).css({background:"#f1f1f1"});
		}).mouseout(function(){
				$(this).css({background:"transparent"});
		});

	});
/* ================================================================
	communication_show tab 
 ================================================================*/
	$(document).ready(function(){
		$("#jqtab-example1 > ul,#config_menu > ul").tabs();

	});
/* ================================================================
 ================================================================*/

})();
