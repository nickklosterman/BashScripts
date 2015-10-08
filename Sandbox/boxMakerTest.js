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
    
    
//    console.log(x+","+y);
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

//See the image below.
//The first leg should use the CreateTab, but all subsequent legs should use CreateTabV2
function CreateTabV2(x,y,theta,length,width) {

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


function CreateTabbedPolygon(parameterObject){
    var i=0,
	k=0,
	angle=0,
	obj;
    
    console.log(parameterObject.offsetX+","+parameterObject.offsetY);
    obj=CreateTab(parameterObject.offsetX,parameterObject.offsetY,parameterObject.offsetTheta,parameterObject.sideLength,parameterObject.materialWidth);
    for (k=0;k<parameterObject.tabsPerSide-1;k++){
	obj=CreateTabV2(obj.x,obj.y,parameterObject.offsetTheta,parameterObject.sideLength,parameterObject.materialWidth);
    }
    
    //    console.log(obj);
    
    for ( i=0; i<parameterObject.numberOfSides-1;i++){
	//for interior tabs
	angle=parameterObject.offsetTheta-(i+1)*360/parameterObject.numberOfSides;
	//for exterior tabs; good for slotted construction
	//angle=parameterObject.offsetTheta+(i+1)*360/parameterObject.numberOfSides;
	
	obj=CreateTab(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
	for (k=0;k<parameterObject.tabsPerSide-1;k++){
	    obj=CreateTabV2(obj.x,obj.y,angle,parameterObject.sideLength,parameterObject.materialWidth);
	}
    }
}
//offsetTheta is the offset angle you can start with. Similar to the offsetX,offsetY
//I need to read up on how to set up the svg document. I should cheat off of one created in inkscape.
console.log('<?xml version="1.0" standalone="no"?>'+
	    '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">'+
	    '<svg width="24in" height="12in" viewBox="0 0 2400 1200" xmlns="http://www.w3.org/2000/svg" version="1.1">' +
	   '<polyline points="');
CreateTabbedPolygon({offsetX:1200,offsetY:200,offsetTheta:0,sideLength:30,materialWidth:10,numberOfSides:5,tabsPerSide:5});
console.log('" fill="none" stroke="black" stroke-width="3" />'+
	    '</svg>');

/*
Is it better to have slotted tops?
I'm not sure how well these boxes stay together via tabs.
*/
