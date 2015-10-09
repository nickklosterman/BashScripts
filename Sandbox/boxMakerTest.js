function CreateTab(x,y,theta,length,width) {

    var thetaRadians=Math.PI*theta/180,
	dx = length*Math.sin(thetaRadians),
	dy = length*Math.cos(thetaRadians),
	dxKerf = width*Math.sin(thetaRadians-Math.PI),
	dyKerf = width*Math.cos(thetaRadians-Math.PI),
	dxKerf = -width*Math.cos(thetaRadians),
	dyKerf = width*Math.sin(thetaRadians),
	tempX = x+dx,
	tempY = y+dy;
    console.log(" ");

    /**
      o----A    D---E
           |    |  
           B----C
     */
    
    //A
    console.log(tempX+","+tempY);

    //B
    tempX = x + dx + dxKerf;
    tempY = y + dy + dyKerf;
    console.log(tempX+","+tempY);

    //C
    tempX = x + 2*dx + dxKerf;
    tempY = y + 2*dy + dyKerf;
    console.log(tempX+","+tempY);

    //D
    tempX = x + 2*dx;
    tempY = y + 2*dy;
    console.log(tempX+","+tempY);

    //E
    tempX = x + 3*dx;
    tempY = y + 3*dy;
    console.log(tempX+","+tempY);

    return {x:tempX,y:tempY}
}

function CreateTabCCW(x,y,theta,length,width) {

    var thetaRadians=Math.PI*theta/180,
	dx = length*Math.sin(thetaRadians),
	dy = length*Math.cos(thetaRadians),
	dxKerf = width*Math.sin(thetaRadians-Math.PI),
	dyKerf = width*Math.cos(thetaRadians-Math.PI),
	dxKerf = -width*Math.cos(thetaRadians),
	dyKerf = width*Math.sin(thetaRadians),
	tempX = x-dx,
	tempY = y-dy;
    console.log(" ");

    /**
     E----D    A---o
          |    |  
          C----B
     */

    //A
    console.log(tempX+","+tempY);

    //B
    tempX = x - dx - dxKerf;
    tempY = y - dy - dyKerf;
    console.log(tempX+","+tempY);

    //C
    tempX = x - 2*dx - dxKerf;
    tempY = y - 2*dy - dyKerf;
    console.log(tempX+","+tempY);

    //D
    tempX = x - 2*dx;
    tempY = y - 2*dy;
    console.log(tempX+","+tempY);

    //E
    tempX = x - 3*dx;
    tempY = y - 3*dy;
    console.log(tempX+","+tempY);

    return {x:tempX,y:tempY}
}


//See the image below.
//The first leg should use the CreateTab, but all subsequent legs should use CreateTabV2
//if you don't use createTabV2 then that last leg between D & E will be doubled up and just be more spreadout.
function CreateTabV2(x,y,theta,length,width) {

    var thetaRadians=Math.PI*theta/180,
	dx = length*Math.sin(thetaRadians),
	dy = length*Math.cos(thetaRadians),
	dxKerf = width*Math.sin(thetaRadians-Math.PI),
	dyKerf = width*Math.cos(thetaRadians-Math.PI),
	dxKerf = -width*Math.cos(thetaRadians),
	dyKerf = width*Math.sin(thetaRadians),
	tempX = 0,
	tempY = 0;
    console.log(" ");

    /**
     o    C---D
     |    |  
     A----B
     */
    

    //A
    tempX = x + dxKerf;
    tempY = y + dyKerf;
    console.log(tempX+","+tempY);

    //B
    tempX = x + dx + dxKerf;
    tempY = y + dy + dyKerf;
    console.log(tempX+","+tempY);

    //C
    tempX = x + dx;
    tempY = y + dy;
    console.log(tempX+","+tempY);

    //D
    tempX = x + 2*dx;  //if you wanted to make the tabs offset, then you could set this to 3* etc to length that last bit
    tempY = y + 2*dy;
    console.log(tempX+","+tempY);

    return {x:tempX,y:tempY}
}

//See the image below.
//The first leg should use the CreateTab, but all subsequent legs should use CreateTabV2CCW
//if you don't use createTabV2 then that last leg between D & E will be doubled up and just be more spreadout.
//This is the counterclockwise version.
function CreateTabV2CCW(x,y,theta,length,width) {

    var thetaRadians=Math.PI*theta/180,
	dx = length*Math.sin(thetaRadians),
	dy = length*Math.cos(thetaRadians),
	dxKerf = width*Math.sin(thetaRadians-Math.PI),
	dyKerf = width*Math.cos(thetaRadians-Math.PI),
	dxKerf = -width*Math.cos(thetaRadians),
	dyKerf = width*Math.sin(thetaRadians),
	tempX = 0,
	tempY = 0;
    console.log(" ");

    /**
    D---C    o
        |    |
        B----A
     */
    

    //A
    tempX = x - dxKerf;
    tempY = y - dyKerf;
    console.log(tempX+","+tempY);

    //B
    tempX = x - dx - dxKerf;
    tempY = y - dy - dyKerf;
    console.log(tempX+","+tempY);

    //C
    tempX = x - dx;
    tempY = y - dy;
    console.log(tempX+","+tempY);

    //D
    tempX = x - 2*dx;  //if you wanted to make the tabs offset, then you could set this to 3* etc to length that last bit
    tempY = y - 2*dy;
    console.log(tempX+","+tempY);

    return {x:tempX,y:tempY}
}

function CreateTabbedPolygon(parameterObject){
    var i=0,
	k=0,
	angle=0,
	obj;
    
    console.log('<polyline points="');    
    console.log(parameterObject.offsetX+","+parameterObject.offsetY);
    obj=CreateTab(parameterObject.offsetX,parameterObject.offsetY,parameterObject.offsetTheta,parameterObject.sideLength,parameterObject.materialWidth);
    for (k=0;k<parameterObject.tabsPerSide-1;k++){
	obj=CreateTabV2(obj.x,obj.y,parameterObject.offsetTheta,parameterObject.sideLength,parameterObject.materialWidth);
	//obj=CreateTab(obj.x,obj.y,parameterObject.offsetTheta,parameterObject.sideLength,parameterObject.materialWidth);
    }
    
    //    console.log(obj);
    
    for ( i=0; i<parameterObject.numberOfSides-1;i++){
	if( typeof parameterObject.CCW !== 'undefined' && parameterObject.CCW === true ) {
	    
	//for interior tabs  although we use them here to make exterior tabs as we are 
	    angle=parameterObject.offsetTheta+(i+1)*360/parameterObject.numberOfSides;
	} else {
	//for exterior tabs; good for slotted construction
	    angle=parameterObject.offsetTheta-(i+1)*360/parameterObject.numberOfSides;
	}
	
	obj=CreateTab(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
	for (k=0;k<parameterObject.tabsPerSide-1;k++){
	    obj=CreateTabV2(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
	    //obj=CreateTab(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
	}
    }
    console.log('" fill="none" stroke="black" stroke-width="3" />');
}
function CreateTabbedPolygonCCW(parameterObject){
    parameterObject.CCW=true;
    CreateTabbedPolygon(parameterObject);
/*    var i=0,
	k=0,
	angle=0,
	obj;
    
    console.log(parameterObject.offsetX+","+parameterObject.offsetY);
    obj=CreateTab(parameterObject.offsetX,parameterObject.offsetY,parameterObject.offsetTheta,parameterObject.sideLength,parameterObject.materialWidth);
    for (k=0;k<parameterObject.tabsPerSide-1;k++){
	obj=CreateTabV2(obj.x,obj.y,parameterObject.offsetTheta,parameterObject.sideLength,parameterObject.materialWidth);
	//obj=CreateTab(obj.x,obj.y,parameterObject.offsetTheta,parameterObject.sideLength,parameterObject.materialWidth);
    }
    
    //    console.log(obj);
    
    for ( i=0; i<parameterObject.numberOfSides-1;i++){
	//for interior tabs
	//angle=parameterObject.offsetTheta-(i+1)*360/parameterObject.numberOfSides;
	//for exterior tabs; good for slotted construction
	angle=parameterObject.offsetTheta+(i+1)*360/parameterObject.numberOfSides;
	
	obj=CreateTab(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
	for (k=0;k<parameterObject.tabsPerSide-1;k++){
	    obj=CreateTabV2(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
	    //obj=CreateTab(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
	}
    }
*/
}

function CreateTabbedSide(parameterObject){
    var i=0,
	k=0,
	angle=0,
	obj;

    //create the first side of the panel
    console.log(parameterObject.offsetX+","+parameterObject.offsetY);
    obj=CreateTab(parameterObject.offsetX,parameterObject.offsetY,parameterObject.offsetTheta,parameterObject.sideLength,parameterObject.materialWidth);
     for (k=0;k<parameterObject.tabsPerSide-1;k++){
	obj=CreateTabV2(obj.x,obj.y,parameterObject.offsetTheta,parameterObject.sideLength,parameterObject.materialWidth);
	//obj=CreateTab(obj.x,obj.y,parameterObject.offsetTheta,parameterObject.sideLength,parameterObject.materialWidth);
    }
    
    //    console.log(obj);

    //loop and create the n-1 sides of the panel
    for ( i=0; i<parameterObject.numberOfSides-1; i++){

	//for exterior tabs; good for slotted construction
	angle=parameterObject.offsetTheta+(i+1)*360/parameterObject.numberOfSides;
	
	/*          */
	/*FIX THIS 22+....to flip the last side of the */
	/*          */
	if (i===22+parameterObject.numberOfSides-2) { //for the last side of the box sides, flip the angle 

	    obj=CreateTab(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
	    //for interior tabs
	    angle=parameterObject.offsetTheta-(i+1)*360/parameterObject.numberOfSides;

	    for (k=0;k<parameterObject.tabsPerSide-1;k++){
		//obj=CreateTabV2CCW(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
		obj=CreateTabV2(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
		//obj=CreateTab(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
	    }

	} else {
	    
	    obj=CreateTab(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
	    for (k=0;k<parameterObject.tabsPerSide-1;k++){
		obj=CreateTabV2(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
		//obj=CreateTab(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
	    }
	}
    }
}

function CreateTabbedSides(parameterObject) {
    var i =0;

    for (i=0;i<parameterObject.polygonOrder;i++) {
	console.log('<!-- '+i+' -->');
	console.log('<polyline points="');
	var offsetX=parameterObject.offsetX + i*350;
	CreateTabbedSide({offsetX:offsetX,
			  offsetY:parameterObject.offsetY,
			  offsetTheta:parameterObject.offsetTheta,
			  sideLength:parameterObject.sideLength,
			  materialWidth:parameterObject.materialWidth,
			  numberOfSides:parameterObject.numberOfSides,
			  tabsPerSide:parameterObject.tabsPerSide});
	console.log('" fill="none" stroke="black" stroke-width="3" />');
    }
}

function WriteSVGHeader(){
    //I need to read up on how to set up the svg document. I should cheat off of one created in inkscape.
    console.log('<?xml version="1.0" standalone="no"?>'+
		'<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">'+
		'<svg width="36in" height="12in" viewBox="0 0 3600 1200" xmlns="http://www.w3.org/2000/svg" version="1.1">');
};

function CreateBox() {
    //offsetTheta is the offset angle you can start with. Similar to the offsetX,offsetY

    WriteSVGHeader();
/*
    if (numberOfSides===4) {
we really don't need to run throgh the Top/Bottom as those will be the same as the sides.
    }
*/
    //Top
    CreateTabbedPolygon({offsetX:600,offsetY:200,offsetTheta:0,sideLength:30,materialWidth:10,numberOfSides:6,tabsPerSide:5});
//    CreateTabbedPolygonCCW({offsetX:020,offsetY:200,offsetTheta:0,sideLength:30,materialWidth:10,numberOfSides:5,tabsPerSide:5}); //use this guy if you want the tabs pointing out

    //Bottom
    CreateTabbedPolygon({offsetX:1100,offsetY:200,offsetTheta:0,sideLength:30,materialWidth:10,numberOfSides:6,tabsPerSide:5});
    //CreateTabbedPolygonCCW({offsetX:1200,offsetY:200,offsetTheta:0,sideLength:30,materialWidth:10,numberOfSides:5,tabsPerSide:5}); //use this guy if you want the tabs pointing out
    
   
    //Sides (need numberOfSides sides)
    
    //CreateTabbedPolygon({offsetX:1600,offsetY:200,offsetTheta:0,sideLength:30,materialWidth:10,numberOfSides:4,tabsPerSide:5});
    CreateTabbedSides({offsetX:1100,offsetY:200,offsetTheta:0,sideLength:30,materialWidth:10,numberOfSides:4,tabsPerSide:5,polygonOrder:6});

    WriteText({x:1100,y:150,text:"why are the middle sidepanels not like the end sidepanels?",font_family:"Verdana",font_size:24 })
    WriteText({x:1100,y:170,text:"They aren't it was due to the panels overlapping such that I thought that.",font_family:"Verdana",font_size:24 })

    //close out the svg document
    console.log('</svg>');

}

function WriteText(paramObj) {
    console.log('<text x="'+paramObj.x+'"'+
		' y="'+paramObj.y+'"'+
		 ' font-family="'+paramObj.font_family+'"'+
		' font-size="'+paramObj.font_size+'">'+
		paramObj.text+
		 '</text>');
}

CreateBox();

/*
Is it better to have slotted tops?
I'm not sure how well these boxes stay together via tabs.

Fri Oct  9 10:43:10 EDT 2015
Is there an easy way such that I could construct one of the edges and simply copy and translate those segments easily?
How modular/optimized should I make it?
I'd like to make it such that it minimizes the number of cuts required by eliminating overlapping edges. However, that complicates things if a user would want to put the pieces in separate files. I suppose I could either add a flag or simply output both the optimized version with the minimal amount of cuts as well as the exploded version with separate pieces.
SVG is XML so all just follow the xml guidelines. I.e. commenting follows the xml standard of <!-- comment -->
https://en.wikipedia.org/wiki/Regular_polygon good resource for formulae
Should the top and bottom be interchangeable? Or should one have tabs out and the other tabs in?
I have a feeling that the document properties define the units and the scale of the units.

https://developer.mozilla.org/en-US/docs/Web/SVG/Element/text

as the number of sides increases, how will that affect the corners? Will I need to increase the kerf/depth for a better fit?
Write a webpage frontend for this guy.
*/
