/* Image w/ description tooltip v2.0
* Created: April 23rd, 2010. This notice must stay intact for usage 
* Author: Dynamic Drive at http://www.dynamicdrive.com/
* Visit http://www.dynamicdrive.com/ for full source code
*/


var ddimgtooltip={

	tiparray:function(){
		var tooltips=[]
		//define each tooltip below: tooltip[inc]=['path_to_image', 'optional desc', optional_CSS_object]
		//For desc parameter, backslash any special characters inside your text such as apotrophes ('). Example: "I\'m the king of the world"
		//For CSS object, follow the syntax: {property1:"cssvalue1", property2:"cssvalue2", etc}
		/*
		tooltips[0]=["red_balloon.gif", "Here is a red balloon<br /> on a white background", {background:"#FFFFFF", color:"black", border:"5px ridge darkblue"}]
		tooltips[1]=["duck2.gif", "Here is a duck on a light blue background.", {background:"#DDECFF", width:"200px"}]
		tooltips[2]=["../dynamicindex14/winter.jpg"]
		tooltips[3]=["../dynamicindex17/bridge.gif", "Bridge to somewhere.", {background:"white", font:"bold 12px Arial"}]
		*/

