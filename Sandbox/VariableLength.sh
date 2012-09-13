input="$1"
length=${#input}
if [ $length -lt 10 ]
then
echo "less than 10"
echo "var length is $length"
else
echo "var length is $length"
fi

if [ ${#input} -lt 10 ]
then
echo "less than 10"
echo "var length is $length"
else
echo "var length is $length"
fi


if [ "${#input}" -lt 10 ]
then
echo "less than 10"
echo "var length is $length"
else
echo "var length is $length"
fi
