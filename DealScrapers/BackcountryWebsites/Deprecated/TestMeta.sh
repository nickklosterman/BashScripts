function UpdateWebpageMetaRefresh()
{   
    RefreshTime=${1}
    Webpage="${2}"
    output="<META HTTP-EQUIV=\"REFRESH\" CONTENT=\"${RefreshTime}\">"
    Begin="<\!-- Refresh Begin -->"
    End="<\!-- Refresh End -->"
    BeginLineNumber=$( GetTagLineNumber "${Begin}" "${Webpage}" )
    EndLineNumber=$( GetTagLineNumber "${End}" "${Webpage}" )
    echo $output $BeginLineNumber $EndLineNumber
    Top=$( GetBeginningOfFileToLine ${BeginLineNumber} "${Webpage}" )
    Bottom=$( GetLineToEOF ${EndLineNumber} "${Webpage}" )


    Output="${Top}                                                                                                                                           
 ${output}                                                                                                                                                   
${Bottom}"
  echo "${Output}" > "${Webpage}"

#upload updated webpage                                                                                                                                      
  UploadDjinniusDealsIndex
}
function GetBeginningOfFileToLine
{   
    Output=` head -n +${1} "${2}" `
    echo "${Output}"
}

function GetLineToEOF
{
    Output=` tail -n +${1} "${2}" `
#could also use "sed -n 'N,$p' filename"                                                                                                                    \
                                                                                                                                                             
    echo "${Output}"
}
function GetTagLineNumber
{

    LineNumber=`eval grep -n "${1}" ${2} | sed 's/:.*//' `
#without the eval the pattern to search for, which contains a set of quotes to keep it all together, wasn't returning anything                               
    echo $LineNumber
}

function GetBeginningOfFileToLine
{
    Output=` head -n +${1} "${2}" `
    echo "${Output}"
}

UpdateWebpageMetaRefresh 123  "/home/nicolae/Desktop/index.html" 

echo "for the previous methdo we didn't include the <!--, we just looked for the text we stuck in between the comment markers."