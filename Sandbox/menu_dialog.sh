#!/bin/bash
# SCRIPT  : menu_dialog.sh
# PURPOSE : A menu driven Shell script using dialog utility
#           which has following options:
#           Display Today's Date and Time.
#           Display calendar.
#           Delete selected file from supplied directory.
#           List of users currently logged in
#           Disk Statistics
#           Exit
#
##############################################################################
#                 Checking availability of dialog utility                    #
##############################################################################

# dialog is a utility installed by default on all major Linux distributions.
# But it is good to check availability of dialog utility on your Linux box.

which dialog &> /dev/null

[ $? -ne 0 ]  && echo "Dialog utility is not available, Install it" && exit 1

##############################################################################
#                      Define Functions Here                                 #
##############################################################################

###################### deletetempfiles function ##############################

# This function is called by trap command
# For conformation of deletion use rm -fi *.$$

deletetempfiles()
{
    rm -f *.$$
}


######################## Show_time function #################################

# Shows today's date and time

show_time()
{
   dialog --backtitle "MENU DRIVEN PROGRAM" --title "DATE & TIME" \
   --msgbox "\n        Today's Date:   `date +"%d-%m-%Y"` \n\n \
       Today's Time:   `date +"%r %Z"`" 10 60
}

####################### show_cal function ###################################

# Shows current month calendar

show_cal()
{
   dialog --backtitle "MENU DRIVEN PROGRAM" --title "CALENDAR" \
   --msgbox "`cal`" 12 25
}

####################### deletefile function #################################

# Used to delete file under supplied directory, not including sub dirs.

deletefile()
{

   dialog --backtitle "MENU DRIVEN PROGRAM" --title "Directory Path" \
   --inputbox "\nEnter directory path (Absolute or Relative) \
\nPress just Enter for current directory" 12 60 2> temp1.$$

   if [ $? -ne 0 ]
   then
       rm -f temp1.$$
       return
   fi

   rmdir=`cat temp1.$$`

   if [ -z "$rmdir" ]
   then
       dirname=$(pwd)                  # You can also use `pwd`
       rmdir=$dirname/*
   else

       # remove trailing * and / from directory path

       echo "$rmdir" | grep "\*$" &> /dev/null && rmdir=${rmdir%\*}
       echo "$rmdir" | grep "/$" &> /dev/null && rmdir=${rmdir%/}

       # Check supplied directory exist or not

       ( cd $rmdir 2>&1 | grep "No such file or directory" &> /dev/null )

       # Above codeblock run in sub shell, so your current directory persists.

       if [ $? -eq 0 ]
       then
           dialog --backtitle "MENU DRIVEN PROGRAM" \
           --title "Validating Directory" \
           --msgbox "\n $rmdir: No such file or directory \
\n\n Press ENTER to return to the Main Menu" 10 60
           return
       fi

       # Do you have proper permissions ?

       ( cd $rmdir 2> /dev/null )

       if [ $? -ne 0 ]
       then
           dialog --backtitle "MENU DRIVEN PROGRAM" \
           --title "Checking Permissions" \
           --msgbox "\n $rmdir:  Permission denied to access this directory \
\n\n Press ENTER to return to the Main Menu" 10 60
           return
       fi

       if [ ! -r $rmdir ]
       then
           dialog --backtitle "MENU DRIVEN PROGRAM" \
           --title "Checking Permissions" \
           --msgbox "\n $rmdir:  No read permission \
\n\n Press ENTER to return to the Main Menu" 10 60
           return
       fi

   dirname=$rmdir
   rmdir=$rmdir/*             # get all the files under given directory

   fi

   for i in $rmdir            # process each file
   do

      # Store all regular file names in temp2.$$

      if [ -f $i ]
      then
          echo " $i delete? " >> temp2.$$
      fi

   done

   if [ -f temp2.$$ ]
   then
       dialog --backtitle "MENU DRIVEN PROGRAM" \
       --title "Select File to Delete" \
       --menu "Use [UP/DOWN] keys to move, then press enter \
\nFiles under directory $dirname:" 18 60 12 \
       `cat temp2.$$` 2> file2delete.$$
   else
     dialog --backtitle "MENU DRIVEN PROGRAM" --title "Select File to Delete" \
      --msgbox "\n\n There are no regular files in $dirname directory" 10 60
      return
   fi

   rtval=$?

   file2remove=`cat file2delete.$$`

   case $rtval in

       0) dialog --backtitle "MENU DRIVEN PROGRAM" --title "ARE YOU SURE" \
          --yesno "\nDo you Want to Delete File: $file2remove" 7 70

          if [ $? -eq 0 ]
          then
              rm -f $file2remove 2> Errorfile.$$

              # Check file successfully deleted or not.

              if [ $? -eq 0 ]
              then
                  dialog --backtitle "MENU DRIVEN PROGRAM" \
                  --title "Information : FILE DELETED" \
                  --msgbox "\nFile : $file2remove deleted" 8 70
             else
                 dialog --backtitle "MENU DRIVEN PROGRAM" \
                 --title "Information : ERROR ON DELETION" \
                 --msgbox "\nProblem in Deleting File: $file2remove \
\n\nError: `cat Errorfile.$$` \n\nPress ENTER to return to the Main Menu" 12 70
             fi

          else
              dialog --backtitle "MENU DRIVEN PROGRAM" \
              --title "Information : DELETION ABORTED" \
              --msgbox "Action Aborted: \n\n $file2remove not deleted" 8 70
          fi  ;;

      *)  deletetempfiles               # Remove temporary files
          return ;;
   esac

   deletetempfiles                      # remove temporary files
   return
}

########################## currentusers function ############################

currentusers()
{
   who > userslist.$$
   dialog --backtitle "MENU DRIVEN PROGRAM" \
   --title "CURRENTLY LOGGED IN USERS LIST" \
   --textbox userslist.$$ 12 60
}

############################ diskstats function #############################

diskstats()
{
   df -h | grep "^/" > statsfile.$$
   dialog --backtitle "MENU DRIVEN PROGRAM" \
   --title "DISK STATISTICS" \
   --textbox statsfile.$$ 10 60
}

##############################################################################
#                           MAIN STRATS HERE                                 #
##############################################################################

trap 'deletetempfiles'  EXIT     # calls deletetempfiles function on exit

while :
do

# Dialog utility to display options list

    dialog --clear --backtitle "MENU DRIVEN PROGRAM" --title "MAIN MENU" \
    --menu "Use [UP/DOWN] key to move" 12 60 6 \
    "DATE_TIME" "TO DISPLAY DATE AND TIME" \
    "CALENDAR"  "TO DISPLAY CALENDAR" \
    "DELETE"    "TO DELETE FILES" \
    "USERS"     "TO LIST CURRENTLY LOGGED IN USERS" \
    "DISK"      "TO DISPLAY DISK STATISTICS" \
    "EXIT"      "TO EXIT" 2> menuchoices.$$

    retopt=$?
    choice=`cat menuchoices.$$`

    case $retopt in

           0) case $choice in

                  DATE_TIME)  show_time ;;
                  CALENDAR)   show_cal ;;
                  DELETE)     deletefile ;;
                  USERS)      currentusers ;;
                  DISK)       diskstats ;;
                  EXIT)       clear; exit 0;;

              esac ;;

          *)clear ; exit ;;
    esac

done 
