#!/bin/zsh

echo "-------------------------------------"
echo "This is Zsh script. Bash will produce"
echo "extra output that will throw errors."
echo "-------------------------------------"

#get the username for git from git config
username=`git config user.name` #http://alvinalexander.com/git/git-show-change-username-email-address

#Clean up your cached versions of branches that were deleted on remote origin: http://makandracards.com/makandra/6739-git-remove-information-on-branches-that-were-deleted-on-origin
git remote prune origin

#This shows a list of remote branches by last commit author, sorted by most recent author, then greps that list for the `git config user.name`. So, another way to say it is, all remote branches where I was the last person to commit to that branch.
###
#for branch in `git branch -r | grep -v HEAD`
#do
#    echo -e `git show --format="%ai %ar by %an" $branch | head -n 1` \\t$branch
#done | sort -r | grep "$username"
###

#remove the local branches that are 2+ months old
#this relies on the format of the date output to stay consistent. As it is currently, the date is shown as weeks up to 9 weeks. After 9 weeks in then goes to months. This is how the 2+ months output is achieved
#for branch in `git branch  | grep -v HEAD`;do echo -e `git show --format="%ai %ar by %an" $branch | head -n 1`$branch; done | sort -r | grep Klosterman | grep months | sed 's/^.*Klosterman//' > /tmp/oldBranches.txt
for branch in `git branch  | grep -v HEAD`; do echo -e `git show --format="%ai %ar by %an" $branch | head -n 1`$branch; done | sort -r | grep "$username" | grep months | sed 's/^.*"$username"//' > /tmp/oldBranches.txt

#clean up any branches that weren't created by you; leave the develop branch though
for branch in `git branch  | grep -v HEAD`; do echo -e `git show --format="%ai %ar by %an" $branch | head -n 1`$branch; done | sort -r | grep -v "$username" | grep feature | sed 's/^.*feature/feature/' >> /tmp/oldBranches.txt
for branch in `git branch  | grep -v HEAD`; do echo -e `git show --format="%ai %ar by %an" $branch | head -n 1`$branch; done | sort -r | grep -v "$username" | grep bugfix | sed 's/^.*bugfix/bugfix/' >> /tmp/oldBranches.txt
for branch in `git branch  | grep -v HEAD`; do echo -e `git show --format="%ai %ar by %an" $branch | head -n 1`$branch; done | sort -r | grep -v "$username" | grep release | sed 's/^.*release/release/' >> /tmp/oldBranches.txt
 
#this may produce errors: error: The branch 'feature/VSDP-9138' is not fully merged.
#while read LINE; do echo "git branch -d $LINE"; done < /tmp/oldBranches.txt

#this will force the deletion to get around the 'not fully merged' error
while read LINE; do git branch -D $LINE; done < /tmp/oldBranches.txt

#perform cleanup
if [ -e /tmp/oldBranches.txt ]
then
    echo "cleanup"
    rm /tmp/oldBranches.txt
fi
