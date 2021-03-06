
wget http://rss.chainlove.com/docs/chainlove/rss.xml -O /tmp/cl.xml -nv
wget http://rss.whiskeymilitia.com/docs/wm/rss.xml -O /tmp/wm.xml -nv

wget http://rss.steepandcheap.com/docs/steepcheap/rss.xml -O /tmp/sac.xml -nv 
echo "--**||**--"
echo "Whiskey Militia"
echo "--**||**--"
grep 'title\|:price>' /tmp/wm.xml | sed -n -e '1,5p' | sed 's/<title>//;s/<\/title>//;s/<odat:price>//;s/<\/odat:price>//;'
echo "--**||**--"
echo "Steep And Cheap"
echo "--**||**--"
grep 'title\|:price>' /tmp/sac.xml | sed -n -e '2,5p' | sed 's/<title>//;s/<\/title>//;s/<sac:price>//;s/<\/sac:price>//;'
echo "--**||**--"
echo "Chain Love"
echo "--**||**--"
grep 'title\|:price>' /tmp/cl.xml | sed -n -e '1,5p' | sed 's/<title>//;s/<\/title>//;s/<odat:price>//;s/<\/odat:price>//;'
